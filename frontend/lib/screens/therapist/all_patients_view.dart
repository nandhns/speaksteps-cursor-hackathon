import 'package:flutter/material.dart';
import '../../services/app_service.dart';
import '../../models/user_model.dart';
import '../../models/exercise_score_model.dart';
import '../../models/patient_progress_model.dart';
import 'all_patients_list_tab.dart';
import 'all_patients_report_tab.dart';

// ServiceFactory is in app_service.dart

class AllPatientsView extends StatefulWidget {
  final Function(UserModel)? onPatientSelected;

  const AllPatientsView({
    super.key,
    this.onPatientSelected,
  });

  @override
  State<AllPatientsView> createState() => _AllPatientsViewState();
}

class _AllPatientsViewState extends State<AllPatientsView>
    with SingleTickerProviderStateMixin {
  late final AppService _service;
  late TabController _tabController;
  List<UserModel> _patients = [];
  Map<String, List<ExerciseScore>> _allScores = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _service = ServiceFactory.createService();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final patients = await _service.getTherapistPatients('');
    final allScores = <String, List<ExerciseScore>>{};

    for (var patient in patients) {
      final scores = await _service.getPatientScores(patient.id);
      allScores[patient.id] = scores;
    }

    setState(() {
      _patients = patients;
      _allScores = allScores;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Patient List'),
            Tab(text: 'Report'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              AllPatientsListTab(
                patients: _patients,
                onRefresh: _loadData,
                onPatientSelected: widget.onPatientSelected,
              ),
              AllPatientsReportTab(
                patients: _patients,
                allScores: _allScores,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

