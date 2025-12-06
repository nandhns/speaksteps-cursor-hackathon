import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/app_service.dart';
import '../../widgets/add_patient_dialog.dart';

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

  @override
  void initState() {
    super.initState();
    _service = ServiceFactory.createService();
  }

  Future<void> _handleAddPatient({
    required String email,
    required String name,
    required String diagnosis,
    required String patientPhone,
    required String caregiverName,
    required String caregiverPhone,
  }) async {
    await _service.createPatient(
      email: email,
      name: name,
      diagnosis: diagnosis,
      patientPhone: patientPhone,
      caregiverName: caregiverName,
      caregiverPhone: caregiverPhone,
    );
    // Refresh the patient list
    widget.onRefresh();
  }

  void _showAddPatientDialog() {
    showDialog(
      context: context,
      builder: (context) => AddPatientDialog(
        onSubmit: _handleAddPatient,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with Add Patient button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Patients (${widget.patients.length})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddPatientDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Patient'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ),
        // Patient list
        Expanded(
          child: widget.patients.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No patients yet',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add a patient to get started',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade500,
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: widget.patients.length,
                  itemBuilder: (context, index) {
                    final patient = widget.patients[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade700,
                          child: Text(
                            patient.name[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          patient.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(patient.email),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          if (widget.onPatientSelected != null) {
                            widget.onPatientSelected!(patient);
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

