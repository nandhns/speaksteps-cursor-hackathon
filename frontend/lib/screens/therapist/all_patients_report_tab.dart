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
          // Report Containers - One row with two containers
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
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildReportContainer(
                  context,
                  'Total Time on App',
                  reportData['totalTimeOnApp'] ?? 'N/A',
                  Icons.access_time,
                  Colors.orange,
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
                            items[index],
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
}

