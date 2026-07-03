import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'insights_repository.dart';

class InsightsCard extends ConsumerWidget {
  const InsightsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(insightsProvider).value;
    // Hidden while loading, on error, or when there is no trend yet:
    // insights are encouragement, never a blocker or an empty nag.
    if (insights == null || insights.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.insightsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final insight in insights) _InsightRow(insight: insight),
          ],
        ),
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
      _ => null, // unknown id from a newer backend — skip gracefully
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final message = _message(l10n);
    if (message == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final (icon, color) = switch (insight.level) {
      'positive' => (Icons.celebration, scheme.primary),
      'warn' => (Icons.tips_and_updates, scheme.tertiary),
      _ => (Icons.info_outline, scheme.secondary),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
