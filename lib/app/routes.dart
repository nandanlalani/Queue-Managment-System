import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/auth_controller.dart';
import '../core/constants/app_constants.dart';
import '../core/network/auth_interceptor.dart';

import '../views/splash/splash_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/admin/admin_dashboard_screen.dart';
import '../views/admin/users_list_screen.dart';
import '../views/admin/create_user_screen.dart';
import '../views/patient/patient_dashboard_screen.dart';
import '../views/patient/book_appointment_screen.dart';
import '../views/patient/appointment_detail_screen.dart';
import '../views/patient/prescriptions_screen.dart';
import '../views/patient/reports_screen.dart';
import '../views/receptionist/receptionist_dashboard_screen.dart';
import '../views/receptionist/queue_screen.dart';
import '../views/doctor/doctor_dashboard_screen.dart';
import '../views/doctor/add_prescription_screen.dart';
import '../views/doctor/add_report_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';

  static const adminDashboard = '/admin';
  static const adminUsers = '/admin/users';
  static const adminCreateUser = '/admin/users/create';

  static const patientDashboard = '/patient';
  static const bookAppointment = '/patient/book';
  static const appointmentDetail = '/patient/appointment/:id';
  static const prescriptions = '/patient/prescriptions';
  static const reports = '/patient/reports';

  static const receptionistDashboard = '/receptionist';
  static const queue = '/receptionist/queue';

  static const doctorDashboard = '/doctor';
  static const addPrescription = '/doctor/prescription/:appointmentId';
  static const addReport = '/doctor/report/:appointmentId';
}

class AuthNotifier extends ChangeNotifier {
  AuthState _state = const AuthState();

  AuthState get state => _state;

  void update(AuthState newState) {
    _state = newState;
    notifyListeners();
  }
}

final authNotifierProvider = Provider<AuthNotifier>((ref) {
  final notifier = AuthNotifier();
  ref.listen<AuthState>(authControllerProvider, (_, next) {
    notifier.update(next);
  });
  return notifier;
});

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);

  return GoRouter(
    navigatorKey: appNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: authNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final isAuth = authNotifier.state.isAuthenticated;
      final isLogin = state.matchedLocation == AppRoutes.login;
      final isSplash = state.matchedLocation == AppRoutes.splash;

      if (isSplash) return null;
      if (!isAuth && !isLogin) return AppRoutes.login;
      if (isAuth && isLogin) return _dashboardForRole(authNotifier.state.user?.role);
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (_, __) => const AdminDashboardScreen(),
        routes: [
          GoRoute(path: 'users', builder: (_, __) => const UsersListScreen()),
          GoRoute(path: 'users/create', builder: (_, __) => const CreateUserScreen()),
        ],
      ),
      GoRoute(
        path: AppRoutes.patientDashboard,
        builder: (_, __) => const PatientDashboardScreen(),
        routes: [
          GoRoute(path: 'book', builder: (_, __) => const BookAppointmentScreen()),
          GoRoute(
            path: 'appointment/:id',
            builder: (_, state) =>
                AppointmentDetailScreen(appointmentId: state.pathParameters['id']!),
          ),
          GoRoute(path: 'prescriptions', builder: (_, __) => const PrescriptionsScreen()),
          GoRoute(path: 'reports', builder: (_, __) => const ReportsScreen()),
        ],
      ),
      GoRoute(
        path: AppRoutes.receptionistDashboard,
        builder: (_, __) => const ReceptionistDashboardScreen(),
        routes: [
          GoRoute(path: 'queue', builder: (_, __) => const QueueScreen()),
        ],
      ),
      GoRoute(
        path: AppRoutes.doctorDashboard,
        builder: (_, __) => const DoctorDashboardScreen(),
        routes: [
          GoRoute(
            path: 'prescription/:appointmentId',
            builder: (_, state) =>
                AddPrescriptionScreen(appointmentId: state.pathParameters['appointmentId']!),
          ),
          GoRoute(
            path: 'report/:appointmentId',
            builder: (_, state) =>
                AddReportScreen(appointmentId: state.pathParameters['appointmentId']!),
          ),
        ],
      ),
    ],
    errorBuilder: (_, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.error}'))),
  );
});

String _dashboardForRole(String? role) {
  switch (role) {
    case AppConstants.roleAdmin: return AppRoutes.adminDashboard;
    case AppConstants.rolePatient: return AppRoutes.patientDashboard;
    case AppConstants.roleReceptionist: return AppRoutes.receptionistDashboard;
    case AppConstants.roleDoctor: return AppRoutes.doctorDashboard;
    default: return AppRoutes.login;
  }
}
