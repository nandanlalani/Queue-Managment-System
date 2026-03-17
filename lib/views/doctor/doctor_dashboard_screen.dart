import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/queue_controller.dart';
import '../../app/routes.dart';
import '../../core/utils/date_utils.dart';
import '../../core/constants/app_constants.dart';

class DoctorDashboardScreen extends ConsumerStatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  ConsumerState<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends ConsumerState<DoctorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(queueControllerProvider.notifier).loadDoctorQueue());
  }

  Color _statusColor(String status) {
    switch (status) {
      case AppConstants.statusWaiting: return Colors.orange;
      case AppConstants.statusInProgress: return Colors.blue;
      case AppConstants.statusDone: return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final queueState = ref.watch(queueControllerProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(queueControllerProvider.notifier).loadDoctorQueue(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.medical_services, color: Colors.white, size: 36),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dr. ${authState.user?.name ?? ''}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(AppDateUtils.formatDate(DateTime.now().toIso8601String()),
                          style: TextStyle(color: Colors.blue.shade100, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text("Today's Queue",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
            const SizedBox(height: 12),
            if (queueState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (queueState.doctorQueue.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(Icons.queue, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('No patients in queue',
                          style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                ),
              )
            else
              ...queueState.doctorQueue.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${entry.tokenNumber ?? '#'}',
                                style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(entry.patientName ?? 'Patient',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600, fontSize: 15)),
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _statusColor(entry.status).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(entry.status,
                                      style: TextStyle(
                                          color: _statusColor(entry.status),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500)),
                                ),
                              ],
                            ),
                          ),
                          if (entry.appointmentId != null)
                            Column(
                              children: [
                                _ActionBtn(
                                  label: 'Rx',
                                  color: Colors.teal,
                                  onTap: () => context.go('/doctor/prescription/${entry.appointmentId}'),
                                ),
                                const SizedBox(height: 6),
                                _ActionBtn(
                                  label: 'Report',
                                  color: Colors.orange,
                                  onTap: () => context.go('/doctor/report/${entry.appointmentId}'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
