import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../core/widgets/gradient_header.dart';
import '../../core/widgets/progress_ring.dart';
import '../../core/widgets/soft_card.dart';
import '../../l10n/app_localizations.dart';
import '../gamification/gamification_card.dart';
import '../insights/insights_card.dart';
import '../pet/pet_card.dart';
import '../tracking/tracking_repository.dart';
import '../profile/profile_models.dart';
import '../profile/profile_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(profileProvider);

    return Scaffold(
      body: switch (profile) {
        AsyncValue(:final value?) => _Dashboard(profile: value),
        AsyncValue(hasValue: true) => _CreateProfilePrompt(l10n: l10n),
        AsyncValue(:final error?) => _LoadError(l10n: l10n, error: error),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Dashboard extends ConsumerWidget {
  const _Dashboard({required this.profile});

  final Profile profile;

  String _bmiText(AppLocalizations l10n) => switch (profile.targets.bmiCategory) {
        'underweight' => l10n.bmiUnderweight,
        'healthy' => l10n.bmiHealthy,
        'overweight' => l10n.bmiOverweight,
        _ => l10n.bmiObese,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final targets = profile.targets;
    final today = ref.watch(todayLogProvider).value;

    final waterProgress =
        today == null ? 0.0 : today.waterMl / targets.dailyWaterMl;
    final sleepProgress = today?.sleepHours == null
        ? 0.0
        : today!.sleepHours! / targets.sleepHoursMax;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(profileProvider);
        ref.invalidate(todayLogProvider);
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          GradientHeader(
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                tooltip: l10n.editProfileButton,
                onPressed: () => context.push('/onboarding'),
              ),
              if (Firebase.apps.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  tooltip: l10n.logoutTooltip,
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) context.go('/login');
                  },
                ),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('👋', style: const TextStyle(fontSize: 34)),
                const SizedBox(height: 6),
                Text(
                  l10n.homeGreeting('bạn'),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _HeaderRing(
                      progress: sleepProgress,
                      icon: Icons.bedtime_rounded,
                      label: l10n.sleepTarget,
                    ),
                    _HeaderRing(
                      progress: waterProgress,
                      icon: Icons.water_drop_rounded,
                      label: l10n.waterTarget,
                    ),
                    _HeaderRing(
                      progress: targets.bmiCategory == 'healthy' ? 1.0 : 0.6,
                      icon: Icons.favorite_rounded,
                      label: l10n.bmiLabel,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const PetCard(),
          const GamificationCard(),
          const InsightsCard(),
          _StatCard(
            icon: Icons.monitor_weight_rounded,
            color: AppTheme.lavender,
            title: l10n.bmiLabel,
            value: '${targets.bmi}',
            subtitle: _bmiText(l10n),
          ),
          _StatCard(
            icon: Icons.water_drop_rounded,
            color: AppTheme.sky,
            title: l10n.waterTarget,
            value: '${targets.dailyWaterMl}',
            subtitle: 'ml / ngày',
          ),
          _StatCard(
            icon: Icons.bedtime_rounded,
            color: AppTheme.lavender,
            title: l10n.sleepTarget,
            value: '${targets.sleepHoursMin}–${targets.sleepHoursMax}',
            subtitle: 'giờ / đêm',
          ),
          _StatCard(
            icon: Icons.local_fire_department_rounded,
            color: AppTheme.coral,
            title: l10n.calorieTarget,
            value: '${targets.dailyCalories}',
            subtitle: 'kcal / ngày',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Text(
              l10n.medicalDisclaimer,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderRing extends StatelessWidget {
  const _HeaderRing({
    required this.progress,
    required this.icon,
    required this.label,
  });

  final double progress;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProgressRing(
          progress: progress,
          color: Colors.white,
          size: 76,
          stroke: 8,
          center: Icon(icon, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 88,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateProfilePrompt extends StatelessWidget {
  const _CreateProfilePrompt({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.heroGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_rounded,
                  size: 56, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.createProfilePrompt,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () => context.push('/onboarding'),
              child: Text(l10n.createProfileButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadError extends ConsumerWidget {
  const _LoadError({required this.l10n, required this.error});

  final AppLocalizations l10n;
  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 64),
            const SizedBox(height: 16),
            Text(l10n.loadError, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => ref.invalidate(profileProvider),
              child: Text(l10n.retryButton),
            ),
          ],
        ),
      ),
    );
  }
}
