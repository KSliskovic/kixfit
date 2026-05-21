import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/secrets.dart';

final placesServiceProvider = Provider((ref) => PlacesService());

class PlacesService {
  final String _baseUrl = 'https://maps.googleapis.com/maps/api/place/textsearch/json';

  Future<List<Map<String, dynamic>>> searchRestaurants(String city, String category) async {
    final query = 'restaurants in $city $category healthy fit';
    final url = Uri.parse('$_baseUrl?query=${Uri.encodeComponent(query)}&key=${AppSecrets.placesApiKey}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        
        return results.take(5).map((e) => {
          'name': e['name'],
          'address': e['formatted_address'],
          'rating': e['rating']?.toDouble() ?? 4.0,
          'placeId': e['place_id'],
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
