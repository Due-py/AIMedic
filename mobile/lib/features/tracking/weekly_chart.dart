import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'tracking_models.dart';

enum ChartMetric { water, sleep }

/// Bar color validated for chroma + 3:1 surface contrast per mode
/// (dataviz palette validator); do not swap for the raw theme seed.
const _barColorLight = Color(0xFF0E938C);
const _barColorDark = Color(0xFF2AA5A0);

class WeeklyChart extends StatelessWidget {
  const WeeklyChart({
    super.key,
    required this.logs,
    required this.metric,
    required this.endDate,
    this.target,
  });

  /// Logs within the 7-day window; missing days are rendered as zero.
  final List<DailyLog> logs;
  final ChartMetric metric;
  final DateTime endDate;

  /// Optional goal line (ml or hours, matching [metric]).
  final double? target;

  static const _weekdayVi = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  double _value(DailyLog log) => switch (metric) {
        ChartMetric.water => log.waterMl.toDouble(),
        ChartMetric.sleep => log.sleepHours ?? 0,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? _barColorDark : _barColorLight;
    final mutedInk = Theme.of(context).colorScheme.onSurfaceVariant;

    final byDate = {for (final log in logs) log.date: log};
    final days = [
      for (var i = 6; i >= 0; i--) endDate.subtract(Duration(days: i)),
    ];
    final values = [
      for (final day in days)
        byDate[isoDate(day)] == null ? 0.0 : _value(byDate[isoDate(day)]!),
    ];

    final maxValue = values.fold(0.0, (a, b) => a > b ? a : b);
    final maxY = [maxValue, target ?? 0].reduce((a, b) => a > b ? a : b) * 1.2;

    return AspectRatio(
      aspectRatio: 1.8,
      child: BarChart(
        BarChartData(
          maxY: maxY <= 0 ? 1 : maxY,
          barGroups: [
            for (var i = 0; i < 7; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: values[i],
                  width: 18,
                  color: barColor,
                  // Rounded data-end, flat baseline.
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ]),
          ],
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => value == 0 ||
                        value == meta.max
                    ? const SizedBox.shrink()
                    : Text(
                        value >= 1000
                            ? '${(value / 1000).toStringAsFixed(1)}k'
                            : value.toInt().toString(),
                        style: TextStyle(fontSize: 11, color: mutedInk),
                      ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _weekdayVi[days[value.toInt()].weekday - 1],
                    style: TextStyle(fontSize: 11, color: mutedInk),
                  ),
                ),
              ),
            ),
          ),
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: mutedInk.withValues(alpha: 0.15),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          extraLinesData: target == null
              ? null
              : ExtraLinesData(horizontalLines: [
                  HorizontalLine(
                    y: target!,
                    color: mutedInk,
                    strokeWidth: 1,
                    dashArray: [6, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      style: TextStyle(fontSize: 10, color: mutedInk),
                      labelResolver: (_) => l10n.chartTargetLine,
                    ),
                  ),
                ]),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                metric == ChartMetric.water
                    ? l10n.mlValue(rod.toY.toInt())
                    : l10n.hoursValue(rod.toY.toStringAsFixed(1)),
                Theme.of(context).textTheme.labelMedium!,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
