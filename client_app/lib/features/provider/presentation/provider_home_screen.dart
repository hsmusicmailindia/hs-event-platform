import 'package:flutter/material.dart';
import '../data/provider_booking_repository.dart';
import 'widgets/provider_booking_card.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  final ProviderBookingRepository _repository = ProviderBookingRepository();
  List<ProviderBookingItem> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    final list = await _repository.fetchPendingRequests();
    if (mounted) {
      setState(() {
        _requests = list;
        _isLoading = false;
      });
    }
  }

  void _handleAccept(String bookingId) async {
    final success = await _repository.acceptBooking(bookingId);
    if (!mounted) return;
    if (success) {
      setState(() {
        _requests.removeWhere((item) => item.id == bookingId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking Accepted! Calendar slot secured via GiST.'),
          backgroundColor: Color(0xFF198754),
        ),
      );
    }
  }

  void _handleReject(String bookingId) async {
    final success = await _repository.rejectBooking(bookingId, 'Provider unavailable');
    if (!mounted) return;
    if (success) {
      setState(() {
        _requests.removeWhere((item) => item.id == bookingId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking Declined. Slot freed for client.'),
          backgroundColor: Color(0xFFDC3545),
        ),
      );
    }
  }

  void _handleCounter(String bookingId, int deltaPaisa, String notes) async {
    final success = await _repository.submitCounterOffer(bookingId, deltaPaisa, notes);
    if (!mounted) return;
    if (success) {
      setState(() {
        _requests.removeWhere((item) => item.id == bookingId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Counter-offer of Ã¢â€šÂ¹${deltaPaisa ~/ 100} submitted to client.'),
          backgroundColor: const Color(0xFF0071E3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      appBar: AppBar(
        title: const Text(
          'Provider Operations Console',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _requests.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (ctx, index) {
                      final item = _requests[index];
                      return ProviderBookingCard(
                        booking: item,
                        onAccept: () => _handleAccept(item.id),
                        onReject: () => _handleReject(item.id),
                        onCounter: (delta, notes) => _handleCounter(item.id, delta, notes),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline, color: Color(0xFF2E7D32), size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'All Action Items Clear',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'No pending booking requests. Your calendar is synchronized.',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}