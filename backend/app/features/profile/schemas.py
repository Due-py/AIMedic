from pydantic import BaseModel, Field

from app.features.profile.calculations import ActivityLevel, Gender


class ProfileIn(BaseModel):
    age: int = Field(ge=6, le=19)
    gender: Gender
    height_cm: float = Field(gt=80, lt=220)
    weight_kg: float = Field(gt=15, lt=150)
    activity_level: ActivityLevel
    sleep_time: str = Field(pattern=r"^\d{2}:\d{2}$", description="HH:MM")
    wake_time: str = Field(pattern=r"^\d{2}:\d{2}$", description="HH:MM")


class HealthTargets(BaseModel):
    bmi: float
    bmi_category: str
    daily_calories: int
    daily_water_ml: int
    sleep_hours_min: int
    sleep_hours_max: int


class ProfileOut(ProfileIn):
    targets: HealthTargets
