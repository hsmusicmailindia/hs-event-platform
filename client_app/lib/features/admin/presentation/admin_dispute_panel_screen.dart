import 'package:flutter/material.dart';
import '../data/admin_dispute_repository.dart';
import 'widgets/split_slider_widget.dart';

class AdminDisputePanelScreen extends StatefulWidget {
  const AdminDisputePanelScreen({super.key});

  @override
  State<AdminDisputePanelScreen> createState() => _AdminDisputePanelScreenState();
}

class _AdminDisputePanelScreenState extends State<AdminDisputePanelScreen> with SingleTickerProviderStateMixin {
  final AdminDisputeRepository _repository = AdminDisputeRepository();
  late TabController _tabController;
  List<DisputeRecord> _disputes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDisputes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDisputes() async {
    setState(() => _isLoading = true);
    final data = await _repository.fetchDisputes();
    if (!mounted) return;
    setState(() {
      _disputes = data;
      _isLoading = false;
    });
  }

  void _showSettlementReceiptModal(DisputeRecord dispute, int clientPaisa, int providerPaisa, int clientPercent) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: Color(0xFF198754), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Escrow Settlement Executed',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        Text(
                          'Booking ID: ${dispute.bookingId} • Status: SPLIT_ARBITRATED',
                          style: const TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBFBFD),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black.withAlpha(12)),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow('Client Refund ($clientPercent%):', '₹${clientPaisa ~/ 100}', const Color(0xFFDC3545)),
                    const SizedBox(height: 8),
                    _buildReceiptRow('Provider Payout (${100 - clientPercent}%):', '₹${providerPaisa ~/ 100}', const Color(0xFF198754)),
                    const SizedBox(height: 8),
                    const Divider(height: 1, thickness: 0.5),
                    const SizedBox(height: 8),
                    _buildReceiptRow('Retained Platform Fee:', '₹${dispute.platformFeePaisa ~/ 100}', const Color(0xFF0071E3)),
                    const SizedBox(height: 4),
                    _buildReceiptRow('Shielded Gateway Fee:', '₹${dispute.gatewayFeePaisa ~/ 100}', Colors.black54),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _tabController.animateTo(1); // Switch to "Arbitrated" tab automatically
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0071E3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('View in Arbitrated Ledger', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String title, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: valueColor)),
      ],
    );
  }

  void _openArbitrationModal(DisputeRecord dispute) {
    int clientRatio = 50;
    int clientPaisa = (dispute.maxRefundablePoolPaisa * 0.50).round();
    int providerPaisa = dispute.maxRefundablePoolPaisa - clientPaisa;
    final notesController = TextEditingController(text: 'Split agreed based on verified event timeline.');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Arbitrate Escrow Split',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Dispute ID: ${dispute.disputeId.toUpperCase()} • Booking: ${dispute.bookingId}',
                style: const TextStyle(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              // Split Slider
              SplitSliderWidget(
                maxPoolPaisa: dispute.maxRefundablePoolPaisa,
                onSplitChanged: (percent, cPaisa, pPaisa) {
                  setModalState(() {
                    clientRatio = percent;
                    clientPaisa = cPaisa;
                    providerPaisa = pPaisa;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Non-Refundable Fee Protection Shield
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, size: 18, color: Color(0xFFB25E00)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Platform Fee (₹${dispute.platformFeePaisa ~/ 100}) & Sunk Gateway Fee (₹${dispute.gatewayFeePaisa ~/ 100}) are shielded from refund liability.',
                        style: const TextStyle(fontSize: 11, color: Color(0xFFB25E00), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'Arbitration Order Notes',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop(); // Close arbitration slider modal

                    final success = await _repository.arbitrateDispute(
                      bookingId: dispute.bookingId,
                      clientRefundPaisa: clientPaisa,
                      providerPayoutPaisa: providerPaisa,
                      arbitrationNotes: notesController.text.trim(),
                    );

                    if (!mounted) return;
                    if (success) {
                      await _loadDisputes();
                      _showSettlementReceiptModal(dispute, clientPaisa, providerPaisa, clientRatio);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0071E3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Execute Final Split Settlement', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
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
    final activeList = _disputes.where((d) => d.status == 'disputed').toList();
    final arbitratedList = _disputes.where((d) => d.status == 'split_arbitrated').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Admin Dispute Arbitration',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Colors.black87),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0071E3),
          unselectedLabelColor: Colors.black54,
          indicatorColor: const Color(0xFF0071E3),
          tabs: [
            Tab(text: 'Active Disputes (${activeList.length})'),
            Tab(text: 'Arbitrated (${arbitratedList.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildActiveTab(activeList),
                _buildArbitratedTab(arbitratedList),
              ],
            ),
    );
  }

  Widget _buildActiveTab(List<DisputeRecord> activeList) {
    if (activeList.isEmpty) {
      return _buildEmptyState('Zero Active Disputes', 'All disputes have been arbitrated or completed.');
    }
    return RefreshIndicator(
      onRefresh: _loadDisputes,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: activeList.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (ctx, index) => _buildActiveDisputeCard(activeList[index]),
      ),
    );
  }

  Widget _buildArbitratedTab(List<DisputeRecord> arbitratedList) {
    if (arbitratedList.isEmpty) {
      return _buildEmptyState('No Arbitrated Settlements Yet', 'Executed splits will be archived here for financial audits.');
    }
    return RefreshIndicator(
      onRefresh: _loadDisputes,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: arbitratedList.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (ctx, index) => _buildArbitratedDisputeCard(arbitratedList[index]),
      ),
    );
  }

  Widget _buildActiveDisputeCard(DisputeRecord dispute) {
    final poolRupees = dispute.maxRefundablePoolPaisa ~/ 100;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.gavel_rounded, size: 14, color: Color(0xFFDC3545)),
                      const SizedBox(width: 6),
                      Text(
                        'DISPUTE #${dispute.disputeId.toUpperCase()}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFDC3545), letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Pool: ₹$poolRupees',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              dispute.eventName,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: -0.3),
            ),
            const SizedBox(height: 4),
            Text(
              'Client: ${dispute.clientName} • Provider: ${dispute.providerName}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 14),

            // Claims Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFBFBFD),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black.withAlpha(10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Client Claim: ', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFFDC3545))),
                      Expanded(child: Text(dispute.clientReason, style: const TextStyle(fontSize: 12, color: Colors.black87))),
                    ],
                  ),
                  if (dispute.providerRebuttal != null) ...[
                    const SizedBox(height: 8),
                    const Divider(height: 1, thickness: 0.5),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Rebuttal: ', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF0071E3))),
                        Expanded(child: Text(dispute.providerRebuttal!, style: const TextStyle(fontSize: 12, color: Colors.black87))),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => _openArbitrationModal(dispute),
                icon: const Icon(Icons.tune_rounded, size: 18),
                label: const Text('Arbitrate Settlement (Split Slider)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0071E3),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArbitratedDisputeCard(DisputeRecord dispute) {
    final clientRupees = (dispute.arbitratedClientPaisa ?? 0) ~/ 100;
    final providerRupees = (dispute.arbitratedProviderPaisa ?? 0) ~/ 100;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF198754)),
                      const SizedBox(width: 6),
                      Text(
                        'SETTLED #${dispute.disputeId.toUpperCase()}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF198754), letterSpacing: 1),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Escrow Released',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF198754)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              dispute.eventName,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: -0.3),
            ),
            const SizedBox(height: 4),
            Text(
              'Client: ${dispute.clientName} • Provider: ${dispute.providerName}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 14),

            // Execution Breakdown
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFBFBFD),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black.withAlpha(10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Client Refund', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      const SizedBox(height: 2),
                      Text('₹$clientRupees', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFFDC3545))),
                    ],
                  ),
                  Container(height: 24, width: 1, color: Colors.black12),
                  Column(
                    children: [
                      const Text('Provider Payout', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      const SizedBox(height: 2),
                      Text('₹$providerRupees', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF198754))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.done_all_rounded, color: Color(0xFF198754), size: 32),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }
}