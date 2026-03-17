import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../storage/secure_storage_service.dart';

/// Callback types so the interceptor can trigger app-level navigation
/// without depending on BuildContext directly.
typedef OnUnauthorized = Future<void> Function();
typedef OnForbidden = void Function();

class AuthInterceptor extends Interceptor {
  final OnUnauthorized? onUnauthorized;
  final OnForbidden? onForbidden;

  AuthInterceptor({this.onUnauthorized, this.onForbidden});

  // ── Attach JWT to every outgoing request ───────────────
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  // ── Global error handling ──────────────────────────────
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    // Skip 401 handling for the login endpoint itself —
    // let the error bubble up to the controller so the UI can show it
    final isLoginRequest = path.contains('/auth/login');

    if (statusCode == 401 && !isLoginRequest) {
      // Token expired or invalid → clear storage and redirect to login
      await SecureStorageService.clearAll();
      if (onUnauthorized != null) await onUnauthorized!();
    } else if (statusCode == 403) {
      // Forbidden → show access denied message
      if (onForbidden != null) onForbidden!();
    }

    handler.next(err);
  }
}

/// Global navigator key — used to navigate without BuildContext
/// Set this in main.dart and pass to MaterialApp.router
final GlobalKey<NavigatorState> appNavigatorKey =
    GlobalKey<NavigatorState>();
