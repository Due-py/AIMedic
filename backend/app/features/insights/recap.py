"""Weekly AI recap: a friendly Gemini-written summary of the student's week.

Generated at most once per user per ISO week (cached), and only when there
is enough data to say something meaningful (MIN_DAYS logged days).
"""

import threading
from typing import Protocol

from app.core.firebase import firebase_available
from app.features.gamification.rules import categories_logged

MIN_LOGGED_DAYS = 3

RECAP_SYSTEM = """\
Bạn là AIMedic — người bạn đồng hành sức khỏe của học sinh trung học Việt Nam.
Hãy viết một đoạn tổng kết tuần thân thiện (4-6 câu, xưng "mình", gọi "bạn"):
- Khen cụ thể những điều bạn ấy làm tốt (dùng số liệu được cung cấp).
- Nếu có điểm cần cải thiện, gợi ý MỘT thay đổi nhỏ, nhẹ nhàng, không phán xét.
- Kết thúc bằng một lời động viên vui vẻ cho tuần mới. Có thể dùng 1-2 emoji.
Không chẩn đoán bệnh, không kê thuốc, không dùng thuật ngữ y khoa phức tạp.
"""


def build_recap_input(logs: list[dict], trend_lines: list[str]) -> str:
    """Aggregate the week into a compact prompt for the model."""
    logged = [log for log in logs if categories_logged(log) > 0]
    water = [log.get("water_ml") or 0 for log in logged if log.get("water_ml")]
    sleep = [log["sleep_hours"] for log in logged if log.get("sleep_hours") is not None]
    active_days = sum(
        1 for log in logged if log.get("exercise_minutes") or log.get("steps")
    )
    moods = [log["mood"] for log in logged if log.get("mood") is not None]

    lines = [f"Số ngày ghi nhật ký tuần qua: {len(logged)}/7."]
    if water:
        lines.append(f"Nước uống trung bình: {round(sum(water) / len(water))} ml/ngày.")
    if sleep:
        lines.append(f"Giấc ngủ trung bình: {round(sum(sleep) / len(sleep), 1)} giờ/đêm.")
    lines.append(f"Số ngày có vận động: {active_days}.")
    if moods:
        lines.append(f"Tâm trạng trung bình: {round(sum(moods) / len(moods), 1)}/5.")
    if trend_lines:
        lines.append("Xu hướng: " + "; ".join(trend_lines) + ".")
    return "\n".join(lines)


class RecapRepository(Protocol):
    def get(self, uid: str, week: str) -> str | None: ...
    def save(self, uid: str, week: str, text: str) -> None: ...


class InMemoryRecapRepository:
    def __init__(self) -> None:
        self._store: dict[tuple[str, str], str] = {}
        self.lock = threading.Lock()

    def get(self, uid: str, week: str) -> str | None:
        return self._store.get((uid, week))

    def save(self, uid: str, week: str, text: str) -> None:
        self._store[(uid, week)] = text


class FirestoreRecapRepository:
    lock = threading.Lock()

    def _doc(self, uid: str, week: str):
        from firebase_admin import firestore

        return (
            firestore.client()
            .collection("users")
            .document(uid)
            .collection("recaps")
            .document(week)
        )

    def get(self, uid: str, week: str) -> str | None:
        doc = self._doc(uid, week).get()
        return (doc.to_dict() or {}).get("text") if doc.exists else None

    def save(self, uid: str, week: str, text: str) -> None:
        self._doc(uid, week).set({"text": text})


_memory_repo = InMemoryRecapRepository()


def get_recap_repository() -> RecapRepository:
    if firebase_available():
        return FirestoreRecapRepository()
    return _memory_repo
