"""Short human-friendly join codes (classes, challenges)."""

import secrets

# No 0/O/1/I — students read these off a blackboard.
_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"


def new_code(length: int = 6) -> str:
    return "".join(secrets.choice(_ALPHABET) for _ in range(length))
