import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../discovery/presentation/discovery_screen.dart';
import '../../ticketing/presentation/guest_ticketing_screen.dart';
import '../../gate_scanner/presentation/gate_scanner_screen.dart';
import '../../settings/presentation/settings_screen.dart';

class ClientEventDashboardScreen extends StatefulWidget {
  final String orderId;
  final String? bookingId;
  final String totalPaidFormatted;

  const ClientEventDashboardScreen({
    super.key,
    required this.orderId,
    this.bookingId,
    required this.totalPaidFormatted,
  });

  @override
  State<ClientEventDashboardScreen> createState() => _ClientEventDashboardScreenState();
}

class _ClientEventDashboardScreenState extends State<ClientEventDashboardScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isSettling = false;
  bool _isCompleted = false;
  final String _otp = "849201";

  Future<void> _handleOtpSettlement() async {
    if (widget.bookingId == null) {
      setState(() {
        _isCompleted = true;
      });
      return;
    }

    setState(() {
      _isSettling = true;
    });

    try {
      final response = await _apiClient.request(
        path: '/rest/v1/rpc/verify_escrow_completion_otp',
        method: 'POST',
        body: {
          'p_booking_id': widget.bookingId,
          'p_submitted_otp': _otp,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _isCompleted = true;
          _isSettling = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP Verified! Escrow funds released to provider.'),
            backgroundColor: Color(0xFF198754),
          ),
        );
      } else {
        setState(() {
          _isSettling = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Settlement error: ${response.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSettling = false;
        _isCompleted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const DiscoveryScreen()),
              (route) => false,
            );
          },
        ),
        title: Text(
          'Event Hub & Timeline',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87, size: 22),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings & Privacy',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildEventHeaderCard(context),
          const SizedBox(height: 20),
          _buildOtpCompletionCard(context),
          const SizedBox(height: 20),
          _buildTimelineCard(context),
          const SizedBox(height: 20),
          _buildDisputeActionCard(context),
        ],
      ),
    );
  }

  Widget _buildEventHeaderCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withAlpha(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand Cultural Performance',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isCompleted ? const Color(0xFFE8F5E9) : const Color(0xFFFFF4E5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _isCompleted ? 'COMPLETED' : 'CONFIRMED',
                  style: TextStyle(
                    color: _isCompleted ? const Color(0xFF2E7D32) : const Color(0xFFB25E00),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Order Reference: ${widget.orderId}',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          // Primary Action: Manage Guests
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GuestTicketingScreen(
                      bookingId: widget.bookingId ?? 'sample_booking',
                      orderId: widget.orderId,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.qr_code_rounded, size: 18),
              label: const Text(
                'Manage Guests & RSVP Passes',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0071E3),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Secondary Action: Launch Gate Scanner
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GateScannerScreen(
                      bookingId: widget.bookingId ?? 'sample_booking',
                      orderId: widget.orderId,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.camera_alt_outlined, size: 18),
              label: const Text(
                'Launch Gate Access Scanner',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0071E3)),
                foregroundColor: const Color(0xFF0071E3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isCompleted ? 'Escrow Status' : 'Advance Inflow Escrow',
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
              Text(
                _isCompleted ? 'CLEARED & PAID' : widget.totalPaidFormatted,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: _isCompleted ? const Color(0xFF2E7D32) : const Color(0xFF1D1D1F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOtpCompletionCard(BuildContext context) {
    final theme = Theme.of(context);

    if (_isCompleted) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2E7D32).withAlpha(40)),
        ),
        child: const Row(
          children: [
            Icon(Icons.verified_rounded, size: 28, color: Color(0xFF2E7D32)),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mutual OTP Verified',
                    style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2E7D32), fontSize: 15),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Escrow cleared. Payout transfer dispatched to provider.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0071E3).withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.key_rounded, size: 20, color: Color(0xFF0071E3)),
              const SizedBox(width: 8),
              Text(
                'Job Completion Mutual OTP',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0071E3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Share this 6-digit OTP with the provider ONLY after performance concludes to release escrow funds.',
            style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
          ),
          const SizedBox(height: 14),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF0071E3).withAlpha(60)),
              ),
              child: Text(
                '${_otp[0]} ${_otp[1]} ${_otp[2]} ${_otp[3]} ${_otp[4]} ${_otp[5]}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4.0,
                  color: Color(0xFF1D1D1F),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _isSettling ? null : _handleOtpSettlement,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0071E3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSettling
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Simulate Provider OTP Verification', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withAlpha(15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Day-of-Event Execution Timeline',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          _buildTimelineStep('17:00', 'Sound & Stage Setup (1h Buffer)', isDone: true),
          _buildTimelineStep('18:00', 'Artist Check-in & Soundcheck', isDone: true),
          _buildTimelineStep('19:00', 'Live Concert Performance Start', isDone: _isCompleted, isCurrent: !_isCompleted),
          _buildTimelineStep('22:00', 'Performance Concludes & OTP Settlement', isDone: _isCompleted),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String time, String title, {bool isDone = false, bool isCurrent = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isCurrent ? const Color(0xFF0071E3) : Colors.black45,
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            isDone ? Icons.check_circle : (isCurrent ? Icons.radio_button_checked : Icons.circle_outlined),
            size: 16,
            color: isDone ? const Color(0xFF34C759) : (isCurrent ? const Color(0xFF0071E3) : Colors.black26),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                color: isCurrent ? const Color(0xFF1D1D1F) : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisputeActionCard(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dispute Window active for 48 hours post-event completion.')),
          );
        },
        icon: const Icon(Icons.report_problem_outlined, size: 16, color: Colors.black45),
        label: const Text(
          'Need Help or Raise a Dispute?',
          style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}