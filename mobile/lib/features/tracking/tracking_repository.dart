import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../gamification/gamification_repository.dart';
import '../insights/insights_repository.dart';
import '../pet/pet_repository.dart';
import 'tracking_models.dart';
import 'water_widget.dart';

class TrackingRepository {
  TrackingRepository(this._dio);

  final Dio _dio;

  Future<DailyLog> fetchDay(String date) async {
    final resp = await _dio.get<Map<String, dynamic>>('/logs/$date');
    return DailyLog.fromJson(resp.data!);
  }

  Future<List<DailyLog>> fetchRange(String start, String end) async {
    final resp = await _dio.get<List<dynamic>>(
      '/logs',
      queryParameters: {'start': start, 'end': end},
    );
    return resp.data!
        .map((e) => DailyLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DailyLog> patchDay(String date, DailyLogPatch patch) async {
    final resp = await _dio.put<Map<String, dynamic>>(
      '/logs/$date',
      data: patch.toJson(),
    );
    return DailyLog.fromJson(resp.data!);
  }

  Future<DailyLog> addWater(String date, {int amountMl = 250}) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '/logs/$date/water',
      data: {'amount_ml': amountMl},
    );
    return DailyLog.fromJson(resp.data!);
  }
}

final trackingRepositoryProvider = Provider<TrackingRepository>(
  (ref) => TrackingRepository(ref.watch(apiClientProvider)),
);

/// Today's date as YYYY-MM-DD; a provider so tests can freeze it.
/// Self-invalidates just past midnight so a long-running app never keeps
/// logging under yesterday's date.
final todayDateProvider = Provider<String>((ref) {
  final now = DateTime.now();
  final nextMidnight = DateTime(now.year, now.month, now.day + 1);
  final timer = Timer(
    nextMidnight.difference(now) + const Duration(seconds: 1),
    ref.invalidateSelf,
  );
  ref.onDispose(timer.cancel);
  return isoDate(now);
});

class TodayLogNotifier extends AsyncNotifier<DailyLog> {
  String get _date => ref.read(todayDateProvider);

  @override
  Future<DailyLog> build() =>
      ref.watch(trackingRepositoryProvider).fetchDay(_date);

  Future<void> patch(DailyLogPatch p) => _mutate(
      (repo) => repo.patchDay(_date, p));

  Future<void> addWater({int amountMl = 250}) => _mutate(
      (repo) => repo.addWater(_date, amountMl: amountMl));

  Future<void> _mutate(
      Future<DailyLog> Function(TrackingRepository repo) op) async {
    final repo = ref.read(trackingRepositoryProvider);
    state = await AsyncValue.guard(() => op(repo));
    // Logging affects the weekly chart, XP/streak/badges, trends and pet.
    ref.invalidate(weekLogsProvider);
    ref.invalidate(gamificationProvider);
    ref.invalidate(insightsProvider);
    ref.invalidate(petProvider);
    final water = state.value?.waterMl;
    if (water != null) updateWaterWidget(water);
  }
}

final todayLogProvider =
    AsyncNotifierProvider<TodayLogNotifier, DailyLog>(TodayLogNotifier.new);

/// Logs for the last 7 days (inclusive of today).
final weekLogsProvider = FutureProvider<List<DailyLog>>((ref) {
  final today = DateTime.parse(ref.watch(todayDateProvider));
  final start = isoDate(today.subtract(const Duration(days: 6)));
  return ref
      .watch(trackingRepositoryProvider)
      .fetchRange(start, isoDate(today));
});
