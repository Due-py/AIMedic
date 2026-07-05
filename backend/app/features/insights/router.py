import logging
from datetime import timedelta

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

from app.core.auth import get_current_uid
from app.core.dates import app_today
from app.features.coach.service import CoachAI, get_coach_ai
from app.features.insights.recap import (
    MIN_LOGGED_DAYS,
    RECAP_SYSTEM,
    RecapRepository,
    build_recap_input,
    get_recap_repository,
)
from app.features.insights.rules import (
    Insight,
    coach_context_lines,
    compute_insights,
)
from app.features.gamification.rules import categories_logged
from app.features.profile.repository import (
    ProfileRepository,
    get_profile_repository,
)
from app.features.tracking.repository import (
    TrackingRepository,
    get_tracking_repository,
)

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/insights", tags=["insights"])


def get_optional_coach_ai() -> CoachAI | None:
    """The recap degrades to nothing (rather than erroring) without an AI key."""
    try:
        return get_coach_ai()
    except HTTPException:
        return None


class Recap(BaseModel):
    recap: str | None


@router.get("", response_model=list[Insight])
def get_insights(
    uid: str = Depends(get_current_uid),
    profiles: ProfileRepository = Depends(get_profile_repository),
    tracking: TrackingRepository = Depends(get_tracking_repository),
) -> list[Insight]:
    today = app_today()
    logs = tracking.get_range(
        uid, (today - timedelta(days=6)).isoformat(), today.isoformat()
    )
    return compute_insights(profiles.get(uid), logs)


@router.get("/recap", response_model=Recap)
def weekly_recap(
    uid: str = Depends(get_current_uid),
    profiles: ProfileRepository = Depends(get_profile_repository),
    tracking: TrackingRepository = Depends(get_tracking_repository),
    recaps: RecapRepository = Depends(get_recap_repository),
    ai: CoachAI | None = Depends(get_optional_coach_ai),
) -> Recap:
    today = app_today()
    iso = today.isocalendar()
    week = f"{iso.year}-W{iso.week:02d}"

    cached = recaps.get(uid, week)
    if cached is not None:
        return Recap(recap=cached)

    if ai is None:
        return Recap(recap=None)

    logs = tracking.get_range(
        uid, (today - timedelta(days=6)).isoformat(), today.isoformat()
    )
    if sum(1 for log in logs if categories_logged(log) > 0) < MIN_LOGGED_DAYS:
        return Recap(recap=None)

    trends = coach_context_lines(compute_insights(profiles.get(uid), logs))
    prompt = build_recap_input(logs, trends)
    try:
        text = ai.reply(RECAP_SYSTEM, [], prompt)
    except Exception:
        logger.exception("Weekly recap generation failed")
        return Recap(recap=None)

    if text:
        recaps.save(uid, week, text)
    return Recap(recap=text or None)
