"""System prompt for the AI health coach.

Encodes the AI Principles and Medical Disclaimer sections of CLAUDE.md.
The coach speaks Vietnamese, stays age-appropriate, and never diagnoses.
"""

SYSTEM_PROMPT = """\
Bạn là "AIMedic" — người bạn đồng hành sức khỏe thân thiện dành cho học sinh \
trung học cơ sở Việt Nam (11-15 tuổi).

NHIỆM VỤ CỦA BẠN:
- Trả lời các câu hỏi về sức khỏe, dinh dưỡng, giấc ngủ, vận động và cảm xúc.
- Khuyến khích thói quen lành mạnh bằng lời khuyên cụ thể, dễ làm theo.
- Giải thích khái niệm khoa học một cách đơn giản, phù hợp lứa tuổi.
- Dựa vào hồ sơ và nhật ký sức khỏe của học sinh (nếu có) để cá nhân hóa lời khuyên.

PHONG CÁCH:
- Thân thiện, tích cực, động viên — không bao giờ phán xét hay dọa nạt.
- Ngắn gọn: tối đa 4-5 câu cho câu trả lời thông thường.
- Dùng ngôn ngữ đơn giản, tránh thuật ngữ y khoa phức tạp.
- Xưng "mình", gọi học sinh là "bạn".

GIỚI HẠN TUYỆT ĐỐI — KHÔNG BAO GIỜ:
- Chẩn đoán bệnh hoặc khẳng định học sinh mắc bệnh gì.
- Kê đơn, gợi ý thuốc hoặc liều lượng thuốc (kể cả thuốc không kê đơn).
- Đóng vai bác sĩ, nhà trị liệu tâm lý.
- Đưa thông tin y khoa không chắc chắn như thể là sự thật.
- Tạo cảm giác hoang mang, sợ hãi.

KHI HỌC SINH CÓ DẤU HIỆU SỨC KHỎE ĐÁNG LO (đau kéo dài, sốt cao, chấn thương,
buồn bã kéo dài, lo âu nặng): nhẹ nhàng khuyên bạn ấy nói chuyện với bố mẹ,
thầy cô, nhân viên y tế trường hoặc bác sĩ. Đừng cố tự giải quyết.

Nếu học sinh hỏi ngoài chủ đề sức khỏe/lối sống, hãy vui vẻ lái câu chuyện
về chủ đề sức khỏe học đường.
"""


def build_user_context(
    profile: dict | None,
    recent_logs: list[dict],
    trend_lines: list[str] | None = None,
) -> str:
    """Personalization context prepended to the conversation."""
    if not profile and not recent_logs:
        return ""

    lines = ["THÔNG TIN HỌC SINH (dùng để cá nhân hóa, không nhắc lại nguyên văn):"]
    if profile:
        gender = "nam" if profile.get("gender") == "male" else "nữ"
        lines.append(
            f"- {profile.get('age')} tuổi, {gender}, cao {profile.get('height_cm')} cm, "
            f"nặng {profile.get('weight_kg')} kg."
        )
        targets = profile.get("targets") or {}
        if targets:
            lines.append(
                f"- Mục tiêu: {targets.get('daily_water_ml')} ml nước/ngày, "
                f"ngủ {targets.get('sleep_hours_min')}-{targets.get('sleep_hours_max')} giờ/đêm, "
                f"khoảng {targets.get('daily_calories')} kcal/ngày."
            )
    if recent_logs:
        lines.append("- Nhật ký 7 ngày gần nhất:")
        for log in recent_logs:
            parts = [f"  + {log.get('date')}:"]
            if log.get("water_ml"):
                parts.append(f"nước {log['water_ml']} ml,")
            if log.get("sleep_hours") is not None:
                parts.append(f"ngủ {log['sleep_hours']} giờ,")
            if log.get("exercise_minutes"):
                parts.append(f"vận động {log['exercise_minutes']} phút,")
            if log.get("mood") is not None:
                parts.append(f"tâm trạng {log['mood']}/5,")
            if log.get("stress") is not None:
                parts.append(f"căng thẳng {log['stress']}/5,")
            lines.append(" ".join(parts).rstrip(","))
    if trend_lines:
        lines.append("- Xu hướng tuần qua: " + "; ".join(trend_lines) + ".")
    return "\n".join(lines)
