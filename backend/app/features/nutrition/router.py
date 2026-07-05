import base64
import binascii
import logging

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field

from app.core.auth import get_current_uid
from app.core.dates import app_today
from app.core.ratelimit import PerUserLimiter
from app.features.nutrition.service import (
    MealAnalysis,
    NutritionAI,
    get_nutrition_ai,
)
from app.features.tracking.repository import (
    TrackingRepository,
    get_tracking_repository,
)

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/nutrition", tags=["nutrition"])

MAX_IMAGE_BYTES = 4 * 1024 * 1024
MAX_MEALS_PER_DAY = 10

# Vision calls are the most expensive request in the app.
_limiter = PerUserLimiter(limit=5)

_MAGIC = {
    b"\xff\xd8\xff": "image/jpeg",
    b"\x89PNG": "image/png",
    b"RIFF": "image/webp",
}


def _sniff_mime(image: bytes) -> str | None:
    for magic, mime in _MAGIC.items():
        if image.startswith(magic):
            return mime
    return None


class AnalyzeRequest(BaseModel):
    image_base64: str = Field(min_length=1)
    caption: str | None = Field(default=None, max_length=200)


@router.post("/analyze", response_model=MealAnalysis)
def analyze_meal(
    body: AnalyzeRequest,
    uid: str = Depends(get_current_uid),
    ai: NutritionAI = Depends(get_nutrition_ai),
    tracking: TrackingRepository = Depends(get_tracking_repository),
) -> MealAnalysis:
    _limiter.check(uid)

    try:
        image = base64.b64decode(body.image_base64, validate=True)
    except (binascii.Error, ValueError):
        raise HTTPException(status_code=422, detail="Invalid image encoding.")
    if len(image) > MAX_IMAGE_BYTES:
        raise HTTPException(status_code=413, detail="Image too large (max 4MB).")
    mime = _sniff_mime(image)
    if mime is None:
        raise HTTPException(
            status_code=422, detail="Unsupported image format (JPEG/PNG/WebP)."
        )

    try:
        analysis = ai.analyze(image, mime, body.caption)
    except HTTPException:
        raise
    except Exception:
        logger.exception("Meal analysis failed")
        raise HTTPException(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail="AI service is temporarily unavailable.",
        )

    # Log recognized food into today's meals so it counts toward the day.
    if analysis.is_food:
        today = app_today().isoformat()
        current = tracking.get(uid, today) or {}
        meals = list(current.get("meals") or [])
        if len(meals) < MAX_MEALS_PER_DAY:
            meals.append(f"{analysis.name} (~{analysis.calories} kcal)")
            tracking.merge(uid, today, {"meals": meals})

    return analysis
