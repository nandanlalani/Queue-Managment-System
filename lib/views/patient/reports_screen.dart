import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/report_controller.dart';
import '../../core/utils/date_utils.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(reportControllerProvider.notifier).loadMyReports());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportControllerProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Reports'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        elevation: 0,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.reports.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description_outlined, size: 56, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('No reports found', style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(reportControllerProvider.notifier).loadMyReports(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.reports.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final r = state.reports[i];
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
                                Icon(Icons.description, color: Colors.orange, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(r.diagnosis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600, fontSize: 15)),
                                ),
                                Text(AppDateUtils.formatDate(r.createdAt),
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                              ],
                            ),
                            if (r.testRecommended != null) ...[
                              const SizedBox(height: 6),
                              Text('Test: ${r.testRecommended}',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                            ],
                            if (r.remarks != null) ...[
                              const SizedBox(height: 4),
                              Text('Remarks: ${r.remarks}',
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
