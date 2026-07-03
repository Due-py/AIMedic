import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base URL of the FastAPI backend.
/// Override at build time: flutter run --dart-define=API_BASE_URL=https://...
const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000',
);

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
