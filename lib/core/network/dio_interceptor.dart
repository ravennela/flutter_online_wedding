import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_online/features/auth/data/datasources/token_storage.dart';
import 'package:flutter_online/core/network/unauthorized_notifier.dart';

class DioInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  final UnauthorizedNotifier unauthorizedNotifier;

  DioInterceptor({
    required this.tokenStorage,
    required this.unauthorizedNotifier,
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final requiresAuth = options.extra['requiresAuth'] ?? true;

    if (requiresAuth) {
      final token = await tokenStorage.getAccessToken();
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

    if (err.response?.statusCode == 401) {
      tokenStorage.clearTokens();
      unauthorizedNotifier.notifyUnauthorized();
    }

    super.onError(err, handler);
  }
}
