from datetime import date

import pytest
from fastapi.testclient import TestClient

from app.core.config import get_settings
from app.features.insights import router as insights_router
from app.features.insights.recap import (
    InMemoryRecapRepository,
    get_recap_repository,
)
from app.features.tracking.repository import (
    InMemoryTrackingRepository,
    get_tracking_repository,
)
from app.main import app

TODAY = date(2026, 7, 3)


class FakeAI:
    def __init__(self):
        self.calls = []

    def reply(self, system, history, message):
        self.calls.append({"system": system, "message": message})
        return "Tuần này bạn làm rất tốt! 🎉"


@pytest.fixture
def fake_ai():
    return FakeAI()


@pytest.fixture
def tracking():
    return InMemoryTrackingRepository()


@pytest.fixture
def client(monkeypatch, fake_ai, tracking):
    monkeypatch.setattr(get_settings(), "debug", True)
    monkeypatch.setattr(insights_router, "app_today", lambda: TODAY)
    app.dependency_overrides[get_tracking_repository] = lambda: tracking
    app.dependency_overrides[get_recap_repository] = (
        lambda: InMemoryRecapRepository()
    )
    app.dependency_overrides[insights_router.get_optional_coach_ai] = (
        lambda: fake_ai
    )
    yield TestClient(app)
    app.dependency_overrides.clear()


def _seed_week(tracking, days=4):
    # `days` consecutive days ending at TODAY (2026-07-03), inside the window.
    from datetime import timedelta

    for offset in range(days):
        day = (TODAY - timedelta(days=offset)).isoformat()
        tracking.merge(
            "dev-user",
            day,
            {"water_ml": 1500, "sleep_hours": 8.0, "mood": 4, "steps": 6000},
        )


def test_recap_generated_with_aggregates(client, tracking, fake_ai):
    _seed_week(tracking)
    resp = client.get("/insights/recap")
    assert resp.status_code == 200
    assert resp.json()["recap"] == "Tuần này bạn làm rất tốt! 🎉"
    prompt = fake_ai.calls[0]["message"]
    assert "4/7" in prompt  # logged days
    assert "1500 ml" in prompt
    assert "8.0 giờ" in prompt


def test_recap_cached_one_ai_call_per_week(client, tracking, fake_ai, monkeypatch):
    # Same repo across both requests so the cache persists.
    repo = InMemoryRecapRepository()
    app.dependency_overrides[get_recap_repository] = lambda: repo
    _seed_week(tracking)
    client.get("/insights/recap")
    client.get("/insights/recap")
    assert len(fake_ai.calls) == 1


def test_recap_null_when_not_enough_days(client, tracking, fake_ai):
    _seed_week(tracking, days=2)
    resp = client.get("/insights/recap")
    assert resp.json()["recap"] is None
    assert fake_ai.calls == []


def test_recap_null_when_ai_unavailable(client, tracking):
    app.dependency_overrides[insights_router.get_optional_coach_ai] = (
        lambda: None
    )
    _seed_week(tracking)
    resp = client.get("/insights/recap")
    assert resp.status_code == 200
    assert resp.json()["recap"] is None
