import 'package:uuid/uuid.dart';

class WorkoutSet {
  final String id;
  final int reps;
  final double weight;
  final bool isCompleted;
  final String type; // normal, warmup, dropset, failure
  final int? rpe;

  WorkoutSet({
    String? id,
    this.reps = 0,
    this.weight = 0.0,
    this.isCompleted = false,
    this.type = 'normal',
    this.rpe,
  }) : id = id ?? const Uuid().v4();

  WorkoutSet copyWith({
    String? id,
    int? reps,
    double? weight,
    bool? isCompleted,
    String? type,
    int? rpe,
  }) {
    return WorkoutSet(
      id: id ?? this.id,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      isCompleted: isCompleted ?? this.isCompleted,
      type: type ?? this.type,
      rpe: rpe ?? this.rpe,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reps': reps,
      'weight': weight,
      'isCompleted': isCompleted,
      'type': type,
      'rpe': rpe,
    };
  }

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      id: json['id'] as String?,
      reps: json['reps'] as int? ?? 0,
      weight: (json['weight'] as num? ?? 0.0).toDouble(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      type: json['type'] as String? ?? 'normal',
      rpe: json['rpe'] as int?,
    );
  }
}
