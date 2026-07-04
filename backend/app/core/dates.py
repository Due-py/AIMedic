"""App-timezone date handling.

The app keys daily logs by the student's device-local date, while the server
may run in UTC (e.g. Render). "Today" must therefore be computed in the
app's audience timezone — Vietnam (UTC+7) by default, configurable via
APP_TZ_OFFSET_MINUTES — or logs written after 17:00 UTC would be invisible
to streaks, insights, and coach context until the next server-UTC day.
"""

from datetime import date, datetime, timedelta, timezone

from app.core.config import get_settings


def app_today() -> date:
    offset = timedelta(minutes=get_settings().app_tz_offset_minutes)
    return datetime.now(timezone(offset)).date()
