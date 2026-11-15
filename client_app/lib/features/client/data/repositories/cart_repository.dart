import 'package:supabase_flutter/supabase_flutter.dart';

class CartRepository {
  final SupabaseClient _supabase;

  CartRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<Map<String, dynamic>> calculateQuote(String packageId) async {
    final response = await _supabase.rpc(
      'rpc_calculate_cart_quote',
      params: {'p_package_id': packageId},
    );
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> acquireCartHold({
    required String packageId,
    required List<Map<String, dynamic>> slots,
  }) async {
    final response = await _supabase.rpc(
      'rpc_acquire_cart_hold',
      params: {
        'p_package_id': packageId,
        'p_slots': slots,
      },
    );
    return Map<String, dynamic>.from(response as Map);
  }
}