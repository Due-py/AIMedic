"""Habit-trend detection over the last week of logs.

Pattern-based, per CLAUDE.md §8: recommendations come from trends, not
single days. Each rule needs a minimum number of logged days so one bad
night never triggers a warning. Levels: positive | info | warn.
"""

from pydantic import BaseModel

MIN_DAYS = 3  # minimum logged days before a trend is trusted


class Insight(BaseModel):
    id: str
    level: str  # "positive" | "info" | "warn"
    value: float | None = None


def _avg(values: list[float]) -> float:
    return sum(values) / len(values)


def compute_insights(profile: dict | None, logs: list[dict]) -> list[Insight]:
    targets = (profile or {}).get("targets") or {}
    insights: list[Insight] = []

    sleep = [log["sleep_hours"] for log in logs if log.get("sleep_hours") is not None]
    if len(sleep) >= MIN_DAYS and targets.get("sleep_hours_min"):
        avg = round(_avg(sleep), 1)
        if avg < targets["sleep_hours_min"]:
            insights.append(Insight(id="sleep_debt", level="warn", value=avg))
        elif avg <= targets.get("sleep_hours_max", 24):
            insights.append(Insight(id="sleep_good", level="positive", value=avg))

    water = [log["water_ml"] for log in logs if log.get("water_ml")]
    if len(water) >= MIN_DAYS and targets.get("daily_water_ml"):
        avg = round(_avg(water))
        if avg < 0.75 * targets["daily_water_ml"]:
            insights.append(Insight(id="low_water", level="warn", value=avg))
        elif avg >= targets["daily_water_ml"]:
            insights.append(Insight(id="water_good", level="positive", value=avg))

    screen = [
        log["screen_time_minutes"]
        for log in logs
        if log.get("screen_time_minutes") is not None
    ]
    if len(screen) >= MIN_DAYS:
        avg = round(_avg(screen))
        if avg > 180:
            insights.append(Insight(id="high_screen_time", level="warn", value=avg))

    stress = [log["stress"] for log in logs if log.get("stress") is not None]
    if len(stress) >= MIN_DAYS:
        avg = round(_avg(stress), 1)
        if avg >= 4:
            insights.append(Insight(id="high_stress", level="warn", value=avg))

    exercise_days = sum(1 for log in logs if log.get("exercise_minutes"))
    logged_days = sum(
        1
        for log in logs
        if any(
            [
                log.get("water_ml"),
                log.get("sleep_hours") is not None,
                log.get("exercise_minutes"),
                log.get("screen_time_minutes") is not None,
                log.get("mood") is not None,
                log.get("stress") is not None,
            ]
        )
    )
    if logged_days >= 4 and exercise_days <= 1:
        insights.append(Insight(id="low_exercise", level="info"))

    return insights


# Short Vietnamese lines for the AI coach's context (server-internal;
# the app renders its own localized messages from the ids).
_COACH_LINES = {
    "sleep_debt": "ngủ trung bình {value} giờ/đêm, ít hơn khuyến nghị",
    "sleep_good": "duy trì giấc ngủ tốt ({value} giờ/đêm)",
    "low_water": "uống trung bình {value} ml nước/ngày, thấp hơn mục tiêu",
    "water_good": "uống đủ nước ({value} ml/ngày)",
    "high_screen_time": "dùng màn hình trung bình {value} phút/ngày, khá nhiều",
    "high_stress": "mức căng thẳng trung bình {value}/5, đang cao",
    "low_exercise": "rất ít vận động trong tuần qua",
}


def coach_context_lines(insights: list[Insight]) -> list[str]:
    return [
        _COACH_LINES[i.id].format(value=i.value)
        for i in insights
        if i.id in _COACH_LINES
    ]
