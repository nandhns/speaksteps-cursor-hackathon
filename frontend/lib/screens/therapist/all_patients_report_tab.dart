import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../models/exercise_score_model.dart';
import '../../models/exercise_model.dart';
import 'report_utils.dart';
import 'category_breakdown_widget.dart';

class AllPatientsReportTab extends StatelessWidget {
  final List<UserModel> patients;
  final Map<String, List<ExerciseScore>> allScores;

  const AllPatientsReportTab({
    super.key,
    required this.patients,
    required this.allScores,
  });

  @override
  Widget build(BuildContext context) {
    final allScoresList = allScores.values.expand((scores) => scores).toList();
    final reportData = ReportUtils.calculateAllPatientsReport(
      patients,
      allScoresList,
    );
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Download Report Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {
                ReportUtils.generatePDFReport(
                  context,
                  reportData,
                  patients,
                  isAllPatients: true,
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
          // Report Containers - responsive layout
          if (isMobile) ...[
            // Mobile: Stack vertically
            _buildReportContainer(
              context,
              'Total Patients',
              '${patients.length}',
              Icons.people,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildReportContainer(
              context,
              'Avg Time to Complete',
              reportData['avgTimeComplete'] ?? 'N/A',
              Icons.timer,
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildReportContainer(
              context,
              'Total Time on App',
              reportData['totalTimeOnApp'] ?? 'N/A',
              Icons.access_time,
              Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildListContainer(
              context,
              'Question Duration',
              reportData['questionDurations'] ?? [],
              Icons.schedule,
              Colors.purple,
            ),
            const SizedBox(height: 16),
            _buildListContainer(
              context,
              'Cue Needed per Question',
              reportData['cueNeededPerQuestion'] ?? [],
              Icons.lightbulb,
              Colors.amber,
            ),
            const SizedBox(height: 16),
            _buildTextContainer(
              context,
              'Avg Cue Type',
              reportData['avgCueType'] ?? 'N/A',
              Icons.help_outline,
              Colors.teal,
            ),
          ] else ...[
            // Desktop: 2 rows, 3 columns
            Row(
              children: [
                Expanded(
                  child: _buildReportContainer(
                    context,
                    'Total Patients',
                    '${patients.length}',
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
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
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextContainer(
                    context,
                    'Avg Cue Type',
                    reportData['avgCueType'] ?? 'N/A',
                    Icons.help_outline,
                    Colors.teal,
                  ),
                ),
              ],
            ),
          ],
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
            allScores: allScoresList,
            isAllPatients: true,
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
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                        ),
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
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListContainer(
    BuildContext context,
    String label,
    List<String> items,
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
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No data',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 120,
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            items[index],
                            style: Theme.of(context).textTheme.bodySmall,
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
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                        ),
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
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

