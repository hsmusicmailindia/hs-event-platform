import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

enum BookingRequestState { requested, pendingClientApproval, confirmed, rejected }

class BookingRequestModel {
  final String bookingId;
  final String clientName;
  final String serviceTitle;
  final String category;
  final int baseQuotePaisa;
  final DateTime eventDateTime;
  final DateTime requestedAt;
  BookingRequestState state;
  int? counterDeltaPaisa;
  String? counterReason;

  BookingRequestModel({
    required this.bookingId,
    required this.clientName,
    required this.serviceTitle,
    required this.category,
    required this.baseQuotePaisa,
    required this.eventDateTime,
    required this.requestedAt,
    this.state = BookingRequestState.requested,
    this.counterDeltaPaisa,
    this.counterReason,
  });

  // PRD AC-08: Dynamic SLA (4 hours if event < 48 hours away, else 24 hours)
  Duration get slaTotalDuration {
    final diffToEvent = eventDateTime.difference(requestedAt);
    if (diffToEvent.inHours < 48) {
      return const Duration(hours: 4);
    }
    return const Duration(hours: 24);
  }

  DateTime get slaDeadline => requestedAt.add(slaTotalDuration);
}

class BookingRequestsScreen extends StatefulWidget {
  const BookingRequestsScreen({super.key});

  @override
  State<BookingRequestsScreen> createState() => _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends State<BookingRequestsScreen> {
  Timer? _slaTimer;

  // Mock Active Requests (Simulating 1 Urgent & 1 Standard Request)
  late final List<BookingRequestModel> _requests;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _requests = [
      BookingRequestModel(
        bookingId: 'bkg-urg-101',
        clientName: 'Vikram Malhotra',
        serviceTitle: 'Live Acoustic Performance • 3 Hours',
        category: 'artist',
        baseQuotePaisa: 2000000, // ₹20,000
        eventDateTime: now.add(const Duration(hours: 36)), // < 48 hours -> 4h SLA
        requestedAt: now.subtract(const Duration(hours: 1, minutes: 20)),
      ),
      BookingRequestModel(
        bookingId: 'bkg-std-202',
        clientName: 'Pooja Agarwal',
        serviceTitle: 'Wedding Sangeet Trio Setup',
        category: 'artist',
        baseQuotePaisa: 4500000, // ₹45,000
        eventDateTime: now.add(const Duration(days: 14)), // Standard -> 24h SLA
        requestedAt: now.subtract(const Duration(hours: 4)),
      ),
    ];

    _slaTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _slaTimer?.cancel();
    super.dispose();
  }

  String _formatPaisa(int paisa) => '₹${(paisa / 100).toStringAsFixed(2)}';

  String _formatRemaining(DateTime deadline) {
    final diff = deadline.difference(DateTime.now());
    if (diff.isNegative) return 'SLA BREACHED (EXPIRED)';
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void _openCounterOfferModal(BookingRequestModel req) {
    final deltaController = TextEditingController();
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Submit Counter-Offer',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Original Quote: ${_formatPaisa(req.baseQuotePaisa)}',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: deltaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Additional Delta Amount (₹)',
                    hintText: 'e.g. 2500 for travel/equipment',
                    prefixText: '₹ ',
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Enter a valid amount';
                    final parsed = int.tryParse(val);
                    if (parsed == null || parsed <= 0) return 'Must be greater than 0';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: reasonController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Reason for Revision',
                    hintText: 'e.g. Sound engineer addition & outstation transit',
                    filled: true,
                    fillColor: const Color(0xFFF8F9FA),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Reason is required';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.actionPrimary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (formKey.currentState?.validate() == true) {
                      final deltaRupees = int.parse(deltaController.text.trim());
                      final deltaPaisa = deltaRupees * 100;
                      setState(() {
                        req.state = BookingRequestState.pendingClientApproval;
                        req.counterDeltaPaisa = deltaPaisa;
                        req.counterReason = reasonController.text.trim();
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Counter-offer of ₹$deltaRupees sent to client.'),
                          backgroundColor: AppColors.statusSuccess,
                        ),
                      );
                    }
                  },
                  child: const Text('Dispatch Counter-Offer (Pause SLA)', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Booking Inquiries & SLAs',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _requests.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, idx) {
          final req = _requests[idx];
          final isUrgent = req.slaTotalDuration.inHours == 4;
          final isPendingApproval = req.state == BookingRequestState.pendingClientApproval;
          final isConfirmed = req.state == BookingRequestState.confirmed;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUrgent ? AppColors.statusError.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.06),
                width: isUrgent ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isUrgent
                            ? AppColors.statusError.withValues(alpha: 0.1)
                            : AppColors.actionPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isUrgent ? 'URGENT SLA (4H)' : 'STANDARD SLA (24H)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isUrgent ? AppColors.statusError : AppColors.actionPrimary,
                        ),
                      ),
                    ),
                    Text(
                      isPendingApproval
                          ? 'Awaiting Client'
                          : isConfirmed
                              ? 'CONFIRMED'
                              : _formatRemaining(req.slaDeadline),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isPendingApproval ? Colors.amber[800] : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(req.clientName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(req.serviceTitle, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Base Offer Amount:', style: TextStyle(color: Colors.black45, fontSize: 12)),
                    Text(_formatPaisa(req.baseQuotePaisa), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
                if (isPendingApproval && req.counterDeltaPaisa != null) ...[
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Proposed Revision:', style: TextStyle(color: Colors.black45, fontSize: 12)),
                      Text(
                        '+${_formatPaisa(req.counterDeltaPaisa!)} (Total: ${_formatPaisa(req.baseQuotePaisa + req.counterDeltaPaisa!)})',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.actionPrimary),
                      ),
                    ],
                  ),
                  if (req.counterReason != null) ...[
                    const SizedBox(height: 2),
                    Text('Note: ${req.counterReason}', style: const TextStyle(color: Colors.black54, fontSize: 11, fontStyle: FontStyle.italic)),
                  ],
                ],
                const SizedBox(height: 16),
                if (req.state == BookingRequestState.requested) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.actionPrimary,
                            side: const BorderSide(color: AppColors.actionPrimary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _openCounterOfferModal(req),
                          child: const Text('Counter-Offer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.statusSuccess,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            setState(() => req.state = BookingRequestState.confirmed);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Booking Accepted. Slot locked on calendar.'),
                                backgroundColor: AppColors.statusSuccess,
                              ),
                            );
                          },
                          child: const Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ] else if (isPendingApproval) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Counter-Offer Dispatched • SLA Paused for Client Approval',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF856404)),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}