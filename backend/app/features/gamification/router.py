from datetime import date, timedelta

from fastapi import APIRouter, Depends

from app.core.auth import get_current_uid
from app.features.gamification.rules import HISTORY_DAYS, GamificationState, compute_state
from app.features.tracking.repository import (
    TrackingRepository,
    get_tracking_repository,
)

router = APIRouter(prefix="/gamification", tags=["gamification"])


@router.get("", response_model=GamificationState)
def get_state(
    uid: str = Depends(get_current_uid),
    tracking: TrackingRepository = Depends(get_tracking_repository),
) -> GamificationState:
    today = date.today()
    start = today - timedelta(days=HISTORY_DAYS)
    logs = tracking.get_range(uid, start.isoformat(), today.isoformat())
    return compute_state(logs, today)
