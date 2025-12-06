import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/app_service.dart';
import '../../models/user_model.dart';
import '../../models/patient_progress_model.dart';
import '../../models/exercise_score_model.dart';
import 'all_patients_view.dart';
import 'by_patient_view.dart';

enum DashboardView { all, byPatient }

class TherapistDashboardScreen extends StatefulWidget {
  const TherapistDashboardScreen({super.key});

  @override
  State<TherapistDashboardScreen> createState() => _TherapistDashboardScreenState();
}

class _TherapistDashboardScreenState extends State<TherapistDashboardScreen> {
  DashboardView _currentView = DashboardView.all;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Therapist Dashboard'),
        actions: [
          // View switcher buttons - show as bottom navigation on mobile
          if (!isMobile)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildViewButton('All', DashboardView.all),
                  const SizedBox(width: 8),
                  _buildViewButton('By Patient', DashboardView.byPatient),
                ],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (mounted) context.go('/login');
            },
            tooltip: 'Sign out',
          ),
        ],
        bottom: isMobile
            ? PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMobileViewButton('All', DashboardView.all),
                    ),
                    Expanded(
                      child: _buildMobileViewButton('By Patient', DashboardView.byPatient),
                    ),
                  ],
                ),
              )
            : null,
      ),
      body: _currentView == DashboardView.all
          ? const AllPatientsView()
          : const ByPatientView(),
    );
  }

  Widget _buildMobileViewButton(String label, DashboardView view) {
    final isSelected = _currentView == view;
    return InkWell(
      onTap: () {
        setState(() {
          _currentView = view;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildViewButton(String label, DashboardView view) {
    final isSelected = _currentView == view;
    return SizedBox(
      height: 32,
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _currentView = view;
          });
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          backgroundColor: isSelected ? Colors.blue.shade50 : null,
          side: BorderSide(
            color: isSelected ? Colors.blue : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
