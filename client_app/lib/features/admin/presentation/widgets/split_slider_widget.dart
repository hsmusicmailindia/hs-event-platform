import 'package:flutter/material.dart';

class SplitSliderWidget extends StatefulWidget {
  final int maxPoolPaisa;
  final Function(int clientPercent, int clientPaisa, int providerPaisa) onSplitChanged;

  const SplitSliderWidget({
    super.key,
    required this.maxPoolPaisa,
    required this.onSplitChanged,
  });

  @override
  State<SplitSliderWidget> createState() => _SplitSliderWidgetState();
}

class _SplitSliderWidgetState extends State<SplitSliderWidget> {
  double _clientRatio = 0.50; // Default 50/50 Split

  @override
  void initState() {
    super.initState();
    _recalculate(0.50);
  }

  void _recalculate(double ratio) {
    _clientRatio = ratio;
    final clientPaisa = (widget.maxPoolPaisa * _clientRatio).round();
    final providerPaisa = widget.maxPoolPaisa - clientPaisa; // Asymmetric Fractional Remainder
    final clientPercent = (_clientRatio * 100).round();
    widget.onSplitChanged(clientPercent, clientPaisa, providerPaisa);
  }

  @override
  Widget build(BuildContext context) {
    final clientPercent = (_clientRatio * 100).round();
    final providerPercent = 100 - clientPercent;
    final clientRupees = ((widget.maxPoolPaisa * _clientRatio).round()) ~/ 100;
    final providerRupees = (widget.maxPoolPaisa - (widget.maxPoolPaisa * _clientRatio).round()) ~/ 100;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withAlpha(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Arbitration Split Ratio',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black87),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0071E3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$clientPercent% Client / $providerPercent% Provider',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Double-Entry Split Cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFDC3545).withAlpha(40)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Client Refund', style: TextStyle(fontSize: 11, color: Color(0xFFDC3545), fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('₹$clientRupees', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F))),
                      Text('$clientPercent% of Pool', style: const TextStyle(fontSize: 10, color: Colors.black45)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF198754).withAlpha(40)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Provider Payout', style: TextStyle(fontSize: 11, color: Color(0xFF198754), fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('₹$providerRupees', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1D1D1F))),
                      Text('$providerPercent% of Pool', style: const TextStyle(fontSize: 10, color: Colors.black45)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Interactive Split Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFDC3545),
              inactiveTrackColor: const Color(0xFF198754),
              thumbColor: const Color(0xFF0071E3),
              overlayColor: const Color(0xFF0071E3).withAlpha(40),
              trackHeight: 6,
            ),
            child: Slider(
              value: _clientRatio,
              min: 0.0,
              max: 1.0,
              divisions: 20, // 5% increments
              onChanged: (val) => setState(() => _recalculate(val)),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('0% (Full Provider)', style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w600)),
              Text('50/50', style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w700)),
              Text('100% (Full Refund)', style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}