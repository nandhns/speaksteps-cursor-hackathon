import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/cue_predictor_demo_web.dart';
import 'all_patients_view.dart';
import 'by_patient_view.dart';

enum DashboardView { all, byPatient, mlPredictor }

class TherapistDashboardScreen extends StatefulWidget {
  const TherapistDashboardScreen({super.key});

  @override
  State<TherapistDashboardScreen> createState() => _TherapistDashboardScreenState();
}

class _TherapistDashboardScreenState extends State<TherapistDashboardScreen> {
  DashboardView _currentView = DashboardView.all;
  UserModel? _patientToSelect;

  void _navigateToPatient(UserModel patient) {
    setState(() {
      _currentView = DashboardView.byPatient;
      _patientToSelect = patient;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<app_auth.AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Custom App Bar
          _buildAppBar(context, user, authProvider),
          
          // Content
          Expanded(child: _buildCurrentView()),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, UserModel? user, app_auth.AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingLg,
        vertical: AppTheme.spacingMd,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Logo and title
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurpleLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                color: AppTheme.primaryPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (user != null)
                  Text(
                    'Welcome, ${user.name}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            
            const Spacer(),
            
            // Navigation tabs
            _buildNavTabs(),
            
            const SizedBox(width: AppTheme.spacingLg),
            
            // User menu
            _buildUserMenu(context, authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NavTab(
            label: 'All Patients',
            icon: Icons.people_outline,
            isSelected: _currentView == DashboardView.all,
            onTap: () => setState(() {
              _currentView = DashboardView.all;
              _patientToSelect = null;
            }),
          ),
          _NavTab(
            label: 'By Patient',
            icon: Icons.person_search_outlined,
            isSelected: _currentView == DashboardView.byPatient,
            onTap: () => setState(() => _currentView = DashboardView.byPatient),
          ),
          _NavTab(
            label: 'ML Predictor',
            icon: Icons.psychology_outlined,
            isSelected: _currentView == DashboardView.mlPredictor,
            onTap: () => setState(() => _currentView = DashboardView.mlPredictor),
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildUserMenu(BuildContext context, app_auth.AuthProvider authProvider) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppTheme.primaryPurpleLight,
              child: Text(
                authProvider.currentUser?.name.isNotEmpty == true
                    ? authProvider.currentUser!.name[0].toUpperCase()
                    : 'T',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Icon(Icons.expand_more, size: 18, color: AppTheme.textSecondary),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 18, color: AppTheme.textSecondary),
              const SizedBox(width: AppTheme.spacingMd),
              const Text('Profile'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 18, color: AppTheme.error),
              const SizedBox(width: AppTheme.spacingMd),
              Text('Sign out', style: TextStyle(color: AppTheme.error)),
            ],
          ),
        ),
      ],
      onSelected: (value) async {
        if (value == 'logout') {
          await authProvider.signOut();
          if (mounted) context.go('/login');
        }
      },
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case DashboardView.all:
        return AllPatientsView(onPatientSelected: _navigateToPatient);
      case DashboardView.byPatient:
        return ByPatientView(initialPatient: _patientToSelect);
      case DashboardView.mlPredictor:
        return const CuePredictorDemoWeb();
    }
  }
}

class _NavTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isPrimary;

  const _NavTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = isPrimary ? AppTheme.primaryPurple : AppTheme.textPrimary;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? selectedColor : AppTheme.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? selectedColor : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
