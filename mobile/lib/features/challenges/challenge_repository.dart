import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import 'challenge_models.dart';

class ChallengeRepository {
  ChallengeRepository(this._dio);

  final Dio _dio;

  Future<List<Challenge>> mine() async {
    final resp = await _dio.get<List<dynamic>>('/challenges');
    return resp.data!
        .map((e) => Challenge.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Challenge> create({
    required String name,
    required String metric,
    required int goal,
  }) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '/challenges',
      data: {'name': name, 'metric': metric, 'goal': goal},
    );
    return Challenge.fromJson(resp.data!);
  }

  Future<Challenge> join(String code) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '/challenges/join',
      data: {'code': code},
    );
    return Challenge.fromJson(resp.data!);
  }
}

final challengeRepositoryProvider = Provider<ChallengeRepository>(
  (ref) => ChallengeRepository(ref.watch(apiClientProvider)),
);

final challengesProvider = FutureProvider<List<Challenge>>(
  (ref) => ref.watch(challengeRepositoryProvider).mine(),
);
