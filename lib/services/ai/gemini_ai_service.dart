import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../features/auth/domain/entities/user_profile.dart';
import '../../features/food_tracking/domain/entities/nutrition_info.dart';
import '../../features/food_tracking/domain/entities/meal_recommendation.dart';
import 'ai_service.dart';
import '../../core/config/secrets.dart';

final geminiAIServiceProvider = Provider<GeminiAIService>((ref) {
  return GeminiAIService(AppSecrets.geminiApiKey);
});

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
    
    TASK: Suggest exactly 3 meal variations to help hit daily targets.
    
    REFERENCE NUTRITION (Standard per 100g):
    - Chicken/Turkey (Cooked): ~23-25g Protein
    - Beef (Lean): ~26g Protein
    - White Rice (Cooked): ~28g Carbs
    - Potato (Boiled): ~17g Carbs
    - Pasta (Cooked): ~25g Carbs
    - Eggs: ~6g Protein per egg
    
    Based on what's missing to hit their daily targets, suggest:
    1. A quick snack or light meal.
    2. A protein-dense meal.
    3. A balanced meal fitting the remaining macros.
    
    IMPORTANT: ALL text responses (title, description, type) MUST be in the Croatian language.
    
    Return a JSON array of objects with these fields:
    - title (String): Short name of the meal (in Croatian).
    - description (String): Brief explanation why this is good now (in Croatian).
    - calories (int): Realistic estimated calories.
    - protein (double): Realistic grams of protein (avoid overestimation).
    - carbs (double): Realistic grams of carbs.
    - fat (double): Realistic grams of fat.
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
    You are a highly accurate professional nutrition coach and personal trainer.
    $profileContext
    
    TASK: Analyze the food input and provide PRECISE macronutrient estimations. 
    It is CRITICAL not to overestimate protein or calories.
    
    REFERENCE DATA (Standard values per 100g):
    - Chicken/Turkey Breast (Grilled): ~23-25g Protein, 1-3g Fat, 110-130 kcal.
    - Beef Steak (Lean): ~25-27g Protein, 5-10g Fat, 150-200 kcal.
    - White Rice (Cooked): ~28g Carbs, 2g Protein, 130 kcal.
    - Eggs (1 large): 6g Protein, 5g Fat, 70 kcal.
    - Whey Protein (1 scoop/30g): 22-25g Protein.
    
    User Input: "${input.isEmpty ? 'Analyze the provided image' : input}".
    Category: "${category ?? 'Ručak'}".
    
    INSTRUCTIONS:
    1. If the user says "100g chicken", protein MUST be ~23-25g, NOT more.
    2. If weight is not specified, assume standard portions: 150g for meat, 200g for cooked grains, 15ml for oil.
    3. Analyze ${imageBytes != null ? 'the image and description' : 'the description'} carefully.
    4. Account for preparation methods (fried vs grilled).
    
    IMPORTANT: ALL text responses (mealName, ingredients, confidenceNote) MUST be in the Croatian language.
    
    Return a JSON object with:
    - mealName (String): Descriptive name (in Croatian).
    - ingredients (List<String>): Detect main ingredients and estimated weights (in Croatian).
    - calories (int): Estimated total calories.
    - protein (double): Estimated protein (be realistic!).
    - carbs (double): Estimated carbohydrates.
    - fat (double): Estimated fat.
    - sugar (double): Estimated sugar in grams.
    - fiber (double): Estimated fiber in grams.
    - sodium (double): Estimated sodium in MILLIGRAMS (mg).
    - saturatedFat (double): Estimated saturated fat in grams.
    - cholesterol (double): Estimated cholesterol in MILLIGRAMS (mg).
    - transFat (double): Estimated trans fat in grams.
    - confidenceNote (String): Explain your estimation logic (in Croatian).
    
    Return ONLY raw JSON.
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

  Future<List<Map<String, dynamic>>> searchRestaurants(String city, String category) async {
    final prompt = """
    Ponašaj se kao lokalni vodič za zdravu prehranu. 
    Pronađi 5 STVARNIH i popularnih restorana u gradu $city koji spadaju u kategoriju: $category.
    NE IZMIŠLJAJ PODATKE. Ako nisi siguran u adresu, koristi samo naziv mjesta i grad.
    
    Fokusiraj se na mjesta koja su "Fit-friendly", imaju nutritivne podatke ili su poznata po zdravoj hrani (npr. bez glutena, vegan, high protein).
    
    Vrati listu u JSON formatu s poljima:
    - name (String): Točan naziv restorana.
    - address (String): Točna adresa u gradu $city.
    - rating (double): Procjena ocjene (npr. 4.5).
    - description (String): Zašto je ovo dobro za fitness (na hrvatskom).
    - tags (List<String>): npr. ["Bez glutena", "Vegan", "Fit"].
    - websiteUrl (String): OBAVEZNO generiraj link u formatu: https://www.google.com/maps/search/?api=1&query=NAZIV+RESTORANA+$city
    
    Vrati SAMO sirovi JSON.
    """;

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text == null) return [];

      String cleanedText = text.trim();
      if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText.replaceAll(RegExp(r'^```(json)?\n?'), '');
        cleanedText = cleanedText.replaceAll(RegExp(r'\n?```$'), '');
      }

      final List<dynamic> data = jsonDecode(cleanedText);
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error searching restaurants: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> analyzeRestaurants(List<Map<String, dynamic>> places) async {
    if (places.isEmpty) return [];

    final placesJson = jsonEncode(places);
    final prompt = """
    Ponašaj se kao stručnjak za fitness prehranu. 
    Dobio sam listu stvarnih restorana s Google Mapsa: $placesJson
    
    Za svaki od ovih restorana, napiši:
    1. Kratki opis (description) na hrvatskom zašto je dobar za osobu koja pazi na prehranu/fitness.
    2. Listu tagova (npr. ["Bez glutena", "High Protein", "Vegan"]).
    
    Vrati istu listu u JSON formatu, ali svakom objektu DODAJ polja 'description' i 'tags'.
    Također, za svakog generiraj 'websiteUrl' koristeći ovaj format:
    https://www.google.com/maps/search/?api=1&query=NAZIV+ADRESA
    
    Vrati SAMO sirovi JSON listu objekata.
    """;

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text == null) return places;

      String cleanedText = text.trim();
      if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText.replaceAll(RegExp(r'^```(json)?\n?'), '');
        cleanedText = cleanedText.replaceAll(RegExp(r'\n?```$'), '');
      }

      final List<dynamic> analyzedData = jsonDecode(cleanedText);
      return analyzedData.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error analyzing restaurants: $e');
      return places;
    }
  }
}
