import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/queue_controller.dart';
import '../../app/routes.dart';
import '../../core/utils/date_utils.dart';

class ReceptionistDashboardScreen extends ConsumerStatefulWidget {
  const ReceptionistDashboardScreen({super.key});

  @override
  ConsumerState<ReceptionistDashboardScreen> createState() =>
      _ReceptionistDashboardScreenState();
}

class _ReceptionistDashboardScreenState
    extends ConsumerState<ReceptionistDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(queueControllerProvider.notifier).loadQueue());
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final queueState = ref.watch(queueControllerProvider);

    final waiting = queueState.queue.where((q) => q.status == 'waiting').length;
    final inProgress = queueState.queue.where((q) => q.status == 'in_progress').length;
    final done = queueState.queue.where((q) => q.status == 'done').length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Receptionist'),
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
        onRefresh: () => ref.read(queueControllerProvider.notifier).loadQueue(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.badge, color: Colors.white, size: 36),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hello, ${authState.user?.name ?? 'Receptionist'}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(AppDateUtils.formatDate(DateTime.now().toIso8601String()),
                          style: TextStyle(color: Colors.teal.shade100, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _StatCard(label: 'Waiting', value: '$waiting', color: Colors.orange)),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(label: 'In Progress', value: '$inProgress', color: Colors.blue)),
                const SizedBox(width: 10),
                Expanded(child: _StatCard(label: 'Done', value: '$done', color: Colors.green)),
              ],
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () => context.go(AppRoutes.queue),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.queue, color: Colors.teal, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Today's Queue",
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          Text('Manage patient queue',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
