from fastapi import APIRouter, Depends, HTTPException

from app.core.auth import get_current_uid
from app.features.profile import calculations as calc
from app.features.profile.repository import ProfileRepository, get_profile_repository
from app.features.profile.schemas import HealthTargets, ProfileIn, ProfileOut

router = APIRouter(prefix="/profile", tags=["profile"])


def _compute_targets(profile: ProfileIn) -> HealthTargets:
    bmi_value = calc.bmi(profile.weight_kg, profile.height_cm)
    sleep_min, sleep_max = calc.recommended_sleep_hours(profile.age)
    return HealthTargets(
        bmi=bmi_value,
        bmi_category=calc.bmi_category(bmi_value),
        daily_calories=calc.daily_calories(
            profile.weight_kg, profile.height_cm, profile.age,
            profile.gender, profile.activity_level,
        ),
        daily_water_ml=calc.daily_water_ml(profile.weight_kg, profile.activity_level),
        sleep_hours_min=sleep_min,
        sleep_hours_max=sleep_max,
    )


@router.put("", response_model=ProfileOut)
def upsert_profile(
    profile: ProfileIn,
    uid: str = Depends(get_current_uid),
    repo: ProfileRepository = Depends(get_profile_repository),
) -> ProfileOut:
    result = ProfileOut(**profile.model_dump(), targets=_compute_targets(profile))
    repo.save(uid, result.model_dump(mode="json"))
    return result


@router.get("", response_model=ProfileOut)
def get_profile(
    uid: str = Depends(get_current_uid),
    repo: ProfileRepository = Depends(get_profile_repository),
) -> ProfileOut:
    data = repo.get(uid)
    if data is None:
        raise HTTPException(status_code=404, detail="Profile not found.")
    return ProfileOut(**data)
