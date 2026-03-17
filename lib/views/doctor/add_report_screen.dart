import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/report_controller.dart';
import '../../core/utils/snackbar_utils.dart';

class AddReportScreen extends ConsumerStatefulWidget {
  final String appointmentId;
  const AddReportScreen({super.key, required this.appointmentId});

  @override
  ConsumerState<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends ConsumerState<AddReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisCtrl = TextEditingController();
  final _testCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();

  @override
  void dispose() {
    _diagnosisCtrl.dispose();
    _testCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(reportControllerProvider.notifier).addReport(
          appointmentId: widget.appointmentId,
          diagnosis: _diagnosisCtrl.text.trim(),
          testRecommended: _testCtrl.text.trim(),
          remarks: _remarksCtrl.text.trim(),
        );

    if (!mounted) return;
    if (ok) {
      SnackbarUtils.showSuccess(context, 'Report added successfully.');
      context.pop();
    } else {
      final err = ref.read(reportControllerProvider).error;
      SnackbarUtils.showError(context, err ?? 'Failed to add report.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportControllerProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Add Report'),
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
              TextFormField(
                controller: _diagnosisCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Diagnosis *',
                  prefixIcon: Icon(Icons.medical_information_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Diagnosis is required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _testCtrl,
                decoration: const InputDecoration(
                  labelText: 'Test Recommended (optional)',
                  prefixIcon: Icon(Icons.biotech_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _remarksCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Remarks (optional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Save Report',
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
