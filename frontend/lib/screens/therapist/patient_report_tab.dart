import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/exercise_score_model.dart';
import 'report_utils.dart';
import 'category_breakdown_widget.dart';

class PatientReportTab extends StatelessWidget {
  final UserModel patient;
  final List<ExerciseScore> scores;

  const PatientReportTab({
    super.key,
    required this.patient,
    required this.scores,
  });

  @override
  Widget build(BuildContext context) {
    final reportData = ReportUtils.calculatePatientReport(patient, scores);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Download Report Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {
                ReportUtils.generatePDFReport(
                  context,
                  reportData,
                  [patient],
                  isAllPatients: false,
                );
              },
              icon: const Icon(Icons.download),
              label: const Text('Download Report (PDF)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Report Containers - One row with two containers
          Row(
            children: [
              Expanded(
                child: _buildReportContainer(
                  context,
                  'Avg Time to Complete',
                  reportData['avgTimeComplete'] ?? 'N/A',
                  Icons.timer,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildReportContainer(
                  context,
                  'Total Time on App',
                  reportData['totalTimeOnApp'] ?? 'N/A',
                  Icons.access_time,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildListContainer(
                  context,
                  'Question Duration',
                  reportData['questionDurations'] ?? [],
                  Icons.schedule,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildListContainer(
                  context,
                  'Cue Needed per Question',
                  reportData['cueNeededPerQuestion'] ?? [],
                  Icons.lightbulb,
                  Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextContainer(
                  context,
                  'Avg Cue Type',
                  reportData['avgCueType'] ?? 'N/A',
                  Icons.help_outline,
                  Colors.teal,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(child: SizedBox()), // Empty space for alignment
            ],
          ),
          const SizedBox(height: 24),
          // Performance by Module (moved from details tab)
          Text(
            'Performance by Module',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildModulePerformanceCards(context, scores),
          const SizedBox(height: 24),
          // Category Breakdown
          Text(
            'Breakdown by Category',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          CategoryBreakdownWidget(
            allScores: scores,
            isAllPatients: false,
          ),
        ],
      ),
    );
  }

  Widget _buildReportContainer(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 20,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListContainer(
    BuildContext context,
    String label,
    List<dynamic> items,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            items.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'No data',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  )
                : ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 120),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            items[index].toString(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  height: 1.4,
                                  letterSpacing: 0.2,
                                ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextContainer(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 18,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModulePerformanceCards(BuildContext context, List<ExerciseScore> scores) {
    final menulisScores = scores.where((s) => s.exerciseModule == 'Menulis').toList();
    final kefahamanScores = scores.where((s) => s.exerciseModule == 'Kefahaman').toList();

    if (menulisScores.isEmpty && kefahamanScores.isEmpty) {
      return Card(
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
      );
    }

    return Column(
      children: [
        if (menulisScores.isNotEmpty)
          _buildModuleCard(context, 'Menulis (Writing)', menulisScores, Colors.blue),
        if (menulisScores.isNotEmpty && kefahamanScores.isNotEmpty)
          const SizedBox(height: 12),
        if (kefahamanScores.isNotEmpty)
          _buildModuleCard(context, 'Kefahaman (Comprehension)', kefahamanScores, Colors.purple),
      ],
    );
  }

  Widget _buildModuleCard(
    BuildContext context,
    String moduleName,
    List<ExerciseScore> scores,
    MaterialColor color,
  ) {
    final totalScores = scores.length;
    final averageScore = scores.fold<double>(0, (sum, s) => sum + (s.score / s.maxScore * 100)) / totalScores;
    final passingCount = scores.where((s) => s.score / s.maxScore >= 0.7).length;
    final passingRate = (passingCount / totalScores * 100);
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

  Widget _buildModuleStatItem(
    String label,
    String value,
    IconData icon,
    MaterialColor color,
  ) {
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

