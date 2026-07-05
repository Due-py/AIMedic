import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:home_widget/home_widget.dart';

import '../features/tracking/tracking_repository.dart';
import '../features/tracking/water_widget.dart';

import '../features/auth/auth_screen.dart';
import '../features/classroom/class_dashboard_screen.dart';
import '../features/coach/coach_screen.dart';
import '../features/intro/intro_gate.dart';
import '../features/intro/intro_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/posture/posture_screen.dart';
import '../features/tracking/tracking_screen.dart';
import '../features/wellness/breathing_screen.dart';
import '../features/wellness/soundscape_screen.dart';
import '../l10n/app_localizations.dart';

final router = GoRouter(
  initialLocation: '/',
  // Auth is enforced only when Firebase is configured; tests and desktop
  // dev builds run without it and skip sign-in entirely.
  redirect: (context, state) {
    // First launch: show the welcome intro before anything else.
    if (!IntroGate.seen) {
      return state.matchedLocation == '/intro' ? null : '/intro';
    }
    if (state.matchedLocation == '/intro') return '/';

    if (Firebase.apps.isEmpty) return null;
    final signedIn = FirebaseAuth.instance.currentUser != null;
    final onAuthScreen = state.matchedLocation == '/login';
    if (!signedIn && !onAuthScreen) return '/login';
    if (signedIn && onAuthScreen) return '/';
    return null;
  },
  routes: [
    GoRoute(
      path: '/intro',
      builder: (_, _) => const IntroScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (_, _) => const AuthScreen(),
    ),
    GoRoute(
      path: '/breathe',
      builder: (_, _) => const BreathingScreen(),
    ),
    GoRoute(
      path: '/posture',
      builder: (_, _) => const PostureScreen(),
    ),
    GoRoute(
      path: '/sounds',
      builder: (_, _) => const SoundscapeScreen(),
    ),
    GoRoute(
      path: '/class/:code/dashboard',
      builder: (_, state) =>
          ClassDashboardScreen(code: state.pathParameters['code']!),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (_, _) => const OnboardingScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _AppShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/tracking', builder: (_, _) => const TrackingScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/coach', builder: (_, _) => const CoachScreen()),
        ]),
      ],
    ),
  ],
);

class _AppShell extends ConsumerStatefulWidget {
  const _AppShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  ConsumerState<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<_AppShell> {
  StatefulNavigationShell get shell => widget.shell;
  StreamSubscription<Uri?>? _widgetClicks;

  @override
  void initState() {
    super.initState();
    _handleWidgetLaunches();
  }

  /// The home-screen widget opens the app with aimedic://water —
  /// log one cup immediately and land on the tracking tab.
  Future<void> _handleWidgetLaunches() async {
    if (kIsWeb) return;
    try {
      final initial = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (isWaterWidgetUri(initial)) _quickWater();
      _widgetClicks = HomeWidget.widgetClicked.listen((uri) {
        if (isWaterWidgetUri(uri)) _quickWater();
      });
    } catch (e) {
      debugPrint('Widget launch handling unavailable: $e');
    }
  }

  void _quickWater() {
    ref.read(todayLogProvider.notifier).addWater();
    shell.goBranch(1); // tracking tab
  }

  @override
  void dispose() {
    _widgetClicks?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: shell.goBranch,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l10n.homeTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_outline_rounded),
            selectedIcon: const Icon(Icons.favorite_rounded),
            label: l10n.trackingTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.forum_outlined),
            selectedIcon: const Icon(Icons.forum_rounded),
            label: l10n.coachTitle,
          ),
        ],
      ),
    );
  }
}
