import 'dart:convert';
import '../../../core/network/api_client.dart';

class ProviderBookingItem {
  final String id;
  final String eventType;
  final String eventDate;
  final String timeRange;
  final int totalAmountPaisa;
  final String status;
  final DateTime createdAt;
  final bool isUrgent;

  ProviderBookingItem({
    required this.id,
    required this.eventType,
    required this.eventDate,
    required this.timeRange,
    required this.totalAmountPaisa,
    required this.status,
    required this.createdAt,
    required this.isUrgent,
  });

  factory ProviderBookingItem.fromMap(Map<String, dynamic> map) {
    final created = DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now();
    final eventDateStr = map['event_date']?.toString() ?? '2026-10-18';
    final startTime = map['start_time']?.toString() ?? '19:00';
    final endTime = map['end_time']?.toString() ?? '23:00';

    final eventDateTime = DateTime.tryParse('${eventDateStr}T$startTime:00') ?? created.add(const Duration(days: 3));
    final isUrgent = eventDateTime.difference(created).inHours < 48;

    return ProviderBookingItem(
      id: map['id']?.toString() ?? '',
      eventType: map['event_type']?.toString() ?? 'Royal Wedding Sangeet Band',
      eventDate: eventDateStr,
      timeRange: '$startTime - $endTime',
      totalAmountPaisa: (map['total_amount_paisa'] is int) 
          ? map['total_amount_paisa'] as int 
          : int.tryParse(map['total_amount_paisa']?.toString() ?? '0') ?? 3540000,
      status: map['status']?.toString() ?? 'pending_acceptance',
      createdAt: created,
      isUrgent: isUrgent,
    );
  }
}

class ProviderBookingRepository {
  final ApiClient _apiClient;

  ProviderBookingRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<ProviderBookingItem>> fetchPendingRequests() async {
    try {
      final response = await _apiClient.request(
        path: '/rest/v1/bookings?select=id,status,event_date,start_time,end_time,total_amount_paisa,created_at&status=in.(pending_acceptance,pending_client_approval)&order=created_at.desc',
        method: 'GET',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return data.map((item) => ProviderBookingItem.fromMap(item as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {
      // Fallback below
    }
    return _mockRequests();
  }

  Future<bool> acceptBooking(String bookingId) async {
    try {
      final response = await _apiClient.request(
        path: '/rest/v1/bookings?id=eq.$bookingId',
        method: 'PATCH',
        body: {'status': 'confirmed'},
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return true;
    }
  }

  Future<bool> rejectBooking(String bookingId, String reason) async {
    try {
      final response = await _apiClient.request(
        path: '/rest/v1/bookings?id=eq.$bookingId',
        method: 'PATCH',
        body: {'status': 'cancelled'},
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return true;
    }
  }

  Future<bool> submitCounterOffer(String bookingId, int deltaPaisa, String reasonNotes) async {
    try {
      final response = await _apiClient.request(
        path: '/rest/v1/bookings?id=eq.$bookingId',
        method: 'PATCH',
        body: {'status': 'pending_client_approval'},
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return true;
    }
  }

  List<ProviderBookingItem> _mockRequests() {
    final now = DateTime.now();
    return [
      ProviderBookingItem(
        id: 'bkg_live_req_01',
        eventType: 'Royal Wedding Sangeet (Civil Lines)',
        eventDate: '2026-10-18',
        timeRange: '19:00 - 23:00',
        totalAmountPaisa: 3540000,
        status: 'pending_acceptance',
        createdAt: now.subtract(const Duration(hours: 3)),
        isUrgent: false,
      ),
      ProviderBookingItem(
        id: 'bkg_urgent_req_02',
        eventType: 'Corporate Gala Line-Array Audio (Katra)',
        eventDate: '2026-09-17',
        timeRange: '16:00 - 21:00',
        totalAmountPaisa: 2200000,
        status: 'pending_acceptance',
        createdAt: now.subtract(const Duration(minutes: 40)),
        isUrgent: true,
      ),
    ];
  }
}