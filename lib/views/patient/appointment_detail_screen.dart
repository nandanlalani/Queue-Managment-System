import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/appointment_controller.dart';
import '../../core/utils/date_utils.dart';

class AppointmentDetailScreen extends ConsumerStatefulWidget {
  final String appointmentId;
  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  ConsumerState<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends ConsumerState<AppointmentDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref
        .read(appointmentControllerProvider.notifier)
        .loadAppointmentById(widget.appointmentId));
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'confirmed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentControllerProvider);
    final appt = state.selectedAppointment;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Appointment Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        elevation: 0,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : appt == null
              ? Center(
                  child: Text('Appointment not found.',
                      style: TextStyle(color: Colors.grey.shade500)))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _InfoCard(children: [
                      _InfoRow(icon: Icons.calendar_today, label: 'Date', value: AppDateUtils.formatDate(appt.appointmentDate)),
                      _InfoRow(icon: Icons.access_time, label: 'Time Slot', value: appt.timeSlot ?? '-'),
                      _InfoRow(icon: Icons.confirmation_number, label: 'Token', value: appt.tokenNumber?.toString() ?? '-'),
                    ]),
                    const SizedBox(height: 14),
                    _InfoCard(children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey.shade500, size: 18),
                          const SizedBox(width: 10),
                          const Text('Status', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: _statusColor(appt.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(appt.status,
                                style: TextStyle(
                                    color: _statusColor(appt.status),
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ]),
                    if (appt.queueStatus != null) ...[
                      const SizedBox(height: 14),
                      _InfoCard(children: [
                        _InfoRow(icon: Icons.queue, label: 'Queue Status', value: appt.queueStatus!),
                      ]),
                    ],
                  ],
                ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: children
            .expand((w) => [w, const Divider(height: 16)])
            .toList()
          ..removeLast(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey.shade400, size: 18),
        const SizedBox(width: 10),
        Text('$label: ', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        ),
      ],
    );
  }
}
