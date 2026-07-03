import pytest
from fastapi.testclient import TestClient

from app.core.config import get_settings
from app.main import app


@pytest.fixture
def client(monkeypatch):
    # Force DEBUG so auth falls back to "dev-user" without Firebase.
    monkeypatch.setattr(get_settings(), "debug", True)
    return TestClient(app)


VALID_PROFILE = {
    "age": 13,
    "gender": "male",
    "height_cm": 155,
    "weight_kg": 45,
    "activity_level": "moderate",
    "sleep_time": "22:00",
    "wake_time": "06:30",
}


def test_health_check(client):
    resp = client.get("/health")
    assert resp.status_code == 200
    assert resp.json()["status"] == "ok"


def test_upsert_profile_returns_targets(client):
    resp = client.put("/profile", json=VALID_PROFILE)
    assert resp.status_code == 200
    targets = resp.json()["targets"]
    assert targets["bmi"] == 18.7
    assert targets["daily_calories"] == 2106
    assert targets["daily_water_ml"] == 1800
    assert targets["sleep_hours_min"] == 9


def test_profile_roundtrip(client):
    client.put("/profile", json=VALID_PROFILE)
    resp = client.get("/profile")
    assert resp.status_code == 200
    assert resp.json()["age"] == 13


def test_invalid_profile_rejected(client):
    bad = {**VALID_PROFILE, "age": 45}
    resp = client.put("/profile", json=bad)
    assert resp.status_code == 422


def test_auth_required_when_not_debug(client, monkeypatch):
    monkeypatch.setattr(get_settings(), "debug", False)
    resp = client.get("/profile")
    assert resp.status_code == 401  # missing token outside DEBUG


def test_provided_token_never_uses_dev_fallback(client):
    # Even in DEBUG, a real token must be verified — Firebase is not
    # configured in tests, so verification is impossible → 503.
    resp = client.get("/profile", headers={"Authorization": "Bearer abc"})
    assert resp.status_code == 503
