import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

class _AppShell extends StatelessWidget {
  const _AppShell({required this.shell});

  final StatefulNavigationShell shell;

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
