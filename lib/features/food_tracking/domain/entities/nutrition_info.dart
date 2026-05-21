class NutritionInfo {
  final String? id; // Firestore Document ID
  final String mealName;
  final List<String> ingredients;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  // Detailed Macros
  final double sugar;
  final double fiber;
  final double sodium; // in mg
  final double saturatedFat;
  final double cholesterol; // in mg
  final double transFat;
  
  final String confidenceNote;
  final String category; // Doručak, Ručak, Večera, Snack
  final DateTime? timestamp;
  final String? imageUrl;

  NutritionInfo({
    this.id,
    required this.mealName,
    required this.ingredients,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.sugar = 0,
    this.fiber = 0,
    this.sodium = 0,
    this.saturatedFat = 0,
    this.cholesterol = 0,
    this.transFat = 0,
    this.confidenceNote = '',
    this.category = 'Ručak',
    this.timestamp,
    this.imageUrl,
  });

  NutritionInfo copyWith({
    String? id,
    String? mealName,
    List<String>? ingredients,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? sugar,
    double? fiber,
    double? sodium,
    double? saturatedFat,
    double? cholesterol,
    double? transFat,
    String? confidenceNote,
    String? category,
    DateTime? timestamp,
    String? imageUrl,
  }) {
    return NutritionInfo(
      id: id ?? this.id,
      mealName: mealName ?? this.mealName,
      ingredients: ingredients ?? this.ingredients,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      sugar: sugar ?? this.sugar,
      fiber: fiber ?? this.fiber,
      sodium: sodium ?? this.sodium,
      saturatedFat: saturatedFat ?? this.saturatedFat,
      cholesterol: cholesterol ?? this.cholesterol,
      transFat: transFat ?? this.transFat,
      confidenceNote: confidenceNote ?? this.confidenceNote,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mealName': mealName,
      'ingredients': ingredients,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'sugar': sugar,
      'fiber': fiber,
      'sodium': sodium,
      'saturatedFat': saturatedFat,
      'cholesterol': cholesterol,
      'transFat': transFat,
      'confidenceNote': confidenceNote,
      'category': category,
      'timestamp': timestamp?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['timestamp'] != null) {
      if (json['timestamp'] is String) {
        parsedDate = DateTime.parse(json['timestamp'] as String);
      } else if (json['timestamp'] is DateTime) {
        parsedDate = json['timestamp'] as DateTime;
      } else {
        try {
          parsedDate = (json['timestamp'] as dynamic).toDate();
        } catch (_) {
          parsedDate = DateTime.now();
        }
      }
    }

    return NutritionInfo(
      id: json['id'] as String?,
      mealName: json['mealName'] as String,
      ingredients: List<String>.from(json['ingredients'] as List),
      calories: json['calories'] as int,
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      sugar: (json['sugar'] as num? ?? 0).toDouble(),
      fiber: (json['fiber'] as num? ?? 0).toDouble(),
      sodium: (json['sodium'] as num? ?? 0).toDouble(),
      saturatedFat: (json['saturatedFat'] as num? ?? 0).toDouble(),
      cholesterol: (json['cholesterol'] as num? ?? 0).toDouble(),
      transFat: (json['transFat'] as num? ?? 0).toDouble(),
      confidenceNote: json['confidenceNote'] as String? ?? '',
      category: json['category'] as String? ?? 'Ručak',
      timestamp: parsedDate,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
