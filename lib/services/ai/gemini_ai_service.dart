import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../features/auth/domain/entities/user_profile.dart';
import '../../features/food_tracking/domain/entities/nutrition_info.dart';
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
  Future<NutritionInfo> parseFood(String input, {UserProfile? profile, String? category}) async {
    final profileContext = profile != null 
      ? "User Profile: Age ${profile.age}, Gender ${profile.gender}, Weight ${profile.weight}kg, Height ${profile.height}cm. Medical Conditions: ${profile.medicalConditions}. Goals: ${profile.goals}."
      : "No user profile provided.";

    final prompt = """
    You are a professional nutrition coach and personal trainer.
    $profileContext
    
    The user ate: "$input".
    This is for the category: "${category ?? 'Ručak'}".
    
    Analyze this meal and return a JSON object with the following fields:
    - mealName (String): A descriptive name of the meal.
    - ingredients (List<String>): Main ingredients detected.
    - calories (int): Estimated total calories.
    - protein (double): Estimated protein in grams.
    - carbs (double): Estimated carbohydrates in grams.
    - fat (double): Estimated fat in grams.
    - confidenceNote (String): A short, personalized note or advice based on the user's profile and medical conditions.
    
    Return ONLY the raw JSON object. Do not include markdown formatting.
    """;

    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    
    if (response.text == null) throw Exception('AI did not return any text.');

    // Clean markdown code blocks if present
    String cleanedText = response.text!.trim();
    if (cleanedText.startsWith('```')) {
      cleanedText = cleanedText.replaceAll(RegExp(r'^```(json)?\n?'), '');
      cleanedText = cleanedText.replaceAll(RegExp(r'\n?```$'), '');
    }

    final jsonMap = jsonDecode(cleanedText) as Map<String, dynamic>;
    
    // Ručno ubacujemo kategoriju u JSON prije nego što napravimo NutritionInfo objekat
    if (category != null) {
      jsonMap['category'] = category;
    }
    
    return NutritionInfo.fromJson(jsonMap);
  }
}
