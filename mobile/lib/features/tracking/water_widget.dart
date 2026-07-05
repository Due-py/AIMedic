import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Keeps the Android home-screen widget in sync with today's water total.
/// Failures are swallowed — the widget is a bonus, never a blocker.
Future<void> updateWaterWidget(int todayMl) async {
  if (kIsWeb) return;
  try {
    await HomeWidget.saveWidgetData<String>('water_text', '💧 $todayMl ml');
    await HomeWidget.updateWidget(name: 'WaterWidgetProvider');
  } catch (e) {
    debugPrint('Water widget update failed: $e');
  }
}

/// True when [uri] is the widget's quick-log deep link.
bool isWaterWidgetUri(Uri? uri) => uri?.scheme == 'aimedic' && uri?.host == 'water';
