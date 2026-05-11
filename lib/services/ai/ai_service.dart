import 'dart:typed_data';
import '../../features/auth/domain/entities/user_profile.dart';
import '../../features/food_tracking/domain/entities/nutrition_info.dart';

abstract class AIService {
  Future<NutritionInfo> parseFood(String input, {UserProfile? profile, String? category, Uint8List? imageBytes});
}
