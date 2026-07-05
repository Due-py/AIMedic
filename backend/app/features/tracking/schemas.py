from pydantic import BaseModel, Field

DATE_PATTERN = r"^\d{4}-\d{2}-\d{2}$"
MAX_DAILY_WATER_ML = 10_000


class DailyLogPatch(BaseModel):
    """Partial update: only the fields the student logged right now.

    Values replace the stored ones; omitted fields are left untouched so
    quick actions (e.g. "+1 cup of water") never erase other entries.
    """

    water_ml: int | None = Field(default=None, ge=0, le=MAX_DAILY_WATER_ML)
    sleep_hours: float | None = Field(default=None, ge=0, le=24)
    exercise_minutes: int | None = Field(default=None, ge=0, le=1_440)
    screen_time_minutes: int | None = Field(default=None, ge=0, le=1_440)
    mood: int | None = Field(default=None, ge=1, le=5)
    stress: int | None = Field(default=None, ge=1, le=5)
    steps: int | None = Field(default=None, ge=0, le=100_000)
    meals: list[str] | None = Field(default=None, max_length=10)


class DailyLog(BaseModel):
    date: str = Field(pattern=DATE_PATTERN)
    water_ml: int = 0
    sleep_hours: float | None = None
    exercise_minutes: int = 0
    screen_time_minutes: int | None = None
    mood: int | None = None
    stress: int | None = None
    steps: int = 0
    meals: list[str] = []


class WaterIncrement(BaseModel):
    amount_ml: int = Field(default=250, gt=0, le=2_000)
