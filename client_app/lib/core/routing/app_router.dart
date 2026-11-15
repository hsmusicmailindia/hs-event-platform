import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/phone_auth_screen.dart';
import '../../features/client/presentation/client_home_screen.dart';
import '../../features/client/presentation/provider_detail_screen.dart';
import '../../features/client/presentation/cart_screen.dart';
import '../../features/client/presentation/event_completion_screen.dart';
import '../../features/client/presentation/event_guest_list_screen.dart';
import '../../features/client/data/models/provider_model.dart';
import '../../features/provider/presentation/provider_home_screen.dart';
import '../../features/provider/presentation/provider_calendar_screen.dart';
import '../../features/provider/presentation/provider_requests_screen.dart';
import '../../features/provider/presentation/provider_otp_verify_screen.dart';
import '../../features/admin/presentation/admin_dispute_arbitration_screen.dart';
import '../../features/gate/presentation/gate_scanner_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/provider/home',
    routes: [
      GoRoute(
        path: '/auth/phone',
        builder: (context, state) => const PhoneAuthScreen(),
      ),
      GoRoute(
        path: '/client/home',
        builder: (context, state) => const ClientHomeScreen(),
      ),
      GoRoute(
        path: '/client/provider/:provider_id',
        builder: (context, state) {
          final id = state.pathParameters['provider_id'] ?? '';
          final provider = state.extra as ProviderModel?;
          return ProviderDetailScreen(providerId: id, provider: provider);
        },
      ),
      GoRoute(
        path: '/client/cart',
        builder: (context, state) {
          final packageId = state.extra as String?;
          return CartScreen(packageId: packageId);
        },
      ),
      GoRoute(
        path: '/client/completion/:booking_id',
        builder: (context, state) {
          final id = state.pathParameters['booking_id'] ?? '';
          return EventCompletionScreen(bookingId: id);
        },
      ),
      GoRoute(
        path: '/client/event/:event_id/guests',
        builder: (context, state) {
          final id = state.pathParameters['event_id'] ?? '';
          return EventGuestListScreen(bookingId: id);
        },
      ),
      GoRoute(
        path: '/provider/home',
        builder: (context, state) => const ProviderHomeScreen(),
      ),
      GoRoute(
        path: '/provider/requests',
        builder: (context, state) => const ProviderRequestsScreen(),
      ),
      GoRoute(
        path: '/provider/calendar',
        builder: (context, state) => const ProviderCalendarScreen(),
      ),
      GoRoute(
        path: '/provider/verify-otp/:booking_id',
        builder: (context, state) {
          final id = state.pathParameters['booking_id'] ?? '';
          return ProviderOtpVerifyScreen(bookingId: id);
        },
      ),
      GoRoute(
        path: '/admin/disputes/:dispute_id',
        builder: (context, state) {
          final id = state.pathParameters['dispute_id'] ?? '';
          return AdminDisputeArbitrationScreen(bookingId: id);
        },
      ),
      GoRoute(
        path: '/gate/scan',
        builder: (context, state) => const GateScannerScreen(),
      ),
    ],
  );
}

final GoRouter appRouter = AppRouter.router;