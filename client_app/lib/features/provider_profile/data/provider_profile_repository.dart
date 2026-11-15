import 'dart:convert';
import '../../../core/network/api_client.dart';
import 'provider_profile_model.dart';

class ProviderProfileRepository {
  final ApiClient _apiClient;

  ProviderProfileRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<ProviderDetailModel> fetchProviderDetails(String providerId) async {
    // 1. Explicit lean projection to prevent geometry serialization crashes
    final providerResponse = await _apiClient.request(
      path: '/rest/v1/providers?id=eq.$providerId&select=id,business_name,city,base_price,rating,is_verified,bio',
      method: 'GET',
    );

    if (providerResponse.statusCode != 200) {
      throw Exception('HTTP ${providerResponse.statusCode}: ${providerResponse.body}');
    }

    final List<dynamic> providerList = jsonDecode(providerResponse.body);
    if (providerList.isEmpty) {
      throw Exception('Provider record not found for ID: $providerId');
    }

    final providerJson = providerList.first as Map<String, dynamic>;

    // 2. Fetch active inventory tiers
    final inventoryResponse = await _apiClient.request(
      path: '/rest/v1/service_inventory?provider_id=eq.$providerId&select=id,ticket_tier_name,price_paisa,total_capacity,booked_capacity,held_capacity,event_date',
      method: 'GET',
    );

    List<ServiceInventoryTier> tiers = [];
    if (inventoryResponse.statusCode == 200) {
      final List<dynamic> inventoryList = jsonDecode(inventoryResponse.body);
      tiers = inventoryList
          .map((e) => ServiceInventoryTier.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return ProviderDetailModel.fromJson(providerJson, tiers: tiers);
  }
}