import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/entities/workout_exercise.dart';
import '../../domain/entities/workout_set.dart';
import '../../domain/entities/workout_template.dart';
import '../../domain/entities/exercise.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/repositories/profile_repository.dart';
import 'gym_provider.dart';

final activeWorkoutProvider = NotifierProvider<ActiveWorkoutNotifier, WorkoutSession?>(() {
  return ActiveWorkoutNotifier();
});

class ActiveWorkoutNotifier extends Notifier<WorkoutSession?> {
  Timer? _bgTimer;

  @override
  WorkoutSession? build() {
    ref.onDispose(() {
      _bgTimer?.cancel();
    });
    return null;
  }

  void _startTimer() {
    _bgTimer?.cancel();
    _bgTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state != null && !state!.isPaused) {
        state = state!.copyWith(
          durationSeconds: state!.durationSeconds + 1,
        );
      }
    });
  }

  void togglePause() {
    if (state == null) return;
    state = state!.copyWith(isPaused: !state!.isPaused);
  }

  void startWorkout({WorkoutTemplate? template}) {
    if (state != null) return; // Workout already in progress

    state = WorkoutSession(
      id: const Uuid().v4(),
      templateId: template?.id,
      name: template != null ? template.name : 'Slobodni Trening',
      startTime: DateTime.now(),
      durationSeconds: 0,
      isPaused: false,
      exercises: template?.exercises.map((e) {
            // Kopiramo vježbe i resetiramo setove da ne budu označeni kao completed
            return e.copyWith(
              id: const Uuid().v4(),
              sets: e.sets.map((s) => s.copyWith(id: const Uuid().v4(), isCompleted: false)).toList(),
            );
          }).toList() ??
          [],
    );
    _startTimer();
  }

  void addExercise(Exercise exercise) {
    if (state == null) return;

    final newExercise = WorkoutExercise(
      exerciseId: exercise.id,
      exerciseName: exercise.name,
      muscleGroup: exercise.muscleGroup,
      sets: [WorkoutSet()], // One initial empty set
    );

    state = state!.copyWith(
      exercises: [...state!.exercises, newExercise],
    );
  }

  void addSetToExercise(String workoutExerciseId) {
    if (state == null) return;

    final updatedExercises = state!.exercises.map((e) {
      if (e.id == workoutExerciseId) {
        // Find previous set to copy weight/reps if possible
        final prevSet = e.sets.isNotEmpty ? e.sets.last : null;
        
        return e.copyWith(
          sets: [
            ...e.sets,
            WorkoutSet(
              reps: prevSet?.reps ?? 0,
              weight: prevSet?.weight ?? 0.0,
            ),
          ],
        );
      }
      return e;
    }).toList();

    state = state!.copyWith(exercises: updatedExercises);
  }

  void updateSet(String workoutExerciseId, String setId, {int? reps, double? weight, bool? isCompleted}) {
    if (state == null) return;

    final updatedExercises = state!.exercises.map((e) {
      if (e.id == workoutExerciseId) {
        final updatedSets = e.sets.map((s) {
          if (s.id == setId) {
            return s.copyWith(
              reps: reps ?? s.reps,
              weight: weight ?? s.weight,
              isCompleted: isCompleted ?? s.isCompleted,
            );
          }
          return s;
        }).toList();
        return e.copyWith(sets: updatedSets);
      }
      return e;
    }).toList();

    state = state!.copyWith(exercises: updatedExercises);
  }

  void removeSet(String workoutExerciseId, String setId) {
    if (state == null) return;

    final updatedExercises = state!.exercises.map((e) {
      if (e.id == workoutExerciseId) {
        return e.copyWith(
          sets: e.sets.where((s) => s.id != setId).toList(),
        );
      }
      return e;
    }).toList();

    // Optionally remove exercise if sets are empty
    final filteredExercises = updatedExercises.where((e) => e.sets.isNotEmpty).toList();

    state = state!.copyWith(exercises: filteredExercises);
  }

  void removeExercise(String workoutExerciseId) {
    if (state == null) return;

    state = state!.copyWith(
      exercises: state!.exercises.where((e) => e.id != workoutExerciseId).toList(),
    );
  }

  Future<void> finishWorkout() async {
    if (state == null) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    // Automatically set all sets as completed when finishing so nothing is lost
    final cleanExercises = state!.exercises.map((e) {
      return e.copyWith(
        sets: e.sets.map((s) => s.copyWith(isCompleted: true)).toList(),
      );
    }).where((e) => e.sets.isNotEmpty).toList();

    if (cleanExercises.isEmpty) {
      // Prazan trening, samo poništi
      state = null;
      return;
    }

    // Izračunaj volumen
    double totalVolume = 0.0;
    for (var ex in cleanExercises) {
      for (var s in ex.sets) {
        totalVolume += (s.reps * s.weight);
      }
    }

    final durationSeconds = state!.durationSeconds;
    final durationMinutes = durationSeconds / 60.0;
    
    // Izračunaj kalorije
    final profile = ref.read(userProfileProvider).value;
    final weight = profile?.weight.toDouble() ?? 80.0;
    // Formula: (MET * težina * 3.5) / 200 * minute (MET za teretanu je oko 4.5)
    final caloriesBurned = ((4.5 * weight * 3.5) / 200 * durationMinutes).round();

    final finishedSession = state!.copyWith(
      endTime: DateTime.now(),
      durationSeconds: durationSeconds,
      exercises: cleanExercises,
      totalVolume: totalVolume,
      caloriesBurned: caloriesBurned,
    );

    try {
      await ref.read(gymRepositoryProvider).saveSession(user.id, finishedSession);
      _bgTimer?.cancel();
      state = null; // Reset nakon uspješnog spremanja
    } catch (e) {
      rethrow;
    }
  }
  
  void cancelWorkout() {
    _bgTimer?.cancel();
    state = null;
  }
}
