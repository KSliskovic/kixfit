class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final String equipment;
  final String type; // strength, cardio
  final String description;

  Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.equipment = 'Bodyweight',
    this.type = 'strength',
    this.description = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'muscleGroup': muscleGroup,
      'equipment': equipment,
      'type': type,
      'description': description,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      muscleGroup: json['muscleGroup'] as String,
      equipment: json['equipment'] as String? ?? 'Bodyweight',
      type: json['type'] as String? ?? 'strength',
      description: json['description'] as String? ?? '',
    );
  }
}
