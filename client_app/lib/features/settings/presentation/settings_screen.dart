import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../discovery/presentation/discovery_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isProcessing = false;

  Future<void> _handleAccountDeletion() async {
    setState(() => _isProcessing = true);

    try {
      final response = await _apiClient.request(
        path: '/rest/v1/rpc/request_account_deletion',
        method: 'POST',
      );

      if (!mounted) return;
      setState(() => _isProcessing = false);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account anonymized per DPDP Act 2023. Session cleared.'),
              backgroundColor: Color(0xFF198754),
            ),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const DiscoveryScreen()),
            (route) => false,
          );
        } else if (data['error_code'] == 'ERR_ACTIVE_LIABILITY') {
          _showActiveLiabilityModal(data['active_bookings'] ?? 1);
        }
      } else {
        _showActiveLiabilityModal(1);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showActiveLiabilityModal(1);
    }
  }

  void _showActiveLiabilityModal(int activeCount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3CD),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_outlined, color: Color(0xFF856404), size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              'Account Deletion Blocked',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Under Indian DPDP Act 2023 and Financial Regulations, you cannot delete an account while holding $activeCount active booking(s) or escrow funds.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0071E3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Understand & Return', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Account?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
          'This action will permanently anonymize your personal information under the DPDP Act 2023. Historical billing ledgers will be retained for tax audit compliance.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _handleAccountDeletion();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC3545),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Yes, Anonymize Data'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      appBar: AppBar(
        title: const Text(
          'Settings & Privacy',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Section 1: User Identity Card
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.black.withAlpha(15)),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFFE3F2FD),
                    child: Icon(Icons.person, color: Color(0xFF0071E3), size: 28),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Authorized Client Account', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        SizedBox(height: 2),
                        Text('+91 Verified Session', style: TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section 2: Legal & Governance
          Text(
            'LEGAL & REGULATORY',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black.withAlpha(120), letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.black.withAlpha(15)),
            ),
            child: Column(
              children: [
                _buildTile(Icons.policy_outlined, 'Privacy Policy (DPDP Act 2023)'),
                const Divider(height: 1, indent: 52, thickness: 0.5),
                _buildTile(Icons.account_balance_outlined, 'Nodal Escrow & Cancellation Terms'),
                const Divider(height: 1, indent: 52, thickness: 0.5),
                _buildTile(Icons.verified_user_outlined, 'Platform Trust & Verification'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 3: Danger Zone (DPDP Deletion)
          Text(
            'DATA PRIVACY & ACCOUNT',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black.withAlpha(120), letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.black.withAlpha(15)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.delete_forever_outlined, color: Color(0xFFDC3545), size: 20),
              ),
              title: const Text('Delete Account & Anonymize', style: TextStyle(color: Color(0xFFDC3545), fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: const Text('Exercise DPDP Right to Erasure', style: TextStyle(fontSize: 11, color: Colors.black45)),
              trailing: _isProcessing
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black26),
              onTap: _isProcessing ? null : _confirmDeletionDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(IconData icon, String title) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: const Color(0xFF0071E3), size: 18),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.black26),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Viewing $title')));
      },
    );
  }
}