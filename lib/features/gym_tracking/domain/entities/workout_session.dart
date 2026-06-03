import 'workout_exercise.dart';

class WorkoutSession {
  final String id;
  final String? templateId;
  final String name;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
  final bool isPaused;
  final List<WorkoutExercise> exercises;
  final String notes;
  final double totalVolume;
  final int caloriesBurned;

  WorkoutSession({
    required this.id,
    this.templateId,
    required this.name,
    required this.startTime,
    this.endTime,
    this.durationSeconds = 0,
    this.isPaused = false,
    required this.exercises,
    this.notes = '',
    this.totalVolume = 0.0,
    this.caloriesBurned = 0,
  });

  WorkoutSession copyWith({
    String? id,
    String? templateId,
    String? name,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    bool? isPaused,
    List<WorkoutExercise>? exercises,
    String? notes,
    double? totalVolume,
    int? caloriesBurned,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isPaused: isPaused ?? this.isPaused,
      exercises: exercises ?? this.exercises,
      notes: notes ?? this.notes,
      totalVolume: totalVolume ?? this.totalVolume,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'templateId': templateId,
      'name': name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationSeconds': durationSeconds,
      'isPaused': isPaused,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'notes': notes,
      'totalVolume': totalVolume,
      'caloriesBurned': caloriesBurned,
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String,
      templateId: json['templateId'] as String?,
      name: json['name'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      isPaused: json['isPaused'] as bool? ?? false,
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String? ?? '',
      totalVolume: (json['totalVolume'] as num? ?? 0.0).toDouble(),
      caloriesBurned: json['caloriesBurned'] as int? ?? 0,
    );
  }
}
