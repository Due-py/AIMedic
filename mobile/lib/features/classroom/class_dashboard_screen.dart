import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets/soft_card.dart';
import '../../l10n/app_localizations.dart';
import 'classroom_models.dart';
import 'classroom_repository.dart';

/// Owner-only anonymous class aggregates (CLAUDE.md §10).
class ClassDashboardScreen extends ConsumerWidget {
  const ClassDashboardScreen({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dashboard = ref.watch(classDashboardProvider(code));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.classDashboardTitle)),
      body: switch (dashboard) {
        AsyncValue(:final value?) => _Dashboard(dashboard: value),
        AsyncValue(hasError: true) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.loadError, textAlign: TextAlign.center),
            ),
          ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.dashboard});

  final ClassDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Text(
            '${dashboard.name} · ${l10n.challengeMembers(dashboard.memberCount)}',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            l10n.classAnonymityNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        const SizedBox(height: 8),
        if (dashboard.locked)
          SoftCard(
            child: Row(
              children: [
                const Text('🔒', style: TextStyle(fontSize: 26)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(l10n.classLockedStats(dashboard.minMembers)),
                ),
              ],
            ),
          )
        else ...[
          _StatTile(
            emoji: '🙋',
            label: l10n.classActiveMembers,
            value: '${dashboard.activeMembers}/${dashboard.memberCount}',
            color: AppTheme.teal,
          ),
          _StatTile(
            emoji: '😴',
            label: l10n.classAvgSleep,
            value: dashboard.avgSleepHours == null
                ? null
                : l10n.hoursValue(dashboard.avgSleepHours!.toStringAsFixed(1)),
            color: AppTheme.lavender,
          ),
          _StatTile(
            emoji: '💧',
            label: l10n.classAvgWater,
            value: dashboard.avgWaterMl == null
                ? null
                : l10n.mlValue(dashboard.avgWaterMl!),
            color: AppTheme.sky,
          ),
          _StatTile(
            emoji: '👟',
            label: l10n.classAvgSteps,
            value: dashboard.avgSteps == null
                ? null
                : l10n.stepsValue(dashboard.avgSteps!),
            color: AppTheme.berry,
          ),
          _StatTile(
            emoji: '🏃',
            label: l10n.classAvgExercise,
            value: dashboard.avgExerciseMinutes == null
                ? null
                : l10n.minutesValue(dashboard.avgExerciseMinutes!),
            color: AppTheme.mint,
          ),
          _StatTile(
            emoji: '🙂',
            label: l10n.classAvgMood,
            value: dashboard.avgMood == null
                ? null
                : '${dashboard.avgMood}/5',
            color: AppTheme.sunny,
          ),
          _StatTile(
            emoji: '😮‍💨',
            label: l10n.classAvgStress,
            value: dashboard.avgStress == null
                ? null
                : '${dashboard.avgStress}/5',
            color: AppTheme.coral,
          ),
        ],
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  final String emoji;
  final String label;
  final String? value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SoftCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Text(
            value ?? l10n.classNoData,
            style: TextStyle(
              fontSize: value == null ? 13 : 18,
              fontWeight: FontWeight.w800,
              color: value == null
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
