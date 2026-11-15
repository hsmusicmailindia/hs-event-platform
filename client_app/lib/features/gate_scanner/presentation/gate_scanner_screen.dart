import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../data/gate_scan_model.dart';
import '../data/gate_scanner_repository.dart';

class GateScannerScreen extends StatefulWidget {
  final String bookingId;
  final String orderId;

  const GateScannerScreen({
    super.key,
    required this.bookingId,
    required this.orderId,
  });

  @override
  State<GateScannerScreen> createState() => _GateScannerScreenState();
}

class _GateScannerScreenState extends State<GateScannerScreen> {
  final GateScannerRepository _repository = GateScannerRepository();
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  GateScanRecord? _lastScan;
  bool _isProcessing = false;
  bool _isTorchOn = false;
  bool _isSyncing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() => _isProcessing = true);

    final record = await _repository.verifyTicketPayload(
      bookingId: widget.bookingId,
      rawPayload: code,
    );

    if (!mounted) return;

    setState(() {
      _lastScan = record;
    });

    await Future.delayed(const Duration(milliseconds: 1800));

    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _toggleTorch() async {
    try {
      await _scannerController.toggleTorch();
      if (mounted) {
        setState(() {
          _isTorchOn = !_isTorchOn;
        });
      }
    } catch (_) {
      // Torch fallback
    }
  }

  Future<void> _triggerCloudSync() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    final synced = await _repository.syncPendingScans(widget.bookingId);

    if (!mounted) return;
    setState(() => _isSyncing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(synced > 0 ? '$synced scans synced to cloud!' : 'All scans already synced.'),
        backgroundColor: const Color(0xFF198754),
      ),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _repository.pendingSyncCount;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Gate Access Scanner',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
              size: 20,
            ),
            onPressed: _toggleTorch,
            tooltip: 'Toggle Flashlight',
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full-Screen Edge-to-Edge Camera Viewfinder
          MobileScanner(
            controller: _scannerController,
            fit: BoxFit.cover,
            onDetect: _onDetect,
          ),

          // 2. Centered Targeting Reticle Frame
          Center(
            child: _buildReticleOverlay(context),
          ),

          // 3. Top-Centered Cloud Batch Sync Pill
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Center(
                child: _buildSyncPill(context, pendingCount),
              ),
            ),
          ),

          // 4. Floating Result Banner on Scan
          if (_lastScan != null) _buildResultBanner(context, _lastScan!),
        ],
      ),
    );
  }

  Widget _buildSyncPill(BuildContext context, int pendingCount) {
    final bool hasPending = pendingCount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasPending ? _triggerCloudSync : null,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(200),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: hasPending ? const Color(0xFF0071E3) : const Color(0xFF34C759),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(100),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isSyncing)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              else
                Icon(
                  hasPending ? Icons.cloud_upload_rounded : Icons.cloud_done_rounded,
                  color: hasPending ? const Color(0xFF0071E3) : const Color(0xFF34C759),
                  size: 18,
                ),
              const SizedBox(width: 8),
              Text(
                _isSyncing
                    ? 'Syncing to Cloud...'
                    : hasPending
                        ? '$pendingCount Pending • Tap to Sync'
                        : 'Scans Synced to Cloud',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: hasPending ? FontWeight.w700 : FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReticleOverlay(BuildContext context) {
    return Container(
      width: 270,
      height: 270,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withAlpha(180), width: 2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'ALIGN PASS QR INSIDE FRAME',
              style: TextStyle(
                color: Colors.white.withAlpha(200),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'OFFLINE VERIFICATION ACTIVE',
              style: TextStyle(
                color: Colors.white.withAlpha(160),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultBanner(BuildContext context, GateScanRecord record) {
    Color bg;
    IconData icon;
    String title;
    String subtitle;

    switch (record.result) {
      case ScanVerificationResult.granted:
        bg = const Color(0xFF2E7D32);
        icon = Icons.check_circle_rounded;
        title = 'ENTRY GRANTED';
        subtitle = 'Valid Ed25519 Pass • Check-in Recorded';
        break;
      case ScanVerificationResult.alreadyUsed:
        bg = const Color(0xFFC62828);
        icon = Icons.warning_rounded;
        title = 'ALREADY SCANNED';
        subtitle = 'Pass has already been used for entry';
        break;
      case ScanVerificationResult.invalidHash:
        bg = const Color(0xFFE65100);
        icon = Icons.cancel_rounded;
        title = 'INVALID PASS';
        subtitle = 'Unrecognized cryptographic signature';
        break;
    }

    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(80), blurRadius: 16, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}