class MealRecommendation {
  final String title;
  final String description;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String type; // npr. "Brzi snack", "Glavni obrok", "Lagana večera"

  MealRecommendation({
    required this.title,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.type,
  });

  factory MealRecommendation.fromJson(Map<String, dynamic> json) {
    return MealRecommendation(
      title: json['title'] as String,
      description: json['description'] as String,
      calories: json['calories'] as int,
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      type: json['type'] as String? ?? 'Preporuka',
    );
  }
}
