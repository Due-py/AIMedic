import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';
import '../profile/profile_models.dart';
import '../profile/profile_repository.dart';
import '../reminders/reminder_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _totalSteps = 4;

  final _pageController = PageController();
  final _basicsFormKey = GlobalKey<FormState>();
  final _bodyFormKey = GlobalKey<FormState>();

  int _step = 0;
  bool _saving = false;

  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  Gender _gender = Gender.male;
  ActivityLevel _activity = ActivityLevel.moderate;
  TimeOfDay _sleepTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 6, minute: 30);

  @override
  void dispose() {
    _pageController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  bool _validateStep() => switch (_step) {
        0 => _basicsFormKey.currentState!.validate(),
        1 => _bodyFormKey.currentState!.validate(),
        _ => true,
      };

  void _next() {
    if (!_validateStep()) return;
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
      _pageController.animateToPage(
        _step,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step == 0) return;
    setState(() => _step--);
    _pageController.animateToPage(
      _step,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final draft = ProfileDraft(
      age: int.parse(_ageController.text),
      gender: _gender,
      heightCm: double.parse(_heightController.text),
      weightKg: double.parse(_weightController.text),
      activityLevel: _activity,
      sleepTime: _formatTime(_sleepTime),
      wakeTime: _formatTime(_wakeTime),
    );

    setState(() => _saving = true);
    try {
      await ref.read(profileProvider.notifier).save(draft);
      final profile = ref.read(profileProvider);
      if (!mounted) return;
      if (profile.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profileSaveError)),
        );
        setState(() => _saving = false);
      } else {
        // Fire-and-forget: reminders must never block onboarding.
        ReminderService.instance.scheduleFromProfile(draft);
        context.go('/');
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileSaveError)),
      );
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.onboardingTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: (_step + 1) / _totalSteps),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                l10n.stepOf(_step + 1, _totalSteps),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _basicsStep(l10n),
                  _bodyStep(l10n),
                  _activityStep(l10n),
                  _sleepStep(l10n),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_step > 0)
                    TextButton(
                      onPressed: _saving ? null : _back,
                      child: Text(l10n.backButton),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _saving ? null : _next,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_step == _totalSteps - 1
                            ? l10n.finishButton
                            : l10n.nextButton),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _basicsStep(AppLocalizations l10n) {
    return _StepBody(
      emoji: '🙋',
      title: l10n.stepBasicsTitle,
      child: Form(
        key: _basicsFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.ageLabel),
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.fieldRequired;
                final age = int.tryParse(v);
                if (age == null || age < 6 || age > 19) return l10n.fieldInvalid;
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text(l10n.genderLabel),
            const SizedBox(height: 8),
            SegmentedButton<Gender>(
              segments: [
                ButtonSegment(
                  value: Gender.male,
                  label: Text(l10n.genderMale),
                  icon: const Icon(Icons.boy),
                ),
                ButtonSegment(
                  value: Gender.female,
                  label: Text(l10n.genderFemale),
                  icon: const Icon(Icons.girl),
                ),
              ],
              selected: {_gender},
              onSelectionChanged: (s) => setState(() => _gender = s.first),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bodyStep(AppLocalizations l10n) {
    String? numberValidator(String? v, double min, double max) {
      if (v == null || v.isEmpty) return l10n.fieldRequired;
      final value = double.tryParse(v);
      if (value == null || value <= min || value >= max) {
        return l10n.fieldInvalid;
      }
      return null;
    }

    return _StepBody(
      emoji: '📏',
      title: l10n.stepBodyTitle,
      child: Form(
        key: _bodyFormKey,
        child: Column(
          children: [
            TextFormField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.heightLabel,
                suffixText: 'cm',
              ),
              validator: (v) => numberValidator(v, 80, 220),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.weightLabel,
                suffixText: 'kg',
              ),
              validator: (v) => numberValidator(v, 15, 150),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activityStep(AppLocalizations l10n) {
    final options = [
      (ActivityLevel.sedentary, l10n.activitySedentary, l10n.activitySedentaryDesc),
      (ActivityLevel.light, l10n.activityLight, l10n.activityLightDesc),
      (ActivityLevel.moderate, l10n.activityModerate, l10n.activityModerateDesc),
      (ActivityLevel.active, l10n.activityActive, l10n.activityActiveDesc),
      (ActivityLevel.veryActive, l10n.activityVeryActive, l10n.activityVeryActiveDesc),
    ];
    return _StepBody(
      emoji: '🏃',
      title: l10n.stepActivityTitle,
      child: RadioGroup<ActivityLevel>(
        groupValue: _activity,
        onChanged: (v) => setState(() => _activity = v!),
        child: Column(
          children: [
            for (final (level, title, desc) in options)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: _activity == level
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.10)
                      : Theme.of(context).colorScheme.surface,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: _activity == level
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .outlineVariant
                              .withValues(alpha: 0.5),
                      width: _activity == level ? 2 : 1,
                    ),
                  ),
                  child: RadioListTile<ActivityLevel>(
                    value: level,
                    title: Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(desc),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sleepStep(AppLocalizations l10n) {
    Future<void> pick(bool isSleep) async {
      final picked = await showTimePicker(
        context: context,
        initialTime: isSleep ? _sleepTime : _wakeTime,
      );
      if (picked != null) {
        setState(() => isSleep ? _sleepTime = picked : _wakeTime = picked);
      }
    }

    Widget timeTile(IconData icon, Color color, String label, TimeOfDay t,
            VoidCallback onTap) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.5),
              ),
            ),
            child: ListTile(
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color),
            ),
            title: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            trailing: Text(
              _formatTime(t),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
              onTap: onTap,
            ),
          ),
        );

    return _StepBody(
      emoji: '😴',
      title: l10n.stepSleepTitle,
      child: Column(
        children: [
          timeTile(Icons.bedtime_rounded, AppTheme.lavender,
              l10n.sleepTimeLabel, _sleepTime, () => pick(true)),
          timeTile(Icons.wb_sunny_rounded, AppTheme.sunny, l10n.wakeTimeLabel,
              _wakeTime, () => pick(false)),
        ],
      ),
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({required this.title, required this.emoji, required this.child});

  final String title;
  final String emoji;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 44)),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}
