import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.homeGreeting('bạn'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          _TargetCard(icon: Icons.water_drop, title: l10n.waterTarget),
          _TargetCard(icon: Icons.bedtime, title: l10n.sleepTarget),
          _TargetCard(icon: Icons.bolt, title: l10n.calorieTarget),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.medicalDisclaimer,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetCard extends StatelessWidget {
  const _TargetCard({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(l10n.comingSoon),
      ),
    );
  }
}
