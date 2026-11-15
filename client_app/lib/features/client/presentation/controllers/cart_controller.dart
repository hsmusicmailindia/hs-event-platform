import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/cart_repository.dart';

class CartState {
  final bool isLoading;
  final bool isLockAcquired;
  final bool isExpired;
  final int remainingSeconds;
  final Map<String, dynamic>? quote;
  final String? errorMessage;
  final List<String> bookingIds;

  const CartState({
    this.isLoading = false,
    this.isLockAcquired = false,
    this.isExpired = false,
    this.remainingSeconds = 900,
    this.quote,
    this.errorMessage,
    this.bookingIds = const [],
  });

  CartState copyWith({
    bool? isLoading,
    bool? isLockAcquired,
    bool? isExpired,
    int? remainingSeconds,
    Map<String, dynamic>? quote,
    String? errorMessage,
    List<String>? bookingIds,
  }) {
    return CartState(
      isLoading: isLoading ?? this.isLoading,
      isLockAcquired: isLockAcquired ?? this.isLockAcquired,
      isExpired: isExpired ?? this.isExpired,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      quote: quote ?? this.quote,
      errorMessage: errorMessage,
      bookingIds: bookingIds ?? this.bookingIds,
    );
  }
}

class CartController extends ChangeNotifier {
  final CartRepository _repository;
  final SupabaseClient _supabase;
  CartState _state = const CartState();
  Timer? _timer;

  CartController({CartRepository? repository, SupabaseClient? supabase})
      : _repository = repository ?? CartRepository(),
        _supabase = supabase ?? Supabase.instance.client;

  CartState get state => _state;

  // Local active timer preview prior to RPC commit
  void startPreviewTimer() {
    if (_timer != null && _timer!.isActive) return;
    _startCountdown();
  }

  Future<bool> checkoutAndAcquireHold({
    required List<Map<String, dynamic>> slots,
    String? existingPackageId,
  }) async {
    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;
      String packageId = existingPackageId ?? '';

      // Ensure a valid event_package exists for auth user to satisfy RPC foreign constraint
      if (packageId.isEmpty || packageId == '00000000-0000-0000-0000-000000000001') {
        if (user != null) {
          final pkgRes = await _supabase.from('event_packages').insert({
            'client_id': user.id,
            'event_type': 'Celebration',
            'status': 'draft',
          }).select('id').single();
          packageId = pkgRes['id'].toString();
        } else {
          // Dev test mode without active login session
          _simulateLocalLock();
          return true;
        }
      }

      final result = await _repository.acquireCartHold(
        packageId: packageId,
        slots: slots,
      );

      final lockedUntilStr = result['locked_until'] as String?;
      int seconds = 900;
      if (lockedUntilStr != null) {
        final lockTime = DateTime.parse(lockedUntilStr).toLocal();
        final diff = lockTime.difference(DateTime.now()).inSeconds;
        seconds = diff > 0 ? diff : 900;
      }

      final bookingIds = (result['booking_ids'] as List?)?.map((e) => e.toString()).toList() ?? [];

      _state = _state.copyWith(
        isLoading: false,
        isLockAcquired: true,
        remainingSeconds: seconds,
        bookingIds: bookingIds,
      );
      _startCountdown();
      notifyListeners();
      return true;
    } catch (e) {
      final errorStr = e.toString();
      debugPrint('Hold acquisition error: $errorStr');
      
      // If DB error is unauthenticated session, fallback to local timer for UX demonstration
      if (errorStr.contains('ERR_UNAUTHORIZED') || _supabase.auth.currentUser == null) {
        _simulateLocalLock();
        return true;
      }

      _state = _state.copyWith(
        isLoading: false,
        errorMessage: errorStr.contains('ERR_GIST_COLLISION')
            ? 'Slot collision: A selected provider is already booked for this window.'
            : 'Hold acquisition failed: $errorStr',
      );
      notifyListeners();
      return false;
    }
  }

  void _simulateLocalLock() {
    _state = _state.copyWith(
      isLoading: false,
      isLockAcquired: true,
      remainingSeconds: 900,
    );
    _startCountdown();
    notifyListeners();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state.remainingSeconds > 0) {
        _state = _state.copyWith(remainingSeconds: _state.remainingSeconds - 1);
        notifyListeners();
      } else {
        _state = _state.copyWith(isExpired: true);
        _timer?.cancel();
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}