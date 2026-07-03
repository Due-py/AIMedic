import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../gamification/gamification_card.dart';
import '../insights/insights_card.dart';
import '../profile/profile_models.dart';
import '../profile/profile_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (profile.value != null)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: l10n.editProfileButton,
              onPressed: () => context.push('/onboarding'),
            ),
          if (Firebase.apps.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: l10n.logoutTooltip,
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) context.go('/login');
              },
            ),
        ],
      ),
      body: switch (profile) {
        AsyncValue(:final value?) => _Dashboard(profile: value),
        AsyncValue(hasValue: true) => _CreateProfilePrompt(l10n: l10n),
        AsyncValue(:final error?) => _LoadError(l10n: l10n, error: error, ref: ref),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.profile});

  final Profile profile;

  String _bmiText(AppLocalizations l10n) => switch (profile.targets.bmiCategory) {
        'underweight' => l10n.bmiUnderweight,
        'healthy' => l10n.bmiHealthy,
        'overweight' => l10n.bmiOverweight,
        _ => l10n.bmiObese,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final targets = profile.targets;
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.homeGreeting('bạn'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const GamificationCard(),
        const InsightsCard(),
        _TargetCard(
          icon: Icons.monitor_weight,
          title: l10n.bmiLabel,
          value: '${targets.bmi} · ${_bmiText(l10n)}',
        ),
        _TargetCard(
          icon: Icons.water_drop,
          title: l10n.waterTarget,
          value: l10n.waterValue(targets.dailyWaterMl),
        ),
        _TargetCard(
          icon: Icons.bedtime,
          title: l10n.sleepTarget,
          value: l10n.sleepValue(targets.sleepHoursMin, targets.sleepHoursMax),
        ),
        _TargetCard(
          icon: Icons.bolt,
          title: l10n.calorieTarget,
          value: l10n.calorieValue(targets.dailyCalories),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.medicalDisclaimer,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _TargetCard extends StatelessWidget {
  const _TargetCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(value),
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
            Icon(
              Icons.favorite,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(l10n.createProfilePrompt, textAlign: TextAlign.center),
            const SizedBox(height: 24),
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

class _LoadError extends StatelessWidget {
  const _LoadError({required this.l10n, required this.error, required this.ref});

  final AppLocalizations l10n;
  final Object error;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 64),
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
