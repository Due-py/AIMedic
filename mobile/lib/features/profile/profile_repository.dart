import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import 'profile_models.dart';

class ProfileRepository {
  ProfileRepository(this._dio);

  final Dio _dio;

  /// Returns null when the user has no profile yet (backend 404).
  Future<Profile?> fetch() async {
    try {
      final resp = await _dio.get<Map<String, dynamic>>('/profile');
      return Profile.fromJson(resp.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<Profile> save(ProfileDraft draft) async {
    final resp = await _dio.put<Map<String, dynamic>>(
      '/profile',
      data: draft.toJson(),
    );
    return Profile.fromJson(resp.data!);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(apiClientProvider)),
);

class ProfileNotifier extends AsyncNotifier<Profile?> {
  @override
  Future<Profile?> build() => ref.watch(profileRepositoryProvider).fetch();

  Future<void> save(ProfileDraft draft) async {
    final repo = ref.read(profileRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repo.save(draft));
  }
}

final profileProvider =
    AsyncNotifierProvider<ProfileNotifier, Profile?>(ProfileNotifier.new);
