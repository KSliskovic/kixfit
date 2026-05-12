import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/water_repository.dart';

final waterRepositoryProvider = Provider<WaterRepository>((ref) => WaterRepository());

final todayWaterProvider = StreamProvider.family<double, String>((ref, userId) {
  return ref.watch(waterRepositoryProvider).getTodayWater(userId);
});
