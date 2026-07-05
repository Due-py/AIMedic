"""Class co-op challenges (StepUp / Duolingo Friend Quest pattern, softened).

A cooperative team goal — "our class drinks 500 cups this week" — with one
collective progress bar. By design there are NO individual rankings: the API
exposes only the team total and the caller's own contribution, so nobody can
be singled out (CLAUDE.md: friendly competition, individual privacy).
"""

import secrets

from pydantic import BaseModel, Field

from app.features.gamification.rules import categories_logged

MAX_MEMBERS = 50
MAX_CHALLENGES_PER_USER = 5
DURATION_DAYS = 7

# Unambiguous alphabet for join codes (no 0/O/1/I).
_CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"

METRICS = {
    # metric id -> (per-day value extractor, sane team-goal bounds)
    "water_ml": (lambda log: log.get("water_ml") or 0, (1_000, 2_000_000)),
    "steps": (lambda log: log.get("steps") or 0, (1_000, 10_000_000)),
    "logged_days": (
        lambda log: 1 if categories_logged(log) > 0 else 0,
        (1, 2_000),
    ),
}


def new_code() -> str:
    return "".join(secrets.choice(_CODE_ALPHABET) for _ in range(6))


def metric_day_value(metric: str, log: dict) -> int:
    return METRICS[metric][0](log)


class ChallengeCreate(BaseModel):
    name: str = Field(min_length=1, max_length=40)
    metric: str
    goal: int


class ChallengeJoin(BaseModel):
    code: str = Field(min_length=6, max_length=6)


class ChallengeView(BaseModel):
    code: str
    name: str
    metric: str
    goal: int
    total: int
    my_contribution: int
    member_count: int
    start: str
    end: str
    days_left: int
