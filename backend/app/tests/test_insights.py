from app.features.insights.rules import coach_context_lines, compute_insights

PROFILE = {
    "targets": {
        "sleep_hours_min": 9,
        "sleep_hours_max": 11,
        "daily_water_ml": 1800,
    }
}


def _days(**fields_per_day) -> list[dict]:
    """Build logs: _days(sleep_hours=[7,7,6]) → 3 daily logs."""
    n = max(len(v) for v in fields_per_day.values())
    return [
        {"date": f"2026-07-{d + 1:02d}"}
        | {k: v[d] for k, v in fields_per_day.items() if d < len(v)}
        for d in range(n)
    ]


def ids(insights):
    return {i.id for i in insights}


class TestRules:
    def test_no_logs_no_insights(self):
        assert compute_insights(PROFILE, []) == []

    def test_two_days_is_not_a_trend(self):
        logs = _days(sleep_hours=[5, 5])
        assert compute_insights(PROFILE, logs) == []

    def test_sleep_debt(self):
        logs = _days(sleep_hours=[7, 6.5, 7])
        result = compute_insights(PROFILE, logs)
        assert ids(result) == {"sleep_debt"}
        assert result[0].level == "warn"
        assert result[0].value == 6.8

    def test_sleep_good(self):
        logs = _days(sleep_hours=[9, 9.5, 10])
        assert ids(compute_insights(PROFILE, logs)) == {"sleep_good"}

    def test_low_water(self):
        logs = _days(water_ml=[800, 900, 1000])
        result = compute_insights(PROFILE, logs)
        assert ids(result) == {"low_water"}
        assert result[0].value == 900

    def test_water_good(self):
        logs = _days(water_ml=[1800, 2000, 1900])
        assert ids(compute_insights(PROFILE, logs)) == {"water_good"}

    def test_high_screen_time(self):
        logs = _days(screen_time_minutes=[240, 300, 200])
        assert ids(compute_insights(PROFILE, logs)) == {"high_screen_time"}

    def test_high_stress(self):
        logs = _days(stress=[4, 5, 4])
        assert ids(compute_insights(PROFILE, logs)) == {"high_stress"}

    def test_low_exercise_needs_enough_logged_days(self):
        logs = _days(mood=[3, 3, 3, 3], exercise_minutes=[30])
        assert ids(compute_insights(PROFILE, logs)) == {"low_exercise"}

    def test_no_profile_still_detects_profile_free_trends(self):
        logs = _days(screen_time_minutes=[240, 300, 200], sleep_hours=[5, 5, 5])
        # Without targets, sleep rules are skipped but screen time still works.
        assert ids(compute_insights(None, logs)) == {"high_screen_time"}

    def test_coach_lines_formatted(self):
        logs = _days(sleep_hours=[7, 6.5, 7])
        lines = coach_context_lines(compute_insights(PROFILE, logs))
        assert lines == ["ngủ trung bình 6.8 giờ/đêm, ít hơn khuyến nghị"]
