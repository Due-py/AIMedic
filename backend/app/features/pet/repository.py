"""Pet purchase state: Firestore when configured, in-memory for dev.

Only spending is stored (users/{uid}/pet/state); everything else about the
pet is derived from logs on each request.
"""

import threading
from typing import Protocol

from app.core.firebase import firebase_available

_USERS = "users"
_PET = "pet"
_STATE = "state"

_EMPTY = {"coins_spent": 0, "owned": [], "equipped": []}


class PetRepository(Protocol):
    def get(self, uid: str) -> dict: ...
    def save(self, uid: str, data: dict) -> None: ...


class InMemoryPetRepository:
    def __init__(self) -> None:
        self._store: dict[str, dict] = {}
        self.lock = threading.Lock()

    def get(self, uid: str) -> dict:
        return self._store.get(uid) or dict(_EMPTY)

    def save(self, uid: str, data: dict) -> None:
        self._store[uid] = data


class FirestorePetRepository:
    lock = threading.Lock()  # buy/equip are read-modify-write

    def _doc(self, uid: str):
        from firebase_admin import firestore

        return (
            firestore.client()
            .collection(_USERS)
            .document(uid)
            .collection(_PET)
            .document(_STATE)
        )

    def get(self, uid: str) -> dict:
        doc = self._doc(uid).get()
        return doc.to_dict() if doc.exists else dict(_EMPTY)

    def save(self, uid: str, data: dict) -> None:
        self._doc(uid).set(data)


_memory_repo = InMemoryPetRepository()


def get_pet_repository() -> PetRepository:
    if firebase_available():
        return FirestorePetRepository()
    return _memory_repo
