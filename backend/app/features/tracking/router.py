from fastapi import APIRouter, Depends, HTTPException, Path, Query

from app.core.auth import get_current_uid
from app.features.tracking.repository import (
    TrackingRepository,
    get_tracking_repository,
)
from app.features.tracking.schemas import (
    DATE_PATTERN,
    DailyLog,
    DailyLogPatch,
    WaterIncrement,
)

router = APIRouter(prefix="/logs", tags=["tracking"])

DateParam = Path(pattern=DATE_PATTERN, description="YYYY-MM-DD")


def _load(repo: TrackingRepository, uid: str, date: str) -> DailyLog:
    data = repo.get(uid, date)
    return DailyLog(**data) if data else DailyLog(date=date)


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
    log = _load(repo, uid, date)
    updated = log.model_copy(update=patch.model_dump(exclude_none=True))
    repo.save(uid, date, updated.model_dump())
    return updated


@router.post("/{date}/water", response_model=DailyLog)
def add_water(
    increment: WaterIncrement,
    date: str = DateParam,
    uid: str = Depends(get_current_uid),
    repo: TrackingRepository = Depends(get_tracking_repository),
) -> DailyLog:
    log = _load(repo, uid, date)
    updated = log.model_copy(update={"water_ml": log.water_ml + increment.amount_ml})
    repo.save(uid, date, updated.model_dump())
    return updated
