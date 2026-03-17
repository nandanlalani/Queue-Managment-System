import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prescription_model.dart';
import '../models/medicine_model.dart';
import '../services/prescription_service.dart';

class PrescriptionState {
  final bool isLoading;
  final List<PrescriptionModel> prescriptions;
  final String? error;
  final String? successMessage;

  const PrescriptionState({
    this.isLoading = false,
    this.prescriptions = const [],
    this.error,
    this.successMessage,
  });

  PrescriptionState copyWith({
    bool? isLoading,
    List<PrescriptionModel>? prescriptions,
    String? error,
    String? successMessage,
  }) {
    return PrescriptionState(
      isLoading: isLoading ?? this.isLoading,
      prescriptions: prescriptions ?? this.prescriptions,
      error: error,
      successMessage: successMessage,
    );
  }
}

class PrescriptionController extends StateNotifier<PrescriptionState> {
  final PrescriptionService _service;

  PrescriptionController(this._service) : super(const PrescriptionState());

  Future<void> loadMyPrescriptions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _service.getMyPrescriptions();
      final list = data.map((p) => PrescriptionModel.fromJson(p as Map<String, dynamic>)).toList();
      state = state.copyWith(isLoading: false, prescriptions: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addPrescription({
    required String appointmentId,
    required List<MedicineModel> medicines,
    String? notes,
  }) async {
    if (appointmentId.isEmpty || medicines.isEmpty) {
      state = state.copyWith(error: 'Appointment ID and at least one medicine are required.');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      await _service.addPrescription(appointmentId, {
        'medicines': medicines.map((m) => m.toJson()).toList(),
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });
      state = state.copyWith(isLoading: false, successMessage: 'Prescription added successfully.');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final prescriptionServiceProvider =
    Provider<PrescriptionService>((ref) => PrescriptionService());

final prescriptionControllerProvider =
    StateNotifierProvider<PrescriptionController, PrescriptionState>((ref) {
  return PrescriptionController(ref.read(prescriptionServiceProvider));
});
