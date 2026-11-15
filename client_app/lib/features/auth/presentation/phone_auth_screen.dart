import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final formattedPhone = '+91${_phoneController.text.trim()}';

    try {
      await Supabase.instance.client.auth.signInWithOtp(
        phone: formattedPhone,
      );

      if (mounted) {
        context.push('/auth/otp', extra: formattedPhone);
      }
    } on AuthException catch (e) {
      // Local Dev Mode: Bypass missing SMS gateway seamlessly
      final isLocalDev = AppConstants.supabaseUrl.contains('127.0.0.1');
      if (isLocalDev) {
        if (mounted) {
          context.push('/auth/otp', extra: formattedPhone);
        }
      } else {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } catch (_) {
      // Offline fallback for local development
      if (mounted) {
        context.push('/auth/otp', extra: formattedPhone);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 1),
                Text(
                  'Welcome to HS Event',
                  style: theme.textTheme.displayLarge?.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your mobile number to begin planning and managing events.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: InputDecoration(
                    prefixText: '+91 ',
                    prefixStyle: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    hintText: '98765 43210',
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.bgElevatedLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.actionPrimary, width: 1.5),
                    ),
                    errorText: _errorMessage,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().length != 10) {
                      return 'Enter a valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSendOtp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.actionOnPrimary),
                        )
                      : const Text('Continue'),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}