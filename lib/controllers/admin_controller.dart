import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/clinic_model.dart';
import '../models/user_model.dart';
import '../services/admin_service.dart';

class AdminState {
  final bool isLoading;
  final ClinicModel? clinic;
  final List<UserModel> users;
  final String? error;
  final String? successMessage;

  const AdminState({
    this.isLoading = false,
    this.clinic,
    this.users = const [],
    this.error,
    this.successMessage,
  });

  AdminState copyWith({
    bool? isLoading,
    ClinicModel? clinic,
    List<UserModel>? users,
    String? error,
    String? successMessage,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      clinic: clinic ?? this.clinic,
      users: users ?? this.users,
      error: error,
      successMessage: successMessage,
    );
  }
}

class AdminController extends StateNotifier<AdminState> {
  final AdminService _adminService;

  AdminController(this._adminService) : super(const AdminState());

  Future<void> loadClinic() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _adminService.getClinic();
      state = state.copyWith(isLoading: false, clinic: ClinicModel.fromJson(data));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _adminService.getUsers();
      final list = data.map((u) => UserModel.fromJson(u as Map<String, dynamic>)).toList();
      state = state.copyWith(isLoading: false, users: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty || role.isEmpty) {
      state = state.copyWith(error: 'All fields are required.');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      await _adminService.createUser({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      });
      state = state.copyWith(isLoading: false, successMessage: 'User created successfully.');
      await loadUsers();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final adminServiceProvider = Provider<AdminService>((ref) => AdminService());

final adminControllerProvider =
    StateNotifierProvider<AdminController, AdminState>((ref) {
  return AdminController(ref.read(adminServiceProvider));
});
