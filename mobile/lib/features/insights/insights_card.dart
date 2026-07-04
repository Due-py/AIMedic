import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets/soft_card.dart';
import '../../l10n/app_localizations.dart';
import 'insights_repository.dart';

class InsightsCard extends ConsumerWidget {
  const InsightsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(insightsProvider).value;
    if (insights == null || insights.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                l10n.insightsTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final insight in insights) _InsightRow(insight: insight),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.insight});

  final Insight insight;

  String? _message(AppLocalizations l10n) {
    final value = insight.value;
    String num(double v) =>
        v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
    return switch (insight.id) {
      'sleep_debt' when value != null => l10n.insightSleepDebt(num(value)),
      'sleep_good' when value != null => l10n.insightSleepGood(num(value)),
      'low_water' when value != null => l10n.insightLowWater(num(value)),
      'water_good' when value != null => l10n.insightWaterGood(num(value)),
      'high_screen_time' when value != null =>
        l10n.insightHighScreenTime(num(value)),
      'high_stress' => l10n.insightHighStress,
      'low_exercise' => l10n.insightLowExercise,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final message = _message(l10n);
    if (message == null) return const SizedBox.shrink();

    final (icon, color) = switch (insight.level) {
      'positive' => (Icons.celebration_rounded, AppTheme.mint),
      'warn' => (Icons.tips_and_updates_rounded, AppTheme.sunny),
      _ => (Icons.info_rounded, AppTheme.sky),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 19, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(message, style: const TextStyle(height: 1.35)),
            ),
          ),
        ],
      ),
    );
  }
}
