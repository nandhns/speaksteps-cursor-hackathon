import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../models/patient_progress_model.dart';
import '../../models/exercise_score_model.dart';
import '../../services/app_service.dart';

class PatientDetailScreen extends StatefulWidget {
  final UserModel patient;

  const PatientDetailScreen({
    super.key,
    required this.patient,
  });

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  late final AppService _service;
  PatientProgress? _progress;
  List<ExerciseScore> _recentScores = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _service = ServiceFactory.createService();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    setState(() => _isLoading = true);
    
    final progress = await _service.getPatientProgress(widget.patient.id);
    final scores = await _service.getPatientScores(widget.patient.id);
    
    setState(() {
      _progress = progress;
      _recentScores = scores.take(20).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient.name),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient Info Card
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.blue.shade700,
                            child: Text(
                              widget.patient.name[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.patient.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.patient.email,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.grey.shade700,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Progress Summary
                  if (_progress != null) ...[
                    Text(
                      'Progress Summary',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            context,
                            'Total Exercises',
                            '${_progress!.totalExercisesCompleted}',
                            Icons.assignment,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            context,
                            'Average Score',
                            '${_progress!.averageScore.toStringAsFixed(1)}%',
                            Icons.trending_up,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            context,
                            'Last Activity',
                            _progress!.lastActivity != null
                                ? DateFormat('MMM d, yyyy').format(_progress!.lastActivity)
                                : 'Never',
                            Icons.access_time,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            context,
                            'Exercises Tracked',
                            '${_progress!.scoresByExercise.length}',
                            Icons.list,
                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Recent Scores
                  Text(
                    'Recent Exercise Scores',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  if (_recentScores.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No exercises completed yet',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ..._recentScores.map((score) {
                      final isPassing = score.score >= 70;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isPassing
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                            child: Icon(
                              isPassing ? Icons.check : Icons.close,
                              color: isPassing
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                          title: Text(
                            score.exerciseTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (score.exerciseModule != null) ...[
                                Text(
                                  'Module: ${score.exerciseModule}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: score.exerciseModule == 'Menulis'
                                        ? Colors.blue.shade700
                                        : Colors.purple.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                'Completed: ${DateFormat('MMM d, yyyy • h:mm a').format(score.completedAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (score.answer != null && score.correctAnswer != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Answer: ${score.answer}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  'Correct: ${score.correctAnswer}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: score.answer == score.correctAnswer
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${score.score}/${score.maxScore}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isPassing
                                          ? Colors.green.shade700
                                          : Colors.orange.shade700,
                                    ),
                              ),
                              Text(
                                '${((score.score / score.maxScore) * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                  // Performance by Module Section
                  const SizedBox(height: 32),
                  Text(
                    'Performance by Module',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildModulePerformanceCards(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    MaterialColor color,
  ) {
    return Card(
      color: color.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModulePerformanceCards() {
    // Calculate module statistics
    final menulistScores = _recentScores.where((s) => s.exerciseModule == 'Menulis').toList();
    final kefahamanScores = _recentScores.where((s) => s.exerciseModule == 'Kefahaman').toList();

    return Column(
      children: [
        if (menulistScores.isNotEmpty)
          _buildModuleCard(
            'Menulis (Writing)',
            menulistScores,
            Colors.blue,
          ),
        const SizedBox(height: 12),
        if (kefahamanScores.isNotEmpty)
          _buildModuleCard(
            'Kefahaman (Comprehension)',
            kefahamanScores,
            Colors.purple,
          ),
        if (menulistScores.isEmpty && kefahamanScores.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'No module performance data available yet',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildModuleCard(String moduleName, List<ExerciseScore> scores, MaterialColor color) {
    final totalScores = scores.length;
    final averageScore = scores.fold<double>(0, (sum, s) => sum + (s.score / s.maxScore * 100)) / totalScores;
    final passingCount = scores.where((s) => s.score / s.maxScore >= 0.7).length;
    final passingRate = (passingCount / totalScores * 100);

    // Get unique exercises
    final uniqueExercises = scores.map((s) => s.exerciseId).toSet().length;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  moduleName.contains('Writing') ? Icons.edit : Icons.hearing,
                  color: color,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  moduleName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color.shade700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildModuleStatItem(
                    'Average Score',
                    '${averageScore.toStringAsFixed(1)}%',
                    Icons.trending_up,
                    color,
                  ),
                ),
                Expanded(
                  child: _buildModuleStatItem(
                    'Passing Rate',
                    '${passingRate.toStringAsFixed(0)}%',
                    Icons.check_circle,
                    color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildModuleStatItem(
                    'Total Attempts',
                    '$totalScores',
                    Icons.assignment,
                    color,
                  ),
                ),
                Expanded(
                  child: _buildModuleStatItem(
                    'Exercises Tried',
                    '$uniqueExercises',
                    Icons.apps,
                    color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleStatItem(String label, String value, IconData icon, MaterialColor color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color.shade400),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color.shade700,
          ),
        ),
      ],
    );
  }
}
