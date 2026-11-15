import 'package:supabase_flutter/supabase_flutter.dart';

class ProviderBookingRepository {
  final SupabaseClient _supabase;

  ProviderBookingRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchPendingRequests() async {
    final response = await _supabase
        .from('bookings')
        .select('id, provider_id, client_id, event_date, start_time, end_time, status, created_at')
        .eq('status', 'confirmed')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> respondToBooking({
    required String bookingId,
    required String action, // 'ACCEPT', 'REJECT', 'COUNTER'
    int counterDeltaPaisa = 0,
    String? counterNotes,
  }) async {
    await _supabase.rpc(
      'rpc_provider_respond_booking',
      params: {
        'p_booking_id': bookingId,
        'p_action': action,
        'p_counter_delta_paisa': counterDeltaPaisa,
        'p_counter_notes': counterNotes,
      },
    );
  }
}