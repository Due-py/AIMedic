import pytest
from fastapi.testclient import TestClient

from app.core.config import get_settings
from app.features.tracking.repository import InMemoryTrackingRepository, get_tracking_repository
from app.main import app


@pytest.fixture
def client(monkeypatch):
    monkeypatch.setattr(get_settings(), "debug", True)
    # Fresh store per test so logs don't leak between tests.
    repo = InMemoryTrackingRepository()
    app.dependency_overrides[get_tracking_repository] = lambda: repo
    yield TestClient(app)
    app.dependency_overrides.clear()


def test_empty_day_returns_defaults(client):
    resp = client.get("/logs/2026-07-03")
    assert resp.status_code == 200
    body = resp.json()
    assert body["water_ml"] == 0
    assert body["sleep_hours"] is None
    assert body["meals"] == []


def test_patch_merges_fields(client):
    client.put("/logs/2026-07-03", json={"sleep_hours": 8.5})
    client.put("/logs/2026-07-03", json={"mood": 4})
    body = client.get("/logs/2026-07-03").json()
    assert body["sleep_hours"] == 8.5
    assert body["mood"] == 4


def test_water_increment_accumulates(client):
    client.post("/logs/2026-07-03/water", json={})
    client.post("/logs/2026-07-03/water", json={"amount_ml": 500})
    body = client.get("/logs/2026-07-03").json()
    assert body["water_ml"] == 750  # default 250 + 500


def test_range_query_sorted(client):
    for date in ["2026-07-02", "2026-06-30", "2026-07-01"]:
        client.put(f"/logs/{date}", json={"water_ml": 100})
    resp = client.get("/logs", params={"start": "2026-06-30", "end": "2026-07-02"})
    dates = [log["date"] for log in resp.json()]
    assert dates == ["2026-06-30", "2026-07-01", "2026-07-02"]


def test_range_excludes_outside(client):
    client.put("/logs/2026-06-01", json={"water_ml": 100})
    resp = client.get("/logs", params={"start": "2026-06-25", "end": "2026-07-02"})
    assert resp.json() == []


def test_invalid_date_rejected(client):
    assert client.get("/logs/03-07-2026").status_code == 422
    assert client.put("/logs/2026-07-03", json={"mood": 9}).status_code == 422
    resp = client.get("/logs", params={"start": "2026-07-05", "end": "2026-07-01"})
    assert resp.status_code == 422
