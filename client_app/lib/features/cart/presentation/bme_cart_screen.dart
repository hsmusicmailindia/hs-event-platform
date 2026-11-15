import '../../booking_success/presentation/booking_success_screen.dart';
import 'package:flutter/material.dart';
import '../data/cart_models.dart';
import '../data/bme_cart_repository.dart';

class BmeCartScreen extends StatefulWidget {
  final List<CartItemModel> initialItems;

  const BmeCartScreen({
    super.key,
    required this.initialItems,
  });

  @override
  State<BmeCartScreen> createState() => _BmeCartScreenState();
}

class _BmeCartScreenState extends State<BmeCartScreen> {
  final BmeCartRepository _repository = BmeCartRepository();
  late List<CartItemModel> _items;
  Future<AuthoritativeQuoteModel>? _quoteFuture;
  AuthoritativeQuoteModel? _cachedQuote;
  bool _isCheckingOut = false;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.initialItems);
    _refreshQuote();
  }

  void _refreshQuote() {
    if (_items.isEmpty) {
      setState(() {
        _quoteFuture = null;
        _cachedQuote = null;
      });
      return;
    }
    setState(() {
      _quoteFuture = _repository.calculateAuthoritativeQuote(_items).then((quote) {
        _cachedQuote = quote;
        return quote;
      });
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    _refreshQuote();
  }

  Future<void> _handleCheckout() async {
    if (_cachedQuote == null || _isCheckingOut) return;

    setState(() {
      _isCheckingOut = true;
    });

    final result = await _repository.executeCheckoutIntent(
      items: _items,
      quote: _cachedQuote!,
    );

    if (!mounted) return;

    setState(() {
      _isCheckingOut = false;
    });

    if (result.isGistCollision) {
      _showCollisionDialog(result.errorMessage!);
    } else if (result.isSuccess) {
      _showPaymentGatewayModal(result.gatewayOrderId!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? 'Checkout failed. Please retry.')),
      );
    }
  }

  void _showCollisionDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Slot Unavailable'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Choose Alternate Slot'),
          ),
        ],
      ),
    );
  }

  void _showPaymentGatewayModal(String orderId) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment Gateway Bridge',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '15-Min Lock Active',
                    style: TextStyle(color: Color(0xFF2E7D32), fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Simulating Gateway Transaction for Order Reference:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(
              orderId,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Payable:'),
                Text(
                  _cachedQuote != null ? _cachedQuote!.formatPaisa(_cachedQuote!.totalAmountPaisa) : '',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  final formattedTotal = _cachedQuote != null
                      ? _cachedQuote!.formatPaisa(_cachedQuote!.totalAmountPaisa)
                      : '₹0';
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => BookingSuccessScreen(
                        orderId: orderId,
                        totalPaidFormatted: formattedTotal,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0071E3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Simulate Success (Capture & Confirm)', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel Payment', style: TextStyle(color: Colors.black54)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      appBar: AppBar(
        title: Text(
          'Build My Event Cart',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _items.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                _buildHoldTimerBanner(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Selected Event Services (${_items.length})',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      ..._items.asMap().entries.map((entry) {
                        return _buildCartItemCard(context, entry.key, entry.value);
                      }),
                      const SizedBox(height: 16),
                      if (_quoteFuture != null) _buildAuthoritativeSummaryCard(context),
                    ],
                  ),
                ),
                if (_quoteFuture != null) _buildBottomCheckoutBar(context),
              ],
            ),
    );
  }

  Widget _buildHoldTimerBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFFFFF4E5),
      child: const Row(
        children: [
          Icon(Icons.timer_outlined, size: 18, color: Color(0xFFFF9500)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Slots reserved for 15:00 minutes upon checkout',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFFB25E00),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.black26),
          const SizedBox(height: 16),
          Text(
            'Your event cart is empty',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Explore providers and assemble your event package.',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, int index, CartItemModel item) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withAlpha(15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.businessName,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  item.tierName,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Text(
                  item.formattedPrice,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1D1D1F),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: Colors.black45),
            onPressed: () => _removeItem(index),
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }

  Widget _buildAuthoritativeSummaryCard(BuildContext context) {
    return FutureBuilder<AuthoritativeQuoteModel>(
      future: _quoteFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(strokeWidth: 2.0),
          ));
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.redAccent.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('Failed to calculate quote: ${snapshot.error}'),
          );
        }

        final quote = snapshot.data!;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withAlpha(15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Authoritative Price Breakdown',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _buildSummaryRow('Base Services Subtotal', quote.formatPaisa(quote.baseQuotePaisa)),
              const SizedBox(height: 8),
              _buildSummaryRow('GST (18% Statutory)', quote.formatPaisa(quote.gstPaisa)),
              const SizedBox(height: 10),
              const Divider(height: 1, thickness: 0.5),
              const SizedBox(height: 10),
              _buildSummaryRow('Total Event Cost', quote.formatPaisa(quote.totalAmountPaisa), isTotal: true),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
            color: isTotal ? const Color(0xFF1D1D1F) : Colors.black54,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 17 : 13,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: const Color(0xFF1D1D1F),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomCheckoutBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withAlpha(15))),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isCheckingOut ? null : _handleCheckout,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0071E3),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isCheckingOut
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    'Confirm Package & Pay',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ),
    );
  }
}