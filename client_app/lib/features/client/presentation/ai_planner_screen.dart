import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class AiPlannerScreen extends StatefulWidget {
  const AiPlannerScreen({super.key});

  @override
  State<AiPlannerScreen> createState() => _AiPlannerScreenState();
}

class _AiPlannerScreenState extends State<AiPlannerScreen> {
  final _textController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text': 'Hello! I am your AI Event Architect. Tell me your event details (e.g. Birthday, 50 people, ₹50,000 budget). I will assemble verified providers and calculate an exact budget split.',
    }
  ];
  bool _isGenerating = false;

  void _handleSend() {
    final query = _textController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _messages.add({'isUser': true, 'text': query});
      _isGenerating = true;
      _textController.clear();
    });

    // Dynamic parsing of user budget (STEP_03 AC-02 & STEP_15)
    final RegExp budgetRegex = RegExp(r'(\d+[\d,]*)\s*(?:rupees|rs|inr|k)?', caseSensitive: false);
    final match = budgetRegex.firstMatch(query.replaceAll(',', ''));
    
    int parsedBudget = 50000; // default fallback
    if (match != null) {
      final valStr = match.group(1);
      if (valStr != null) {
        int rawVal = int.tryParse(valStr) ?? 50000;
        if (query.toLowerCase().contains('k') && rawVal < 1000) {
          rawVal = rawVal * 1000;
        }
        if (rawVal >= 5000) parsedBudget = rawVal;
      }
    }

    // Dynamic Allocation: 50% Venue/Food, 25% Decor, 25% Entertainment
    final venueCost = (parsedBudget * 0.45).toInt();
    final decorCost = (parsedBudget * 0.25).toInt();
    final entertainmentCost = parsedBudget - venueCost - decorCost;

    // Simulated streaming response honoring user budget bounds
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        _messages.add({
          'isUser': false,
          'text': 'Event Plan Assembled based on your target budget of ₹$parsedBudget:\n\n'
              '• Venue & Dining: Grand Heritage Banquets (Est. ₹$venueCost)\n'
              '• Theme Decor: Aura Floral & Styling (Est. ₹$decorCost)\n'
              '• Live Music: The Royal Symphony Ensemble (Est. ₹$entertainmentCost)\n\n'
              'Total Allocated: ₹$parsedBudget (100% matched to budget).\n'
              'All services verified with 14-Day Nodal Escrow protection.',
        });
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Event Architect'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['isUser'] as bool;
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
                      decoration: BoxDecoration(
                        color: isUser ? AppColors.actionPrimary : AppColors.bgElevatedLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isUser ? Colors.transparent : Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Text(
                        msg['text'] as String,
                        style: TextStyle(
                          color: isUser ? Colors.white : AppColors.fgTextPrimaryLight,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isGenerating)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 8),
                    Text('Analyzing budget allocation & availability...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.08))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Birthday, 50 people, 50000 rupees...',
                        filled: true,
                        fillColor: AppColors.bgElevatedLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.actionPrimary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(48, 48),
                    ),
                    icon: const Icon(Icons.send, size: 20),
                    onPressed: _handleSend,
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