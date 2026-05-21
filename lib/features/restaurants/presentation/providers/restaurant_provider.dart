import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/ai/gemini_ai_service.dart';
import '../../../../services/location/places_service.dart';
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
      final placesService = ref.read(placesServiceProvider);
      final aiService = ref.read(geminiAIServiceProvider);

      // 1. DOHVATI STVARNE PODATKE S GOOGLE-A
      final realPlaces = await placesService.searchRestaurants(city, category);
      
      if (realPlaces.isEmpty) {
        state = const AsyncValue.data([]);
        return;
      }

      // 2. DAJ AI-U DA ANALIZIRA TE STVARNE PODATKE
      final analyzedData = await aiService.analyzeRestaurants(realPlaces);
      
      final restaurants = analyzedData.map((json) => Restaurant.fromJson(json)).toList();
      state = AsyncValue.data(restaurants);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
