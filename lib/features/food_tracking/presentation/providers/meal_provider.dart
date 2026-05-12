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

final weeklyStatsProvider = FutureProvider.family<List<NutritionInfo>, String>((ref, userId) {
  final now = DateTime.now();
  final startOfWeek = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
  return ref.watch(mealRepositoryProvider).getMealsForRange(userId, startOfWeek, now);
});

final recentMealsProvider = FutureProvider.family<List<NutritionInfo>, String>((ref, userId) {
  return ref.watch(mealRepositoryProvider).getRecentMeals(userId);
});



final aiServiceProvider = Provider<AIService>((ref) {
  return GeminiAIService(AppSecrets.geminiApiKey);
});
