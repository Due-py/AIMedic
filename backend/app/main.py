from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware
from slowapi.util import get_remote_address

from app.core.config import get_settings
from app.core.firebase import init_firebase
from app.features.coach.router import router as coach_router
from app.features.gamification.router import router as gamification_router
from app.features.insights.router import router as insights_router
from app.features.pet.router import router as pet_router
from app.features.profile.router import router as profile_router
from app.features.tracking.router import router as tracking_router

settings = get_settings()

init_firebase()

# Disabled in dev/tests (DEBUG) so local iteration and the test suite are
# never throttled; production (DEBUG=false) enforces the global limit.
limiter = Limiter(
    key_func=get_remote_address,
    default_limits=["60/minute"],
    enabled=not settings.debug,
)

app = FastAPI(title=settings.app_name)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
app.add_middleware(SlowAPIMiddleware)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(profile_router)
app.include_router(tracking_router)
app.include_router(coach_router)
app.include_router(gamification_router)
app.include_router(insights_router)
app.include_router(pet_router)


@app.get("/health", tags=["meta"])
def health(request: Request) -> dict:
    return {"status": "ok", "app": settings.app_name}
