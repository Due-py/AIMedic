import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.trackingTitle)),
      body: Center(child: Text(l10n.comingSoon)),
    );
  }
}
