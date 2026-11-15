import 'dart:async';
import 'package:flutter/material.dart';
import '../../event_dashboard/presentation/client_event_dashboard_screen.dart';

class CartScreen extends StatefulWidget {
  final String preselectedServiceId;
  final int preselectedPricePaisa;
  final String providerName;

  const CartScreen({
    super.key,
    required this.preselectedServiceId,
    required this.preselectedPricePaisa,
    required this.providerName,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Timer _holdTimer;
  int _secondsRemaining = 900; // 15 Minutes Soft Hold (AWAITING_PAYMENT_HOLD)
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _startHoldTimer();
  }

  void _startHoldTimer() {
    _holdTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _holdTimer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _holdTimer.cancel();
    super.dispose();
  }

  String _formatTimer(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _executeCheckout() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() => _isProcessing = false);

    final totalPaidFormatted = '₹${((widget.preselectedPricePaisa * 1.18) / 100).toStringAsFixed(0)}';

    // Transition cleanly to Event Hub & Timeline
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ClientEventDashboardScreen(
          orderId: 'ORD-LIVE-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          bookingId: widget.preselectedServiceId,
          totalPaidFormatted: totalPaidFormatted,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseRupees = widget.preselectedPricePaisa ~/ 100;
    final gstRupees = (baseRupees * 0.18).round();
    final totalRupees = baseRupees + gstRupees;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Build My Event (Cart)',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // 1. Soft-Reservation Hold Banner (15 Min Countdown)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFFFF4E5),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, color: Color(0xFFB25E00), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Slots held for ${_formatTimer(_secondsRemaining)} to prevent double-booking',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFB25E00),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Line Item Card
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.black.withAlpha(15)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.event_available, color: Color(0xFF0071E3), size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.providerName,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Confirmed Performance Slot • Standard Package',
                                style: TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '₹$baseRupees',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: Color(0xFF1D1D1F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Authoritative Quote Breakdown
                Text(
                  'PAYMENT BREAKDOWN (AUTHORITATIVE)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.black.withAlpha(120),
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.black.withAlpha(15)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildPriceRow('Base Package Fee', '₹$baseRupees'),
                        const SizedBox(height: 10),
                        _buildPriceRow('Statutory GST (18%)', '₹$gstRupees'),
                        const SizedBox(height: 10),
                        _buildPriceRow('Platform Service Guarantee', 'Waived (Launch)'),
                        const SizedBox(height: 12),
                        const Divider(height: 1, thickness: 0.5),
                        const SizedBox(height: 12),
                        _buildPriceRow(
                          'Total Payable Advance',
                          '₹$totalRupees',
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Checkout Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _executeCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0071E3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Confirm & Pay ₹$totalRupees',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? Colors.black87 : Colors.black54,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isBold ? const Color(0xFF0071E3) : Colors.black87,
          ),
        ),
      ],
    );
  }
}