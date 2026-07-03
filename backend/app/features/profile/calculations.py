"""Health engine: pure, unit-testable calculations for personalized targets.

References:
- BMR: Mifflin-St Jeor equation.
- Water: ~35 ml per kg body weight, adjusted for activity, clamped to a
  sensible range for middle-school students.
- Sleep: National Sleep Foundation recommendations by age group.

Note on BMI: proper interpretation for ages 10-17 uses BMI-for-age growth
percentiles. The MVP uses simplified categories and always presents the
result as educational guidance, never as a diagnosis (see CLAUDE.md).
"""

from enum import Enum


class Gender(str, Enum):
    male = "male"
    female = "female"


class ActivityLevel(str, Enum):
    sedentary = "sedentary"        # little or no exercise
    light = "light"                # 1-3 days/week
    moderate = "moderate"          # 3-5 days/week
    active = "active"              # 6-7 days/week
    very_active = "very_active"    # daily sport / physical school program

ACTIVITY_FACTORS: dict[ActivityLevel, float] = {
    ActivityLevel.sedentary: 1.2,
    ActivityLevel.light: 1.375,
    ActivityLevel.moderate: 1.55,
    ActivityLevel.active: 1.725,
    ActivityLevel.very_active: 1.9,
}


def bmi(weight_kg: float, height_cm: float) -> float:
    if weight_kg <= 0 or height_cm <= 0:
        raise ValueError("Weight and height must be positive.")
    height_m = height_cm / 100
    return round(weight_kg / (height_m**2), 1)


def bmi_category(bmi_value: float) -> str:
    if bmi_value < 18.5:
        return "underweight"
    if bmi_value < 25:
        return "healthy"
    if bmi_value < 30:
        return "overweight"
    return "obese"


def bmr_mifflin_st_jeor(
    weight_kg: float, height_cm: float, age: int, gender: Gender
) -> float:
    base = 10 * weight_kg + 6.25 * height_cm - 5 * age
    return base + 5 if gender == Gender.male else base - 161


def daily_calories(
    weight_kg: float, height_cm: float, age: int, gender: Gender,
    activity: ActivityLevel,
) -> int:
    tdee = bmr_mifflin_st_jeor(weight_kg, height_cm, age, gender) * ACTIVITY_FACTORS[activity]
    return round(tdee)


def daily_water_ml(weight_kg: float, activity: ActivityLevel) -> int:
    base = weight_kg * 35
    if activity in (ActivityLevel.active, ActivityLevel.very_active):
        base += 350
    elif activity == ActivityLevel.moderate:
        base += 200
    # Clamp to a healthy range for students; round to the nearest 50 ml.
    clamped = min(max(base, 1500), 2500)
    return round(clamped / 50) * 50


def recommended_sleep_hours(age: int) -> tuple[int, int]:
    """Recommended nightly sleep range (min, max) by age."""
    if age <= 13:
        return (9, 11)
    if age <= 17:
        return (8, 10)
    return (7, 9)
