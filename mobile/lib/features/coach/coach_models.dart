class ChatMessage {
  const ChatMessage({required this.role, required this.content});

  final String role; // "user" | "assistant"
  final String content;

  bool get isUser => role == 'user';

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        role: json['role'] as String,
        content: json['content'] as String,
      );
}
