"""Firebase Admin initialization.

Firebase is optional in local development: when no service-account file is
configured the app still boots, auth falls back to a dev user (DEBUG only)
and data is kept in memory.
"""

import logging
import os

import firebase_admin
from firebase_admin import credentials

from app.core.config import get_settings

logger = logging.getLogger(__name__)

_initialized = False


def init_firebase() -> bool:
    """Initialize Firebase Admin once. Returns True if Firebase is available."""
    global _initialized
    if _initialized:
        return True

    settings = get_settings()
    cred_path = settings.firebase_credentials
    if not cred_path or not os.path.exists(cred_path):
        logger.warning("Firebase credentials not found — running without Firebase.")
        return False

    firebase_admin.initialize_app(credentials.Certificate(cred_path))
    _initialized = True
    logger.info("Firebase Admin initialized.")
    return True


def firebase_available() -> bool:
    return _initialized
