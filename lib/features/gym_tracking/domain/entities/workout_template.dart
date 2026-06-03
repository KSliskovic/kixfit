import 'workout_exercise.dart';

class WorkoutTemplate {
  final String id;
  final String name;
  final String description;
  final List<WorkoutExercise> exercises;
  final bool isAiGenerated;
  final DateTime createdAt;

  WorkoutTemplate({
    required this.id,
    required this.name,
    this.description = '',
    required this.exercises,
    this.isAiGenerated = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  WorkoutTemplate copyWith({
    String? id,
    String? name,
    String? description,
    List<WorkoutExercise>? exercises,
    bool? isAiGenerated,
    DateTime? createdAt,
  }) {
    return WorkoutTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'isAiGenerated': isAiGenerated,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isAiGenerated: json['isAiGenerated'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}
