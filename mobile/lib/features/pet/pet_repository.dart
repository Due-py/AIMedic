import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import 'pet_models.dart';

class PetRepository {
  PetRepository(this._dio);

  final Dio _dio;

  Future<PetState> fetch() async {
    final resp = await _dio.get<Map<String, dynamic>>('/pet');
    return PetState.fromJson(resp.data!);
  }

  Future<PetState> buy(String accessoryId) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '/pet/buy',
      data: {'accessory_id': accessoryId},
    );
    return PetState.fromJson(resp.data!);
  }

  Future<PetState> toggleEquip(String accessoryId) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '/pet/equip',
      data: {'accessory_id': accessoryId},
    );
    return PetState.fromJson(resp.data!);
  }
}

final petRepositoryProvider = Provider<PetRepository>(
  (ref) => PetRepository(ref.watch(apiClientProvider)),
);

class PetNotifier extends AsyncNotifier<PetState> {
  @override
  Future<PetState> build() => ref.watch(petRepositoryProvider).fetch();

  /// Returns false when the purchase failed (e.g. not enough coins).
  Future<bool> buy(String accessoryId) async {
    try {
      final state = await ref.read(petRepositoryProvider).buy(accessoryId);
      this.state = AsyncData(state);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> toggleEquip(String accessoryId) async {
    try {
      final state =
          await ref.read(petRepositoryProvider).toggleEquip(accessoryId);
      this.state = AsyncData(state);
    } catch (_) {
      // Leave state unchanged; the UI simply doesn't toggle.
    }
  }
}

final petProvider =
    AsyncNotifierProvider<PetNotifier, PetState>(PetNotifier.new);
