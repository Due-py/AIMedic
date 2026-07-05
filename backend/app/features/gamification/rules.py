"""Gamification rules, derived entirely from stored daily logs.

Nothing here is client-writable: XP, streaks and badges are recomputed from
the log history on every request, so they cannot be forged by a modified app.
"""

from datetime import date, timedelta

from pydantic import BaseModel

XP_PER_CATEGORY = 5
LEVEL_XP = 100  # XP per level
HISTORY_DAYS = 90  # how far back logs are considered


def categories_logged(log: dict) -> int:
    return sum([
        bool(log.get("water_ml")),
        log.get("sleep_hours") is not None,
        bool(log.get("exercise_minutes")),
        log.get("screen_time_minutes") is not None,
        log.get("mood") is not None,
        log.get("stress") is not None,
        bool(log.get("meals")),
    ])


class Badge(BaseModel):
    id: str
    earned: bool


class GamificationState(BaseModel):
    xp: int
    level: int
    xp_into_level: int
    xp_per_level: int = LEVEL_XP
    streak_days: int
    streak_freeze_used: bool = False
    badges: list[Badge]


def compute_state(logs: list[dict], today: date) -> GamificationState:
    logged_days = {
        log["date"]: categories_logged(log)
        for log in logs
        if categories_logged(log) > 0
    }

    xp = XP_PER_CATEGORY * sum(logged_days.values())

    # Streak of consecutive logged days ending today — or yesterday, so the
    # streak isn't shown as broken before the student logs anything today.
    # Streak freeze (no-punishment rule): one single-day gap is forgiven per
    # rolling 7 streak days, so one busy day never resets the whole streak.
    streak = 0
    freeze_used = False
    day = today
    days_since_freeze = 7  # a freeze is available immediately
    if day.isoformat() not in logged_days:
        day -= timedelta(days=1)
    while True:
        if day.isoformat() in logged_days:
            streak += 1
            days_since_freeze += 1
            day -= timedelta(days=1)
        elif (
            days_since_freeze >= 7
            and streak > 0
            and (day - timedelta(days=1)).isoformat() in logged_days
        ):
            freeze_used = True
            days_since_freeze = 0
            day -= timedelta(days=1)  # skip the single missed day
        else:
            break

    total_water = sum(log.get("water_ml") or 0 for log in logs)
    mood_days = sum(1 for log in logs if log.get("mood") is not None)
    exercise_days = sum(1 for log in logs if log.get("exercise_minutes"))

    badges = [
        Badge(id="first_log", earned=bool(logged_days)),
        Badge(id="streak_3", earned=streak >= 3),
        Badge(id="streak_7", earned=streak >= 7),
        Badge(id="water_10l", earned=total_water >= 10_000),
        Badge(id="mood_5_days", earned=mood_days >= 5),
        Badge(id="active_5_days", earned=exercise_days >= 5),
    ]

    return GamificationState(
        xp=xp,
        level=xp // LEVEL_XP + 1,
        xp_into_level=xp % LEVEL_XP,
        streak_days=streak,
        streak_freeze_used=freeze_used,
        badges=badges,
    )
