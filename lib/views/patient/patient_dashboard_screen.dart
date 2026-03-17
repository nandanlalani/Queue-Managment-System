import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/appointment_controller.dart';
import '../../app/routes.dart';
import '../../core/utils/date_utils.dart';

class PatientDashboardScreen extends ConsumerStatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  ConsumerState<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends ConsumerState<PatientDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(appointmentControllerProvider.notifier).loadMyAppointments());
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final apptState = ref.watch(appointmentControllerProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Dashboard'),
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
        onRefresh: () =>
            ref.read(appointmentControllerProvider.notifier).loadMyAppointments(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _WelcomeBanner(name: authState.user?.name ?? 'Patient'),
            const SizedBox(height: 16),
            _QuickActions(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Appointments',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800)),
                TextButton(
                  onPressed: () => context.go(AppRoutes.patientDashboard),
                  child: const Text('See all'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (apptState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (apptState.appointments.isEmpty)
              _EmptyAppointments()
            else
              ...apptState.appointments.take(3).map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AppointmentCard(
                      date: a.appointmentDate,
                      status: a.status,
                      slot: a.timeSlot ?? '-',
                      onTap: () => context.go('/patient/appointment/${a.id}'),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  final String name;
  const _WelcomeBanner({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: Colors.white, size: 36),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello, $name',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(AppDateUtils.formatDate(DateTime.now().toIso8601String()),
                  style: TextStyle(color: Colors.blue.shade100, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            icon: Icons.add_circle_outline,
            label: 'Book Appointment',
            color: Colors.blue.shade700,
            onTap: () => context.go(AppRoutes.bookAppointment),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionTile(
            icon: Icons.receipt_long_outlined,
            label: 'Prescriptions',
            color: Colors.teal,
            onTap: () => context.go(AppRoutes.prescriptions),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionTile(
            icon: Icons.description_outlined,
            label: 'Reports',
            color: Colors.orange,
            onTap: () => context.go(AppRoutes.reports),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile(
      {required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final String date;
  final String status;
  final String slot;
  final VoidCallback onTap;
  const _AppointmentCard(
      {required this.date, required this.status, required this.slot, required this.onTap});

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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.calendar_today, color: Colors.blue.shade700, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppDateUtils.formatDate(date),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(slot, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(status,
                  style: TextStyle(
                      color: _statusColor(status), fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAppointments extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.calendar_today_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('No appointments yet', style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}
