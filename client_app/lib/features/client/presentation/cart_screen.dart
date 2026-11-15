import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'controllers/cart_controller.dart';

class CartScreen extends StatefulWidget {
  final String? packageId;
  const CartScreen({super.key, this.packageId});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final CartController _controller;

  final List<Map<String, dynamic>> _mockCartSlots = [
    {
      'provider_id': '449a9131-44c9-49a3-82f7-51e5c5a0637b',
      'provider_name': 'The Royal Symphony Band',
      'category': 'Entertainment',
      'service_title': 'Live Sufi & Fusion Performance',
      'event_date': '2026-10-25',
      'start_time': '18:00:00',
      'end_time': '22:00:00',
      'price_paisa': 1500000,
    }
  ];

  @override
  void initState() {
    super.initState();
    _controller = CartController()..addListener(() => setState(() {}));
    // Auto-initiate live preview countdown on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.startPreviewTimer();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatTimer(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = _controller.state;

    final int subtotalPaisa = state.quote?['base_quote_paisa'] ??
        _mockCartSlots.fold<int>(0, (sum, item) => sum + (item['price_paisa'] as int));
    final int platformFeePaisa = state.quote?['platform_fee_paisa'] ?? ((subtotalPaisa * 500 + 5000) ~/ 10000);
    final int gstPaisa = state.quote?['gst_paisa'] ?? (((subtotalPaisa + platformFeePaisa) * 1800 + 5000) ~/ 10000);
    final int totalPayablePaisa = state.quote?['total_payable_paisa'] ?? (subtotalPaisa + platformFeePaisa + gstPaisa);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Cart (BME)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // 15-Minute Reservation Hold Countdown Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: state.isExpired
                ? AppColors.statusError.withValues(alpha: 0.15)
                : state.isLockAcquired
                    ? AppColors.statusSuccess.withValues(alpha: 0.15)
                    : AppColors.statusWarning.withValues(alpha: 0.15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  state.isExpired
                      ? Icons.lock_clock_outlined
                      : state.isLockAcquired
                          ? Icons.lock_outline
                          : Icons.hourglass_top,
                  size: 18,
                  color: state.isExpired
                      ? AppColors.statusError
                      : state.isLockAcquired
                          ? AppColors.statusSuccess
                          : const Color(0xFF856404),
                ),
                const SizedBox(width: 8),
                Text(
                  state.isExpired
                      ? 'Reservation hold expired. Slots released.'
                      : state.isLockAcquired
                          ? 'Lock Active: ${_formatTimer(state.remainingSeconds)} remaining'
                          : 'Hold Active: ${_formatTimer(state.remainingSeconds)} (Confirming...)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: state.isExpired
                        ? AppColors.statusError
                        : state.isLockAcquired
                            ? AppColors.statusSuccess
                            : const Color(0xFF856404),
                  ),
                ),
              ],
            ),
          ),
          if (state.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              color: AppColors.statusError.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.statusError, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: const TextStyle(color: AppColors.statusError, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  'Selected Services (${_mockCartSlots.length})',
                  style: theme.textTheme.headlineSmall?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 12),
                ..._mockCartSlots.map((item) {
                  final priceRupees = (item['price_paisa'] as int) ~/ 100;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item['category'] as String,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              Text(
                                '₹$priceRupees',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.actionPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['service_title'] as String,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'By ${item['provider_name']} • Date: ${item['event_date']}',
                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgElevatedLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    children: [
                      _buildPriceRow('Subtotal', '₹${subtotalPaisa ~/ 100}'),
                      const SizedBox(height: 8),
                      _buildPriceRow('Platform Fee (5%)', '₹${platformFeePaisa ~/ 100}'),
                      const SizedBox(height: 8),
                      _buildPriceRow('Statutory GST (18%)', '₹${gstPaisa ~/ 100}'),
                      const Divider(height: 24),
                      _buildPriceRow('Total Payable', '₹${totalPayablePaisa ~/ 100}', isTotal: true),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.shield_outlined, color: AppColors.statusSuccess),
                  title: Text(
                    '14-Day Nodal Escrow Protection',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  subtitle: Text('Payment is secured and held in trust until event completion.'),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.08))),
            ),
            child: SafeArea(
              bottom: true,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: state.isExpired ? Colors.grey : AppColors.actionPrimary,
                ),
                onPressed: (state.isExpired || state.isLoading)
                    ? null
                    : () async {
                        final success = await _controller.checkoutAndAcquireHold(
                          slots: _mockCartSlots,
                          existingPackageId: widget.packageId,
                        );

                        if (!context.mounted) return;
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reservation hold verified. Proceeding to payment gateway...'),
                              backgroundColor: AppColors.statusSuccess,
                            ),
                          );
                        }
                      },
                child: state.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        state.isExpired
                            ? 'Reservation Expired'
                            : 'Pay ₹${totalPayablePaisa ~/ 100} & Confirm',
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black87 : Colors.black54,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? AppColors.actionPrimary : Colors.black87,
          ),
        ),
      ],
    );
  }
}