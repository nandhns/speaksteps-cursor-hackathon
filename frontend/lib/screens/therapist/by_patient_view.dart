import 'package:flutter/material.dart';
import '../../services/app_service.dart';
import '../../models/user_model.dart';
import '../../models/exercise_score_model.dart';
import 'patient_list_sidebar.dart';
import 'patient_details_tab.dart';
import 'patient_report_tab.dart';

// ServiceFactory is in app_service.dart

class ByPatientView extends StatefulWidget {
  final UserModel? initialPatient;

  const ByPatientView({
    super.key,
    this.initialPatient,
  });

  @override
  State<ByPatientView> createState() => _ByPatientViewState();
}

class _ByPatientViewState extends State<ByPatientView>
    with SingleTickerProviderStateMixin {
  late final AppService _service;
  late TabController _tabController;
  List<UserModel> _patients = [];
  UserModel? _selectedPatient;
  List<ExerciseScore> _patientScores = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _service = ServiceFactory.createService();
    _tabController = TabController(length: 2, vsync: this);
    _loadPatients();
  }

  @override
  void didUpdateWidget(ByPatientView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If initialPatient changed and patients are already loaded, select it
    if (widget.initialPatient != null &&
        widget.initialPatient != oldWidget.initialPatient &&
        _patients.isNotEmpty &&
        !_isLoading) {
      final foundPatient = _patients.firstWhere(
        (p) => p.id == widget.initialPatient!.id,
        orElse: () => _patients.first,
      );
      if (_selectedPatient?.id != foundPatient.id) {
        _handlePatientSelected(foundPatient);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    setState(() => _isLoading = true);
    // Get current therapist ID from the service
    final therapistId = _service.currentUser?.id ?? '';
    final patients = await _service.getTherapistPatients(therapistId);
    setState(() {
      _patients = patients;
      // If initialPatient is provided, use it; otherwise use first patient
      if (patients.isNotEmpty) {
        if (widget.initialPatient != null) {
          // Find the patient in the list by ID
          final foundPatient = patients.firstWhere(
            (p) => p.id == widget.initialPatient!.id,
            orElse: () => patients.first,
          );
          _selectedPatient = foundPatient;
          _loadPatientScores(foundPatient.id);
        } else if (_selectedPatient == null) {
          _selectedPatient = patients.first;
          _loadPatientScores(patients.first.id);
        }
      }
      _isLoading = false;
    });
  }

  Future<void> _loadPatientScores(String patientId) async {
    final scores = await _service.getPatientScores(patientId);
    setState(() {
      _patientScores = scores;
    });
  }

  void _handlePatientSelected(UserModel patient) async {
    setState(() {
      _selectedPatient = patient;
    });
    await _loadPatientScores(patient.id);
  }

  Future<void> _refreshCurrentPatient() async {
    if (_selectedPatient != null) {
      // Reload the patient data and scores
      await _loadPatients();
      await _loadPatientScores(_selectedPatient!.id);
    }
  }

  List<UserModel> get _filteredAndSortedPatients {
    var filtered = _patients.where((p) {
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    filtered.sort((a, b) {
      final comparison = a.name.compareTo(b.name);
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      drawer: Drawer(
        width: 300,
        child: PatientListSidebar(
          patients: _filteredAndSortedPatients,
          selectedPatient: _selectedPatient,
          searchQuery: _searchQuery,
          sortAscending: _sortAscending,
          onSearchChanged: (query) {
            setState(() {
              _searchQuery = query;
            });
          },
          onSortChanged: (ascending) {
            setState(() {
              _sortAscending = ascending;
            });
          },
          onPatientSelected: (patient) {
            _handlePatientSelected(patient);
            Navigator.of(context).pop(); // Close drawer after selection
          },
        ),
      ),
      appBar: AppBar(
        title: Text(
          _selectedPatient?.name ?? 'Select a Patient',
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Open patient list',
          ),
        ),
      ),
      body: _selectedPatient == null
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
                    'Select a patient to view details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the menu icon to browse patients',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Patient Details'),
                    Tab(text: 'Performance Progress'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      PatientDetailsTab(
                        patient: _selectedPatient!,
                        scores: _patientScores,
                        onPatientUpdated: _refreshCurrentPatient,
                      ),
                      PatientReportTab(
                        patient: _selectedPatient!,
                        scores: _patientScores,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

