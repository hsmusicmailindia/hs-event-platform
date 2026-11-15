import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class CartReversingScreen extends StatelessWidget {
  const CartReversingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.statusWarning),
              ),
              const SizedBox(height: 24),
              const Text(
                'Reversing Incomplete Charges...',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'One or more providers in your bundle could not be secured due to concurrency locking. '
                'Uncommitted funds are being automatically refunded via Gateway Saga rollback.',
                style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size(200, 48)),
                onPressed: () => context.go('/client/cart'),
                child: const Text('Return to Cart'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}