import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../core/widgets/progress_ring.dart';
import '../../core/widgets/soft_card.dart';
import '../../l10n/app_localizations.dart';
import '../nutrition/meal_section.dart';
import '../profile/profile_repository.dart';
import 'step_counter.dart';
import 'tracking_models.dart';
import 'tracking_repository.dart';
import 'weekly_chart.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  ChartMetric _metric = ChartMetric.water;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final today = ref.watch(todayLogProvider);
    final week = ref.watch(weekLogsProvider);
    final targets = ref.watch(profileProvider).value?.targets;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayLogProvider);
          ref.invalidate(weekLogsProvider);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 20, 20, 24),
              decoration: const BoxDecoration(
                gradient: AppTheme.heroGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Text(
                '${l10n.trackingTitle} · ${l10n.todayTitle}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 4),
            switch (today) {
              AsyncValue(:final value?) => _TodayCard(
                  log: value,
                  waterTarget: targets?.dailyWaterMl,
                ),
              AsyncValue(:final error?) => _InlineError(l10n: l10n, error: error),
              _ => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
            },
            _SectionTitle('📊 ${l10n.weeklyTitle}'),
            SoftCard(
              child: Column(
                children: [
                  SegmentedButton<ChartMetric>(
                    segments: [
                      ButtonSegment(
                        value: ChartMetric.water,
                        label: Text(l10n.chartWater),
                        icon: const Icon(Icons.water_drop_rounded, size: 18),
                      ),
                      ButtonSegment(
                        value: ChartMetric.sleep,
                        label: Text(l10n.chartSleep),
                        icon: const Icon(Icons.bedtime_rounded, size: 18),
                      ),
                    ],
                    selected: {_metric},
                    onSelectionChanged: (s) => setState(() => _metric = s.first),
                  ),
                  const SizedBox(height: 18),
                  switch (week) {
                    AsyncValue(:final value?) => WeeklyChart(
                        logs: value,
                        metric: _metric,
                        endDate: DateTime.parse(ref.read(todayDateProvider)),
                        target: switch (_metric) {
                          ChartMetric.water => targets?.dailyWaterMl.toDouble(),
                          ChartMetric.sleep =>
                            targets?.sleepHoursMin.toDouble(),
                        },
                      ),
                    AsyncValue(:final error?) =>
                      _InlineError(l10n: l10n, error: error),
                    _ => const Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                  },
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 2),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.l10n, required this.error});

  final AppLocalizations l10n;
  final Object error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(l10n.loadError, textAlign: TextAlign.center),
    );
  }
}

class _TodayCard extends ConsumerWidget {
  const _TodayCard({required this.log, required this.waterTarget});

  final DailyLog log;
  final int? waterTarget;

  static const _moodEmojis = ['😢', '🙁', '😐', '🙂', '😄'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(todayLogProvider.notifier);
    final target = waterTarget ?? 2000;
    // Live sensor value (null on web/emulators) vs last synced/manual value.
    final liveSteps = ref.watch(stepCounterProvider);
    final steps = [log.steps, liveSteps ?? 0].reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        // Water hero with a ring + quick add.
        SoftCard(
          child: Row(
            children: [
              ProgressRing(
                progress: log.waterMl / target,
                color: AppTheme.sky,
                size: 84,
                center: const Icon(Icons.water_drop_rounded,
                    color: AppTheme.sky, size: 28),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.waterLog,
                        style: Theme.of(context).textTheme.labelLarge),
                    Text(
                      '${log.waterMl} / $target ml',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () => notifier.addWater(),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: Text(l10n.addCupButton),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.sky,
                        minimumSize: const Size(0, 44),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Quick log tiles.
        SoftCard(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              _NumberTile(
                icon: Icons.bedtime_rounded,
                color: AppTheme.lavender,
                title: l10n.sleepLog,
                value: log.sleepHours == null
                    ? null
                    : l10n.hoursValue(log.sleepHours!.toStringAsFixed(1)),
                onSave: (v) => notifier.patch(DailyLogPatch(sleepHours: v)),
                max: 24,
              ),
              _NumberTile(
                icon: Icons.directions_walk_rounded,
                color: AppTheme.berry,
                title: l10n.stepsLog,
                value: steps > 0 ? l10n.stepsValue(steps) : null,
                subtitleWhenEmpty: l10n.stepsAuto,
                onSave: (v) => notifier.patch(DailyLogPatch(steps: v.toInt())),
                max: 100000,
              ),
              _NumberTile(
                icon: Icons.directions_run_rounded,
                color: AppTheme.mint,
                title: l10n.exerciseLog,
                value: log.exerciseMinutes == 0
                    ? null
                    : l10n.minutesValue(log.exerciseMinutes),
                onSave: (v) =>
                    notifier.patch(DailyLogPatch(exerciseMinutes: v.toInt())),
                max: 1440,
              ),
              _NumberTile(
                icon: Icons.phone_android_rounded,
                color: AppTheme.coral,
                title: l10n.screenTimeLog,
                value: log.screenTimeMinutes == null
                    ? null
                    : l10n.minutesValue(log.screenTimeMinutes!),
                onSave: (v) =>
                    notifier.patch(DailyLogPatch(screenTimeMinutes: v.toInt())),
                max: 1440,
              ),
            ],
          ),
        ),
        MealSection(meals: log.meals),
        // Mood.
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.moodLog,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < 5; i++)
                    GestureDetector(
                      onTap: () => notifier.patch(DailyLogPatch(mood: i + 1)),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: log.mood == i + 1
                              ? AppTheme.sunny.withValues(alpha: 0.25)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _moodEmojis[i],
                          style: TextStyle(
                            fontSize: 30,
                            color: log.mood == null || log.mood == i + 1
                                ? null
                                : Colors.black.withValues(alpha: 0.25),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        // Stress.
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.stressLog,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  Text(
                    log.stress == null ? l10n.notLoggedYet : '${log.stress}/5',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Slider(
                value: (log.stress ?? 1).toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: l10n.stressLevelValue(log.stress ?? 1),
                // Persist once when the drag ends — avoids a request per tick.
                onChanged: (_) {},
                onChangeEnd: (v) =>
                    notifier.patch(DailyLogPatch(stress: v.toInt())),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  onPressed: () => context.push('/breathe'),
                  icon: const Text('😌', style: TextStyle(fontSize: 16)),
                  label: Text(l10n.breathingOpenButton),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NumberTile extends StatelessWidget {
  const _NumberTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.onSave,
    required this.max,
    this.subtitleWhenEmpty,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? value;
  final void Function(double) onSave;
  final double max;
  final String? subtitleWhenEmpty;

  Future<void> _edit(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancelButton),
          ),
          FilledButton(
            onPressed: () {
              final parsed = double.tryParse(controller.text);
              Navigator.pop(
                dialogContext,
                parsed != null && parsed >= 0 && parsed <= max ? parsed : null,
              );
            },
            child: Text(l10n.saveButton),
          ),
        ],
      ),
    );
    if (result != null) onSave(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(value ?? subtitleWhenEmpty ?? l10n.notLoggedYet),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => _edit(context),
    );
  }
}
