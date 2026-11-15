import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/provider_booking_repository.dart';

class ProviderBookingCard extends StatefulWidget {
  final ProviderBookingItem booking;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final Function(int deltaPaisa, String notes) onCounter;

  const ProviderBookingCard({
    super.key,
    required this.booking,
    required this.onAccept,
    required this.onReject,
    required this.onCounter,
  });

  @override
  State<ProviderBookingCard> createState() => _ProviderBookingCardState();
}

class _ProviderBookingCardState extends State<ProviderBookingCard> {
  late Timer _timer;
  late Duration _remainingSla;

  @override
  void initState() {
    super.initState();
    _calculateRemainingSla();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(_calculateRemainingSla);
      }
    });
  }

  void _calculateRemainingSla() {
    // Dynamic SLA: Standard = 24h, Urgent (<48h to event) = 4h
    final totalWindow = widget.booking.isUrgent ? const Duration(hours: 4) : const Duration(hours: 24);
    final elapsed = DateTime.now().difference(widget.booking.createdAt);
    final remaining = totalWindow - elapsed;
    _remainingSla = remaining.isNegative ? Duration.zero : remaining;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void _openCounterOfferModal(BuildContext context) {
    final deltaController = TextEditingController();
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Propose Counter-Offer',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add logistics, travel, or customized riders. Client gets 24 hours to review and pay delta.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: deltaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Additional Amount (₹ INR)',
                prefixText: '₹ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Reason / Itemized Notes',
                hintText: 'e.g., Added outstation travel & additional audio setup',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final parsedRupees = int.tryParse(deltaController.text.trim()) ?? 0;
                  final deltaPaisa = parsedRupees * 100;
                  Navigator.of(ctx).pop();
                  widget.onCounter(deltaPaisa, notesController.text.trim());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0071E3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Submit Counter-Offer', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent = widget.booking.isUrgent;
    final isExpired = _remainingSla == Duration.zero;
    final inRupees = widget.booking.totalAmountPaisa ~/ 100;

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.black.withAlpha(15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: SLA Badge + Urgency
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUrgent ? const Color(0xFFFFEBEE) : const Color(0xFFFFF4E5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: isUrgent ? const Color(0xFFDC3545) : const Color(0xFFB25E00),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isExpired ? 'SLA EXPIRED' : 'SLA: ${_formatDuration(_remainingSla)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isUrgent ? const Color(0xFFDC3545) : const Color(0xFFB25E00),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  widget.booking.isUrgent ? 'LAST-MINUTE (4h)' : 'STANDARD (24h)',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black45),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.booking.eventType,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: -0.3),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.black54),
                const SizedBox(width: 6),
                Text(
                  '${widget.booking.eventDate} • ${widget.booking.timeRange}',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Gross Payout Offer', style: TextStyle(fontSize: 13, color: Colors.black54)),
                Text(
                  '₹$inRupees',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Buttons: Accept / Counter / Reject
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: isExpired ? null : widget.onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF198754),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: isExpired ? null : () => _openCounterOfferModal(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0071E3)),
                        foregroundColor: const Color(0xFF0071E3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Counter', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: widget.onReject,
                  icon: const Icon(Icons.close_rounded, color: Color(0xFFDC3545), size: 22),
                  tooltip: 'Decline Booking',
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEBEE),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}