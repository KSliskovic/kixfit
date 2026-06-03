import 'dart:typed_data';
import '../../features/auth/domain/entities/user_profile.dart';
import '../../features/food_tracking/domain/entities/nutrition_info.dart';
import '../../features/food_tracking/domain/entities/meal_recommendation.dart';
import '../../features/gym_tracking/domain/entities/workout_template.dart';

abstract class AIService {
  Future<NutritionInfo> parseFood(String input, {UserProfile? profile, String? category, Uint8List? imageBytes});
  Future<List<MealRecommendation>> getRecommendations({
    required UserProfile profile,
    required int currentCalories,
    required double currentProtein,
    required double currentCarbs,
    required double currentFat,
  });
  Future<List<WorkoutTemplate>> generateWorkoutTemplates({
    required UserProfile profile,
    required int daysPerWeek,
    required String equipment,
    required String focus,
  });
}
