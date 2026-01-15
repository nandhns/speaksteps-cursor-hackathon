import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/app_service.dart';
import '../../widgets/add_patient_dialog.dart';
import '../../widgets/csv_upload_dialog.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui/app_card.dart';

class AllPatientsListTab extends StatefulWidget {
  final List<UserModel> patients;
  final VoidCallback onRefresh;
  final Function(UserModel)? onPatientSelected;

  const AllPatientsListTab({
    super.key,
    required this.patients,
    required this.onRefresh,
    this.onPatientSelected,
  });

  @override
  State<AllPatientsListTab> createState() => _AllPatientsListTabState();
}

class _AllPatientsListTabState extends State<AllPatientsListTab> {
  late final AppService _service;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _service = ServiceFactory.createService();
  }

  List<UserModel> get _filteredPatients {
    if (_searchQuery.isEmpty) return widget.patients;
    final query = _searchQuery.toLowerCase();
    return widget.patients.where((p) {
      return p.name.toLowerCase().contains(query) ||
          p.email.toLowerCase().contains(query) ||
          (p.diagnosis?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  Future<void> _handleAddPatient({
    required String email,
    required String name,
    required String diagnosis,
    required String patientPhone,
    required String caregiverName,
    required String caregiverEmail,
    required String caregiverPhone,
    required List<TherapyModule> assignedModules,
    required bool sendOnboardingEmail,
    required String preferredLanguage,
  }) async {
    await _service.createPatient(
      email: email,
      name: name,
      diagnosis: diagnosis,
      patientPhone: patientPhone,
      caregiverName: caregiverName,
      caregiverEmail: caregiverEmail,
      caregiverPhone: caregiverPhone,
      assignedModules: assignedModules,
      sendOnboardingEmail: sendOnboardingEmail,
      preferredLanguage: preferredLanguage,
    );
    widget.onRefresh();
  }

  void _showAddPatientDialog() {
    showDialog(
      context: context,
      builder: (context) => AddPatientDialog(onSubmit: _handleAddPatient),
    );
  }

  void _showCsvUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => CsvUploadDialog(
        onPatientsImported: (count) {
          widget.onRefresh();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully imported $count patients!'),
              backgroundColor: AppTheme.success,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          _buildHeader(),
          const SizedBox(height: AppTheme.spacingLg),
          
          // Search bar
          _buildSearchBar(),
          const SizedBox(height: AppTheme.spacingLg),
          
          // Patient list
          Expanded(
            child: _filteredPatients.isEmpty
                ? _buildEmptyState()
                : _buildPatientList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Patients',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppTheme.spacingXs),
              Text(
                '${widget.patients.length} total patients',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: _showCsvUploadDialog,
          icon: const Icon(Icons.upload_file_outlined, size: 18),
          label: const Text('Import'),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        FilledButton.icon(
          onPressed: _showAddPatientDialog,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Patient'),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: InputDecoration(
        hintText: 'Search patients by name, email, or diagnosis...',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () => setState(() => _searchQuery = ''),
              )
            : null,
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_searchQuery.isNotEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'No patients found',
        subtitle: 'Try adjusting your search terms',
      );
    }
    return EmptyState(
      icon: Icons.people_outline,
      title: 'No patients yet',
      subtitle: 'Add your first patient to get started',
      action: FilledButton.icon(
        onPressed: _showAddPatientDialog,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add Patient'),
      ),
    );
  }

  Widget _buildPatientList() {
    return ListView.separated(
      itemCount: _filteredPatients.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppTheme.spacingMd),
      itemBuilder: (context, index) {
        final patient = _filteredPatients[index];
        return _PatientCard(
          patient: patient,
          onTap: () => widget.onPatientSelected?.call(patient),
        );
      },
    );
  }
}

class _PatientCard extends StatelessWidget {
  final UserModel patient;
  final VoidCallback? onTap;

  const _PatientCard({
    required this.patient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryPurple.withOpacity(0.8),
                  AppTheme.primaryPurple,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Center(
              child: Text(
                patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingLg),
          
          // Patient info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  patient.email,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (patient.diagnosis != null) ...[
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    patient.diagnosis!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                  ),
                ],
              ],
            ),
          ),
          
          // Modules badges
          if (patient.assignedModules != null && patient.assignedModules!.isNotEmpty)
            Wrap(
              spacing: AppTheme.spacingSm,
              children: patient.assignedModules!.map((module) {
                return _ModuleBadge(module: module);
              }).toList(),
            )
          else
            Text(
              'No modules',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          
          const SizedBox(width: AppTheme.spacingMd),
          
          // Chevron
          Icon(
            Icons.chevron_right,
            color: AppTheme.textTertiary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _ModuleBadge extends StatelessWidget {
  final TherapyModule module;

  const _ModuleBadge({required this.module});

  @override
  Widget build(BuildContext context) {
    final isWriting = module == TherapyModule.writing;
    final color = isWriting ? AppTheme.primaryPurple : const Color(0xFF0D9488);
    final bgColor = isWriting ? AppTheme.primaryPurpleLight : const Color(0xFFCCFBF1);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isWriting ? Icons.edit_outlined : Icons.headphones_outlined,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            module.name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
