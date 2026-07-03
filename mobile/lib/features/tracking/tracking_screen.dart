import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../profile/profile_repository.dart';
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
      appBar: AppBar(title: Text(l10n.trackingTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayLogProvider);
          ref.invalidate(weekLogsProvider);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _SectionTitle(l10n.todayTitle),
            switch (today) {
              AsyncValue(:final value?) => _TodayCard(log: value),
              AsyncValue(:final error?) =>
                _InlineError(l10n: l10n, error: error),
              _ => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                ),
            },
            _SectionTitle(l10n.weeklyTitle),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SegmentedButton<ChartMetric>(
                      segments: [
                        ButtonSegment(
                          value: ChartMetric.water,
                          label: Text(l10n.chartWater),
                          icon: const Icon(Icons.water_drop, size: 18),
                        ),
                        ButtonSegment(
                          value: ChartMetric.sleep,
                          label: Text(l10n.chartSleep),
                          icon: const Icon(Icons.bedtime, size: 18),
                        ),
                      ],
                      selected: {_metric},
                      onSelectionChanged: (s) =>
                          setState(() => _metric = s.first),
                    ),
                    const SizedBox(height: 16),
                    switch (week) {
                      AsyncValue(:final value?) => WeeklyChart(
                          logs: value,
                          metric: _metric,
                          endDate: DateTime.parse(ref.read(todayDateProvider)),
                          target: switch (_metric) {
                            ChartMetric.water =>
                              targets?.dailyWaterMl.toDouble(),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
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
  const _TodayCard({required this.log});

  final DailyLog log;

  static const _moodEmojis = ['😞', '🙁', '😐', '🙂', '😄'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(todayLogProvider.notifier);

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.water_drop),
            title: Text(l10n.waterLog),
            subtitle: Text(l10n.mlValue(log.waterMl)),
            trailing: FilledButton.tonal(
              onPressed: () => notifier.addWater(),
              child: Text(l10n.addCupButton),
            ),
          ),
          _NumberTile(
            icon: Icons.bedtime,
            title: l10n.sleepLog,
            value: log.sleepHours == null
                ? null
                : l10n.hoursValue(log.sleepHours!.toStringAsFixed(1)),
            onSave: (v) => notifier.patch(DailyLogPatch(sleepHours: v)),
            max: 24,
          ),
          _NumberTile(
            icon: Icons.directions_run,
            title: l10n.exerciseLog,
            value: log.exerciseMinutes == 0
                ? null
                : l10n.minutesValue(log.exerciseMinutes),
            onSave: (v) =>
                notifier.patch(DailyLogPatch(exerciseMinutes: v.toInt())),
            max: 1440,
          ),
          _NumberTile(
            icon: Icons.phone_android,
            title: l10n.screenTimeLog,
            value: log.screenTimeMinutes == null
                ? null
                : l10n.minutesValue(log.screenTimeMinutes!),
            onSave: (v) =>
                notifier.patch(DailyLogPatch(screenTimeMinutes: v.toInt())),
            max: 1440,
          ),
          ListTile(
            leading: const Icon(Icons.emoji_emotions),
            title: Text(l10n.moodLog),
            subtitle: Row(
              children: [
                for (var i = 0; i < 5; i++)
                  IconButton(
                    onPressed: () =>
                        notifier.patch(DailyLogPatch(mood: i + 1)),
                    icon: Text(
                      _moodEmojis[i],
                      style: TextStyle(
                        fontSize: 22,
                        color: log.mood == i + 1
                            ? null
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.35),
                      ),
                    ),
                    isSelected: log.mood == i + 1,
                  ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.spa),
            title: Text(l10n.stressLog),
            subtitle: Slider(
              value: (log.stress ?? 1).toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: l10n.stressLevelValue(log.stress ?? 1),
              onChanged: (v) => notifier.patch(DailyLogPatch(stress: v.toInt())),
            ),
            trailing: Text(
              log.stress == null ? l10n.notLoggedYet : '${log.stress}/5',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tile that opens a number-input dialog on tap.
class _NumberTile extends StatelessWidget {
  const _NumberTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onSave,
    required this.max,
  });

  final IconData icon;
  final String title;
  final String? value;
  final void Function(double) onSave;
  final double max;

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
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value ?? l10n.notLoggedYet),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _edit(context),
    );
  }
}
