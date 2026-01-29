import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioInterceptor extends Interceptor {
  DioInterceptor();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final requiresAuth = options.extra['requiresAuth'] ?? true;

    if (requiresAuth) {
      // TODO: Replace with secure storage later
      final token = await _getAccessToken();

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    if (kDebugMode) {
      debugPrint('➡️ [${options.method}] ${options.uri}');
      debugPrint('Headers: ${options.headers}');
      debugPrint('Query: ${options.queryParameters}');
      debugPrint('Body: ${options.data}');
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint('✅ [${response.statusCode}] ${response.requestOptions.uri}');
      debugPrint('Response: ${response.data}');
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint('❌ ERROR [${err.response?.statusCode}] ${err.requestOptions.uri}');
      debugPrint('Message: ${err.message}');
      debugPrint('Data: ${err.response?.data}');
    }

    // Central place to catch 401
    if (err.response?.statusCode == 401) {
      // TODO:
      // 1. Clear token
      // 2. Navigate to login
      // 3. Emit logout event (later with Bloc)
    }

    super.onError(err, handler);
  }

  /// TEMP: Replace later with flutter_secure_storage
  Future<String?> _getAccessToken() async {
    // Example:
    // return await SecureStorage.instance.readToken();
    return null;
  }
}
