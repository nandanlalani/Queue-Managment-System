import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';

class AppointmentState {
  final bool isLoading;
  final List<AppointmentModel> appointments;
  final AppointmentModel? selectedAppointment;
  final String? error;
  final String? successMessage;

  const AppointmentState({
    this.isLoading = false,
    this.appointments = const [],
    this.selectedAppointment,
    this.error,
    this.successMessage,
  });

  AppointmentState copyWith({
    bool? isLoading,
    List<AppointmentModel>? appointments,
    AppointmentModel? selectedAppointment,
    String? error,
    String? successMessage,
  }) {
    return AppointmentState(
      isLoading: isLoading ?? this.isLoading,
      appointments: appointments ?? this.appointments,
      selectedAppointment: selectedAppointment ?? this.selectedAppointment,
      error: error,
      successMessage: successMessage,
    );
  }
}

class AppointmentController extends StateNotifier<AppointmentState> {
  final AppointmentService _service;

  AppointmentController(this._service) : super(const AppointmentState());

  Future<void> loadMyAppointments() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _service.getMyAppointments();
      final list = data.map((a) => AppointmentModel.fromJson(a as Map<String, dynamic>)).toList();
      state = state.copyWith(isLoading: false, appointments: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadAppointmentById(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _service.getAppointmentById(id);
      state = state.copyWith(isLoading: false, selectedAppointment: AppointmentModel.fromJson(data));
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> bookAppointment({
    required String appointmentDate,
    required String timeSlot,
  }) async {
    if (appointmentDate.isEmpty || timeSlot.isEmpty) {
      state = state.copyWith(error: 'Date and time slot are required.');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      await _service.bookAppointment({
        'appointmentDate': appointmentDate,
        'timeSlot': timeSlot,
      });
      state = state.copyWith(isLoading: false, successMessage: 'Appointment booked successfully.');
      await loadMyAppointments();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final appointmentServiceProvider =
    Provider<AppointmentService>((ref) => AppointmentService());

final appointmentControllerProvider =
    StateNotifierProvider<AppointmentController, AppointmentState>((ref) {
  return AppointmentController(ref.read(appointmentServiceProvider));
});
