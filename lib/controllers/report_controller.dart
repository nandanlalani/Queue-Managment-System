import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

class ReportState {
  final bool isLoading;
  final List<ReportModel> reports;
  final String? error;
  final String? successMessage;

  const ReportState({
    this.isLoading = false,
    this.reports = const [],
    this.error,
    this.successMessage,
  });

  ReportState copyWith({
    bool? isLoading,
    List<ReportModel>? reports,
    String? error,
    String? successMessage,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      reports: reports ?? this.reports,
      error: error,
      successMessage: successMessage,
    );
  }
}

class ReportController extends StateNotifier<ReportState> {
  final ReportService _service;

  ReportController(this._service) : super(const ReportState());

  Future<void> loadMyReports() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _service.getMyReports();
      final list = data.map((r) => ReportModel.fromJson(r as Map<String, dynamic>)).toList();
      state = state.copyWith(isLoading: false, reports: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addReport({
    required String appointmentId,
    required String diagnosis,
    String? testRecommended,
    String? remarks,
  }) async {
    if (appointmentId.isEmpty || diagnosis.isEmpty) {
      state = state.copyWith(error: 'Diagnosis is required.');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      await _service.addReport(appointmentId, {
        'diagnosis': diagnosis,
        if (testRecommended != null && testRecommended.isNotEmpty)
          'testRecommended': testRecommended,
        if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
      });
      state = state.copyWith(isLoading: false, successMessage: 'Report added successfully.');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final reportServiceProvider = Provider<ReportService>((ref) => ReportService());

final reportControllerProvider =
    StateNotifierProvider<ReportController, ReportState>((ref) {
  return ReportController(ref.read(reportServiceProvider));
});
