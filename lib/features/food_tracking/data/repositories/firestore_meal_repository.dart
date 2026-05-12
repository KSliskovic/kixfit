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
  
  @override
  Future<List<NutritionInfo>> getMealsForRange(String userId, DateTime start, DateTime end) async {
    final query = await _firestore
        .collection('users')
        .doc(userId)
        .collection('meals')
        .where('timestamp', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('timestamp', isLessThanOrEqualTo: end.toIso8601String())
        .get();
        
    return query.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return NutritionInfo.fromJson(data);
    }).toList();
  }

  @override
  Future<List<NutritionInfo>> getRecentMeals(String userId, {int limit = 20}) async {
    final query = await _firestore
        .collection('users')
        .doc(userId)
        .collection('meals')
        .orderBy('timestamp', descending: true)
        .limit(100) // Dohvatimo više pa ćemo profiltrirati unikatne
        .get();

    final Map<String, NutritionInfo> uniqueMeals = {};
    
    for (var doc in query.docs) {
      final meal = NutritionInfo.fromJson({...doc.data(), 'id': doc.id});
      if (!uniqueMeals.containsKey(meal.mealName.toLowerCase().trim())) {
        uniqueMeals[meal.mealName.toLowerCase().trim()] = meal;
      }
      if (uniqueMeals.length >= limit) break;
    }

    return uniqueMeals.values.toList();
  }
}
