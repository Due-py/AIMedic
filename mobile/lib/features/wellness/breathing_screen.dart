import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';

/// "Calm corner": guided box breathing behind an animated bubble
/// (inhale 4s → hold 4s → exhale 4s), for 1–3 minutes.
class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

enum _Phase { inhale, hold, exhale }

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  static const _phaseSeconds = 4;

  late final AnimationController _bubble = AnimationController(
    vsync: this,
    duration: const Duration(seconds: _phaseSeconds),
  );

  int _minutes = 1;
  bool _running = false;
  bool _done = false;
  _Phase _phase = _Phase.inhale;
  int _secondsLeft = 0;
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    _bubble.dispose();
    super.dispose();
  }

  void _start() {
    setState(() {
      _running = true;
      _done = false;
      _secondsLeft = _minutes * 60;
      _phase = _Phase.inhale;
    });
    _bubble.forward(from: 0);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _stop({bool finished = false}) {
    _ticker?.cancel();
    _bubble.stop();
    setState(() {
      _running = false;
      _done = finished;
    });
  }

  void _tick() {
    if (_secondsLeft <= 1) {
      _stop(finished: true);
      return;
    }
    setState(() {
      _secondsLeft--;
      final elapsed = _minutes * 60 - _secondsLeft;
      final next = switch ((elapsed ~/ _phaseSeconds) % 3) {
        0 => _Phase.inhale,
        1 => _Phase.hold,
        _ => _Phase.exhale,
      };
      if (next != _phase) {
        _phase = next;
        switch (next) {
          case _Phase.inhale:
            _bubble.forward(from: 0);
          case _Phase.hold:
            _bubble.stop();
          case _Phase.exhale:
            _bubble.reverse(from: 1);
        }
      }
    });
  }

  String _phaseLabel(AppLocalizations l10n) => switch (_phase) {
        _Phase.inhale => l10n.breathingInhale,
        _Phase.hold => l10n.breathingHold,
        _Phase.exhale => l10n.breathingExhale,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      l10n.breathingTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.music_note_rounded,
                        color: Colors.white),
                    tooltip: l10n.soundsTitle,
                    onPressed: () => context.push('/sounds'),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _bubble,
                        builder: (context, _) {
                          final scale = 0.55 + 0.45 * _bubble.value;
                          return SizedBox(
                            width: 260,
                            height: 260,
                            child: Center(
                              child: Container(
                                width: 260 * scale,
                                height: 260 * scale,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      Colors.white.withValues(alpha: 0.22),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 190 * scale,
                                    height: 190 * scale,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white
                                          .withValues(alpha: 0.85),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _done ? '💚' : '🫧',
                                        style:
                                            const TextStyle(fontSize: 44),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 34),
                      Text(
                        _done
                            ? l10n.breathingDone
                            : _running
                                ? _phaseLabel(l10n)
                                : l10n.breathingSubtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (_running) ...[
                        const SizedBox(height: 10),
                        Text(
                          '${(_secondsLeft ~/ 60)}:${(_secondsLeft % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: Column(
                  children: [
                    if (!_running) ...[
                      SegmentedButton<int>(
                        style: SegmentedButton.styleFrom(
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.15),
                          foregroundColor: Colors.white,
                          selectedBackgroundColor: Colors.white,
                          selectedForegroundColor: AppTheme.teal,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        segments: [
                          for (final m in [1, 2, 3])
                            ButtonSegment(
                              value: m,
                              label: Text(l10n.breathingMinutes(m)),
                            ),
                        ],
                        selected: {_minutes},
                        onSelectionChanged: (s) =>
                            setState(() => _minutes = s.first),
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _running ? _stop : _start,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.teal,
                          minimumSize: const Size(0, 56),
                        ),
                        child: Text(
                          _running ? l10n.breathingStop : l10n.breathingStart,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
