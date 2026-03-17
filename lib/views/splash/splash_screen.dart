import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';
import '../../app/routes.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final ok = await ref.read(authControllerProvider.notifier).tryAutoLogin();
    if (!mounted) return;
    if (!ok) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 24),
            Text(
              'ClinicQ',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text('Queue Management System', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
            const SizedBox(height: 48),
            CircularProgressIndicator(color: Colors.blue.shade700, strokeWidth: 2.5),
          ],
        ),
      ),
    );
  }
}
