import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _CardBody extends StatefulWidget {
  const _CardBody({required this.state});

  final GamificationState state;

  @override
  State<_CardBody> createState() => _CardBodyState();
}

class _CardBodyState extends State<_CardBody> {
  final _confetti = ConfettiController(
    duration: const Duration(milliseconds: 1200),
  );

  GamificationState get state => widget.state;

  @override
  void didUpdateWidget(covariant _CardBody old) {
    super.didUpdateWidget(old);
    // Duolingo-style instant feedback: celebrate the moment a level is
    // gained or a new badge unlocks.
    if (state.level > old.state.level ||
        state.earnedBadges > old.state.earnedBadges) {
      _confetti.play();
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

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

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        _card(l10n),
        ConfettiWidget(
          confettiController: _confetti,
          blastDirection: math.pi / 2, // downward over the card
          numberOfParticles: 24,
          maxBlastForce: 18,
          minBlastForce: 6,
          gravity: 0.25,
          shouldLoop: false,
          colors: const [
            AppTheme.sunny,
            AppTheme.coral,
            AppTheme.mint,
            AppTheme.sky,
            Colors.white,
          ],
        ),
      ],
    );
  }

  Widget _card(AppLocalizations l10n) {
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
                        // A freeze quietly saved this streak.
                        if (state.streakFreezeUsed) ...[
                          const SizedBox(width: 4),
                          const Text('❄️', style: TextStyle(fontSize: 13)),
                        ],
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
