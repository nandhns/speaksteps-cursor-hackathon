import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../models/exercise_score_model.dart';
import '../../models/exercise_model.dart';
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
          // Report Containers - Single row
          _buildReportContainer(
            context,
            'Avg Time to Complete',
            reportData['avgTimeComplete'] ?? 'N/A',
            Icons.timer,
            Colors.green,
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
          // Performance Statistics
          if (scores.isNotEmpty) ...[
            Text(
              'Performance Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildStatisticsSection(context, scores),
            const SizedBox(height: 24),
          ],
          // Performance by Category
          if (scores.isNotEmpty) ...[
            Text(
              'Performance by Category',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildCategoryPerformance(context, scores),
            const SizedBox(height: 24),
          ],
          // Performance by Module
          Text(
            'Performance by Module',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildModulePerformanceCards(context, scores),
          const SizedBox(height: 24),
          // Recent Exercise Scores
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Exercise Scores',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (scores.isEmpty)
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
            ...scores.take(20).map((score) {
              final percentage = score.maxScore > 0 ? (score.score / score.maxScore * 100) : 0;
              final isPassing = percentage >= 70;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircleAvatar(
                      backgroundColor: isPassing
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      child: Icon(
                        isPassing ? Icons.check : Icons.close,
                        color: isPassing
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                        size: 20,
                      ),
                    ),
                  ),
                  title: Text(
                    score.exerciseTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d, yyyy • h:mm a').format(score.completedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (score.metadata?['timeTaken'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Time: ${score.metadata!["timeTaken"]}s',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ],
                  ),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${score.score}/${score.maxScore}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isPassing
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
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

  Widget _buildStatisticsSection(BuildContext context, List<ExerciseScore> scores) {
    if (scores.isEmpty) return const SizedBox.shrink();

    // Calculate statistics
    final totalScores = scores.length;
    final correctAnswers = scores.where((s) {
      final percentage = s.maxScore > 0 ? (s.score / s.maxScore * 100) : 0;
      return percentage >= 70;
    }).length;
    final successRate = totalScores > 0 ? (correctAnswers / totalScores * 100) : 0.0;

    final times = scores
        .where((s) => s.metadata?['timeTaken'] != null)
        .map((s) => s.metadata!['timeTaken'] as int)
        .toList();
    final avgTime = times.isEmpty
        ? 0
        : (times.reduce((a, b) => a + b) / times.length).round();
    final totalTime = times.isEmpty ? 0 : times.reduce((a, b) => a + b);
    final totalTimeMin = (totalTime / 60).toStringAsFixed(1);

    final avgScore = scores.isEmpty
        ? 0.0
        : scores.map((s) => s.maxScore > 0 ? (s.score / s.maxScore * 100) : 0).reduce((a, b) => a + b) / scores.length;

    final cueLevels = scores
        .where((s) => s.metadata?['cueLevel'] != null)
        .map((s) => s.metadata!['cueLevel'] as int)
        .toList();
    final avgCueLevel = cueLevels.isEmpty
        ? 0
        : (cueLevels.reduce((a, b) => a + b) / cueLevels.length).round();
    final avgCueType = avgCueLevel == 0
        ? 'None'
        : avgCueLevel == 1
            ? 'Function'
            : avgCueLevel == 2
                ? 'Rhyming'
                : 'Written';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Success Rate',
                '${successRate.toStringAsFixed(1)}%',
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Avg Score',
                '${avgScore.toStringAsFixed(1)}%',
                Icons.trending_up,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Avg Time',
                '${avgTime}s',
                Icons.timer,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Total Time',
                '$totalTimeMin min',
                Icons.access_time,
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Avg Cue Type',
                avgCueType,
                Icons.lightbulb,
                Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Exercises Done',
                '$totalScores',
                Icons.assignment,
                Colors.teal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
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
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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

  Widget _buildCategoryPerformance(BuildContext context, List<ExerciseScore> scores) {
    final categoryStats = <ExerciseCategory, Map<String, dynamic>>{};

    for (var category in ExerciseCategory.values) {
      final categoryScores = scores.where((score) {
        final scoreCategory = score.metadata?['category'] as String?;
        if (scoreCategory == null) return false;
        try {
          return ExerciseCategory.values.firstWhere(
            (e) => e.name == scoreCategory,
          ) == category;
        } catch (e) {
          return false;
        }
      }).toList();

      if (categoryScores.isEmpty) continue;

      final correct = categoryScores.where((s) {
        final percentage = s.maxScore > 0 ? (s.score / s.maxScore * 100) : 0;
        return percentage >= 70;
      }).length;
      final successRate = categoryScores.isEmpty
          ? 0.0
          : (correct / categoryScores.length * 100);

      final times = categoryScores
          .where((s) => s.metadata?['timeTaken'] != null)
          .map((s) => s.metadata!['timeTaken'] as int)
          .toList();
      final avgTime = times.isEmpty
          ? 0
          : (times.reduce((a, b) => a + b) / times.length).round();

      categoryStats[category] = {
        'count': categoryScores.length,
        'successRate': successRate,
        'avgTime': avgTime,
      };
    }

    if (categoryStats.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No category data available',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ),
      );
    }

    return Column(
      children: categoryStats.entries.map((entry) {
        final category = entry.key;
        final stats = entry.value;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  _getCategoryEmoji(category),
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getCategoryName(category),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMiniStat(
                              context,
                              '${stats['count']} exercises',
                              Icons.assignment,
                            ),
                          ),
                          Expanded(
                            child: _buildMiniStat(
                              context,
                              '${stats['successRate'].toStringAsFixed(0)}% success',
                              Icons.check_circle,
                            ),
                          ),
                          Expanded(
                            child: _buildMiniStat(
                              context,
                              '${stats['avgTime']}s avg',
                              Icons.timer,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMiniStat(BuildContext context, String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade700,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _getCategoryEmoji(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.animal:
        return '🐾';
      case ExerciseCategory.bodyParts:
        return '👤';
      case ExerciseCategory.food:
        return '🍎';
      case ExerciseCategory.verbs:
        return '🎬';
    }
  }

  String _getCategoryName(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.animal:
        return 'Animals';
      case ExerciseCategory.bodyParts:
        return 'Body Parts';
      case ExerciseCategory.food:
        return 'Food';
      case ExerciseCategory.verbs:
        return 'Verbs';
    }
  }
}


