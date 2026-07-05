import base64
from datetime import date

import pytest
from fastapi.testclient import TestClient

from app.core.config import get_settings
from app.features.nutrition import router as nutrition_router
from app.features.nutrition.router import _limiter
from app.features.nutrition.service import MealAnalysis, get_nutrition_ai
from app.features.tracking.repository import (
    InMemoryTrackingRepository,
    get_tracking_repository,
)
from app.main import app

TODAY = date(2026, 7, 3)

# Tiny valid JPEG header + padding — enough for magic-byte sniffing.
FAKE_JPEG = base64.b64encode(b"\xff\xd8\xff\xe0" + b"\x00" * 64).decode()


class FakeVision:
    def __init__(self, result=None):
        self.calls = []
        self.result = result or MealAnalysis(
            is_food=True, name="Phở bò", calories=450,
            protein_g=25, carbs_g=55, fat_g=12,
            comment="Món ăn cân bằng đó! Thêm rau xanh càng tuyệt nhé.",
        )

    def analyze(self, image, mime, caption):
        self.calls.append({"mime": mime, "caption": caption, "size": len(image)})
        return self.result


@pytest.fixture
def vision():
    return FakeVision()


@pytest.fixture
def tracking():
    return InMemoryTrackingRepository()


@pytest.fixture
def client(monkeypatch, vision, tracking):
    monkeypatch.setattr(get_settings(), "debug", True)
    monkeypatch.setattr(nutrition_router, "app_today", lambda: TODAY)
    _limiter._calls.clear()
    app.dependency_overrides[get_nutrition_ai] = lambda: vision
    app.dependency_overrides[get_tracking_repository] = lambda: tracking
    yield TestClient(app)
    app.dependency_overrides.clear()


def test_analyze_returns_macros_and_logs_meal(client, vision, tracking):
    resp = client.post("/nutrition/analyze", json={"image_base64": FAKE_JPEG})
    assert resp.status_code == 200
    body = resp.json()
    assert body["name"] == "Phở bò"
    assert body["calories"] == 450
    assert vision.calls[0]["mime"] == "image/jpeg"
    # Meal appended to today's log → counts as a logged category.
    log = tracking.get("dev-user", TODAY.isoformat())
    assert log["meals"] == ["Phở bò (~450 kcal)"]


def test_caption_forwarded(client, vision):
    client.post(
        "/nutrition/analyze",
        json={"image_base64": FAKE_JPEG, "caption": "bữa trưa ở trường"},
    )
    assert vision.calls[0]["caption"] == "bữa trưa ở trường"


def test_not_food_is_not_logged(client, vision, tracking):
    vision.result = MealAnalysis(
        is_food=False, name="", calories=0, protein_g=0, carbs_g=0, fat_g=0,
        comment="Hình như đây không phải đồ ăn 😄",
    )
    resp = client.post("/nutrition/analyze", json={"image_base64": FAKE_JPEG})
    assert resp.status_code == 200
    assert resp.json()["is_food"] is False
    assert tracking.get("dev-user", TODAY.isoformat()) is None


def test_invalid_base64_rejected(client):
    resp = client.post("/nutrition/analyze", json={"image_base64": "!!!"})
    assert resp.status_code == 422


def test_non_image_bytes_rejected(client):
    payload = base64.b64encode(b"just some text bytes").decode()
    resp = client.post("/nutrition/analyze", json={"image_base64": payload})
    assert resp.status_code == 422


def test_oversized_image_rejected(client):
    huge = base64.b64encode(b"\xff\xd8\xff" + b"\x00" * (5 * 1024 * 1024)).decode()
    resp = client.post("/nutrition/analyze", json={"image_base64": huge})
    assert resp.status_code == 413


def test_rate_limited(client):
    for _ in range(5):
        assert client.post(
            "/nutrition/analyze", json={"image_base64": FAKE_JPEG}
        ).status_code == 200
    assert client.post(
        "/nutrition/analyze", json={"image_base64": FAKE_JPEG}
    ).status_code == 429


def test_meals_capped_per_day(client, tracking):
    tracking.merge(
        "dev-user", TODAY.isoformat(), {"meals": [f"m{i}" for i in range(10)]}
    )
    _limiter._calls.clear()
    client.post("/nutrition/analyze", json={"image_base64": FAKE_JPEG})
    assert len(tracking.get("dev-user", TODAY.isoformat())["meals"]) == 10
