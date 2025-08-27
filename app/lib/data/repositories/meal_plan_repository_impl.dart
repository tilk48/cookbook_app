import '../../domain/repositories/meal_plan_repository.dart';
import '../datasources/remote/remote_meal_plan_datasource.dart';

class MealPlanRepositoryImpl implements MealPlanRepository {
  final RemoteMealPlanDataSource remoteDataSource;
  MealPlanRepositoryImpl({required this.remoteDataSource});
}