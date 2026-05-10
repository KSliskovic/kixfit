class NutritionInfo {
  final String? id; // Firestore Document ID
  final String mealName;
  final List<String> ingredients;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String confidenceNote;
  final String category; // Doručak, Ručak, Večera, Snack
  final DateTime? timestamp;

  NutritionInfo({
    this.id,
    required this.mealName,
    required this.ingredients,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.confidenceNote = '',
    this.category = 'Ručak',
    this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'mealName': mealName,
      'ingredients': ingredients,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'confidenceNote': confidenceNote,
      'category': category,
      'timestamp': timestamp?.toIso8601String() ?? DateTime.now().toIso8601String(),
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
      confidenceNote: json['confidenceNote'] as String? ?? '',
      category: json['category'] as String? ?? 'Ručak',
      timestamp: parsedDate,
    );
  }
}
