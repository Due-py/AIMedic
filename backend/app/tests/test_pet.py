from datetime import date

import pytest
from fastapi.testclient import TestClient

from app.core.config import get_settings
from app.features.pet import router as pet_router
from app.features.pet.repository import InMemoryPetRepository, get_pet_repository
from app.features.pet.rules import mood_for_today, stage_for_xp
from app.features.tracking.repository import (
    InMemoryTrackingRepository,
    get_tracking_repository,
)
from app.main import app

TODAY = date(2026, 7, 3)


class TestRules:
    @pytest.mark.parametrize(
        "xp,stage",
        [(0, "egg"), (29, "egg"), (30, "chick"), (99, "chick"),
         (100, "bird"), (299, "bird"), (300, "phoenix")],
    )
    def test_stages(self, xp, stage):
        assert stage_for_xp(xp) == stage

    def test_moods(self):
        assert mood_for_today(None) == "sleepy"
        assert mood_for_today({"water_ml": 250}) == "ok"
        assert mood_for_today(
            {"water_ml": 250, "mood": 4, "sleep_hours": 8.0}) == "happy"


class TestEndpoints:
    @pytest.fixture
    def client(self, monkeypatch):
        monkeypatch.setattr(get_settings(), "debug", True)
        monkeypatch.setattr(pet_router, "app_today", lambda: TODAY)
        tracking = InMemoryTrackingRepository()
        pets = InMemoryPetRepository()
        app.dependency_overrides[get_tracking_repository] = lambda: tracking
        app.dependency_overrides[get_pet_repository] = lambda: pets
        # 4 days x 3 categories = 12 category-days = 12 coins, 60 XP.
        for d in ["2026-06-30", "2026-07-01", "2026-07-02", "2026-07-03"]:
            tracking.merge(
                "dev-user", d,
                {"water_ml": 500, "mood": 4, "sleep_hours": 8.0},
            )
        yield TestClient(app)
        app.dependency_overrides.clear()

    def test_state_derived_from_logs(self, client):
        pet = client.get("/pet").json()
        assert pet["coins"] == 12
        assert pet["stage"] == "chick"  # 60 XP
        assert pet["mood"] == "happy"  # 3 categories today
        assert pet["owned"] == []
        assert len(pet["catalog"]) == 6

    def test_buy_deducts_and_equips(self, client):
        pet = client.post("/pet/buy", json={"accessory_id": "balloon"}).json()
        assert pet["coins"] == 2  # 12 - 10
        assert pet["owned"] == ["balloon"]
        assert pet["equipped"] == ["balloon"]

    def test_buy_insufficient_coins_rejected(self, client):
        resp = client.post("/pet/buy", json={"accessory_id": "crown"})  # 50
        assert resp.status_code == 422

    def test_buy_twice_rejected(self, client):
        client.post("/pet/buy", json={"accessory_id": "balloon"})
        resp = client.post("/pet/buy", json={"accessory_id": "balloon"})
        assert resp.status_code == 409

    def test_unknown_accessory_404(self, client):
        assert client.post(
            "/pet/buy", json={"accessory_id": "jetpack"}).status_code == 404

    def test_equip_toggle(self, client):
        client.post("/pet/buy", json={"accessory_id": "balloon"})
        pet = client.post("/pet/equip", json={"accessory_id": "balloon"}).json()
        assert pet["equipped"] == []  # unequipped
        pet = client.post("/pet/equip", json={"accessory_id": "balloon"}).json()
        assert pet["equipped"] == ["balloon"]  # re-equipped

    def test_equip_unowned_rejected(self, client):
        resp = client.post("/pet/equip", json={"accessory_id": "hat"})
        assert resp.status_code == 404
