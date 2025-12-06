import 'package:flutter/material.dart';

class AddPatientDialog extends StatefulWidget {
  final Function({
    required String email,
    required String name,
    required String diagnosis,
    required String patientPhone,
    required String caregiverName,
    required String caregiverPhone,
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

  // Common aphasia types
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

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
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
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding patient: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_add, color: Colors.white),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Add New Patient',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // Form content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Patient Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Patient Name *',
                          hintText: 'Enter patient\'s full name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter patient name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Patient Email
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Patient Email *',
                          hintText: 'patient@example.com',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter patient email';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Diagnosis Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedAphasiaType,
                        decoration: const InputDecoration(
                          labelText: 'Diagnosis (Type of Aphasia) *',
                          hintText: 'Select diagnosis',
                          prefixIcon: Icon(Icons.medical_services),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        isExpanded: true,
                        items: _aphasiaTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              type,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAphasiaType = value;
                            if (value != 'Other') {
                              _diagnosisController.clear();
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null && _diagnosisController.text.trim().isEmpty) {
                            return 'Please select or enter diagnosis';
                          }
                          return null;
                        },
                      ),
                      // Custom diagnosis field (shown when "Other" is selected)
                      if (_selectedAphasiaType == 'Other') ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _diagnosisController,
                          decoration: const InputDecoration(
                            labelText: 'Custom Diagnosis *',
                            hintText: 'Enter diagnosis type',
                            prefixIcon: Icon(Icons.edit),
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (_selectedAphasiaType == 'Other' &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Please enter diagnosis';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Patient Phone Number
                      TextFormField(
                        controller: _patientPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Patient Phone Number *',
                          hintText: '+1 (555) 123-4567',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter patient phone number';
                          }
                          // Basic phone validation (at least 10 digits)
                          final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
                          if (digitsOnly.length < 10) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Caregiver Name
                      TextFormField(
                        controller: _caregiverNameController,
                        decoration: const InputDecoration(
                          labelText: 'Caregiver Name *',
                          hintText: 'Enter caregiver\'s full name',
                          prefixIcon: Icon(Icons.people),
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter caregiver name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Caregiver Phone
                      TextFormField(
                        controller: _caregiverPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Caregiver Phone Number *',
                          hintText: '+1 (555) 123-4567',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter caregiver phone number';
                          }
                          // Basic phone validation (at least 10 digits)
                          final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
                          if (digitsOnly.length < 10) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _isSubmitting
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _isSubmitting ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text('Add Patient'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

