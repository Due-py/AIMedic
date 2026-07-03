import pytest

from app.features.profile.calculations import (
    ActivityLevel,
    Gender,
    bmi,
    bmi_category,
    bmr_mifflin_st_jeor,
    daily_calories,
    daily_water_ml,
    recommended_sleep_hours,
)


class TestBmi:
    def test_typical_student(self):
        # 45 kg, 155 cm → 45 / 1.55² = 18.7
        assert bmi(45, 155) == 18.7

    def test_known_value(self):
        assert bmi(60, 170) == 20.8

    @pytest.mark.parametrize("weight,height", [(0, 150), (-5, 150), (45, 0)])
    def test_invalid_input_raises(self, weight, height):
        with pytest.raises(ValueError):
            bmi(weight, height)

    @pytest.mark.parametrize(
        "value,expected",
        [
            (16.0, "underweight"),
            (18.5, "healthy"),
            (24.9, "healthy"),
            (25.0, "overweight"),
            (30.0, "obese"),
        ],
    )
    def test_categories(self, value, expected):
        assert bmi_category(value) == expected


class TestCalories:
    def test_bmr_male(self):
        # Mifflin-St Jeor: 10*45 + 6.25*155 - 5*13 + 5 = 1358.75
        assert bmr_mifflin_st_jeor(45, 155, 13, Gender.male) == 1358.75

    def test_bmr_female(self):
        # 10*45 + 6.25*155 - 5*13 - 161 = 1192.75
        assert bmr_mifflin_st_jeor(45, 155, 13, Gender.female) == 1192.75

    def test_tdee_moderate_male(self):
        # 1358.75 * 1.55 = 2106.06 → 2106
        assert daily_calories(45, 155, 13, Gender.male, ActivityLevel.moderate) == 2106

    def test_more_activity_means_more_calories(self):
        low = daily_calories(45, 155, 13, Gender.male, ActivityLevel.sedentary)
        high = daily_calories(45, 155, 13, Gender.male, ActivityLevel.very_active)
        assert high > low


class TestWater:
    def test_typical_student(self):
        # 45*35 + 200 = 1775 → rounded to 1800
        assert daily_water_ml(45, ActivityLevel.moderate) == 1800

    def test_clamped_low(self):
        assert daily_water_ml(20, ActivityLevel.sedentary) == 1500

    def test_clamped_high(self):
        assert daily_water_ml(90, ActivityLevel.very_active) == 2500

    def test_rounded_to_50(self):
        assert daily_water_ml(52, ActivityLevel.light) % 50 == 0


class TestSleep:
    @pytest.mark.parametrize(
        "age,expected",
        [(11, (9, 11)), (13, (9, 11)), (14, (8, 10)), (17, (8, 10)), (19, (7, 9))],
    )
    def test_ranges(self, age, expected):
        assert recommended_sleep_hours(age) == expected
