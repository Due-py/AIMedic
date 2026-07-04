import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets/soft_card.dart';
import '../../l10n/app_localizations.dart';
import 'gamification_models.dart';
import 'gamification_repository.dart';

class GamificationCard extends ConsumerWidget {
  const GamificationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(gamificationProvider).value;
    if (value == null) return const SizedBox.shrink();
    return _CardBody(state: value);
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.state});

  final GamificationState state;

  static const _badgeIcons = {
    'first_log': Icons.flag_rounded,
    'streak_3': Icons.local_fire_department_rounded,
    'streak_7': Icons.whatshot_rounded,
    'water_10l': Icons.water_drop_rounded,
    'mood_5_days': Icons.emoji_emotions_rounded,
    'active_5_days': Icons.directions_run_rounded,
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

    return SoftCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF9B8CFF), Color(0xFF6C7BFF)],
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${state.level}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.levelLabel(state.level),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        l10n.xpProgress(state.xpIntoLevel, state.xpPerLevel),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (state.streakDays > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_fire_department_rounded,
                            size: 18, color: AppTheme.sunny),
                        const SizedBox(width: 4),
                        Text(
                          '${state.streakDays}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: LinearProgressIndicator(
                value: state.xpIntoLevel / state.xpPerLevel,
                minHeight: 10,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
                valueColor: const AlwaysStoppedAnimation(AppTheme.sunny),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final badge in state.badges)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withValues(alpha: badge.earned ? 0.24 : 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _badgeIcons[badge.id] ?? Icons.star_rounded,
                          size: 16,
                          color: Colors.white
                              .withValues(alpha: badge.earned ? 1 : 0.5),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _badgeName(l10n, badge.id),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white
                                .withValues(alpha: badge.earned ? 1 : 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
