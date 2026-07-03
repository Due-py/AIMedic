import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'gamification_models.dart';
import 'gamification_repository.dart';

class GamificationCard extends ConsumerWidget {
  const GamificationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gamificationProvider);
    // Quietly hidden while loading or on error — gamification is a bonus,
    // never a blocker on the home screen.
    final value = state.value;
    if (value == null) return const SizedBox.shrink();
    return _CardBody(state: value);
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.state});

  final GamificationState state;

  static const _badgeIcons = {
    'first_log': Icons.flag,
    'streak_3': Icons.local_fire_department,
    'streak_7': Icons.whatshot,
    'water_10l': Icons.water_drop,
    'mood_5_days': Icons.emoji_emotions,
    'active_5_days': Icons.directions_run,
  };

  String _badgeName(AppLocalizations l10n, String id) => switch (id) {
        'first_log' => l10n.badgeFirstLog,
        'streak_3' => l10n.badgeStreak3,
        'streak_7' => l10n.badgeStreak7,
        'water_10l' => l10n.badgeWater10l,
        'mood_5_days' => l10n.badgeMood5Days,
        'active_5_days' => l10n.badgeActive5Days,
        _ => id,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  child: Text(
                    '${state.level}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.levelLabel(state.level),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        l10n.xpProgress(state.xpIntoLevel, state.xpPerLevel),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (state.streakDays > 0)
                  Chip(
                    avatar: const Icon(
                      Icons.local_fire_department,
                      size: 18,
                      color: Colors.deepOrange,
                    ),
                    label: Text(l10n.streakDays(state.streakDays)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: state.xpIntoLevel / state.xpPerLevel,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final badge in state.badges)
                  Chip(
                    avatar: Icon(
                      _badgeIcons[badge.id] ?? Icons.star,
                      size: 16,
                      color: badge.earned
                          ? scheme.primary
                          : scheme.onSurface.withValues(alpha: 0.3),
                    ),
                    label: Text(_badgeName(l10n, badge.id)),
                    labelStyle: badge.earned
                        ? null
                        : TextStyle(
                            color: scheme.onSurface.withValues(alpha: 0.4),
                          ),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
