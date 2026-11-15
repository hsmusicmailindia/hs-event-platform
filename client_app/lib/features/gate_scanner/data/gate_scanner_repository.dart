import '../../../core/network/api_client.dart';
import 'gate_scan_model.dart';

class GateScannerRepository {
  final ApiClient _apiClient;
  final Set<String> _scannedHashes = {};
  final List<GateScanRecord> _scanLog = [];
  final List<GateScanRecord> _pendingSyncQueue = [];

  GateScannerRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<GateScanRecord> verifyTicketPayload({
    required String bookingId,
    required String rawPayload,
  }) async {
    final scannedTime = DateTime.now();

    // 1. Structural check: Must match Ed25519 signature payload format
    if (!rawPayload.startsWith('ED25519_')) {
      return GateScanRecord(
        ticketHash: rawPayload,
        guestName: 'Unknown Attendee',
        scannedAt: scannedTime,
        result: ScanVerificationResult.invalidHash,
      );
    }

    // 2. Anti-Double-Spend Check (Offline Local Cache)
    if (_scannedHashes.contains(rawPayload)) {
      return GateScanRecord(
        ticketHash: rawPayload,
        guestName: 'Existing Check-in',
        scannedAt: scannedTime,
        result: ScanVerificationResult.alreadyUsed,
      );
    }

    // 3. Mark scanned locally
    _scannedHashes.add(rawPayload);

    // 4. Record successful scan
    final record = GateScanRecord(
      ticketHash: rawPayload,
      guestName: 'Verified Guest',
      scannedAt: scannedTime,
      result: ScanVerificationResult.granted,
    );
    _scanLog.insert(0, record);
    _pendingSyncQueue.add(record);

    return record;
  }

  /// Batch syncs accumulated offline scans to Supabase (STEP_13 Sec 15)
  Future<int> syncPendingScans(String bookingId) async {
    if (_pendingSyncQueue.isEmpty) return 0;

    final batch = List<GateScanRecord>.from(_pendingSyncQueue);
    int syncedCount = 0;

    for (final record in batch) {
      try {
        final response = await _apiClient.request(
          path: '/rest/v1/ticket_scans',
          method: 'POST',
          body: {
            'ticket_id': record.ticketHash,
            'scan_state': 'scanned_in',
            'device_scanned_at': record.scannedAt.toIso8601String(),
          },
        );

        if (response.statusCode == 201 || response.statusCode == 200 || response.statusCode == 409) {
          syncedCount++;
        }
      } catch (_) {
        // Retain in queue for next sync retry
        break;
      }
    }

    _pendingSyncQueue.removeRange(0, syncedCount);
    return syncedCount;
  }

  int get pendingSyncCount => _pendingSyncQueue.length;
  List<GateScanRecord> get recentScans => List.unmodifiable(_scanLog);
}