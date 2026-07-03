"""Chat history storage: Firestore when configured, in-memory for dev.

Firestore layout: users/{uid}/chat_messages/{auto-id} with a created_at field.
"""

from datetime import datetime, timezone
from typing import Protocol

from app.core.firebase import firebase_available

_USERS = "users"
_MESSAGES = "chat_messages"


def _now() -> str:
    return datetime.now(timezone.utc).isoformat()


class ChatRepository(Protocol):
    def append(self, uid: str, role: str, content: str) -> dict: ...
    def recent(self, uid: str, limit: int) -> list[dict]: ...


class InMemoryChatRepository:
    def __init__(self) -> None:
        self._store: dict[str, list[dict]] = {}

    def append(self, uid: str, role: str, content: str) -> dict:
        msg = {"role": role, "content": content, "created_at": _now()}
        self._store.setdefault(uid, []).append(msg)
        return msg

    def recent(self, uid: str, limit: int) -> list[dict]:
        return self._store.get(uid, [])[-limit:]


class FirestoreChatRepository:
    def _collection(self, uid: str):
        from firebase_admin import firestore

        return (
            firestore.client()
            .collection(_USERS)
            .document(uid)
            .collection(_MESSAGES)
        )

    def append(self, uid: str, role: str, content: str) -> dict:
        msg = {"role": role, "content": content, "created_at": _now()}
        self._collection(uid).add(msg)
        return msg

    def recent(self, uid: str, limit: int) -> list[dict]:
        from google.cloud.firestore_v1 import Query

        docs = (
            self._collection(uid)
            .order_by("created_at", direction=Query.DESCENDING)
            .limit(limit)
            .stream()
        )
        return list(reversed([d.to_dict() for d in docs]))


_memory_repo = InMemoryChatRepository()


def get_chat_repository() -> ChatRepository:
    if firebase_available():
        return FirestoreChatRepository()
    return _memory_repo
