import '../entities/nutrition_info.dart';

abstract class MealRepository {
  Future<void> saveMeal(String userId, NutritionInfo meal);
  Future<void> deleteMeal(String userId, String mealId);
  Stream<List<NutritionInfo>> getTodayMeals(String userId);
}
