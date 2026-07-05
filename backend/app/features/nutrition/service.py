"""Gemini-vision meal analysis, behind a protocol so tests can fake it."""

import json
from typing import Protocol

from fastapi import HTTPException, status
from pydantic import BaseModel, Field

from app.core.config import get_settings

NUTRITION_PROMPT = """\
Bạn là trợ lý dinh dưỡng của AIMedic cho học sinh trung học Việt Nam.
Hãy nhìn ảnh và ước lượng món ăn trong ảnh.

- Ước lượng calo và chất dinh dưỡng cho KHẨU PHẦN trong ảnh (con số gần đúng).
- "comment": 1-2 câu tiếng Việt thân thiện, mang tính giáo dục, KHÔNG chê bai
  hay phán xét; có thể gợi ý nhẹ nhàng cách cân bằng bữa ăn.
- Nếu ảnh không phải đồ ăn/đồ uống: is_food=false, các số = 0, comment giải
  thích vui vẻ.
- Không chẩn đoán bệnh, không nói về giảm cân.
"""


class MealAnalysis(BaseModel):
    is_food: bool
    name: str = Field(max_length=80)
    calories: int = Field(ge=0, le=5_000)
    protein_g: int = Field(ge=0, le=500)
    carbs_g: int = Field(ge=0, le=500)
    fat_g: int = Field(ge=0, le=500)
    comment: str = Field(max_length=500)


class NutritionAI(Protocol):
    def analyze(self, image: bytes, mime: str, caption: str | None) -> MealAnalysis: ...


class GeminiNutrition:
    def __init__(self, api_key: str, model: str) -> None:
        from google import genai

        self._client = genai.Client(api_key=api_key)
        self._model = model

    def analyze(self, image: bytes, mime: str, caption: str | None) -> MealAnalysis:
        from google.genai import types

        parts = [types.Part.from_bytes(data=image, mime_type=mime)]
        if caption:
            parts.append(types.Part(text=f"Ghi chú của học sinh: {caption}"))

        response = self._client.models.generate_content(
            model=self._model,
            contents=[types.Content(role="user", parts=parts)],
            config=types.GenerateContentConfig(
                system_instruction=NUTRITION_PROMPT,
                response_mime_type="application/json",
                response_schema=MealAnalysis,
                temperature=0.4,
                thinking_config=types.ThinkingConfig(thinking_budget=0),
            ),
        )
        return MealAnalysis(**json.loads(response.text or "{}"))


_gemini: GeminiNutrition | None = None


def get_nutrition_ai() -> NutritionAI:
    global _gemini
    settings = get_settings()
    if not settings.gemini_api_key:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="AI service is not configured.",
        )
    if _gemini is None:
        _gemini = GeminiNutrition(settings.gemini_api_key, settings.gemini_model)
    return _gemini
