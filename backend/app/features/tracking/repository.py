"""Daily-log storage: Firestore when configured, in-memory fallback for dev.

Firestore layout: users/{uid}/daily_logs/{YYYY-MM-DD}

Writes are merge-based (only the provided fields touch the document) and the
water counter uses an atomic increment, so concurrent quick-logs never lose
each other's updates.
"""

import threading
from typing import Protocol

from app.core.firebase import firebase_available

_USERS = "users"
_LOGS = "daily_logs"


class TrackingRepository(Protocol):
    def get(self, uid: str, date: str) -> dict | None: ...
    def merge(self, uid: str, date: str, fields: dict) -> None: ...
    def increment_water(self, uid: str, date: str, amount: int) -> None: ...
    def get_range(self, uid: str, start: str, end: str) -> list[dict]: ...


class InMemoryTrackingRepository:
    def __init__(self) -> None:
        self._store: dict[str, dict[str, dict]] = {}
        self._lock = threading.Lock()

    def get(self, uid: str, date: str) -> dict | None:
        return self._store.get(uid, {}).get(date)

    def merge(self, uid: str, date: str, fields: dict) -> None:
        with self._lock:
            day = self._store.setdefault(uid, {}).setdefault(date, {"date": date})
            day.update(fields)

    def increment_water(self, uid: str, date: str, amount: int) -> None:
        with self._lock:
            day = self._store.setdefault(uid, {}).setdefault(date, {"date": date})
            day["water_ml"] = day.get("water_ml", 0) + amount

    def get_range(self, uid: str, start: str, end: str) -> list[dict]:
        logs = self._store.get(uid, {})
        # ISO dates sort lexicographically, so string comparison is correct.
        return [logs[d] for d in sorted(logs) if start <= d <= end]


class FirestoreTrackingRepository:
    def _collection(self, uid: str):
        from firebase_admin import firestore

        return (
            firestore.client()
            .collection(_USERS)
            .document(uid)
            .collection(_LOGS)
        )

    def get(self, uid: str, date: str) -> dict | None:
        doc = self._collection(uid).document(date).get()
        return doc.to_dict() if doc.exists else None

    def merge(self, uid: str, date: str, fields: dict) -> None:
        self._collection(uid).document(date).set(
            {"date": date, **fields}, merge=True
        )

    def increment_water(self, uid: str, date: str, amount: int) -> None:
        from google.cloud.firestore_v1 import Increment

        self._collection(uid).document(date).set(
            {"date": date, "water_ml": Increment(amount)}, merge=True
        )

    def get_range(self, uid: str, start: str, end: str) -> list[dict]:
        from google.cloud.firestore_v1 import FieldFilter

        query = (
            self._collection(uid)
            .where(filter=FieldFilter("date", ">=", start))
            .where(filter=FieldFilter("date", "<=", end))
            .order_by("date")
        )
        return [doc.to_dict() for doc in query.stream()]


_memory_repo = InMemoryTrackingRepository()


def get_tracking_repository() -> TrackingRepository:
    if firebase_available():
        return FirestoreTrackingRepository()
    return _memory_repo
