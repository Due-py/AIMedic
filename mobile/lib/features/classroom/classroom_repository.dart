import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import 'classroom_models.dart';

class ClassroomRepository {
  ClassroomRepository(this._dio);

  final Dio _dio;

  Future<List<ClassInfo>> mine() async {
    final resp = await _dio.get<List<dynamic>>('/classes');
    return resp.data!
        .map((e) => ClassInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ClassInfo> create(String name) async {
    final resp = await _dio
        .post<Map<String, dynamic>>('/classes', data: {'name': name});
    return ClassInfo.fromJson(resp.data!);
  }

  Future<ClassInfo> join(String code) async {
    final resp = await _dio
        .post<Map<String, dynamic>>('/classes/join', data: {'code': code});
    return ClassInfo.fromJson(resp.data!);
  }

  Future<ClassDashboard> dashboard(String code) async {
    final resp =
        await _dio.get<Map<String, dynamic>>('/classes/$code/dashboard');
    return ClassDashboard.fromJson(resp.data!);
  }
}

final classroomRepositoryProvider = Provider<ClassroomRepository>(
  (ref) => ClassroomRepository(ref.watch(apiClientProvider)),
);

final myClassesProvider = FutureProvider<List<ClassInfo>>(
  (ref) => ref.watch(classroomRepositoryProvider).mine(),
);

final classDashboardProvider =
    FutureProvider.family<ClassDashboard, String>(
  (ref, code) => ref.watch(classroomRepositoryProvider).dashboard(code),
);
