import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/firestore_meal_repository.dart';
import '../../domain/repositories/meal_repository.dart';
import '../../domain/entities/nutrition_info.dart';
import '../../../../services/ai/ai_service.dart';
import '../../../../services/ai/gemini_ai_service.dart';
import '../../../../core/config/secrets.dart';

final mealRepositoryProvider = Provider<MealRepository>((ref) {
  return FirestoreMealRepository();
});

final todayMealsProvider = StreamProvider.family<List<NutritionInfo>, String>((ref, userId) {
  return ref.watch(mealRepositoryProvider).getTodayMeals(userId);
});



final aiServiceProvider = Provider<AIService>((ref) {
  return GeminiAIService(AppSecrets.geminiApiKey);
});
