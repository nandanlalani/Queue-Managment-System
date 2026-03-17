import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/queue_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/snackbar_utils.dart';

class QueueScreen extends ConsumerStatefulWidget {
  const QueueScreen({super.key});

  @override
  ConsumerState<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends ConsumerState<QueueScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(queueControllerProvider.notifier).loadQueue());
  }

  Color _statusColor(String status) {
    switch (status) {
      case AppConstants.statusWaiting: return Colors.orange;
      case AppConstants.statusInProgress: return Colors.blue;
      case AppConstants.statusDone: return Colors.green;
      case AppConstants.statusSkipped: return Colors.grey;
      default: return Colors.grey;
    }
  }

  List<String> _nextTransitions(String status) {
    switch (status) {
      case AppConstants.statusWaiting:
        return [AppConstants.statusInProgress, AppConstants.statusSkipped];
      case AppConstants.statusInProgress:
        return [AppConstants.statusDone];
      default:
        return [];
    }
  }

  void _showStatusSheet(BuildContext context, int id, String currentStatus) {
    final options = _nextTransitions(currentStatus);
    if (options.isEmpty) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Update Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ...options.map((t) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _statusColor(t).withOpacity(0.1),
                    child: Icon(Icons.circle, color: _statusColor(t), size: 14),
                  ),
                  title: Text(t.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(color: _statusColor(t), fontWeight: FontWeight.w600)),
                  onTap: () async {
                    Navigator.pop(context);
                    final ok = await ref
                        .read(queueControllerProvider.notifier)
                        .updateStatus(id, t);
                    if (!context.mounted) return;
                    if (ok) {
                      SnackbarUtils.showSuccess(context, 'Status updated to $t');
                    } else {
                      final err = ref.read(queueControllerProvider).error;
                      SnackbarUtils.showError(context, err ?? 'Update failed.');
                    }
                  },
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(queueControllerProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text("Queue — ${state.selectedDate}"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(queueControllerProvider.notifier).loadQueue(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.queue.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.queue, size: 56, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('No queue entries for today',
                          style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(queueControllerProvider.notifier).loadQueue(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.queue.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final entry = state.queue[i];
                      final canUpdate = _nextTransitions(entry.status).isNotEmpty;

                      return Container(
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
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  '${entry.tokenNumber ?? i + 1}',
                                  style: TextStyle(
                                      color: Colors.teal,
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
                                  if (entry.patientPhone != null)
                                    Text(entry.patientPhone!,
                                        style: TextStyle(
                                            color: Colors.grey.shade500, fontSize: 13)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _statusColor(entry.status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    entry.status.replaceAll('_', ' '),
                                    style: TextStyle(
                                        color: _statusColor(entry.status),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                if (canUpdate) ...[
                                  const SizedBox(height: 6),
                                  GestureDetector(
                                    onTap: () => _showStatusSheet(context, entry.id, entry.status),
                                    child: Text('Update',
                                        style: TextStyle(
                                            color: Colors.blue.shade700,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
