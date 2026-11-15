import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl = 'https://lfnmedfymmadqjnluqoy.supabase.co';
  static const String anonKey = 'sb_publishable_acyJp1DcpfUCHnAZD-Xy8Q_JSkiu-Q8';
  
  final _secureStorage = const FlutterSecureStorage();
  final http.Client _httpClient = http.Client();

  // Retrieve current active JWT
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: 'hs_access_token');
  }

  // Set fresh token pairs
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _secureStorage.write(key: 'hs_access_token', value: accessToken);
    await _secureStorage.write(key: 'hs_refresh_token', value: refreshToken);
  }

  // Clear session on explicit logout
  Future<void> clearSession() async {
    await _secureStorage.delete(key: 'hs_access_token');
    await _secureStorage.delete(key: 'hs_refresh_token');
  }

  // Canonical Silent JWT Refresh Interceptor (STEP_06 Sec K5)
  Future<bool> _silentRefreshToken() async {
    final refreshToken = await _secureStorage.read(key: 'hs_refresh_token');
    if (refreshToken == null) return false;

    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/auth/v1/token?grant_type=refresh_token'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': anonKey,
        },
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
        );
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('Token refresh failed: $e');
    }
    return false;
  }

  // Standardized Authorized Request Dispatcher
  Future<http.Response> request({
    required String path,
    required String method,
    Map<String, String>? headers,
    dynamic body,
    String? idempotencyKey,
  }) async {
    String? token = await getAccessToken();

    // Ensure Authorization header is ALWAYS present: active token or fallback to live publishable key
    final String authBearer = token != null ? 'Bearer $token' : 'Bearer $anonKey';

    final reqHeaders = <String, String>{
      'Content-Type': 'application/json',
      'apikey': anonKey,
      'Authorization': authBearer,
    };

    if (idempotencyKey != null) {
      reqHeaders['Idempotency-Key'] = idempotencyKey;
    }
    if (headers != null) {
      reqHeaders.addAll(headers);
    }

    final Uri uri = Uri.parse(path.startsWith('http') ? path : '$baseUrl$path');
    http.Response response;

    switch (method.toUpperCase()) {
      case 'GET':
        response = await _httpClient.get(uri, headers: reqHeaders);
        break;
      case 'POST':
        response = await _httpClient.post(
          uri,
          headers: reqHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'PATCH':
        response = await _httpClient.patch(
          uri,
          headers: reqHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
        break;
      case 'DELETE':
        response = await _httpClient.delete(uri, headers: reqHeaders);
        break;
      default:
        throw UnsupportedError('HTTP method $method not supported');
    }

    // Transparent background retry for expired token sessions
    if (response.statusCode == 401 && token != null) {
      final refreshed = await _silentRefreshToken();
      if (refreshed) {
        token = await getAccessToken();
        reqHeaders['Authorization'] = 'Bearer $token';
        switch (method.toUpperCase()) {
          case 'GET':
            return await _httpClient.get(uri, headers: reqHeaders);
          case 'POST':
            return await _httpClient.post(
              uri,
              headers: reqHeaders,
              body: body != null ? jsonEncode(body) : null,
            );
          case 'PATCH':
            return await _httpClient.patch(
              uri,
              headers: reqHeaders,
              body: body != null ? jsonEncode(body) : null,
            );
          case 'DELETE':
            return await _httpClient.delete(uri, headers: reqHeaders);
        }
      }
    }

    return response;
  }
}