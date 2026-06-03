import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/workout_template.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/repositories/gym_repository.dart';

class FirebaseGymRepository implements GymRepository {
  final FirebaseFirestore _firestore;

  FirebaseGymRepository(this._firestore);

  @override
  Future<void> saveTemplate(String userId, WorkoutTemplate template) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('workout_templates')
        .doc(template.id)
        .set(template.toJson());
  }

  @override
  Future<void> deleteTemplate(String userId, String templateId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('workout_templates')
        .doc(templateId)
        .delete();
  }

  @override
  Stream<List<WorkoutTemplate>> watchTemplates(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('workout_templates')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkoutTemplate.fromJson(doc.data()))
            .toList());
  }

  @override
  Future<void> saveSession(String userId, WorkoutSession session) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('workout_sessions')
        .doc(session.id)
        .set(session.toJson());
  }

  @override
  Future<void> deleteSession(String userId, String sessionId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('workout_sessions')
        .doc(sessionId)
        .delete();
  }

  @override
  Stream<List<WorkoutSession>> watchSessions(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('workout_sessions')
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkoutSession.fromJson(doc.data()))
            .toList());
  }

  @override
  Future<void> saveCustomExercise(String userId, Exercise exercise) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('custom_exercises')
        .doc(exercise.id)
        .set(exercise.toJson());
  }

  @override
  Future<void> deleteCustomExercise(String userId, String exerciseId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('custom_exercises')
        .doc(exerciseId)
        .delete();
  }

  @override
  Stream<List<Exercise>> watchCustomExercises(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('custom_exercises')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Exercise.fromJson(doc.data()))
            .toList());
  }
}
