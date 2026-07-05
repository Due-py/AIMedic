import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme.dart';
import '../../core/widgets/soft_card.dart';
import '../../l10n/app_localizations.dart';
import '../tracking/tracking_repository.dart';
import 'nutrition_repository.dart';

/// Today's meals: chips of what's been logged plus the photo-analysis flow.
class MealSection extends ConsumerWidget {
  const MealSection({super.key, required this.meals});

  final List<String> meals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '🍜 ${l10n.mealsTitle}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: () => _pickAndAnalyze(context, ref),
                icon: const Icon(Icons.photo_camera_rounded, size: 18),
                label: Text(l10n.mealPhotoButton),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          if (meals.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final meal in meals)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppTheme.coral.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      meal,
                      style: const TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickAndAnalyze(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: Text(l10n.mealFromCamera),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(l10n.mealFromGallery),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return;

    final XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 70,
      );
    } catch (_) {
      return; // camera unavailable (emulator/web without webcam)
    }
    if (picked == null || !context.mounted) return;
    final bytes = await picked.readAsBytes();
    if (!context.mounted) return;

    // Blocking progress while Gemini looks at the photo.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 18),
            Expanded(child: Text(l10n.mealAnalyzing)),
          ],
        ),
      ),
    );

    MealAnalysis? analysis;
    try {
      analysis =
          await ref.read(nutritionRepositoryProvider).analyze(bytes);
    } catch (_) {
      analysis = null;
    }
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // close progress

    if (analysis == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.mealAnalyzeError)),
      );
      return;
    }

    // The backend logged the meal; refresh today's data.
    ref.invalidate(todayLogProvider);

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => MealResultSheet(analysis: analysis!),
    );
  }
}

class MealResultSheet extends StatelessWidget {
  const MealResultSheet({super.key, required this.analysis});

  final MealAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!analysis.isFood) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🤔', style: TextStyle(fontSize: 44)),
              const SizedBox(height: 12),
              Text(l10n.mealNotFood,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(analysis.comment, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              analysis.name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              '🔥 ${l10n.mealKcal(analysis.calories)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.coral,
              ),
            ),
            const SizedBox(height: 16),
            _MacroBar(
              label: l10n.mealProtein,
              grams: analysis.proteinG,
              color: AppTheme.mint,
              l10n: l10n,
            ),
            _MacroBar(
              label: l10n.mealCarbs,
              grams: analysis.carbsG,
              color: AppTheme.sunny,
              l10n: l10n,
            ),
            _MacroBar(
              label: l10n.mealFat,
              grams: analysis.fatG,
              color: AppTheme.lavender,
              l10n: l10n,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.mint.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(analysis.comment,
                  style: const TextStyle(height: 1.4)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.label,
    required this.grams,
    required this.color,
    required this.l10n,
  });

  final String label;
  final int grams;
  final Color color;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // Visual scale: 100g fills the bar.
    final fraction = (grams / 100).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 10,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 48,
            child: Text(
              l10n.mealGrams(grams),
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
