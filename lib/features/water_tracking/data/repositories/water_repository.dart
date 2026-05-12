import 'package:cloud_firestore/cloud_firestore.dart';

class WaterRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<double> getTodayWater(String userId) {
    final now = DateTime.now();
    final dateStr = "${now.year}-${now.month}-${now.day}";

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('water_logs')
        .doc(dateStr)
        .snapshots()
        .map((doc) => (doc.data()?['amount'] ?? 0.0).toDouble());
  }

  Future<void> updateWater(String userId, double amount) async {
    final now = DateTime.now();
    final dateStr = "${now.year}-${now.month}-${now.day}";

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('water_logs')
        .doc(dateStr)
        .set({
          'amount': FieldValue.increment(amount),
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }
  
  Future<void> resetWater(String userId) async {
    final now = DateTime.now();
    final dateStr = "${now.year}-${now.month}-${now.day}";
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('water_logs')
        .doc(dateStr)
        .set({'amount': 0.0});
  }
}
