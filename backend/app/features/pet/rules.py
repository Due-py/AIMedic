"""Virtual pet companion (Finch/Plant Nanny pattern).

The pet thrives when the student cares for themselves. All economy values
are server-derived: coins earned = total logged category-days (1 coin per
category per day, i.e. xp / XP_PER_CATEGORY); spending is the only stored
state, so balances cannot be forged by a modified client.
"""

from pydantic import BaseModel

from app.features.gamification.rules import XP_PER_CATEGORY, categories_logged


class Accessory(BaseModel):
    id: str
    emoji: str
    price: int


# Prices assume ~4-6 coins/day for an engaged student: first item within
# a couple of days, the crown is a long-term goal.
CATALOG = [
    Accessory(id="balloon", emoji="🎈", price=10),
    Accessory(id="bow", emoji="🎀", price=15),
    Accessory(id="hat", emoji="🎩", price=20),
    Accessory(id="scarf", emoji="🧣", price=20),
    Accessory(id="glasses", emoji="🕶️", price=25),
    Accessory(id="crown", emoji="👑", price=50),
]

_CATALOG_BY_ID = {a.id: a for a in CATALOG}


class PetState(BaseModel):
    stage: str  # egg | chick | bird | phoenix
    mood: str  # happy | ok | sleepy
    coins: int
    owned: list[str]
    equipped: list[str]
    catalog: list[Accessory] = CATALOG


def stage_for_xp(xp: int) -> str:
    if xp < 30:
        return "egg"
    if xp < 100:
        return "chick"
    if xp < 300:
        return "bird"
    return "phoenix"


def mood_for_today(today_log: dict | None) -> str:
    logged = categories_logged(today_log) if today_log else 0
    if logged >= 3:
        return "happy"
    if logged >= 1:
        return "ok"
    return "sleepy"


def coins_earned(xp: int) -> int:
    return xp // XP_PER_CATEGORY


def accessory_price(accessory_id: str) -> int | None:
    accessory = _CATALOG_BY_ID.get(accessory_id)
    return accessory.price if accessory else None
