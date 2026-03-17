import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/prescription_controller.dart';
import '../../core/utils/date_utils.dart';

class PrescriptionsScreen extends ConsumerStatefulWidget {
  const PrescriptionsScreen({super.key});

  @override
  ConsumerState<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends ConsumerState<PrescriptionsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(prescriptionControllerProvider.notifier).loadMyPrescriptions());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prescriptionControllerProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Prescriptions'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        elevation: 0,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.prescriptions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 56, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('No prescriptions found',
                          style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => ref
                      .read(prescriptionControllerProvider.notifier)
                      .loadMyPrescriptions(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.prescriptions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final p = state.prescriptions[i];
                      return Container(
                        padding: const EdgeInsets.all(16),
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
                                Icon(Icons.receipt_long, color: Colors.teal, size: 20),
                                const SizedBox(width: 8),
                                Text('Prescription #${p.id}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600, fontSize: 15)),
                                const Spacer(),
                                Text(AppDateUtils.formatDate(p.createdAt),
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                              ],
                            ),
                            if (p.medicines.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              const Divider(height: 1),
                              const SizedBox(height: 10),
                              ...p.medicines.map((m) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.medication_outlined,
                                            size: 16, color: Colors.teal),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${m.name} — ${m.dosage}, ${m.duration}',
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                            if (p.notes != null) ...[
                              const SizedBox(height: 8),
                              Text('Note: ${p.notes}',
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic)),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
