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
    assert resp.status_code == 401  # missing token outside dev mode


def test_dev_mode_accepts_token_bearing_requests(client):
    # DEBUG without Firebase: a signed-in app still sends a token, but there
    # is nothing to verify it against — dev mode maps it to dev-user instead
    # of dead-ending every request with 503.
    resp = client.put(
        "/profile",
        json=VALID_PROFILE,
        headers={"Authorization": "Bearer anything"},
    )
    assert resp.status_code == 200


def test_token_verified_when_not_debug(client, monkeypatch):
    # Outside DEBUG, a provided token requires a working verifier;
    # without Firebase that is a hard 503, never a silent fallback.
    monkeypatch.setattr(get_settings(), "debug", False)
    resp = client.get("/profile", headers={"Authorization": "Bearer abc"})
    assert resp.status_code == 503


def test_dev_fallback_off_when_firebase_available(client, monkeypatch):
    # DEBUG=true must NOT bypass auth once Firebase is configured.
    from app.core import auth as auth_module

    monkeypatch.setattr(auth_module, "firebase_available", lambda: True)
    resp = client.get("/profile")
    assert resp.status_code == 401
