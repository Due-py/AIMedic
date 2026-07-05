import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tracking_models.dart';
import 'tracking_repository.dart';

/// Persisted pedometer baseline. The device sensor reports steps
/// cumulatively since boot, so today's count is `reading - base`.
class StepBaseline {
  const StepBaseline({
    required this.date,
    required this.base,
    required this.last,
  });

  final String date; // day the baseline belongs to
  final int base; // sensor value corresponding to 0 steps today
  final int last; // last sensor value seen
}

/// Pure baseline update logic (unit-tested): handles new days and reboots.
(int todaySteps, StepBaseline next) applyReading(
  StepBaseline? stored,
  int reading,
  String today,
) {
  if (stored == null || stored.date != today) {
    // First reading of the day: steps taken before the app first ran
    // today are not counted (matches Google Fit-lite behaviour).
    // A reboot across midnight also lands here safely.
    final next = StepBaseline(date: today, base: reading, last: reading);
    return (0, next);
  }
  if (reading < stored.last) {
    // Device rebooted: the counter restarted near zero. Preserve the steps
    // already credited today by shifting the baseline.
    final creditedSoFar = stored.last - stored.base;
    final next = StepBaseline(
      date: today,
      base: reading - creditedSoFar,
      last: reading,
    );
    return (creditedSoFar, next);
  }
  final next = StepBaseline(date: today, base: stored.base, last: reading);
  return (reading - stored.base, next);
}

/// Today's live step count from the phone sensor; null when the sensor or
/// permission is unavailable (web, emulators, denied permission).
class StepCounter extends Notifier<int?> {
  static const _syncThreshold = 100; // steps between backend syncs

  StreamSubscription<StepCount>? _subscription;
  StepBaseline? _baseline;
  int _lastSynced = 0;

  @override
  int? build() {
    ref.onDispose(() => _subscription?.cancel());
    _start();
    return null;
  }

  Future<void> _start() async {
    if (kIsWeb) return;
    try {
      final permission = await Permission.activityRecognition.request();
      if (!permission.isGranted) return;

      final prefs = await SharedPreferences.getInstance();
      final date = prefs.getString('step_date');
      if (date != null) {
        _baseline = StepBaseline(
          date: date,
          base: prefs.getInt('step_base') ?? 0,
          last: prefs.getInt('step_last') ?? 0,
        );
      }

      _subscription = Pedometer.stepCountStream.listen(
        (event) => _onReading(event.steps),
        onError: (Object e) => debugPrint('Step sensor error: $e'),
      );
    } catch (e) {
      debugPrint('Step counting unavailable: $e');
    }
  }

  Future<void> _onReading(int reading) async {
    final today = ref.read(todayDateProvider);
    final (steps, next) = applyReading(_baseline, reading, today);
    _baseline = next;
    state = steps;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('step_date', next.date);
      await prefs.setInt('step_base', next.base);
      await prefs.setInt('step_last', next.last);
    } catch (_) {}

    // Throttled backend sync so a walk doesn't hammer the API.
    if (steps - _lastSynced >= _syncThreshold) {
      _lastSynced = steps;
      await ref
          .read(todayLogProvider.notifier)
          .patch(DailyLogPatch(steps: steps));
    }
  }
}

final stepCounterProvider =
    NotifierProvider<StepCounter, int?>(StepCounter.new);
