import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';

/// Wind-down soundscapes: looped ambient sounds with a sleep timer.
class SoundscapeScreen extends StatefulWidget {
  const SoundscapeScreen({super.key});

  @override
  State<SoundscapeScreen> createState() => _SoundscapeScreenState();
}

class _SoundscapeScreenState extends State<SoundscapeScreen> {
  final _player = AudioPlayer();

  String? _playing; // sound id or null
  int _timerMinutes = 0; // 0 = no timer
  Timer? _sleepTimer;

  static const _sounds = [
    ('rain', '🌧️'),
    ('waves', '🌊'),
    ('wind', '🍃'),
    ('stream', '💦'),
  ];

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle(String id) async {
    if (_playing == id) {
      setState(() => _playing = null);
      _sleepTimer?.cancel();
      try {
        await _player.stop();
      } catch (_) {}
      return;
    }
    setState(() => _playing = id);
    _armTimer();
    try {
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource('sounds/$id.wav'));
    } catch (e) {
      debugPrint('Soundscape playback failed: $e');
    }
  }

  void _setTimer(int minutes) {
    setState(() => _timerMinutes = minutes);
    _armTimer();
  }

  void _armTimer() {
    _sleepTimer?.cancel();
    if (_timerMinutes > 0 && _playing != null) {
      _sleepTimer = Timer(Duration(minutes: _timerMinutes), () async {
        if (!mounted) return;
        setState(() => _playing = null);
        try {
          await _player.stop();
        } catch (_) {}
      });
    }
  }

  String _name(AppLocalizations l10n, String id) => switch (id) {
        'rain' => l10n.soundRain,
        'waves' => l10n.soundWaves,
        'wind' => l10n.soundWind,
        _ => l10n.soundStream,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A2B4A), Color(0xFF0F1B33)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.soundsTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        l10n.soundsSubtitle,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  children: [
                    for (final (id, emoji) in _sounds)
                      _SoundTile(
                        emoji: emoji,
                        name: _name(l10n, id),
                        active: _playing == id,
                        onTap: () => _toggle(id),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Row(
                  children: [
                    const Icon(Icons.bedtime_rounded,
                        color: Colors.white60, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        children: [
                          for (final minutes in [0, 10, 20, 30])
                            ChoiceChip(
                              label: Text(minutes == 0
                                  ? l10n.soundsTimerOff
                                  : l10n.soundsTimerMinutes(minutes)),
                              selected: _timerMinutes == minutes,
                              onSelected: (_) => _setTimer(minutes),
                              labelStyle: TextStyle(
                                color: _timerMinutes == minutes
                                    ? const Color(0xFF0F1B33)
                                    : Colors.white70,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                              selectedColor: AppTheme.sunny,
                              backgroundColor: Colors.white10,
                              side: BorderSide.none,
                            ),
                        ],
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

class _SoundTile extends StatelessWidget {
  const _SoundTile({
    required this.emoji,
    required this.name,
    required this.active,
    required this.onTap,
  });

  final String emoji;
  final String name;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? Colors.white.withValues(alpha: 0.18) : Colors.white10,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: active
            ? const BorderSide(color: AppTheme.sunny, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 44)),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Icon(
              active
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_fill_rounded,
              color: active ? AppTheme.sunny : Colors.white38,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
