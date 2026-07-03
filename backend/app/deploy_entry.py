"""Production entrypoint for Render (see render.yaml).

Render's free tier passes secrets as environment variables, not files, so
the Firebase service-account JSON arrives in FIREBASE_CREDENTIALS_JSON.
This shim materializes it to a file for firebase-admin, then starts uvicorn
on the port Render assigns.
"""

import os


def main() -> None:
    creds_json = os.environ.get("FIREBASE_CREDENTIALS_JSON", "")
    if creds_json and not os.environ.get("FIREBASE_CREDENTIALS"):
        path = "/tmp/firebase-credentials.json"
        with open(path, "w", encoding="utf-8") as f:
            f.write(creds_json)
        os.environ["FIREBASE_CREDENTIALS"] = path

    import uvicorn

    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=int(os.environ.get("PORT", "8000")),
    )


if __name__ == "__main__":
    main()
