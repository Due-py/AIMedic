"""Daily-log storage: Firestore when configured, in-memory fallback for dev.

Firestore layout: users/{uid}/daily_logs/{YYYY-MM-DD}
"""

from typing import Protocol

from app.core.firebase import firebase_available

_USERS = "users"
_LOGS = "daily_logs"


class TrackingRepository(Protocol):
    def get(self, uid: str, date: str) -> dict | None: ...
    def save(self, uid: str, date: str, data: dict) -> None: ...
    def get_range(self, uid: str, start: str, end: str) -> list[dict]: ...


class InMemoryTrackingRepository:
    def __init__(self) -> None:
        self._store: dict[str, dict[str, dict]] = {}

    def get(self, uid: str, date: str) -> dict | None:
        return self._store.get(uid, {}).get(date)

    def save(self, uid: str, date: str, data: dict) -> None:
        self._store.setdefault(uid, {})[date] = data

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

    def save(self, uid: str, date: str, data: dict) -> None:
        self._collection(uid).document(date).set(data)

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
