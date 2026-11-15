import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;

  AuthInterceptor(this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    options.headers['apikey'] = AppConstants.supabasePublishableKey;
    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // Intercept 401 ERR_TOKEN_EXPIRED (STEP_06 App Flow & STEP_17)
    if (err.response?.statusCode == 401) {
      try {
        final response = await Supabase.instance.client.auth.refreshSession();
        if (response.session != null) {
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer ${response.session!.accessToken}';
          final cloneReq = await dio.fetch(options);
          return handler.resolve(cloneReq);
        }
      } catch (_) {
        // Fallback: Let upstream auth state handle sign-out
      }
    }
    return handler.next(err);
  }
}