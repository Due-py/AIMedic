# AIMedic — AI School Health Coach

AI health companion for middle school students (Samsung Solve for Tomorrow).
Full product spec: [CLAUDE.md](CLAUDE.md) · Development plan phases: profile → tracking → AI coach → reminders/gamification → insights → beta.

## Structure

- `backend/` — Python FastAPI API (health engine, AI coach, Firestore access)
- `mobile/` — Flutter app (Material 3, Vietnamese-first)
- `docs/` — competition documents

## Backend — quick start

```bash
cd backend
python -m venv .venv
.venv/Scripts/pip install -r requirements.txt   # Windows
cp .env.example .env                            # fill in keys later; DEBUG=true works without them
.venv/Scripts/python -m uvicorn app.main:app --reload
# → http://localhost:8000/docs
```

Tests: `.venv/Scripts/python -m pytest app/tests`

Without Firebase credentials and with `DEBUG=true`, the API runs in dev mode
(auth as `dev-user`, in-memory storage) so you can develop before the Firebase
project exists.

## Mobile — quick start

```bash
cd mobile
flutter pub get
flutter gen-l10n
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000   # Android emulator → local backend
```

Checks: `flutter analyze` and `flutter test`

## Pending setup (one-time, needs console access)

1. Create the Firebase project (Auth + Firestore, Spark plan) and download the
   service-account JSON → `backend/serviceAccountKey.json` (gitignored).
2. `dart pub global activate flutterfire_cli && flutterfire configure` in `mobile/`,
   then enable `Firebase.initializeApp` in `lib/main.dart`.
3. Get a Gemini API key (https://aistudio.google.com/apikey) → `backend/.env`.
4. Deploy the backend to Render/Railway free tier.
