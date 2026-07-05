"""Per-user sliding-window rate limiter for expensive (LLM) endpoints.

In-memory and per-process — a deliberate free-tier trade-off (single Render
instance). Complements the global per-IP slowapi limit in main.py.
"""

import time
from collections import defaultdict, deque

from fastapi import HTTPException, status


class PerUserLimiter:
    def __init__(self, limit: int, window_seconds: int = 60) -> None:
        self._limit = limit
        self._window = window_seconds
        self._calls: dict[str, deque[float]] = defaultdict(deque)

    def check(self, uid: str) -> None:
        now = time.monotonic()
        calls = self._calls[uid]
        while calls and now - calls[0] > self._window:
            calls.popleft()
        if len(calls) >= self._limit:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Too many requests; please slow down.",
            )
        calls.append(now)
