from datetime import date

import pytest
from fastapi.testclient import TestClient

from app.core.config import get_settings
from app.features.challenges import router as challenges_router
from app.features.challenges.repository import (
    InMemoryChallengeRepository,
    get_challenge_repository,
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
    monkeypatch.setattr(challenges_router, "app_today", lambda: TODAY)
    challenges = InMemoryChallengeRepository()
    tracking = InMemoryTrackingRepository()
    app.dependency_overrides[get_challenge_repository] = lambda: challenges
    app.dependency_overrides[get_tracking_repository] = lambda: tracking
    yield challenges, tracking
    app.dependency_overrides.clear()


@pytest.fixture
def client(repos):
    return TestClient(app)


def test_create_returns_code_and_window(client):
    resp = client.post(
        "/challenges",
        json={"name": "Lớp 7A1 uống nước", "metric": "water_ml", "goal": 100_000},
    )
    assert resp.status_code == 200
    body = resp.json()
    assert len(body["code"]) == 6
    assert body["member_count"] == 1
    assert body["start"] == "2026-07-03"
    assert body["end"] == "2026-07-09"
    assert body["days_left"] == 6


@pytest.mark.parametrize(
    "payload",
    [
        {"name": "x", "metric": "jumping", "goal": 100},
        {"name": "x", "metric": "water_ml", "goal": 10},  # below bound
        {"name": "", "metric": "water_ml", "goal": 100_000},
    ],
)
def test_create_validation(client, payload):
    assert client.post("/challenges", json=payload).status_code == 422


def test_join_and_team_progress_privacy(client, repos):
    challenges, tracking = repos
    # A classmate created a challenge and has logged water.
    challenges.save("ABCDEF", {
        "code": "ABCDEF", "name": "Uống nước", "metric": "water_ml",
        "goal": 10_000, "start": "2026-07-01", "end": "2026-07-07",
        "created_by": "classmate", "members": ["classmate"],
    })
    tracking.merge("classmate", "2026-07-02", {"water_ml": 1500})
    tracking.merge("dev-user", "2026-07-03", {"water_ml": 500})

    resp = client.post("/challenges/join", json={"code": "abcdef"})  # case-insensitive
    assert resp.status_code == 200
    body = resp.json()
    assert body["member_count"] == 2
    assert body["total"] == 2000  # both members' water
    assert body["my_contribution"] == 500  # only mine is attributed
    # Privacy: no member list or per-member values in the response.
    assert "members" not in body
    assert "created_by" not in body


def test_listed_in_my_challenges(client, repos):
    client.post(
        "/challenges",
        json={"name": "Đi bộ", "metric": "steps", "goal": 100_000},
    )
    listed = client.get("/challenges").json()
    assert len(listed) == 1
    assert listed[0]["name"] == "Đi bộ"


def test_ended_challenge_not_joinable_or_listed(client, repos):
    challenges, _ = repos
    challenges.save("OLDONE", {
        "code": "OLDONE", "name": "Cũ", "metric": "water_ml",
        "goal": 10_000, "start": "2026-06-01", "end": "2026-06-07",
        "created_by": "someone", "members": ["someone", "dev-user"],
    })
    assert client.post(
        "/challenges/join", json={"code": "OLDONE"}).status_code == 404
    assert client.get("/challenges").json() == []


def test_full_challenge_rejected(client, repos):
    challenges, _ = repos
    challenges.save("FULLUP", {
        "code": "FULLUP", "name": "Đầy", "metric": "water_ml",
        "goal": 10_000, "start": "2026-07-01", "end": "2026-07-07",
        "created_by": "x", "members": [f"u{i}" for i in range(50)],
    })
    assert client.post(
        "/challenges/join", json={"code": "FULLUP"}).status_code == 422


def test_leave(client):
    code = client.post(
        "/challenges",
        json={"name": "Tạm", "metric": "logged_days", "goal": 30},
    ).json()["code"]
    assert client.post(f"/challenges/{code}/leave").status_code == 204
    assert client.get("/challenges").json() == []
