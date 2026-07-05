import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';

class MealAnalysis {
  const MealAnalysis({
    required this.isFood,
    required this.name,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.comment,
  });

  final bool isFood;
  final String name;
  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final String comment;

  factory MealAnalysis.fromJson(Map<String, dynamic> json) => MealAnalysis(
        isFood: json['is_food'] as bool,
        name: json['name'] as String,
        calories: json['calories'] as int,
        proteinG: json['protein_g'] as int,
        carbsG: json['carbs_g'] as int,
        fatG: json['fat_g'] as int,
        comment: json['comment'] as String,
      );
}

class NutritionRepository {
  NutritionRepository(this._dio);

  final Dio _dio;

  Future<MealAnalysis> analyze(Uint8List imageBytes, {String? caption}) async {
    final resp = await _dio.post<Map<String, dynamic>>(
      '/nutrition/analyze',
      data: {
        'image_base64': base64Encode(imageBytes),
        if (caption != null && caption.isNotEmpty) 'caption': caption,
      },
    );
    return MealAnalysis.fromJson(resp.data!);
  }
}

final nutritionRepositoryProvider = Provider<NutritionRepository>(
  (ref) => NutritionRepository(ref.watch(apiClientProvider)),
);
