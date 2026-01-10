import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';

class AddPatientDialog extends StatefulWidget {
  final Function({
    required String email,
    required String name,
    required String diagnosis,
    required String patientPhone,
    required String caregiverName,
    required String caregiverPhone,
    required List<TherapyModule> assignedModules,
    required bool sendOnboardingEmail,
    required String preferredLanguage,
  }) onSubmit;

  const AddPatientDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends State<AddPatientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _patientPhoneController = TextEditingController();
  final _caregiverNameController = TextEditingController();
  final _caregiverPhoneController = TextEditingController();
  bool _isSubmitting = false;

  bool _assignWriting = true;
  bool _assignComprehension = false;
  bool _sendOnboardingEmail = true;
  String _preferredLanguage = 'en'; // Default to English

  final List<String> _aphasiaTypes = [
    'Broca\'s Aphasia',
    'Wernicke\'s Aphasia',
    'Global Aphasia',
    'Anomic Aphasia',
    'Conduction Aphasia',
    'Transcortical Motor Aphasia',
    'Transcortical Sensory Aphasia',
    'Mixed Transcortical Aphasia',
    'Other',
  ];

  String? _selectedAphasiaType;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _diagnosisController.dispose();
    _patientPhoneController.dispose();
    _caregiverNameController.dispose();
    _caregiverPhoneController.dispose();
    super.dispose();
  }

  List<TherapyModule> _getSelectedModules() {
    final modules = <TherapyModule>[];
    if (_assignWriting) modules.add(TherapyModule.writing);
    if (_assignComprehension) modules.add(TherapyModule.comprehension);
    return modules;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_assignWriting && !_assignComprehension) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please assign at least one module'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await widget.onSubmit(
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
        diagnosis: _selectedAphasiaType ?? _diagnosisController.text.trim(),
        patientPhone: _patientPhoneController.text.trim(),
        caregiverName: _caregiverNameController.text.trim(),
        caregiverPhone: _caregiverPhoneController.text.trim(),
        assignedModules: _getSelectedModules(),
        sendOnboardingEmail: _sendOnboardingEmail,
        preferredLanguage: _preferredLanguage,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_sendOnboardingEmail
                ? 'Patient added and onboarding email sent!'
                : 'Patient added successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding patient: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.spacingXl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Patient Information'),
                      const SizedBox(height: AppTheme.spacingLg),
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full name',
                        hint: 'Enter patient\'s full name',
                        icon: Icons.person_outline,
                        validator: (v) => v?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email address',
                        hint: 'patient@example.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v?.isEmpty == true) return 'Required';
                          if (!v!.contains('@')) return 'Invalid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                      _buildDropdownField(),
                      if (_selectedAphasiaType == 'Other') ...[
                        const SizedBox(height: AppTheme.spacingLg),
                        _buildTextField(
                          controller: _diagnosisController,
                          label: 'Custom diagnosis',
                          hint: 'Enter diagnosis type',
                          icon: Icons.edit_outlined,
                          validator: (v) => _selectedAphasiaType == 'Other' && v?.isEmpty == true
                              ? 'Required' : null,
                        ),
                      ],
                      const SizedBox(height: AppTheme.spacingLg),
                      _buildTextField(
                        controller: _patientPhoneController,
                        label: 'Patient phone',
                        hint: '+1 (555) 123-4567',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v?.isEmpty == true) return 'Required';
                          if (v!.replaceAll(RegExp(r'[^\d]'), '').length < 10) return 'Invalid phone';
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: AppTheme.spacingXl),
                      _buildSectionTitle('Caregiver Information'),
                      const SizedBox(height: AppTheme.spacingLg),
                      _buildTextField(
                        controller: _caregiverNameController,
                        label: 'Caregiver name',
                        hint: 'Enter caregiver\'s full name',
                        icon: Icons.people_outline,
                        validator: (v) => v?.isEmpty == true ? 'Required' : null,
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                      _buildTextField(
                        controller: _caregiverPhoneController,
                        label: 'Caregiver phone',
                        hint: '+1 (555) 123-4567',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v?.isEmpty == true) return 'Required';
                          if (v!.replaceAll(RegExp(r'[^\d]'), '').length < 10) return 'Invalid phone';
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: AppTheme.spacingXl),
                      _buildModuleSection(),
                      const SizedBox(height: AppTheme.spacingLg),
                      _buildLanguageSection(),
                      const SizedBox(height: AppTheme.spacingLg),
                      _buildEmailSection(),
                    ],
                  ),
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurpleLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: const Icon(Icons.person_add_outlined, color: AppTheme.primaryPurple, size: 20),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add New Patient', style: Theme.of(context).textTheme.titleLarge),
                Text('Fill in the patient details below', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(backgroundColor: AppTheme.surfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.textSecondary));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppTheme.spacingSm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Diagnosis', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppTheme.spacingSm),
        DropdownButtonFormField<String>(
          value: _selectedAphasiaType,
          decoration: const InputDecoration(
            hintText: 'Select aphasia type',
            prefixIcon: Icon(Icons.medical_services_outlined, size: 20),
          ),
          isExpanded: true,
          items: _aphasiaTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
          onChanged: (value) => setState(() {
            _selectedAphasiaType = value;
            if (value != 'Other') _diagnosisController.clear();
          }),
          validator: (v) => v == null && _diagnosisController.text.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildModuleSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurpleLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_outlined, color: AppTheme.primaryPurple, size: 18),
              const SizedBox(width: AppTheme.spacingSm),
              Text('Assign Modules', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.primaryPurple)),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          _ModuleCheckbox(
            title: 'Writing',
            subtitle: 'Picture naming, typing exercises',
            value: _assignWriting,
            onChanged: (v) => setState(() => _assignWriting = v ?? false),
          ),
          _ModuleCheckbox(
            title: 'Comprehension',
            subtitle: 'Word-to-picture matching',
            value: _assignComprehension,
            onChanged: (v) => setState(() => _assignComprehension = v ?? false),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurpleLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.language, color: AppTheme.primaryPurple, size: 18),
              const SizedBox(width: AppTheme.spacingSm),
              Text('Preferred Language', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppTheme.primaryPurple)),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              Expanded(
                child: _LanguageOption(
                  label: 'English',
                  isSelected: _preferredLanguage == 'en',
                  onTap: () => setState(() => _preferredLanguage = 'en'),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: _LanguageOption(
                  label: 'Bahasa Melayu',
                  isSelected: _preferredLanguage == 'ms',
                  onTap: () => setState(() => _preferredLanguage = 'ms'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.successLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _sendOnboardingEmail,
            onChanged: (v) => setState(() => _sendOnboardingEmail = v ?? true),
            activeColor: AppTheme.success,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Send onboarding email', style: Theme.of(context).textTheme.titleSmall),
                Text('Patient receives login instructions', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Icon(Icons.email_outlined, color: AppTheme.success, size: 20),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          FilledButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Add Patient'),
          ),
        ],
      ),
    );
  }
}

class _ModuleCheckbox extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _ModuleCheckbox({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
        child: Row(
          children: [
            Checkbox(value: value, onChanged: onChanged, activeColor: AppTheme.primaryPurple),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd, horizontal: AppTheme.spacingSm),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: isSelected ? AppTheme.primaryPurple : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              Icon(Icons.check_circle, color: AppTheme.surface, size: 18),
            if (isSelected)
              const SizedBox(width: AppTheme.spacingXs),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isSelected ? AppTheme.surface : AppTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
