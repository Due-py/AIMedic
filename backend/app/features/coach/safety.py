"""Safety layer in front of the LLM.

Crisis messages get an immediate, caring canned response pointing to trusted
adults and the national child helpline — they are never sent to the model.

Two pattern tiers, because undiacritized Vietnamese is ambiguous:
- diacritic patterns match the lowercased original text ("tự tử" is
  unambiguous, but its stripped form "tu tu" collides with "từ từ" = "slowly",
  so it must NOT be matched without diacritics);
- normalized patterns match diacritic-stripped text, and only contain phrases
  that stay unambiguous without diacritics.
False negatives fall through to the model, whose system prompt also
escalates; false positives (a crisis reply to an innocent message) would
alarm a child, so ambiguous stripped forms are deliberately excluded.
"""

import re
import unicodedata

_CRISIS_PATTERNS_DIACRITIC = [
    r"tự\s*tử",
    r"tự\s*sát",
    r"tự\s*(làm\s*)?hại\s*bản\s*thân",
]

_CRISIS_PATTERNS_NORMALIZED = [
    # Vietnamese, unambiguous without diacritics
    r"ket\s*thuc\s*cuoc\s*(doi|song)",
    r"khong\s*muon\s*song",
    r"muon\s*chet",
    r"tu\s*sat",
    r"muon\s+tu\s*tu",       # "muốn tự tử" typed without diacritics
    r"tu\s*(cat|ranh)\s*(tay|minh)",
    # English
    r"suicide",
    r"kill\s*myself",
    r"self[\s-]*harm",
    r"end\s*my\s*life",
    r"hurt\s*myself",
]

CRISIS_RESPONSE = (
    "Mình rất tiếc khi bạn đang cảm thấy như vậy — cảm ơn bạn đã chia sẻ với mình. "
    "Điều này quan trọng hơn những gì mình có thể giúp, nên bạn hãy nói chuyện ngay "
    "với bố mẹ, thầy cô hoặc một người lớn mà bạn tin tưởng nhé. "
    "Bạn cũng có thể gọi Tổng đài Quốc gia Bảo vệ Trẻ em 111 (miễn phí, 24/7). "
    "Bạn không hề đơn độc đâu."
)


def _normalize(text: str) -> str:
    """Strip Vietnamese diacritics so patterns match undiacritized typing."""
    text = unicodedata.normalize("NFD", text)
    text = "".join(c for c in text if unicodedata.category(c) != "Mn")
    return text.replace("đ", "d")


def check_crisis(message: str) -> bool:
    lower = message.lower()
    if any(re.search(p, lower) for p in _CRISIS_PATTERNS_DIACRITIC):
        return True
    normalized = _normalize(lower)
    return any(re.search(p, normalized) for p in _CRISIS_PATTERNS_NORMALIZED)
