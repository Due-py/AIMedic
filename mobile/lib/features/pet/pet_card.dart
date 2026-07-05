import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets/soft_card.dart';
import '../../l10n/app_localizations.dart';
import 'pet_models.dart';
import 'pet_repository.dart';

class PetCard extends ConsumerWidget {
  const PetCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pet = ref.watch(petProvider).value;
    if (pet == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final moodText = switch (pet.mood) {
      'happy' => l10n.petMoodHappy,
      'ok' => l10n.petMoodOk,
      _ => l10n.petMoodSleepy,
    };

    return SoftCard(
      child: Row(
        children: [
          _PetAvatar(pet: pet),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.petTitle,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.sunny.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 4),
                          Text(
                            '${pet.coins}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  moodText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonalIcon(
                    onPressed: () => _openShop(context, ref),
                    icon: const Text('🛍️', style: TextStyle(fontSize: 15)),
                    label: Text(l10n.petShopButton),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openShop(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _ShopSheet(),
    );
  }
}

class _PetAvatar extends StatelessWidget {
  const _PetAvatar({required this.pet});

  final PetState pet;

  // Rough emoji "slots" so worn accessories sit around the pet.
  static const _offsets = {
    'hat': Offset(2, -34),
    'crown': Offset(2, -34),
    'glasses': Offset(0, -6),
    'bow': Offset(-26, 22),
    'scarf': Offset(0, 26),
    'balloon': Offset(32, -22),
  };

  @override
  Widget build(BuildContext context) {
    final wornAccessories = pet.catalog
        .where((accessory) => pet.equipped.contains(accessory.id));
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.mint.withValues(alpha: 0.25),
            AppTheme.sky.withValues(alpha: 0.25),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Text(pet.stageEmoji, style: const TextStyle(fontSize: 52)),
          for (final accessory in wornAccessories)
            Transform.translate(
              offset: _offsets[accessory.id] ?? const Offset(28, 24),
              child: Text(accessory.emoji,
                  style: const TextStyle(fontSize: 22)),
            ),
        ],
      ),
    );
  }
}

class _ShopSheet extends ConsumerWidget {
  const _ShopSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final pet = ref.watch(petProvider).value;
    if (pet == null) return const SizedBox(height: 200);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.petShopTitle,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                Text('🪙 ${pet.coins}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16)),
              ],
            ),
            Text(
              l10n.petShopHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final accessory in pet.catalog)
                  _ShopItem(pet: pet, accessory: accessory),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopItem extends ConsumerWidget {
  const _ShopItem({required this.pet, required this.accessory});

  final PetState pet;
  final Accessory accessory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final owned = pet.owned.contains(accessory.id);
    final worn = pet.equipped.contains(accessory.id);
    final affordable = pet.coins >= accessory.price;
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 104,
      child: Material(
        color: worn
            ? scheme.primary.withValues(alpha: 0.12)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: worn
              ? BorderSide(color: scheme.primary, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: () async {
            final notifier = ref.read(petProvider.notifier);
            if (owned) {
              await notifier.toggleEquip(accessory.id);
            } else {
              final ok = await notifier.buy(accessory.id);
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.petNotEnoughCoins)),
                );
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Text(accessory.emoji, style: const TextStyle(fontSize: 30)),
                const SizedBox(height: 6),
                Text(
                  owned
                      ? (worn ? l10n.petWearing : l10n.petOwned)
                      : l10n.petBuy(accessory.price),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: owned
                        ? scheme.primary
                        : affordable
                            ? scheme.onSurface
                            : scheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
