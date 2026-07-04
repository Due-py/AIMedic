from datetime import timedelta

from fastapi import APIRouter, Depends

from app.core.auth import get_current_uid
from app.core.dates import app_today
from app.features.insights.rules import Insight, compute_insights
from app.features.profile.repository import (
    ProfileRepository,
    get_profile_repository,
)
from app.features.tracking.repository import (
    TrackingRepository,
    get_tracking_repository,
)

router = APIRouter(prefix="/insights", tags=["insights"])


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
