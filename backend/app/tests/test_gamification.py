from datetime import date

import pytest
from fastapi.testclient import TestClient

from app.core.config import get_settings
from app.features.gamification.rules import compute_state
from app.features.tracking.repository import (
    InMemoryTrackingRepository,
    get_tracking_repository,
)
from app.main import app

TODAY = date(2026, 7, 3)


def _log(day: str, **fields) -> dict:
    return {"date": day, **fields}


class TestRules:
    def test_empty_logs(self):
        state = compute_state([], TODAY)
        assert state.xp == 0
        assert state.level == 1
        assert state.streak_days == 0
        assert all(not b.earned for b in state.badges)

    def test_xp_per_category(self):
        logs = [_log("2026-07-03", water_ml=500, mood=4, sleep_hours=8.0)]
        state = compute_state(logs, TODAY)
        assert state.xp == 15  # 3 categories x 5
        assert state.level == 1
        assert state.xp_into_level == 15

    def test_level_up(self):
        logs = [
            _log(f"2026-06-{d:02d}", water_ml=500, mood=4, sleep_hours=8.0,
                 exercise_minutes=30)
            for d in range(1, 7)
        ]  # 6 days x 4 categories x 5 = 120 XP
        state = compute_state(logs, TODAY)
        assert state.xp == 120
        assert state.level == 2
        assert state.xp_into_level == 20

    def test_streak_counts_consecutive_days(self):
        logs = [
            _log("2026-07-01", water_ml=250),
            _log("2026-07-02", water_ml=250),
            _log("2026-07-03", water_ml=250),
        ]
        assert compute_state(logs, TODAY).streak_days == 3

    def test_streak_grace_when_today_not_logged_yet(self):
        logs = [
            _log("2026-07-01", water_ml=250),
            _log("2026-07-02", water_ml=250),
        ]
        assert compute_state(logs, TODAY).streak_days == 2

    def test_streak_broken_by_two_day_gap(self):
        logs = [
            _log("2026-06-30", water_ml=250),
            _log("2026-07-03", water_ml=250),  # gap on 07-01 and 07-02
        ]
        state = compute_state(logs, TODAY)
        assert state.streak_days == 1
        assert state.streak_freeze_used is False

    def test_single_day_gap_frozen(self):
        logs = [
            _log("2026-07-01", water_ml=250),
            # 07-02 missed — freeze covers it
            _log("2026-07-03", water_ml=250),
        ]
        state = compute_state(logs, TODAY)
        assert state.streak_days == 2
        assert state.streak_freeze_used is True

    def test_second_gap_within_week_breaks_streak(self):
        logs = [
            _log("2026-06-27", water_ml=250),
            # 06-28 missed (second gap — no freeze left this week)
            _log("2026-06-29", water_ml=250),
            _log("2026-06-30", water_ml=250),
            # 07-01 missed (freeze used here, walking backwards)
            _log("2026-07-02", water_ml=250),
            _log("2026-07-03", water_ml=250),
        ]
        state = compute_state(logs, TODAY)
        # Walk: 03,02 → freeze 01 → 30,29 → gap 28 has no freeze left → stop.
        assert state.streak_days == 4
        assert state.streak_freeze_used is True

    def test_freeze_regenerates_after_seven_streak_days(self):
        logs = [_log(f"2026-06-{d:02d}", water_ml=250) for d in range(18, 25)]
        logs.append(_log("2026-06-26", water_ml=250))  # 06-25 frozen
        logs += [_log(f"2026-06-{d:02d}", water_ml=250) for d in range(27, 31)]
        logs += [_log(f"2026-07-{d:02d}", water_ml=250) for d in range(1, 3)]
        logs.append(_log("2026-07-04", water_ml=250))  # 07-03 would need a 2nd freeze
        # 7+ streak days between the two gaps → both freezes allowed.
        state = compute_state(logs, date(2026, 7, 4))
        assert state.streak_days == 15
        assert state.streak_freeze_used is True

    def test_empty_day_does_not_count(self):
        logs = [_log("2026-07-03", water_ml=0, exercise_minutes=0, meals=[])]
        state = compute_state(logs, TODAY)
        assert state.xp == 0
        assert state.streak_days == 0

    def test_badges(self):
        logs = [
            _log(f"2026-07-{d:02d}", water_ml=4000, mood=3)
            for d in range(1, 4)
        ]
        state = compute_state(logs, TODAY)
        earned = {b.id for b in state.badges if b.earned}
        assert earned == {"first_log", "streak_3", "water_10l"}


class TestEndpoint:
    @pytest.fixture
    def client(self, monkeypatch):
        monkeypatch.setattr(get_settings(), "debug", True)
        repo = InMemoryTrackingRepository()
        app.dependency_overrides[get_tracking_repository] = lambda: repo
        yield TestClient(app)
        app.dependency_overrides.clear()

    def test_state_reflects_logged_data(self, client):
        today = date.today().isoformat()
        client.post(f"/logs/{today}/water", json={})
        client.put(f"/logs/{today}", json={"mood": 5})

        state = client.get("/gamification").json()
        assert state["xp"] == 10
        assert state["streak_days"] == 1
        badge_map = {b["id"]: b["earned"] for b in state["badges"]}
        assert badge_map["first_log"] is True
        assert badge_map["streak_3"] is False
