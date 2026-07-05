from datetime import timedelta

from fastapi import APIRouter, Depends, HTTPException

from app.core.auth import get_current_uid
from app.core.codes import new_code
from app.core.dates import app_today
from app.features.classrooms.repository import (
    ClassRepository,
    get_class_repository,
)
from app.features.classrooms.rules import (
    MAX_CLASSES_PER_USER,
    MAX_MEMBERS,
    MIN_MEMBERS_FOR_STATS,
    WINDOW_DAYS,
    ClassCreate,
    ClassDashboard,
    ClassJoin,
    ClassView,
    aggregate_dashboard,
)
from app.features.tracking.repository import (
    TrackingRepository,
    get_tracking_repository,
)

router = APIRouter(prefix="/classes", tags=["classes"])


def _view(cls: dict, uid: str) -> ClassView:
    return ClassView(
        code=cls["code"],
        name=cls["name"],
        member_count=len(cls["members"]),
        is_owner=cls["created_by"] == uid,
    )


@router.get("", response_model=list[ClassView])
def my_classes(
    uid: str = Depends(get_current_uid),
    repo: ClassRepository = Depends(get_class_repository),
) -> list[ClassView]:
    return [_view(c, uid) for c in repo.list_for_member(uid)]


@router.post("", response_model=ClassView)
def create_class(
    body: ClassCreate,
    uid: str = Depends(get_current_uid),
    repo: ClassRepository = Depends(get_class_repository),
) -> ClassView:
    with repo.lock:
        if len(repo.list_for_member(uid)) >= MAX_CLASSES_PER_USER:
            raise HTTPException(status_code=422, detail="Too many classes.")
        code = new_code()
        while repo.get(code) is not None:
            code = new_code()
        cls = {
            "code": code,
            "name": body.name,
            "created_by": uid,
            "members": [uid],
        }
        repo.save(code, cls)
    return _view(cls, uid)


@router.post("/join", response_model=ClassView)
def join_class(
    body: ClassJoin,
    uid: str = Depends(get_current_uid),
    repo: ClassRepository = Depends(get_class_repository),
) -> ClassView:
    code = body.code.strip().upper()
    with repo.lock:
        cls = repo.get(code)
        if cls is None:
            raise HTTPException(status_code=404, detail="Class not found.")
        if uid not in cls["members"]:
            if len(cls["members"]) >= MAX_MEMBERS:
                raise HTTPException(status_code=422, detail="Class is full.")
            if len(repo.list_for_member(uid)) >= MAX_CLASSES_PER_USER:
                raise HTTPException(status_code=422, detail="Too many classes.")
            cls["members"] = [*cls["members"], uid]
            repo.save(code, cls)
    return _view(cls, uid)


@router.get("/{code}/dashboard", response_model=ClassDashboard)
def class_dashboard(
    code: str,
    uid: str = Depends(get_current_uid),
    repo: ClassRepository = Depends(get_class_repository),
    tracking: TrackingRepository = Depends(get_tracking_repository),
) -> ClassDashboard:
    cls = repo.get(code.strip().upper())
    if cls is None:
        raise HTTPException(status_code=404, detail="Class not found.")
    # Aggregates are for the class creator only.
    if cls["created_by"] != uid:
        raise HTTPException(status_code=403, detail="Owner only.")

    base = {
        "code": cls["code"],
        "name": cls["name"],
        "member_count": len(cls["members"]),
    }
    if len(cls["members"]) < MIN_MEMBERS_FOR_STATS:
        return ClassDashboard(**base, locked=True)

    today = app_today()
    start = (today - timedelta(days=WINDOW_DAYS - 1)).isoformat()
    member_logs = [
        tracking.get_range(member, start, today.isoformat())
        for member in cls["members"]
    ]
    return ClassDashboard(
        **base, locked=False, **aggregate_dashboard(member_logs)
    )


@router.post("/{code}/leave", status_code=204)
def leave_class(
    code: str,
    uid: str = Depends(get_current_uid),
    repo: ClassRepository = Depends(get_class_repository),
) -> None:
    with repo.lock:
        cls = repo.get(code.strip().upper())
        if cls is None or uid not in cls["members"]:
            raise HTTPException(status_code=404, detail="Not a member.")
        cls["members"] = [m for m in cls["members"] if m != uid]
        repo.save(cls["code"], cls)
