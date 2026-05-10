import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_profile.dart';
import '../../presentation/providers/auth_provider.dart';

final profileRepositoryProvider = Provider((ref) {
  return ProfileRepository(FirebaseFirestore.instance);
});

final userProfileProvider = StreamProvider((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  return ref.watch(profileRepositoryProvider).watchProfile(user.id);
});

class ProfileRepository {
  final FirebaseFirestore _firestore;

  ProfileRepository(this._firestore);

  Future<void> saveProfile(UserProfile profile) async {
    await _firestore.collection('profiles').doc(profile.id).set(profile.toJson());
  }

  Stream<UserProfile?> watchProfile(String userId) {
    return _firestore
        .collection('profiles')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserProfile.fromJson(doc.data()!) : null);
  }
}
