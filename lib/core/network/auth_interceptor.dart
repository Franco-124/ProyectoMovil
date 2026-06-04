import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  static VoidCallback? onUnauthorized;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Endpoints públicos — no necesitan token
    final publicPaths = ['/auth/login', '/auth/register'];
    if (publicPaths.contains(options.path)) {
      return handler.next(options);
    }

    final token = await SecureStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Token expirado → limpiar y redirigir al login
    if (err.response?.statusCode == 401) {
      await SecureStorage.deleteToken();
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}
