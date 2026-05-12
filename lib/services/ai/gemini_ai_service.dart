import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../features/auth/domain/entities/user_profile.dart';
import '../../features/food_tracking/domain/entities/nutrition_info.dart';
import '../../features/food_tracking/domain/entities/meal_recommendation.dart';
import 'ai_service.dart';

class GeminiAIService implements AIService {
  final String _apiKey;
  late final GenerativeModel _model;

  GeminiAIService(this._apiKey) {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );
  }

  @override
  Future<List<MealRecommendation>> getRecommendations({
    required UserProfile profile,
    required int currentCalories,
    required double currentProtein,
    required double currentCarbs,
    required double currentFat,
  }) async {
    final targetCals = profile.dailyCaloriesTarget;
    final remainingCals = targetCals - currentCalories;
    
    final prompt = """
    You are a professional nutrition coach.
    User Profile: Age ${profile.age}, Gender ${profile.gender}, Weight ${profile.weight}kg, Height ${profile.height}cm. 
    Medical Conditions: ${profile.medicalConditions}. Goals: ${profile.goals}.
    
    Today's progress so far:
    - Calories: $currentCalories / $targetCals (Remaining: $remainingCals)
    - Protein: ${currentProtein.toInt()}g
    - Carbs: ${currentCarbs.toInt()}g
    - Fat: ${currentFat.toInt()}g
    
    Based on what's missing to hit their daily targets, suggest exactly 3 meal variations.
    Make the variations diverse:
    1. A quick snack or light meal.
    2. A protein-dense meal.
    3. A balanced meal fitting the remaining macros.
    
    Return a JSON array of objects with these fields:
    - title (String): Short name of the meal.
    - description (String): Brief explanation why this is good now.
    - calories (int): Estimated calories.
    - protein (double): Grams of protein.
    - carbs (double): Grams of carbs.
    - fat (double): Grams of fat.
    - type (String): Type of meal (e.g., "Brzi snack", "Proteinski fokus").
    
    Return ONLY the raw JSON array.
    """;

    final response = await _model.generateContent([Content.text(prompt)]);
    
    if (response.text == null) throw Exception('AI did not return any recommendations.');

    String cleanedText = response.text!.trim();
    if (cleanedText.startsWith('```')) {
      cleanedText = cleanedText.replaceAll(RegExp(r'^```(json)?\n?'), '');
      cleanedText = cleanedText.replaceAll(RegExp(r'\n?```$'), '');
    }

    final List<dynamic> jsonList = jsonDecode(cleanedText) as List<dynamic>;
    return jsonList.map((e) => MealRecommendation.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<NutritionInfo> parseFood(String input, {UserProfile? profile, String? category, Uint8List? imageBytes}) async {
    final profileContext = profile != null 
      ? "User Profile: Age ${profile.age}, Gender ${profile.gender}, Weight ${profile.weight}kg, Height ${profile.height}cm. Medical Conditions: ${profile.medicalConditions}. Goals: ${profile.goals}."
      : "No user profile provided.";

    final prompt = """
    You are a professional nutrition coach and personal trainer.
    $profileContext
    
    The user provided: "${input.isEmpty ? 'Analyze the provided image' : input}".
    This is for the category: "${category ?? 'Ručak'}".
    
    Analyze this meal ${imageBytes != null ? 'from the image and description' : 'from the description'}.
    Return a JSON object with the following fields:
    - mealName (String): A descriptive name of the meal.
    - ingredients (List<String>): Main ingredients detected.
    - calories (int): Estimated total calories.
    - protein (double): Estimated protein in grams.
    - carbs (double): Estimated carbohydrates in grams.
    - fat (double): Estimated fat in grams.
    - confidenceNote (String): A short, personalized note or advice based on the user's profile and medical conditions.
    
    Return ONLY the raw JSON object. Do not include markdown formatting.
    """;

    final List<Content> content = [];
    if (imageBytes != null) {
      content.add(Content.multi([
        TextPart(prompt),
        DataPart('image/jpeg', imageBytes),
      ]));
    } else {
      content.add(Content.text(prompt));
    }

    final response = await _model.generateContent(content);
    
    if (response.text == null) throw Exception('AI did not return any text.');

    String cleanedText = response.text!.trim();
    if (cleanedText.startsWith('```')) {
      cleanedText = cleanedText.replaceAll(RegExp(r'^```(json)?\n?'), '');
      cleanedText = cleanedText.replaceAll(RegExp(r'\n?```$'), '');
    }

    final jsonMap = jsonDecode(cleanedText) as Map<String, dynamic>;
    
    if (category != null) {
      jsonMap['category'] = category;
    }
    
    return NutritionInfo.fromJson(jsonMap);
  }
}
