import pytest
from fastapi.testclient import TestClient

from app.core.config import get_settings
from app.features.coach import router as coach_router
from app.features.coach.repository import InMemoryChatRepository, get_chat_repository
from app.features.coach.safety import CRISIS_RESPONSE, check_crisis
from app.features.coach.service import get_coach_ai
from app.main import app


class FakeAI:
    def __init__(self):
        self.calls = []

    def reply(self, system, history, message):
        self.calls.append({"system": system, "history": history, "message": message})
        return "Uống đủ nước rất tốt cho bạn!"


@pytest.fixture
def fake_ai():
    return FakeAI()


@pytest.fixture
def client(monkeypatch, fake_ai):
    monkeypatch.setattr(get_settings(), "debug", True)
    coach_router._recent_calls.clear()
    repo = InMemoryChatRepository()
    app.dependency_overrides[get_chat_repository] = lambda: repo
    app.dependency_overrides[get_coach_ai] = lambda: fake_ai
    yield TestClient(app)
    app.dependency_overrides.clear()


class TestSafety:
    @pytest.mark.parametrize(
        "message",
        [
            "Mình không muốn sống nữa",
            "minh muon chet",  # no diacritics
            "Tớ muốn tự tử",
            "I want to kill myself",
        ],
    )
    def test_crisis_detected(self, message):
        assert check_crisis(message)

    @pytest.mark.parametrize(
        "message",
        [
            "Hôm nay mình rất vui",
            "Làm sao để ngủ ngon hơn?",
            "Mình bị mỏi mắt khi học",
            # "từ từ" (= slowly) strips to "tu tu" — must NOT trigger.
            "Mình sẽ từ từ thay đổi thói quen",
            "Ăn từ từ thôi nhé",
            "Mình rất tự tin vào bản thân",
        ],
    )
    def test_normal_messages_pass(self, message):
        assert not check_crisis(message)


class TestChatEndpoint:
    def test_chat_returns_ai_reply_and_stores_history(self, client, fake_ai):
        resp = client.post("/coach/chat", json={"message": "Uống nước thế nào?"})
        assert resp.status_code == 200
        assert resp.json()["reply"] == "Uống đủ nước rất tốt cho bạn!"

        history = client.get("/coach/history").json()
        assert [m["role"] for m in history] == ["user", "assistant"]

    def test_crisis_message_never_reaches_model(self, client, fake_ai):
        resp = client.post("/coach/chat", json={"message": "mình muốn tự tử"})
        assert resp.status_code == 200
        assert resp.json()["reply"] == CRISIS_RESPONSE
        assert "111" in resp.json()["reply"]
        assert fake_ai.calls == []

    def test_crisis_exchange_scrubbed_from_later_history(self, client, fake_ai):
        client.post("/coach/chat", json={"message": "Mình thích chạy bộ"})
        client.post("/coach/chat", json={"message": "mình muốn tự tử"})
        client.post("/coach/chat", json={"message": "Uống nước thế nào?"})

        # The follow-up call must see neither the crisis message nor the
        # canned crisis response in its history.
        history = fake_ai.calls[-1]["history"]
        contents = [m["content"] for m in history]
        assert "mình muốn tự tử" not in contents
        assert CRISIS_RESPONSE not in contents
        assert "Mình thích chạy bộ" in contents  # normal history preserved

    def test_context_includes_profile(self, client, fake_ai):
        client.put(
            "/profile",
            json={
                "age": 13,
                "gender": "male",
                "height_cm": 155,
                "weight_kg": 45,
                "activity_level": "moderate",
                "sleep_time": "22:00",
                "wake_time": "06:30",
            },
        )
        client.post("/coach/chat", json={"message": "Mình nên uống bao nhiêu nước?"})
        assert "13 tuổi" in fake_ai.calls[0]["system"]
        assert "1800 ml" in fake_ai.calls[0]["system"]

    def test_history_passed_to_model(self, client, fake_ai):
        client.post("/coach/chat", json={"message": "Câu hỏi một"})
        client.post("/coach/chat", json={"message": "Câu hỏi hai"})
        second_call = fake_ai.calls[1]
        assert [m["content"] for m in second_call["history"]] == [
            "Câu hỏi một",
            "Uống đủ nước rất tốt cho bạn!",
        ]
        assert second_call["message"] == "Câu hỏi hai"

    def test_rate_limit(self, client):
        for _ in range(10):
            assert client.post("/coach/chat", json={"message": "hi"}).status_code == 200
        assert client.post("/coach/chat", json={"message": "hi"}).status_code == 429

    def test_empty_message_rejected(self, client):
        assert client.post("/coach/chat", json={"message": ""}).status_code == 422
