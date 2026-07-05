import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/soft_card.dart';
import '../../l10n/app_localizations.dart';
import 'insights_repository.dart';

/// Weekly AI-written recap; hidden until the backend has one this week.
class RecapCard extends ConsumerWidget {
  const RecapCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recap = ref.watch(recapProvider).value;
    if (recap == null || recap.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return SoftCard(
      color: scheme.primary.withValues(alpha: 0.07),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📬', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                l10n.recapTitle,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(recap, style: const TextStyle(height: 1.45)),
        ],
      ),
    );
  }
}
