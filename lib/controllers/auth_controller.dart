import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/storage/secure_storage_service.dart';

class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthController(this._authService) : super(const AuthState());

  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(error: 'Email and password are required.');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.login(email, password);
      final token = response['token'] as String?;
      final userJson = response['user'];

      if (token == null || token.isEmpty || userJson == null) {
        state = state.copyWith(isLoading: false, error: 'Invalid response from server.');
        return false;
      }

      final user = UserModel.fromJson(userJson as Map<String, dynamic>);
      await SecureStorageService.saveToken(token);
      await SecureStorageService.saveUser(jsonEncode(userJson));

      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> tryAutoLogin() async {
    final token = await SecureStorageService.getToken();
    final userStr = await SecureStorageService.getUser();

    if (token == null || userStr == null) return false;

    try {
      final parsed = jsonDecode(userStr) as Map<String, dynamic>;
      final user = UserModel.fromJson(parsed);
      state = state.copyWith(user: user, isAuthenticated: true);
      return true;
    } catch (_) {
      await SecureStorageService.clearAll();
      return false;
    }
  }

  Future<void> logout() async {
    await SecureStorageService.clearAll();
    state = const AuthState();
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.read(authServiceProvider));
});
