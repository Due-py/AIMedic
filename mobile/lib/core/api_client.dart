import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base URL of the FastAPI backend.
/// Override at build time: flutter run --dart-define=API_BASE_URL=https://...
/// Without an override, release builds use production and debug builds use
/// the local dev server (via `adb reverse tcp:8000 tcp:8000` on a device).
const _overrideUrl = String.fromEnvironment('API_BASE_URL');
final apiBaseUrl = _overrideUrl.isNotEmpty
    ? _overrideUrl
    : kReleaseMode
        ? 'https://aimedic-5i8z.onrender.com'
        : 'http://localhost:8000';

final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      // Attach the Firebase ID token when a user is signed in.
      if (Firebase.apps.isNotEmpty) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final token = await user.getIdToken();
          options.headers['Authorization'] = 'Bearer $token';
        }
      }
      handler.next(options);
    },
  ));

  return dio;
});
