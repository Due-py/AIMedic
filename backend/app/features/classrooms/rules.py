"""Class groups with an owner-only aggregate dashboard (CLAUDE.md §10).

Privacy rules, enforced server-side:
- only aggregates are ever computed or returned — never per-student values;
- only the class creator (teacher) can read the dashboard;
- stats stay locked until the class has MIN_MEMBERS_FOR_STATS members, so
  a tiny group can't be used to deanonymize an individual student.
"""

from pydantic import BaseModel, Field

MAX_MEMBERS = 60
MAX_CLASSES_PER_USER = 5
MIN_MEMBERS_FOR_STATS = 3
WINDOW_DAYS = 7


class ClassCreate(BaseModel):
    name: str = Field(min_length=1, max_length=40)


class ClassJoin(BaseModel):
    code: str = Field(min_length=6, max_length=6)


class ClassView(BaseModel):
    code: str
    name: str
    member_count: int
    is_owner: bool


class ClassDashboard(BaseModel):
    code: str
    name: str
    member_count: int
    # Locked until enough members for anonymous aggregates.
    locked: bool
    min_members: int = MIN_MEMBERS_FOR_STATS
    active_members: int | None = None
    avg_sleep_hours: float | None = None
    avg_water_ml: int | None = None
    avg_steps: int | None = None
    avg_exercise_minutes: int | None = None
    avg_mood: float | None = None
    avg_stress: float | None = None


def aggregate_dashboard(member_logs: list[list[dict]]) -> dict:
    """Aggregate per-member 7-day logs into class-level averages.

    Averages are over member-days where that value was logged; a value
    nobody logged stays None.
    """
    from app.features.gamification.rules import categories_logged

    def mean(values: list[float]) -> float | None:
        return sum(values) / len(values) if values else None

    sleep: list[float] = []
    water: list[float] = []
    steps: list[float] = []
    exercise: list[float] = []
    mood: list[float] = []
    stress: list[float] = []
    active = 0

    for logs in member_logs:
        if any(categories_logged(log) > 0 for log in logs):
            active += 1
        for log in logs:
            if log.get("sleep_hours") is not None:
                sleep.append(log["sleep_hours"])
            if log.get("water_ml"):
                water.append(log["water_ml"])
            if log.get("steps"):
                steps.append(log["steps"])
            if log.get("exercise_minutes"):
                exercise.append(log["exercise_minutes"])
            if log.get("mood") is not None:
                mood.append(log["mood"])
            if log.get("stress") is not None:
                stress.append(log["stress"])

    avg_sleep = mean(sleep)
    avg_mood = mean(mood)
    avg_stress = mean(stress)
    return {
        "active_members": active,
        "avg_sleep_hours": round(avg_sleep, 1) if avg_sleep is not None else None,
        "avg_water_ml": round(mean(water)) if water else None,
        "avg_steps": round(mean(steps)) if steps else None,
        "avg_exercise_minutes": round(mean(exercise)) if exercise else None,
        "avg_mood": round(avg_mood, 1) if avg_mood is not None else None,
        "avg_stress": round(avg_stress, 1) if avg_stress is not None else None,
    }
