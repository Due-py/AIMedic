import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets/soft_card.dart';
import '../../l10n/app_localizations.dart';
import 'challenge_models.dart';
import 'challenge_repository.dart';

class ChallengeCard extends ConsumerWidget {
  const ChallengeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenges = ref.watch(challengesProvider).value;
    // Hidden while loading/on error; shows an invite when there are none.
    if (challenges == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🤝', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.challengeTitle,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              TextButton(
                onPressed: () => _joinDialog(context, ref),
                child: Text(l10n.challengeJoinButton),
              ),
              TextButton(
                onPressed: () => _createSheet(context, ref),
                child: Text(l10n.challengeCreateButton),
              ),
            ],
          ),
          if (challenges.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.challengeEmpty,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            )
          else
            for (final challenge in challenges)
              _ChallengeRow(challenge: challenge),
        ],
      ),
    );
  }

  Future<void> _joinDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.challengeJoinButton),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 6,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(labelText: l10n.challengeCodeLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: Text(l10n.challengeJoinButton),
          ),
        ],
      ),
    );
    if (code == null || code.length != 6 || !context.mounted) return;
    try {
      await ref.read(challengeRepositoryProvider).join(code);
      ref.invalidate(challengesProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.challengeJoinError)),
        );
      }
    }
  }

  Future<void> _createSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _CreateChallengeSheet(),
    );
  }
}

class _ChallengeRow extends ConsumerWidget {
  const _ChallengeRow({required this.challenge});

  final Challenge challenge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  challenge.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '${l10n.challengeMembers(challenge.memberCount)} · '
                '${l10n.challengeDaysLeft(challenge.daysLeft)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: LinearProgressIndicator(
              value: challenge.progress,
              minHeight: 12,
              backgroundColor: AppTheme.mint.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(
                challenge.completed ? AppTheme.sunny : AppTheme.mint,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  challenge.completed
                      ? l10n.challengeCompleted
                      : '${challenge.total} / ${challenge.goal}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: challenge.completed ? AppTheme.coral : null,
                  ),
                ),
              ),
              Text(
                '${l10n.challengeMyPart(challenge.myContribution)} · '
                '${l10n.challengeShareCode(challenge.code)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 11.5,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreateChallengeSheet extends ConsumerStatefulWidget {
  const _CreateChallengeSheet();

  @override
  ConsumerState<_CreateChallengeSheet> createState() =>
      _CreateChallengeSheetState();
}

class _CreateChallengeSheetState extends ConsumerState<_CreateChallengeSheet> {
  final _nameController = TextEditingController();
  final _goalController = TextEditingController();
  String _metric = 'water_ml';
  bool _busy = false;

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    final goal = int.tryParse(_goalController.text);
    if (name.isEmpty || goal == null || goal <= 0) return;

    setState(() => _busy = true);
    try {
      await ref.read(challengeRepositoryProvider).create(
            name: name,
            metric: _metric,
            goal: goal,
          );
      ref.invalidate(challengesProvider);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.challengeCreateError)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.challengeCreateButton,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            maxLength: 40,
            decoration: InputDecoration(labelText: l10n.challengeNameLabel),
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: 'water_ml',
                label: Text(l10n.challengeMetricWater),
              ),
              ButtonSegment(
                value: 'steps',
                label: Text(l10n.challengeMetricSteps),
              ),
              ButtonSegment(
                value: 'logged_days',
                label: Text(l10n.challengeMetricDays),
              ),
            ],
            selected: {_metric},
            onSelectionChanged: (s) => setState(() => _metric = s.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _goalController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: l10n.challengeGoalLabel),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _create,
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.challengeCreateButton),
          ),
        ],
      ),
    );
  }
}
