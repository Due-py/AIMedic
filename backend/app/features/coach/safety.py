"""Safety layer in front of the LLM.

Crisis messages get an immediate, caring canned response pointing to trusted
adults and the national child helpline — they are never sent to the model.
This is a narrow keyword net by design: false negatives fall through to the
model, whose system prompt also escalates; false positives would be worse.
"""

import re
import unicodedata

_CRISIS_PATTERNS = [
    # Vietnamese (matched without diacritics, see _normalize)
    r"tu\s*tu",            # tự tử
    r"tu\s*sat",           # tự sát
    r"ket\s*thuc\s*cuoc\s*(doi|song)",
    r"khong\s*muon\s*song",
    r"muon\s*chet",
    r"tu\s*(lam\s*)?hai\s*ban\s*than",
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
    """Lowercase and strip Vietnamese diacritics so patterns match any spelling."""
    text = unicodedata.normalize("NFD", text.lower())
    text = "".join(c for c in text if unicodedata.category(c) != "Mn")
    return text.replace("đ", "d")


def check_crisis(message: str) -> bool:
    normalized = _normalize(message)
    return any(re.search(p, normalized) for p in _CRISIS_PATTERNS)
