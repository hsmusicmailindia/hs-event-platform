import 'dart:convert';
import '../../../core/network/api_client.dart';
import 'provider_discovery_model.dart';

class DiscoveryRepository {
  final ApiClient _apiClient;

  DiscoveryRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<ProviderDiscoveryModel>> searchNearby({
    required double longitude,
    required double latitude,
    double radiusKm = 50.0,
    String? categorySlug,
  }) async {
    final Map<String, dynamic> requestPayload = {
      'p_lon': longitude,
      'p_lat': latitude,
      'p_radius_km': radiusKm,
    };

    if (categorySlug != null) {
      requestPayload['p_category_slug'] = categorySlug;
    }

    final response = await _apiClient.request(
      path: '/rest/v1/rpc/search_nearby_providers',
      method: 'POST',
      body: requestPayload,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ProviderDiscoveryModel.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      // Expose the raw Supabase gateway error message directly
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }
}