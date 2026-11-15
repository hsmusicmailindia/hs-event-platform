import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GateSyncRepository {
  final SupabaseClient _supabase;

  GateSyncRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<Map<String, dynamic>> pushScanBatch({
    required String batchId,
    required List<Map<String, dynamic>> scans,
  }) async {
    if (scans.isEmpty) {
      return {'status': 'EMPTY', 'committed_count': 0, 'discrepancy_count': 0};
    }

    // Compute deterministic chunk_idempotency_hash (SHA-256)
    final rawJson = jsonEncode(scans);
    final chunkHash = sha256.convert(utf8.encode(rawJson)).toString();

    final response = await _supabase.rpc(
      'rpc_sync_ticket_scans_batch',
      params: {
        'p_batch_id': batchId,
        'p_chunk_idempotency_hash': chunkHash,
        'p_scans': scans,
      },
    );

    return Map<String, dynamic>.from(response);
  }
}