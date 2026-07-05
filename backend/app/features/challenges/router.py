from datetime import date, timedelta

from fastapi import APIRouter, Depends, HTTPException

from app.core.auth import get_current_uid
from app.core.dates import app_today
from app.features.challenges.repository import (
    ChallengeRepository,
    get_challenge_repository,
)
from app.features.challenges.rules import (
    DURATION_DAYS,
    MAX_CHALLENGES_PER_USER,
    MAX_MEMBERS,
    METRICS,
    ChallengeCreate,
    ChallengeJoin,
    ChallengeView,
    metric_day_value,
    new_code,
)
from app.features.tracking.repository import (
    TrackingRepository,
    get_tracking_repository,
)

router = APIRouter(prefix="/challenges", tags=["challenges"])


def _view(
    challenge: dict, uid: str, tracking: TrackingRepository, today: date
) -> ChallengeView:
    metric = challenge["metric"]
    total = 0
    mine = 0
    for member in challenge["members"]:
        logs = tracking.get_range(member, challenge["start"], challenge["end"])
        value = sum(metric_day_value(metric, log) for log in logs)
        total += value
        if member == uid:
            mine = value
    days_left = max(0, (date.fromisoformat(challenge["end"]) - today).days)
    return ChallengeView(
        code=challenge["code"],
        name=challenge["name"],
        metric=metric,
        goal=challenge["goal"],
        total=total,
        my_contribution=mine,
        member_count=len(challenge["members"]),
        start=challenge["start"],
        end=challenge["end"],
        days_left=days_left,
    )


def _active_memberships(repo: ChallengeRepository, uid: str, today: date) -> list[dict]:
    return [
        c
        for c in repo.list_for_member(uid)
        if date.fromisoformat(c["end"]) >= today
    ]


@router.get("", response_model=list[ChallengeView])
def my_challenges(
    uid: str = Depends(get_current_uid),
    repo: ChallengeRepository = Depends(get_challenge_repository),
    tracking: TrackingRepository = Depends(get_tracking_repository),
) -> list[ChallengeView]:
    today = app_today()
    challenges = sorted(
        _active_memberships(repo, uid, today), key=lambda c: c["end"]
    )
    return [_view(c, uid, tracking, today) for c in challenges]


@router.post("", response_model=ChallengeView)
def create_challenge(
    body: ChallengeCreate,
    uid: str = Depends(get_current_uid),
    repo: ChallengeRepository = Depends(get_challenge_repository),
    tracking: TrackingRepository = Depends(get_tracking_repository),
) -> ChallengeView:
    if body.metric not in METRICS:
        raise HTTPException(status_code=422, detail="Unknown metric.")
    low, high = METRICS[body.metric][1]
    if not (low <= body.goal <= high):
        raise HTTPException(status_code=422, detail="Goal out of range.")

    today = app_today()
    with repo.lock:
        if len(_active_memberships(repo, uid, today)) >= MAX_CHALLENGES_PER_USER:
            raise HTTPException(status_code=422, detail="Too many challenges.")
        code = new_code()
        while repo.get(code) is not None:  # vanishingly rare collision
            code = new_code()
        challenge = {
            "code": code,
            "name": body.name,
            "metric": body.metric,
            "goal": body.goal,
            "start": today.isoformat(),
            "end": (today + timedelta(days=DURATION_DAYS - 1)).isoformat(),
            "created_by": uid,
            "members": [uid],
        }
        repo.save(code, challenge)
    return _view(challenge, uid, tracking, today)


@router.post("/join", response_model=ChallengeView)
def join_challenge(
    body: ChallengeJoin,
    uid: str = Depends(get_current_uid),
    repo: ChallengeRepository = Depends(get_challenge_repository),
    tracking: TrackingRepository = Depends(get_tracking_repository),
) -> ChallengeView:
    today = app_today()
    code = body.code.strip().upper()
    with repo.lock:
        challenge = repo.get(code)
        if challenge is None or date.fromisoformat(challenge["end"]) < today:
            raise HTTPException(
                status_code=404, detail="Challenge not found or ended."
            )
        if uid not in challenge["members"]:
            if len(challenge["members"]) >= MAX_MEMBERS:
                raise HTTPException(status_code=422, detail="Challenge is full.")
            if len(_active_memberships(repo, uid, today)) >= MAX_CHALLENGES_PER_USER:
                raise HTTPException(status_code=422, detail="Too many challenges.")
            challenge["members"] = [*challenge["members"], uid]
            repo.save(code, challenge)
    return _view(challenge, uid, tracking, today)


@router.post("/{code}/leave", status_code=204)
def leave_challenge(
    code: str,
    uid: str = Depends(get_current_uid),
    repo: ChallengeRepository = Depends(get_challenge_repository),
) -> None:
    with repo.lock:
        challenge = repo.get(code.strip().upper())
        if challenge is None or uid not in challenge["members"]:
            raise HTTPException(status_code=404, detail="Not a member.")
        challenge["members"] = [m for m in challenge["members"] if m != uid]
        repo.save(challenge["code"], challenge)
