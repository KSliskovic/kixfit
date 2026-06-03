import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/workout_template.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/repositories/gym_repository.dart';
import '../../data/repositories/firebase_gym_repository.dart';

final gymRepositoryProvider = Provider<GymRepository>((ref) {
  return FirebaseGymRepository(FirebaseFirestore.instance);
});

final workoutTemplatesProvider = StreamProvider.autoDispose<List<WorkoutTemplate>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  
  return ref.watch(gymRepositoryProvider).watchTemplates(user.id);
});

final workoutHistoryProvider = StreamProvider.autoDispose<List<WorkoutSession>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  
  return ref.watch(gymRepositoryProvider).watchSessions(user.id);
});
