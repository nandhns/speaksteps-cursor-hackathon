import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/app_service.dart';
import '../../theme/app_theme.dart';

class EditPatientDialog extends StatefulWidget {
  final UserModel patient;
  final VoidCallback onSaved;

  const EditPatientDialog({
    super.key,
    required this.patient,
    required this.onSaved,
  });

  @override
  State<EditPatientDialog> createState() => _EditPatientDialogState();
}

class _EditPatientDialogState extends State<EditPatientDialog> {
  late final AppService _service;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _diagnosisController;
  late TextEditingController _caregiverNameController;
  late TextEditingController _caregiverPhoneController;
  late List<TherapyModule> _selectedModules;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _service = ServiceFactory.createService();
    _nameController = TextEditingController(text: widget.patient.name);
    _phoneController = TextEditingController(text: widget.patient.patientPhone ?? '');
    _diagnosisController = TextEditingController(text: widget.patient.diagnosis ?? '');
    _caregiverNameController = TextEditingController(text: widget.patient.caregiverName ?? '');
    _caregiverPhoneController = TextEditingController(text: widget.patient.caregiverPhone ?? '');
    _selectedModules = List.from(widget.patient.assignedModules ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _diagnosisController.dispose();
    _caregiverNameController.dispose();
    _caregiverPhoneController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient name is required')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedPatient = UserModel(
        id: widget.patient.id,
        email: widget.patient.email,
        name: _nameController.text.trim(),
        role: widget.patient.role,
        createdAt: widget.patient.createdAt,
        diagnosis: _diagnosisController.text.trim().isEmpty ? null : _diagnosisController.text.trim(),
        patientPhone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        caregiverName: _caregiverNameController.text.trim().isEmpty ? null : _caregiverNameController.text.trim(),
        caregiverPhone: _caregiverPhoneController.text.trim().isEmpty ? null : _caregiverPhoneController.text.trim(),
        therapistId: widget.patient.therapistId,
        assignedModules: _selectedModules.isEmpty ? null : _selectedModules,
        onboardingEmailSent: widget.patient.onboardingEmailSent,
        preferredLanguage: widget.patient.preferredLanguage,
        mustChangePassword: widget.patient.mustChangePassword,
      );

      await _service.saveUser(updatedPatient);

      if (mounted) {
        widget.onSaved();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient details updated successfully'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving changes: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Patient Details',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Patient Name
                _buildTextField(
                  controller: _nameController,
                  label: 'Patient Name',
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),
                
                // Phone Number
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                
                // Diagnosis
                _buildTextField(
                  controller: _diagnosisController,
                  label: 'Diagnosis (Type of Aphasia)',
                  icon: Icons.medical_services,
                ),
                const SizedBox(height: 24),
                
                // Caregiver Information
                Text(
                  'Caregiver Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                
                _buildTextField(
                  controller: _caregiverNameController,
                  label: 'Caregiver Name',
                  icon: Icons.people,
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _caregiverPhoneController,
                  label: 'Caregiver Phone',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                
                // Assigned Modules
                Text(
                  'Assigned Modules',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: const Text('Writing Module'),
                        value: _selectedModules.contains(TherapyModule.writing),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedModules.add(TherapyModule.writing);
                            } else {
                              _selectedModules.remove(TherapyModule.writing);
                            }
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Comprehension Module'),
                        value: _selectedModules.contains(TherapyModule.comprehension),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedModules.add(TherapyModule.comprehension);
                            } else {
                              _selectedModules.remove(TherapyModule.comprehension);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveChanges,
                      icon: _isSaving ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ) : const Icon(Icons.save),
                      label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
