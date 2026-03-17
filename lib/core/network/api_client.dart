commit"import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(AuthInterceptor(
      onUnauthorized: _handleUnauthorized,
      onForbidden: _handleForbidden,
    ));

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<void> _handleUnauthorized() async {
    await SecureStorageService.clearAll();
    final ctx = appNavigatorKey.currentContext;
    if (ctx != null && ctx.mounted) {
      GoRouter.of(ctx).go('/login');
    }
  }

  void _handleForbidden() {
    final ctx = appNavigatorKey.currentContext;
    if (ctx != null && ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
        content: Text('Access Denied. You don\'t have permission.'),
        backgroundColor: Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }
}
