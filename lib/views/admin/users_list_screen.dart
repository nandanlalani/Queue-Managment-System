import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/admin_controller.dart';
import '../../app/routes.dart';

class UsersListScreen extends ConsumerStatefulWidget {
  const UsersListScreen({super.key});

  @override
  ConsumerState<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends ConsumerState<UsersListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminControllerProvider.notifier).loadUsers());
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin': return Colors.purple;
      case 'doctor': return Colors.blue;
      case 'receptionist': return Colors.teal;
      case 'patient': return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminControllerProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Users'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade800,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () => context.go(AppRoutes.adminCreateUser),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 56, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('No users found', style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(adminControllerProvider.notifier).loadUsers(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.users.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final u = state.users[i];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: _roleColor(u.role).withOpacity(0.1),
                              child: Text(
                                u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                                style: TextStyle(
                                    color: _roleColor(u.role), fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(u.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600, fontSize: 15)),
                                  Text(u.email,
                                      style: TextStyle(
                                          color: Colors.grey.shade500, fontSize: 13)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _roleColor(u.role).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(u.role,
                                  style: TextStyle(
                                      color: _roleColor(u.role),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500)),
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
