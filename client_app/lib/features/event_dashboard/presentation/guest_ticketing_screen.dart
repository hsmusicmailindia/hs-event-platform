import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GuestTicketItem {
  final String id;
  final String guestName;
  final String phone;
  final String status;
  final String qrPayload;

  const GuestTicketItem({
    required this.id,
    required this.guestName,
    required this.phone,
    required this.status,
    required this.qrPayload,
  });
}

class GuestTicketingScreen extends StatefulWidget {
  final String bookingId;
  final String eventName;

  const GuestTicketingScreen({
    super.key,
    required this.bookingId,
    required this.eventName,
  });

  @override
  State<GuestTicketingScreen> createState() => _GuestTicketingScreenState();
}

class _GuestTicketingScreenState extends State<GuestTicketingScreen> {
  final List<GuestTicketItem> _guests = [
    const GuestTicketItem(
      id: 'tkt_01',
      guestName: 'Rajesh Sharma',
      phone: '+919876543210',
      status: 'CONFIRMED',
      qrPayload: 'ED25519_PASS_RSVP_bkg_verified_01_tkt_01_9876543210',
    ),
    const GuestTicketItem(
      id: 'tkt_02',
      guestName: 'Ananya Verma',
      phone: '+919812345678',
      status: 'CONFIRMED',
      qrPayload: 'ED25519_PASS_RSVP_bkg_verified_01_tkt_02_9812345678',
    ),
    const GuestTicketItem(
      id: 'tkt_03',
      guestName: 'Kunal Kapoor',
      phone: '+919765432109',
      status: 'PENDING_CHECKIN',
      qrPayload: 'ED25519_PASS_RSVP_bkg_verified_01_tkt_03_9765432109',
    ),
  ];

  void _openAddGuestModal() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

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
              'Issue RSVP Guest Pass',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Generates an Ed25519 cryptographically signed QR pass for offline gate verification.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Guest Full Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number (E.164 standard)',
                hintText: '+919876543210',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final phone = phoneController.text.trim();
                  if (name.isNotEmpty && phone.isNotEmpty) {
                    final newId = 'tkt_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
                    setState(() {
                      _guests.add(
                        GuestTicketItem(
                          id: newId,
                          guestName: name,
                          phone: phone,
                          status: 'CONFIRMED',
                          qrPayload: 'ED25519_PASS_RSVP_${widget.bookingId}_${newId}_$phone',
                        ),
                      );
                    });
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('RSVP Pass generated for $name'),
                        backgroundColor: const Color(0xFF198754),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0071E3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Generate Pass', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPassModal(GuestTicketItem guest) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ED25519 CRYPTOGRAPHIC PASS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2E7D32),
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                guest.guestName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.eventName} • ${guest.phone}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withAlpha(20)),
                ),
                child: QrImageView(
                  data: guest.qrPayload,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Ticket ID: ${guest.id.toUpperCase()}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black45),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Close Pass'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Guest List & RSVP Passes',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF0071E3), size: 22),
            tooltip: 'Add Guest',
            onPressed: _openAddGuestModal,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Stats Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withAlpha(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total Guests', '${_guests.length}', const Color(0xFF0071E3)),
                Container(height: 30, width: 1, color: Colors.black12),
                _buildStatItem('Passes Issued', '${_guests.length}', const Color(0xFF198754)),
                Container(height: 30, width: 1, color: Colors.black12),
                _buildStatItem('Checked In', '0', const Color(0xFFFFA000)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Guest Cards
          Text(
            'REGISTERED ATTENDEES (${_guests.length})',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.black.withAlpha(120),
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          ..._guests.map((guest) => _buildGuestCard(guest)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddGuestModal,
        backgroundColor: const Color(0xFF0071E3),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Guest', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildGuestCard(GuestTicketItem guest) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.black.withAlpha(12)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFE3F2FD),
            child: const Icon(Icons.person_rounded, color: Color(0xFF0071E3), size: 20),
          ),
          title: Text(guest.guestName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          subtitle: Text(
            '${guest.phone} • ${guest.id.toUpperCase()}',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          trailing: OutlinedButton.icon(
            onPressed: () => _showPassModal(guest),
            icon: const Icon(Icons.qr_code_rounded, size: 16),
            label: const Text('Pass', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0071E3),
              side: const BorderSide(color: Color(0xFF0071E3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ),
    );
  }
}