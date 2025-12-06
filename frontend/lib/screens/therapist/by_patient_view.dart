import 'package:flutter/material.dart';
import '../../services/app_service.dart';
import '../../models/user_model.dart';
import '../../models/exercise_score_model.dart';
import 'patient_list_sidebar.dart';
import 'patient_details_tab.dart';
import 'patient_report_tab.dart';

// ServiceFactory is in app_service.dart

class ByPatientView extends StatefulWidget {
  const ByPatientView({super.key});

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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    setState(() => _isLoading = true);
    final patients = await _service.getTherapistPatients('');
    setState(() {
      _patients = patients;
      if (patients.isNotEmpty && _selectedPatient == null) {
        _selectedPatient = patients.first;
        _loadPatientScores(patients.first.id);
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

  void _handlePatientSelected(UserModel patient) {
    setState(() {
      _selectedPatient = patient;
    });
    _loadPatientScores(patient.id);
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

    return Row(
      children: [
        // Left sidebar with patient list
        PatientListSidebar(
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
          onPatientSelected: _handlePatientSelected,
        ),
        // Right side with tabs
        Expanded(
          child: _selectedPatient == null
              ? const Center(
                  child: Text('Select a patient to view details'),
                )
              : Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Patient Details'),
                        Tab(text: 'Report'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          PatientDetailsTab(
                            patient: _selectedPatient!,
                            scores: _patientScores,
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
        ),
      ],
    );
  }
}

