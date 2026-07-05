from datetime import timedelta

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

from app.core.auth import get_current_uid
from app.core.dates import app_today
from app.features.gamification.rules import (
    HISTORY_DAYS,
    XP_PER_CATEGORY,
    categories_logged,
)
from app.features.pet.repository import PetRepository, get_pet_repository
from app.features.pet.rules import (
    PetState,
    accessory_price,
    coins_earned,
    mood_for_today,
    stage_for_xp,
)
from app.features.tracking.repository import (
    TrackingRepository,
    get_tracking_repository,
)

router = APIRouter(prefix="/pet", tags=["pet"])


class AccessoryAction(BaseModel):
    accessory_id: str


def _build_state(
    uid: str, tracking: TrackingRepository, pets: PetRepository
) -> tuple[PetState, dict]:
    today = app_today()
    logs = tracking.get_range(
        uid, (today - timedelta(days=HISTORY_DAYS)).isoformat(), today.isoformat()
    )
    xp = XP_PER_CATEGORY * sum(categories_logged(log) for log in logs)
    today_log = next(
        (log for log in logs if log.get("date") == today.isoformat()), None
    )
    stored = pets.get(uid)
    state = PetState(
        stage=stage_for_xp(xp),
        mood=mood_for_today(today_log),
        coins=max(0, coins_earned(xp) - stored.get("coins_spent", 0)),
        owned=stored.get("owned", []),
        equipped=stored.get("equipped", []),
    )
    return state, stored


@router.get("", response_model=PetState)
def get_pet(
    uid: str = Depends(get_current_uid),
    tracking: TrackingRepository = Depends(get_tracking_repository),
    pets: PetRepository = Depends(get_pet_repository),
) -> PetState:
    state, _ = _build_state(uid, tracking, pets)
    return state


@router.post("/buy", response_model=PetState)
def buy_accessory(
    action: AccessoryAction,
    uid: str = Depends(get_current_uid),
    tracking: TrackingRepository = Depends(get_tracking_repository),
    pets: PetRepository = Depends(get_pet_repository),
) -> PetState:
    price = accessory_price(action.accessory_id)
    if price is None:
        raise HTTPException(status_code=404, detail="Unknown accessory.")

    with pets.lock:
        state, stored = _build_state(uid, tracking, pets)
        if action.accessory_id in state.owned:
            raise HTTPException(status_code=409, detail="Already owned.")
        if state.coins < price:
            raise HTTPException(status_code=422, detail="Not enough coins.")
        stored = {
            "coins_spent": stored.get("coins_spent", 0) + price,
            "owned": [*state.owned, action.accessory_id],
            # New accessories are worn immediately — instant gratification.
            "equipped": [*state.equipped, action.accessory_id],
        }
        pets.save(uid, stored)

    state, _ = _build_state(uid, tracking, pets)
    return state


@router.post("/equip", response_model=PetState)
def toggle_equip(
    action: AccessoryAction,
    uid: str = Depends(get_current_uid),
    tracking: TrackingRepository = Depends(get_tracking_repository),
    pets: PetRepository = Depends(get_pet_repository),
) -> PetState:
    with pets.lock:
        state, stored = _build_state(uid, tracking, pets)
        if action.accessory_id not in state.owned:
            raise HTTPException(status_code=404, detail="Not owned.")
        equipped = list(state.equipped)
        if action.accessory_id in equipped:
            equipped.remove(action.accessory_id)
        else:
            equipped.append(action.accessory_id)
        stored = {
            "coins_spent": stored.get("coins_spent", 0),
            "owned": state.owned,
            "equipped": equipped,
        }
        pets.save(uid, stored)

    state, _ = _build_state(uid, tracking, pets)
    return state
