import 'package:dio/dio.dart';
import '../models/meal_plan/meal_plan_models.dart';
import '../exceptions/mealie_exception.dart';

class MealPlansApi {
  final Dio _dio;

  MealPlansApi(this._dio);

  /// Get meal plans
  Future<List<MealPlan>> getMealPlans() async {
    try {
      final response = await _dio.get('/api/households/mealplans');
      return (response.data as List)
          .map((json) => MealPlan.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Get today's meal plan
  Future<List<PlanEntry>> getTodaysMealPlan() async {
    try {
      final response = await _dio.get('/api/households/mealplans/today');
      return (response.data as List)
          .map((json) => PlanEntry.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Create a meal plan entry
  Future<PlanEntry> createPlanEntry(CreatePlanEntryRequest request) async {
    try {
      final response = await _dio.post('/api/households/mealplans', data: request.toJson());
      return PlanEntry.fromJson(response.data);
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Update a meal plan entry
  Future<PlanEntry> updatePlanEntry(String entryId, CreatePlanEntryRequest request) async {
    try {
      final response = await _dio.put('/api/households/mealplans/$entryId', data: request.toJson());
      return PlanEntry.fromJson(response.data);
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Delete a meal plan entry
  Future<void> deletePlanEntry(String entryId) async {
    try {
      await _dio.delete('/api/households/mealplans/$entryId');
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }
}