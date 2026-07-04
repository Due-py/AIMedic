"""Authentication dependency: verifies Firebase ID tokens.

Every protected endpoint depends on `get_current_uid`. In DEBUG mode without
Firebase configured, requests authenticate as "dev-user" so the app can be
developed locally before the Firebase project exists.
"""

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.core.config import get_settings
from app.core.firebase import firebase_available

_bearer = HTTPBearer(auto_error=False)


def get_current_uid(
    token: HTTPAuthorizationCredentials | None = Depends(_bearer),
) -> str:
    # Dev mode = DEBUG *and* no Firebase: every request (with or without a
    # token — there is nothing to verify it against) acts as one local dev
    # user. The moment Firebase credentials are configured, real verification
    # applies regardless of DEBUG, so a stray DEBUG=true in production can
    # never grant unauthenticated access to real data.
    if get_settings().debug and not firebase_available():
        return "dev-user"

    if token is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing bearer token.",
        )

    if not firebase_available():
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Authentication service is not configured.",
        )

    from firebase_admin import auth as fb_auth

    try:
        decoded = fb_auth.verify_id_token(token.credentials)
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token.",
        )
    return decoded["uid"]
