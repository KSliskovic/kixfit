import 'package:uuid/uuid.dart';
import 'workout_set.dart';

class WorkoutExercise {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final String muscleGroup;
  final List<WorkoutSet> sets;
  final String notes;

  WorkoutExercise({
    String? id,
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    required this.sets,
    this.notes = '',
  }) : id = id ?? const Uuid().v4();

  WorkoutExercise copyWith({
    String? id,
    String? exerciseId,
    String? exerciseName,
    String? muscleGroup,
    List<WorkoutSet>? sets,
    String? notes,
  }) {
    return WorkoutExercise(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'muscleGroup': muscleGroup,
      'sets': sets.map((s) => s.toJson()).toList(),
      'notes': notes,
    };
  }

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      id: json['id'] as String?,
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      muscleGroup: json['muscleGroup'] as String,
      sets: (json['sets'] as List<dynamic>?)
              ?.map((e) => WorkoutSet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String? ?? '',
    );
  }
}
