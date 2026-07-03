from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address

from app.core.config import get_settings
from app.core.firebase import init_firebase
from app.features.profile.router import router as profile_router
from app.features.tracking.router import router as tracking_router

settings = get_settings()

init_firebase()

limiter = Limiter(key_func=get_remote_address, default_limits=["60/minute"])

app = FastAPI(title=settings.app_name)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(profile_router)
app.include_router(tracking_router)


@app.get("/health", tags=["meta"])
def health(request: Request) -> dict:
    return {"status": "ok", "app": settings.app_name}
