from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    app_name: str = "AIMedic API"
    debug: bool = False
    gemini_api_key: str = ""
    gemini_model: str = "gemini-2.5-flash"
    firebase_credentials: str = ""
    cors_origins: str = "http://localhost:3000"
    # Audience timezone offset for "today" (Vietnam = UTC+7).
    app_tz_offset_minutes: int = 420

    @property
    def cors_origin_list(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()
