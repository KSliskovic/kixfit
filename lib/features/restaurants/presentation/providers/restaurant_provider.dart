import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/ai/gemini_ai_service.dart';
import '../../domain/entities/restaurant.dart';

final restaurantSearchProvider = NotifierProvider<RestaurantSearchNotifier, AsyncValue<List<Restaurant>>>(() {
  return RestaurantSearchNotifier();
});

class RestaurantSearchNotifier extends Notifier<AsyncValue<List<Restaurant>>> {
  @override
  AsyncValue<List<Restaurant>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> search(String city, String category) async {
    state = const AsyncValue.loading();
    try {
      final aiService = ref.read(geminiAIServiceProvider);
      final data = await aiService.searchRestaurants(city, category);
      final restaurants = data.map((json) => Restaurant.fromJson(json)).toList();
      state = AsyncValue.data(restaurants);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
