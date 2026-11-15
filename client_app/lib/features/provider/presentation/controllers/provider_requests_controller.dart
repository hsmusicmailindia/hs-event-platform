import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/repositories/provider_booking_repository.dart';

class ProviderRequestItem {
  final String id;
  final String providerName;
  final String category;
  final String eventDate;
  final String startTime;
  final String endTime;
  final String status;
  final int totalSlaSeconds;
  final DateTime deadline;

  ProviderRequestItem({
    required this.id,
    required this.providerName,
    required this.category,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalSlaSeconds,
    required this.deadline,
  });

  int get remainingSeconds {
    final diff = deadline.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  bool get isUrgentSla => totalSlaSeconds <= 14400; // <= 4 hours
}

class ProviderRequestsController extends ChangeNotifier {
  final ProviderBookingRepository _repo;
  List<ProviderRequestItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _ticker;

  ProviderRequestsController({ProviderBookingRepository? repo})
      : _repo = repo ?? ProviderBookingRepository();

  List<ProviderRequestItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _startTicking() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
  }

  Future<void> loadRequests() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      // Probe active backend repository
      final dbData = await _repo.fetchPendingRequests();

      if (dbData.isNotEmpty) {
        _items = dbData.map((row) {
          final created = DateTime.tryParse(row['created_at'].toString())?.toLocal() ?? now;
          final eventDate = DateTime.tryParse(row['event_date'].toString()) ?? now.add(const Duration(days: 3));
          final timeToEventHours = eventDate.difference(now).inHours;
          final int slaSec = timeToEventHours < 48 ? 14400 : 86400;

          return ProviderRequestItem(
            id: row['id'].toString(),
            providerName: 'The Royal Symphony Band',
            category: 'Entertainment',
            eventDate: row['event_date'].toString(),
            startTime: row['start_time']?.toString() ?? '18:00:00',
            endTime: row['end_time']?.toString() ?? '22:00:00',
            status: row['status']?.toString().toUpperCase() ?? 'PENDING',
            totalSlaSeconds: slaSec,
            deadline: created.add(Duration(seconds: slaSec)),
          );
        }).toList();
      } else {
        _items = _getFallbackTestCards(now);
      }

      _startTicking();
    } catch (_) {
      _items = _getFallbackTestCards(DateTime.now());
      _startTicking();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ProviderRequestItem> _getFallbackTestCards(DateTime now) {
    return [
      ProviderRequestItem(
        id: 'std-bkg-001',
        providerName: 'The Royal Symphony Band',
        category: 'Entertainment',
        eventDate: '2026-10-25',
        startTime: '18:00:00',
        endTime: '22:00:00',
        status: 'PENDING',
        totalSlaSeconds: 86400,
        deadline: now.add(const Duration(hours: 23, minutes: 59, seconds: 55)),
      ),
      ProviderRequestItem(
        id: 'urg-bkg-002',
        providerName: 'Sufi Fusion Live Duo',
        category: 'Entertainment',
        eventDate: '2026-09-10',
        startTime: '19:00:00',
        endTime: '23:00:00',
        status: 'URGENT',
        totalSlaSeconds: 14400,
        deadline: now.add(const Duration(hours: 3, minutes: 59, seconds: 50)),
      ),
    ];
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}