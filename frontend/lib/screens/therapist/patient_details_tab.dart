import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../models/exercise_score_model.dart';
import '../../models/exercise_model.dart';
import '../../services/app_service.dart';

class PatientDetailsTab extends StatefulWidget {
  final UserModel patient;
  final List<ExerciseScore> scores;

  const PatientDetailsTab({
    super.key,
    required this.patient,
    required this.scores,
  });

  @override
  State<PatientDetailsTab> createState() => _PatientDetailsTabState();
}

class _PatientDetailsTabState extends State<PatientDetailsTab> {
  late final AppService _service;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _service = ServiceFactory.createService();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
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
                    radius: 40,
                    backgroundColor: Colors.blue.shade700,
                    child: Text(
                      widget.patient.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
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
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.patient.email,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total Exercises: ${widget.scores.length}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Member since: ${DateFormat('MMM d, yyyy').format(widget.patient.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
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
          // Performance Statistics
          if (widget.scores.isNotEmpty) ...[
            Text(
              'Performance Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildStatisticsSection(context),
            const SizedBox(height: 24),
            // Category Performance
            Text(
              'Performance by Category',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildCategoryPerformance(context),
            const SizedBox(height: 24),
          ],
          // Recent Exercise Scores
          Text(
            'Recent Exercise Scores',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          if (widget.scores.isEmpty)
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
            ...widget.scores.take(20).map((score) {
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
                      if (score.metadata?['timeTaken'] != null)
                        Text(
                          'Time: ${score.metadata!['timeTaken']}s',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
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
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    if (widget.scores.isEmpty) return const SizedBox.shrink();

    // Calculate statistics
    final totalScores = widget.scores.length;
    final correctAnswers = widget.scores.where((s) => s.score >= 70).length;
    final successRate = totalScores > 0 ? (correctAnswers / totalScores * 100) : 0.0;

    final times = widget.scores
        .where((s) => s.metadata?['timeTaken'] != null)
        .map((s) => s.metadata!['timeTaken'] as int)
        .toList();
    final avgTime = times.isEmpty
        ? 0
        : (times.reduce((a, b) => a + b) / times.length).round();
    final totalTime = times.isEmpty ? 0 : times.reduce((a, b) => a + b);
    final totalTimeMin = (totalTime / 60).toStringAsFixed(1);

    final avgScore = widget.scores.isEmpty
        ? 0.0
        : widget.scores.map((s) => s.score).reduce((a, b) => a + b) / widget.scores.length;

    // Cue usage
    final cueLevels = widget.scores
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

    // Exercise types
    final writingCount = widget.scores
        .where((s) => s.metadata?['category'] != null)
        .length; // Simplified - would need exercise type from metadata

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

  Widget _buildCategoryPerformance(BuildContext context) {
    // Group scores by category
    final categoryStats = <ExerciseCategory, Map<String, dynamic>>{};

    for (var category in ExerciseCategory.values) {
      final categoryScores = widget.scores.where((score) {
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

      final correct = categoryScores.where((s) => s.score >= 70).length;
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
      case ExerciseCategory.clothing:
        return '👕';
      case ExerciseCategory.food:
        return '🍎';
    }
  }

  String _getCategoryName(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.animal:
        return 'Animals';
      case ExerciseCategory.bodyParts:
        return 'Body Parts';
      case ExerciseCategory.clothing:
        return 'Clothing';
      case ExerciseCategory.food:
        return 'Food';
    }
  }

  ExerciseCategory _getCategoryFromString(String category) {
    return ExerciseCategory.values.firstWhere(
      (e) => e.name == category,
      orElse: () => ExerciseCategory.animal,
    );
  }

  String _getCueTypeName(int cueLevel) {
    switch (cueLevel) {
      case 0:
        return 'None';
      case 1:
        return 'Function';
      case 2:
        return 'Rhyming';
      case 3:
        return 'Written';
      default:
        return 'Unknown';
    }
  }
}

