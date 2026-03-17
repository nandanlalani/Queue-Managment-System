import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/appointment_controller.dart';
import '../../core/utils/snackbar_utils.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  ConsumerState<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _slotCtrl = TextEditingController();
  DateTime? _pickedDate;

  @override
  void dispose() {
    _slotCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _pickedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedDate == null) {
      SnackbarUtils.showError(context, 'Please select a date.');
      return;
    }
    if (_slotCtrl.text.trim().isEmpty) {
      SnackbarUtils.showError(context, 'Please enter a time slot.');
      return;
    }

    final dateStr =
        '${_pickedDate!.year}-${_pickedDate!.month.toString().padLeft(2, '0')}-${_pickedDate!.day.toString().padLeft(2, '0')}';

    final ok = await ref.read(appointmentControllerProvider.notifier).bookAppointment(
          appointmentDate: dateStr,
          timeSlot: _slotCtrl.text.trim(),
        );

    if (!mounted) return;
    if (ok) {
      SnackbarUtils.showSuccess(context, 'Appointment booked successfully.');
      context.pop();
    } else {
      final err = ref.read(appointmentControllerProvider).error;
      SnackbarUtils.showError(context, err ?? 'Failed to book appointment.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentControllerProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _pickedDate == null
                            ? 'Select appointment date'
                            : '${_pickedDate!.day}/${_pickedDate!.month}/${_pickedDate!.year}',
                        style: TextStyle(
                          color: _pickedDate == null ? Colors.grey.shade400 : Colors.grey.shade800,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _slotCtrl,
                decoration: const InputDecoration(
                  labelText: 'Time Slot (e.g. 10:00-10:15)',
                  prefixIcon: Icon(Icons.access_time_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Time slot is required' : null,
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Book Appointment',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
