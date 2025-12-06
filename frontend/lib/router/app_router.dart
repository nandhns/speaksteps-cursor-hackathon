import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../screens/login_screen.dart';
import '../screens/patient/patient_home_screen.dart';
import '../screens/therapist/therapist_dashboard_screen.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/patient',
          name: 'patient',
          builder: (context, state) => const PatientHomeScreen(),
        ),
        GoRoute(
          path: '/therapist',
          name: 'therapist',
          builder: (context, state) => const TherapistDashboardScreen(),
        ),
      ],
      redirect: (context, state) {
        // Get AuthProvider from context if available
        try {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final isAuthenticated = authProvider.isAuthenticated;
          final currentUser = authProvider.currentUser;
          final isLoginPage = state.matchedLocation == '/login';

          // If not authenticated and not on login page, redirect to login
          if (!isAuthenticated && !isLoginPage) {
            return '/login';
          }

          // If authenticated and on login page, redirect based on role
          if (isAuthenticated && isLoginPage) {
            if (currentUser?.role == UserRole.patient) {
              return '/patient';
            } else if (currentUser?.role == UserRole.therapist) {
              return '/therapist';
            }
          }

          // If authenticated, ensure they're on the right page
          if (isAuthenticated && !isLoginPage) {
            if (currentUser?.role == UserRole.patient && state.matchedLocation != '/patient') {
              return '/patient';
            } else if (currentUser?.role == UserRole.therapist && state.matchedLocation != '/therapist') {
              return '/therapist';
            }
          }
        } catch (e) {
          // Provider not available yet, allow navigation
          // This happens during initial app load
        }

        return null; // No redirect needed
      },
    );
  }

  static final GoRouter router = createRouter();
}

