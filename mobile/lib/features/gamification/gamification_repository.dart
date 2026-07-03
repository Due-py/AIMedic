import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import 'gamification_models.dart';

class GamificationRepository {
  GamificationRepository(this._dio);

  final Dio _dio;

  Future<GamificationState> fetch() async {
    final resp = await _dio.get<Map<String, dynamic>>('/gamification');
    return GamificationState.fromJson(resp.data!);
  }
}

final gamificationRepositoryProvider = Provider<GamificationRepository>(
  (ref) => GamificationRepository(ref.watch(apiClientProvider)),
);

final gamificationProvider = FutureProvider<GamificationState>(
  (ref) => ref.watch(gamificationRepositoryProvider).fetch(),
);
