import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/prescription_controller.dart';
import '../../models/medicine_model.dart';
import '../../core/utils/snackbar_utils.dart';

class AddPrescriptionScreen extends ConsumerStatefulWidget {
  final String appointmentId;
  const AddPrescriptionScreen({super.key, required this.appointmentId});

  @override
  ConsumerState<AddPrescriptionScreen> createState() => _AddPrescriptionScreenState();
}

class _AddPrescriptionScreenState extends ConsumerState<AddPrescriptionScreen> {
  final _notesCtrl = TextEditingController();
  final List<_MedForm> _meds = [_MedForm()];

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  void _addMed() => setState(() => _meds.add(_MedForm()));

  void _removeMed(int idx) {
    if (_meds.length > 1) setState(() => _meds.removeAt(idx));
  }

  Future<void> _submit() async {
    for (final m in _meds) {
      if (m.nameCtrl.text.trim().isEmpty ||
          m.dosageCtrl.text.trim().isEmpty ||
          m.durationCtrl.text.trim().isEmpty) {
        SnackbarUtils.showError(context, 'Fill in name, dosage and duration for each medicine.');
        return;
      }
    }

    final medicines = _meds
        .map((m) => MedicineModel(
              name: m.nameCtrl.text.trim(),
              dosage: m.dosageCtrl.text.trim(),
              duration: m.durationCtrl.text.trim(),
            ))
        .toList();

    final ok = await ref
        .read(prescriptionControllerProvider.notifier)
        .addPrescription(
          appointmentId: widget.appointmentId,
          medicines: medicines,
          notes: _notesCtrl.text.trim(),
        );

    if (!mounted) return;
    if (ok) {
      SnackbarUtils.showSuccess(context, 'Prescription added successfully.');
      context.pop();
    } else {
      final err = ref.read(prescriptionControllerProvider).error;
      SnackbarUtils.showError(context, err ?? 'Failed to add prescription.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prescriptionControllerProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Add Prescription'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...List.generate(_meds.length, (i) {
              final m = _meds[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Medicine ${i + 1}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const Spacer(),
                        if (_meds.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.red, size: 20),
                            onPressed: () => _removeMed(i),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _MedField(ctrl: m.nameCtrl, label: 'Medicine Name *'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _MedField(ctrl: m.dosageCtrl, label: 'Dosage *')),
                        const SizedBox(width: 10),
                        Expanded(child: _MedField(ctrl: m.durationCtrl, label: 'Duration *')),
                      ],
                    ),
                  ],
                ),
              );
            }),
            OutlinedButton.icon(
              onPressed: _addMed,
              icon: const Icon(Icons.add),
              label: const Text('Add Medicine'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue.shade700,
                side: BorderSide(color: Colors.blue.shade700),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: state.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: state.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Save Prescription',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedForm {
  final nameCtrl = TextEditingController();
  final dosageCtrl = TextEditingController();
  final durationCtrl = TextEditingController();
}

class _MedField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  const _MedField({required this.ctrl, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
      ),
    );
  }
}
