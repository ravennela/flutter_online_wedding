import 'dart:io';
import 'package:dio/dio.dart';
import '../config/env.dart';
import '../errors/exceptions.dart';
import 'dio_interceptor.dart';
import 'package:flutter_online/features/auth/data/datasources/token_storage.dart';
import 'package:flutter_online/core/network/unauthorized_notifier.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({
    required TokenStorage tokenStorage,
    required UnauthorizedNotifier unauthorizedNotifier,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(DioInterceptor(
      tokenStorage: tokenStorage,
      unauthorizedNotifier: unauthorizedNotifier,
    ));
  }

  Dio get dio => _dio;

  // ================== GET ==================
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = true,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options ?? Options(extra: {'requiresAuth': requiresAuth}),
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on SocketException catch (e) {
      throw NetworkException('No internet connection', e);
    }
  }

  // ================== POST ==================
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = true,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options ?? Options(extra: {'requiresAuth': requiresAuth}),
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on SocketException catch (e) {
      throw NetworkException('No internet connection', e);
    }
  }

  // ================== PUT ==================
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = true,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options ?? Options(extra: {'requiresAuth': requiresAuth}),
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on SocketException catch (e) {
      throw NetworkException('No internet connection', e);
    }
  }

  // ================== PATCH ==================
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = true,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options ?? Options(extra: {'requiresAuth': requiresAuth}),
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on SocketException catch (e) {
      throw NetworkException('No internet connection', e);
    }
  }

  // ================== DELETE ==================
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = true,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options ?? Options(extra: {'requiresAuth': requiresAuth}),
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    } on SocketException catch (e) {
      throw NetworkException('No internet connection', e);
    }
  }

  // ================== ERROR MAPPER ==================
  AppException _mapDioException(DioException e) {
    final response = e.response;

    if (response == null) {
      // Typically happens on CORS block or DNS failure in Flutter Web
      return ServerException(
        'Network error or CORS block. Ensure the backend allows CORS for this origin.',
        e,
      );

    }

    switch (response.statusCode) {
      case 400:
        return ValidationException(
          response.data['message'] ?? 'Invalid request',
          e,
        );
      case 401:
        return UnauthorizedException(
          'Unauthorized access',
          e,
        );
      case 500:
        return ServerException(
          'Internal server error',
          e,
        );
      default:
        return ServerException(
          response.data['message'] ?? 'Something went wrong',
          e,
        );
    }
  }
}
