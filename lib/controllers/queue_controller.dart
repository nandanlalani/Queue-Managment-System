import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/queue_entry_model.dart';
import '../models/doctor_queue_item_model.dart';
import '../services/queue_service.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/date_utils.dart';

class QueueState {
  final bool isLoading;
  final List<QueueEntryModel> queue;
  final List<DoctorQueueItemModel> doctorQueue;
  final String? error;
  final String? successMessage;
  final String selectedDate;

  QueueState({
    this.isLoading = false,
    this.queue = const [],
    this.doctorQueue = const [],
    this.error,
    this.successMessage,
    String? selectedDate,
  }) : selectedDate = selectedDate ?? AppDateUtils.todayFormatted();

  QueueState copyWith({
    bool? isLoading,
    List<QueueEntryModel>? queue,
    List<DoctorQueueItemModel>? doctorQueue,
    String? error,
    String? successMessage,
    String? selectedDate,
  }) {
    return QueueState(
      isLoading: isLoading ?? this.isLoading,
      queue: queue ?? this.queue,
      doctorQueue: doctorQueue ?? this.doctorQueue,
      error: error,
      successMessage: successMessage,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class QueueController extends StateNotifier<QueueState> {
  final QueueService _service;

  QueueController(this._service) : super(QueueState());

  Future<void> loadQueue({String? date}) async {
    final targetDate = date ?? state.selectedDate;
    state = state.copyWith(isLoading: true, error: null, selectedDate: targetDate);
    try {
      final data = await _service.getQueueByDate(targetDate);
      final list = data.map((q) => QueueEntryModel.fromJson(q as Map<String, dynamic>)).toList();
      state = state.copyWith(isLoading: false, queue: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadDoctorQueue() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _service.getDoctorQueue();
      final list = data.map((q) => DoctorQueueItemModel.fromJson(q as Map<String, dynamic>)).toList();
      state = state.copyWith(isLoading: false, doctorQueue: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateStatus(int id, String newStatus) async {
    final entry = state.queue.firstWhere(
      (q) => q.id == id,
      orElse: () => QueueEntryModel(id: 0, status: ''),
    );

    if (!_isValidTransition(entry.status, newStatus)) {
      state = state.copyWith(error: 'Invalid status transition: ${entry.status} → $newStatus');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      await _service.updateQueueStatus(id.toString(), newStatus);

      final updated = state.queue.map((q) {
        if (q.id != id) return q;
        return QueueEntryModel(
          id: q.id,
          tokenNumber: q.tokenNumber,
          status: newStatus,
          queueDate: q.queueDate,
          appointmentId: q.appointmentId,
          patientName: q.patientName,
          patientPhone: q.patientPhone,
        );
      }).toList();

      state = state.copyWith(
        isLoading: false,
        queue: updated,
        successMessage: 'Status updated to $newStatus.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  bool _isValidTransition(String current, String next) {
    const transitions = {
      AppConstants.statusWaiting: [AppConstants.statusInProgress, AppConstants.statusSkipped],
      AppConstants.statusInProgress: [AppConstants.statusDone],
    };
    return transitions[current]?.contains(next) ?? false;
  }
}

final queueServiceProvider = Provider<QueueService>((ref) => QueueService());

final queueControllerProvider =
    StateNotifierProvider<QueueController, QueueState>((ref) {
  return QueueController(ref.read(queueServiceProvider));
});
