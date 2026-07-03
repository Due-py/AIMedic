import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import 'coach_models.dart';

class CoachRepository {
  CoachRepository(this._dio);

  final Dio _dio;

  Future<List<ChatMessage>> history() async {
    final resp = await _dio.get<List<dynamic>>('/coach/history');
    return resp.data!
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ChatMessage> send(String message) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '/coach/chat',
      data: {'message': message},
    );
    return ChatMessage(role: 'assistant', content: resp.data!['reply'] as String);
  }
}

final coachRepositoryProvider = Provider<CoachRepository>(
  (ref) => CoachRepository(ref.watch(apiClientProvider)),
);

/// True while a reply is being generated.
class CoachSendingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

final coachSendingProvider =
    NotifierProvider<CoachSendingNotifier, bool>(CoachSendingNotifier.new);

class ChatNotifier extends AsyncNotifier<List<ChatMessage>> {
  @override
  Future<List<ChatMessage>> build() =>
      ref.watch(coachRepositoryProvider).history();

  /// Sends [text]; returns false when the request failed (message kept
  /// locally so the student can retry).
  Future<bool> send(String text) async {
    final repo = ref.read(coachRepositoryProvider);
    final current = state.value ?? const <ChatMessage>[];
    state = AsyncData([...current, ChatMessage(role: 'user', content: text)]);
    ref.read(coachSendingProvider.notifier).set(true);
    try {
      final reply = await repo.send(text);
      state = AsyncData([...state.value!, reply]);
      return true;
    } catch (_) {
      return false;
    } finally {
      ref.read(coachSendingProvider.notifier).set(false);
    }
  }
}

final chatProvider =
    AsyncNotifierProvider<ChatNotifier, List<ChatMessage>>(ChatNotifier.new);
