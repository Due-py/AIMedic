"""Gemini-backed coach AI, behind a small protocol so tests can fake it."""

from typing import Protocol

from fastapi import HTTPException, status

from app.core.config import get_settings


class CoachAI(Protocol):
    def reply(self, system: str, history: list[dict], message: str) -> str: ...


class GeminiCoach:
    def __init__(self, api_key: str, model: str) -> None:
        from google import genai

        self._client = genai.Client(api_key=api_key)
        self._model = model

    def reply(self, system: str, history: list[dict], message: str) -> str:
        from google.genai import types

        contents = [
            types.Content(
                role="user" if m["role"] == "user" else "model",
                parts=[types.Part(text=m["content"])],
            )
            for m in history
        ]
        contents.append(
            types.Content(role="user", parts=[types.Part(text=message)])
        )
        response = self._client.models.generate_content(
            model=self._model,
            contents=contents,
            config=types.GenerateContentConfig(
                system_instruction=system,
                temperature=0.7,
                max_output_tokens=800,
                # Without this, "thinking" tokens eat into max_output_tokens
                # and replies get truncated mid-sentence.
                thinking_config=types.ThinkingConfig(thinking_budget=0),
            ),
        )
        return response.text or ""


_gemini: GeminiCoach | None = None


def get_coach_ai() -> CoachAI:
    global _gemini
    settings = get_settings()
    if not settings.gemini_api_key:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="AI service is not configured.",
        )
    if _gemini is None:
        _gemini = GeminiCoach(settings.gemini_api_key, settings.gemini_model)
    return _gemini
