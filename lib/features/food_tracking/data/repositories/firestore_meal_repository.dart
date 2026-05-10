import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/nutrition_info.dart';
import '../../domain/repositories/meal_repository.dart';

class FirestoreMealRepository implements MealRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> saveMeal(String userId, NutritionInfo meal) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('meals')
        .add(meal.toJson());
  }

  @override
  Future<void> deleteMeal(String userId, String mealId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('meals')
        .doc(mealId)
        .delete();
  }

  @override
  Stream<List<NutritionInfo>> getTodayMeals(String userId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('meals')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Dodajemo Firestore ID u podatke
        return NutritionInfo.fromJson(data);
      }).toList();
    });
  }
}
