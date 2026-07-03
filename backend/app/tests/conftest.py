"""Keep the test suite hermetic: no Firebase, no Gemini, regardless of .env.

Must run before app.main is imported (pytest loads conftest first).
"""

import os

os.environ["FIREBASE_CREDENTIALS"] = ""
os.environ["GEMINI_API_KEY"] = ""
os.environ["DEBUG"] = "true"
