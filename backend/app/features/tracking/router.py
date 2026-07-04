from datetime import date as date_type
from datetime import timedelta

from fastapi import APIRouter, Depends, HTTPException, Path, Query

from app.core.auth import get_current_uid
from app.core.dates import app_today
from app.features.tracking.repository import (
    TrackingRepository,
    get_tracking_repository,
)
from app.features.tracking.schemas import (
    DATE_PATTERN,
    MAX_DAILY_WATER_ML,
    DailyLog,
    DailyLogPatch,
    WaterIncrement,
)

router = APIRouter(prefix="/logs", tags=["tracking"])

DateParam = Path(pattern=DATE_PATTERN, description="YYYY-MM-DD")


def _load(repo: TrackingRepository, uid: str, date: str) -> DailyLog:
    data = repo.get(uid, date)
    return DailyLog(**data) if data else DailyLog(date=date)


def _validate_write_date(date_str: str) -> None:
    """Writes are only accepted for a real calendar date near 'today'.

    The ±1-day window absorbs client/server timezone skew while blocking
    backdated logs that would let a modified client mint streaks and XP.
    """
    try:
        d = date_type.fromisoformat(date_str)
    except ValueError:
        raise HTTPException(status_code=422, detail="Invalid calendar date.")
    today = app_today()
    if not (today - timedelta(days=1) <= d <= today + timedelta(days=1)):
        raise HTTPException(
            status_code=422,
            detail="Logs can only be written for yesterday, today or tomorrow.",
        )


@router.get("", response_model=list[DailyLog])
def list_logs(
    start: str = Query(pattern=DATE_PATTERN),
    end: str = Query(pattern=DATE_PATTERN),
    uid: str = Depends(get_current_uid),
    repo: TrackingRepository = Depends(get_tracking_repository),
) -> list[DailyLog]:
    if start > end:
        raise HTTPException(status_code=422, detail="start must be <= end.")
    return [DailyLog(**d) for d in repo.get_range(uid, start, end)]


@router.get("/{date}", response_model=DailyLog)
def get_log(
    date: str = DateParam,
    uid: str = Depends(get_current_uid),
    repo: TrackingRepository = Depends(get_tracking_repository),
) -> DailyLog:
    return _load(repo, uid, date)


@router.put("/{date}", response_model=DailyLog)
def patch_log(
    patch: DailyLogPatch,
    date: str = DateParam,
    uid: str = Depends(get_current_uid),
    repo: TrackingRepository = Depends(get_tracking_repository),
) -> DailyLog:
    _validate_write_date(date)
    fields = patch.model_dump(exclude_none=True)
    if fields:
        repo.merge(uid, date, fields)
    return _load(repo, uid, date)


@router.post("/{date}/water", response_model=DailyLog)
def add_water(
    increment: WaterIncrement,
    date: str = DateParam,
    uid: str = Depends(get_current_uid),
    repo: TrackingRepository = Depends(get_tracking_repository),
) -> DailyLog:
    _validate_write_date(date)
    current = _load(repo, uid, date).water_ml
    # Cap the daily total; the badge economy assumes water can't be farmed.
    amount = min(increment.amount_ml, MAX_DAILY_WATER_ML - current)
    if amount > 0:
        repo.increment_water(uid, date, amount)
    return _load(repo, uid, date)
