import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/ai/gemini_ai_service.dart';
import '../../domain/entities/restaurant.dart';

final restaurantSearchProvider = StateNotifierProvider<RestaurantSearchNotifier, AsyncValue<List<Restaurant>>>((ref) {
  return RestaurantSearchNotifier(ref.read(geminiAIServiceProvider));
});

class RestaurantSearchNotifier extends StateNotifier<AsyncValue<List<Restaurant>>> {
  final GeminiAIService _aiService;

  RestaurantSearchNotifier(this._aiService) : super(const AsyncValue.data([]));

  Future<void> search(String city, String category) async {
    state = const AsyncValue.loading();
    try {
      final data = await _aiService.searchRestaurants(city, category);
      final restaurants = data.map((json) => Restaurant.fromJson(json)).toList();
      state = AsyncValue.data(restaurants);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
