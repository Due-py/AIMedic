import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';

class Insight {
  const Insight({required this.id, required this.level, this.value});

  final String id;
  final String level; // "positive" | "info" | "warn"
  final double? value;

  factory Insight.fromJson(Map<String, dynamic> json) => Insight(
        id: json['id'] as String,
        level: json['level'] as String,
        value: (json['value'] as num?)?.toDouble(),
      );
}

class InsightsRepository {
  InsightsRepository(this._dio);

  final Dio _dio;

  Future<List<Insight>> fetch() async {
    final resp = await _dio.get<List<dynamic>>('/insights');
    return resp.data!
        .map((e) => Insight.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final insightsRepositoryProvider = Provider<InsightsRepository>(
  (ref) => InsightsRepository(ref.watch(apiClientProvider)),
);

final insightsProvider = FutureProvider<List<Insight>>(
  (ref) => ref.watch(insightsRepositoryProvider).fetch(),
);
