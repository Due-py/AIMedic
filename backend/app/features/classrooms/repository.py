"""Class-group storage: Firestore when configured, in-memory for dev.

Firestore layout: classes/{code} with a members uid array (server-side
only; member uids are never returned by the API).
"""

import threading
from typing import Protocol

from app.core.firebase import firebase_available

_CLASSES = "classes"


class ClassRepository(Protocol):
    def get(self, code: str) -> dict | None: ...
    def save(self, code: str, data: dict) -> None: ...
    def list_for_member(self, uid: str) -> list[dict]: ...


class InMemoryClassRepository:
    def __init__(self) -> None:
        self._store: dict[str, dict] = {}
        self.lock = threading.Lock()

    def get(self, code: str) -> dict | None:
        return self._store.get(code)

    def save(self, code: str, data: dict) -> None:
        self._store[code] = data

    def list_for_member(self, uid: str) -> list[dict]:
        return [c for c in self._store.values() if uid in c.get("members", [])]


class FirestoreClassRepository:
    lock = threading.Lock()

    def _collection(self):
        from firebase_admin import firestore

        return firestore.client().collection(_CLASSES)

    def get(self, code: str) -> dict | None:
        doc = self._collection().document(code).get()
        return doc.to_dict() if doc.exists else None

    def save(self, code: str, data: dict) -> None:
        self._collection().document(code).set(data)

    def list_for_member(self, uid: str) -> list[dict]:
        from google.cloud.firestore_v1 import FieldFilter

        query = self._collection().where(
            filter=FieldFilter("members", "array_contains", uid)
        )
        return [doc.to_dict() for doc in query.stream()]


_memory_repo = InMemoryClassRepository()


def get_class_repository() -> ClassRepository:
    if firebase_available():
        return FirestoreClassRepository()
    return _memory_repo
