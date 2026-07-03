import logging
import time
from collections import defaultdict, deque
from datetime import date, timedelta

from fastapi import APIRouter, Depends, HTTPException, Query, status

from app.core.auth import get_current_uid
from app.features.coach.prompts import SYSTEM_PROMPT, build_user_context
from app.features.coach.repository import ChatRepository, get_chat_repository
from app.features.coach.safety import CRISIS_RESPONSE, check_crisis
from app.features.coach.schemas import ChatMessage, ChatRequest, ChatResponse
from app.features.coach.service import CoachAI, get_coach_ai
from app.features.profile.repository import (
    ProfileRepository,
    get_profile_repository,
)
from app.features.tracking.repository import (
    TrackingRepository,
    get_tracking_repository,
)

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/coach", tags=["coach"])

_HISTORY_WINDOW = 10  # messages of context sent to the model

# Per-user sliding window on top of the global per-IP limit: LLM calls are
# the expensive resource on the free tier.
_RATE_LIMIT = 10
_RATE_WINDOW_SECONDS = 60
_recent_calls: dict[str, deque[float]] = defaultdict(deque)


def _check_rate(uid: str) -> None:
    now = time.monotonic()
    calls = _recent_calls[uid]
    while calls and now - calls[0] > _RATE_WINDOW_SECONDS:
        calls.popleft()
    if len(calls) >= _RATE_LIMIT:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Too many messages; please slow down.",
        )
    calls.append(now)


@router.post("/chat", response_model=ChatResponse)
def chat(
    request: ChatRequest,
    uid: str = Depends(get_current_uid),
    chats: ChatRepository = Depends(get_chat_repository),
    profiles: ProfileRepository = Depends(get_profile_repository),
    tracking: TrackingRepository = Depends(get_tracking_repository),
    ai: CoachAI = Depends(get_coach_ai),
) -> ChatResponse:
    _check_rate(uid)

    chats.append(uid, "user", request.message)

    if check_crisis(request.message):
        chats.append(uid, "assistant", CRISIS_RESPONSE)
        return ChatResponse(reply=CRISIS_RESPONSE)

    profile = profiles.get(uid)
    today = date.today()
    logs = tracking.get_range(
        uid, (today - timedelta(days=6)).isoformat(), today.isoformat()
    )
    context = build_user_context(profile, logs)
    system = f"{SYSTEM_PROMPT}\n\n{context}" if context else SYSTEM_PROMPT

    history = chats.recent(uid, _HISTORY_WINDOW + 1)[:-1]  # exclude msg just saved
    try:
        reply = ai.reply(system, history, request.message)
    except HTTPException:
        raise
    except Exception:
        logger.exception("Coach AI call failed")
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="AI service is temporarily unavailable.",
        )

    chats.append(uid, "assistant", reply)
    return ChatResponse(reply=reply)


@router.get("/history", response_model=list[ChatMessage])
def history(
    limit: int = Query(default=50, ge=1, le=200),
    uid: str = Depends(get_current_uid),
    chats: ChatRepository = Depends(get_chat_repository),
) -> list[ChatMessage]:
    return [ChatMessage(**m) for m in chats.recent(uid, limit)]
