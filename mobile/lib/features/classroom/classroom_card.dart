import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/soft_card.dart';
import '../../l10n/app_localizations.dart';
import 'classroom_repository.dart';

class ClassroomCard extends ConsumerWidget {
  const ClassroomCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classes = ref.watch(myClassesProvider).value;
    if (classes == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏫', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.classTitle,
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
                onPressed: () => _createDialog(context, ref),
                child: Text(l10n.challengeCreateButton),
              ),
            ],
          ),
          if (classes.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.classEmpty,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            )
          else
            for (final cls in classes)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Row(
                  children: [
                    Text(cls.name,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    if (cls.isOwner) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          l10n.classOwnerBadge,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: Text(
                  '${l10n.challengeMembers(cls.memberCount)} · '
                  '${l10n.challengeShareCode(cls.code)}',
                ),
                trailing: cls.isOwner
                    ? FilledButton.tonal(
                        onPressed: () =>
                            context.push('/class/${cls.code}/dashboard'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 38),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: Text(l10n.classViewStats),
                      )
                    : null,
              ),
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
      await ref.read(classroomRepositoryProvider).join(code);
      ref.invalidate(myClassesProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.classJoinError)),
        );
      }
    }
  }

  Future<void> _createDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.challengeCreateButton),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 40,
          decoration: InputDecoration(labelText: l10n.classNameLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: Text(l10n.challengeCreateButton),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || !context.mounted) return;
    try {
      await ref.read(classroomRepositoryProvider).create(name);
      ref.invalidate(myClassesProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.challengeCreateError)),
        );
      }
    }
  }
}
