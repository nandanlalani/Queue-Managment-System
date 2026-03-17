import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/admin_controller.dart';
import '../../app/routes.dart';
import '../../core/utils/date_utils.dart';
import '../../models/clinic_model.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminControllerProvider.notifier).loadClinic();
      ref.read(adminControllerProvider.notifier).loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminControllerProvider);
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
      body: adminState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(adminControllerProvider.notifier).loadClinic();
                await ref.read(adminControllerProvider.notifier).loadUsers();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _WelcomeCard(name: authState.user?.name ?? 'Admin'),
                  const SizedBox(height: 16),
                  if (adminState.clinic != null) _ClinicCard(clinic: adminState.clinic!),
                  const SizedBox(height: 16),
                  _StatsRow(
                    userCount: adminState.users.length,
                    appointmentCount: adminState.clinic?.appointmentCount ?? 0,
                    queueCount: adminState.clinic?.queueCount ?? 0,
                  ),
                  const SizedBox(height: 24),
                  Text('Quick Actions',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800)),
                  const SizedBox(height: 12),
                  _ActionCard(
                    icon: Icons.people_outline,
                    title: 'Manage Users',
                    subtitle: 'View and create system users',
                    onTap: () => context.go(AppRoutes.adminUsers),
                  ),
                  const SizedBox(height: 10),
                  _ActionCard(
                    icon: Icons.person_add_outlined,
                    title: 'Create User',
                    subtitle: 'Add a new user to the system',
                    onTap: () => context.go(AppRoutes.adminCreateUser),
                  ),
                  if (adminState.error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(adminState.error!,
                          style: TextStyle(color: Colors.red.shade700)),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final String name;
  const _WelcomeCard({required this.name});

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
          const Icon(Icons.admin_panel_settings, color: Colors.white, size: 36),
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

class _ClinicCard extends StatelessWidget {
  final ClinicModel clinic;
  const _ClinicCard({required this.clinic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.local_hospital_outlined, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(clinic.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                if (clinic.code != null)
                  Text('Code: ${clinic.code}',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int userCount;
  final int appointmentCount;
  final int queueCount;
  const _StatsRow(
      {required this.userCount,
      required this.appointmentCount,
      required this.queueCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _StatCard(
                label: 'Users',
                value: '$userCount',
                icon: Icons.people,
                color: Colors.blue.shade700)),
        const SizedBox(width: 10),
        Expanded(
            child: _StatCard(
                label: 'Appointments',
                value: '$appointmentCount',
                icon: Icons.calendar_today,
                color: Colors.teal)),
        const SizedBox(width: 10),
        Expanded(
            child: _StatCard(
                label: 'Queue',
                value: '$queueCount',
                icon: Icons.queue,
                color: Colors.orange)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              Text(label,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionCard(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
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
              child: Icon(icon, color: Colors.blue.shade700, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(subtitle,
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
