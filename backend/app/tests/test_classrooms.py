from datetime import date

import pytest
from fastapi.testclient import TestClient

from app.core.config import get_settings
from app.features.classrooms import router as classrooms_router
from app.features.classrooms.repository import (
    InMemoryClassRepository,
    get_class_repository,
)
from app.features.tracking.repository import (
    InMemoryTrackingRepository,
    get_tracking_repository,
)
from app.main import app

TODAY = date(2026, 7, 3)


@pytest.fixture
def repos(monkeypatch):
    monkeypatch.setattr(get_settings(), "debug", True)
    monkeypatch.setattr(classrooms_router, "app_today", lambda: TODAY)
    classes = InMemoryClassRepository()
    tracking = InMemoryTrackingRepository()
    app.dependency_overrides[get_class_repository] = lambda: classes
    app.dependency_overrides[get_tracking_repository] = lambda: tracking
    yield classes, tracking
    app.dependency_overrides.clear()


@pytest.fixture
def client(repos):
    return TestClient(app)


def test_create_and_list(client):
    resp = client.post("/classes", json={"name": "Lớp 7A1"})
    assert resp.status_code == 200
    body = resp.json()
    assert len(body["code"]) == 6
    assert body["is_owner"] is True

    listed = client.get("/classes").json()
    assert listed[0]["name"] == "Lớp 7A1"


def test_join_by_code(client, repos):
    classes, _ = repos
    classes.save("ABC234", {
        "code": "ABC234", "name": "Lớp 6B", "created_by": "teacher",
        "members": ["teacher"],
    })
    resp = client.post("/classes/join", json={"code": "abc234"})
    assert resp.status_code == 200
    assert resp.json()["member_count"] == 2
    assert resp.json()["is_owner"] is False


def test_dashboard_owner_only(client, repos):
    classes, _ = repos
    classes.save("ABC234", {
        "code": "ABC234", "name": "Lớp 6B", "created_by": "teacher",
        "members": ["teacher", "dev-user", "s2"],
    })
    # dev-user is a member but not the owner.
    assert client.get("/classes/ABC234/dashboard").status_code == 403


def test_dashboard_locked_below_min_members(client, repos):
    classes, _ = repos
    classes.save("ABC234", {
        "code": "ABC234", "name": "Nhỏ", "created_by": "dev-user",
        "members": ["dev-user", "s1"],
    })
    body = client.get("/classes/ABC234/dashboard").json()
    assert body["locked"] is True
    assert body["avg_sleep_hours"] is None
    assert body["min_members"] == 3


def test_dashboard_aggregates_anonymously(client, repos):
    classes, tracking = repos
    classes.save("ABC234", {
        "code": "ABC234", "name": "Lớp 7A1", "created_by": "dev-user",
        "members": ["dev-user", "s1", "s2"],
    })
    tracking.merge("s1", "2026-07-02", {"sleep_hours": 8.0, "water_ml": 1500})
    tracking.merge("s1", "2026-07-03", {"sleep_hours": 7.0})
    tracking.merge("s2", "2026-07-03", {"sleep_hours": 9.0, "stress": 4})
    # dev-user (teacher) logs nothing.

    body = client.get("/classes/ABC234/dashboard").json()
    assert body["locked"] is False
    assert body["member_count"] == 3
    assert body["active_members"] == 2
    assert body["avg_sleep_hours"] == 8.0  # (8+7+9)/3
    assert body["avg_water_ml"] == 1500
    assert body["avg_stress"] == 4.0
    assert body["avg_steps"] is None  # nobody logged steps
    # Privacy: nothing per-member in the payload.
    assert "members" not in body


def test_leave(client):
    code = client.post("/classes", json={"name": "Tạm"}).json()["code"]
    assert client.post(f"/classes/{code}/leave").status_code == 204
    assert client.get("/classes").json() == []
