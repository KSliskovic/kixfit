import '../entities/workout_template.dart';
import '../entities/workout_session.dart';
import '../entities/exercise.dart';

abstract class GymRepository {
  // Templates (Splits)
  Future<void> saveTemplate(String userId, WorkoutTemplate template);
  Future<void> deleteTemplate(String userId, String templateId);
  Stream<List<WorkoutTemplate>> watchTemplates(String userId);
  
  // Sessions (History)
  Future<void> saveSession(String userId, WorkoutSession session);
  Future<void> deleteSession(String userId, String sessionId);
  Stream<List<WorkoutSession>> watchSessions(String userId);

  // Custom Exercises
  Future<void> saveCustomExercise(String userId, Exercise exercise);
  Stream<List<Exercise>> watchCustomExercises(String userId);
}
