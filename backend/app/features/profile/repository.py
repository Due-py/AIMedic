"""Profile storage: Firestore when configured, in-memory fallback for local dev."""

from typing import Protocol

from app.core.firebase import firebase_available

_COLLECTION = "users"


class ProfileRepository(Protocol):
    def get(self, uid: str) -> dict | None: ...
    def save(self, uid: str, data: dict) -> None: ...


class InMemoryProfileRepository:
    def __init__(self) -> None:
        self._store: dict[str, dict] = {}

    def get(self, uid: str) -> dict | None:
        return self._store.get(uid)

    def save(self, uid: str, data: dict) -> None:
        self._store[uid] = data


class FirestoreProfileRepository:
    def get(self, uid: str) -> dict | None:
        from firebase_admin import firestore

        doc = firestore.client().collection(_COLLECTION).document(uid).get()
        return doc.to_dict() if doc.exists else None

    def save(self, uid: str, data: dict) -> None:
        from firebase_admin import firestore

        firestore.client().collection(_COLLECTION).document(uid).set(data)


_memory_repo = InMemoryProfileRepository()


def get_profile_repository() -> ProfileRepository:
    if firebase_available():
        return FirestoreProfileRepository()
    return _memory_repo
