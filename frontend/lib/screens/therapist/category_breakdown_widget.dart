import 'package:flutter/material.dart';
import '../../models/exercise_score_model.dart';
import '../../models/exercise_model.dart';

class CategoryBreakdownWidget extends StatelessWidget {
  final List<ExerciseScore> allScores;
  final bool isAllPatients;

  const CategoryBreakdownWidget({
    super.key,
    required this.allScores,
    required this.isAllPatients,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate metrics for each category
    final categoryMetrics = <ExerciseCategory, Map<String, dynamic>>{};

    for (var category in ExerciseCategory.values) {
      final categoryScores = allScores.where((score) {
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

      // Calculate metrics
      final times = categoryScores
          .where((s) => s.metadata?['timeTaken'] != null)
          .map((s) => s.metadata!['timeTaken'] as int)
          .toList();
      
      final avgTime = times.isEmpty
          ? 0
          : (times.reduce((a, b) => a + b) / times.length).round();
      
      final totalTime = times.isEmpty ? 0 : times.reduce((a, b) => a + b);
      final totalTimeMin = (totalTime / 60).toStringAsFixed(1);

      // Question durations by exercise ID
      final questionDurations = <String, List<int>>{};
      for (var score in categoryScores) {
        if (score.metadata?['timeTaken'] != null) {
          final exerciseId = score.exerciseId;
          questionDurations.putIfAbsent(exerciseId, () => []).add(
                score.metadata!['timeTaken'] as int,
              );
        }
      }
      final questionDurationList = questionDurations.entries.map((e) {
        final avg = (e.value.reduce((a, b) => a + b) / e.value.length).round();
        return 'Question ${e.key.substring(e.key.length - 1)} - ${avg}s';
      }).toList();

      // Cue needed per question
      final cueNeededPerQuestion = <String, List<int>>{};
      for (var score in categoryScores) {
        if (score.metadata?['cueLevel'] != null) {
          final exerciseId = score.exerciseId;
          final cueLevel = score.metadata!['cueLevel'] as int;
          cueNeededPerQuestion.putIfAbsent(exerciseId, () => []).add(cueLevel);
        }
      }
      final cueNeededList = cueNeededPerQuestion.entries.map((e) {
        final avgCue = (e.value.reduce((a, b) => a + b) / e.value.length).round();
        final cueType = avgCue == 1
            ? 'Function'
            : avgCue == 2
                ? 'Rhyming'
                : avgCue == 3
                    ? 'Written'
                    : 'None';
        return 'Question ${e.key.substring(e.key.length - 1)} - $cueType';
      }).toList();

      // Average cue type
      final allCueLevels = categoryScores
          .where((s) => s.metadata?['cueLevel'] != null)
          .map((s) => s.metadata!['cueLevel'] as int)
          .toList();
      final avgCueLevel = allCueLevels.isEmpty
          ? 0
          : (allCueLevels.reduce((a, b) => a + b) / allCueLevels.length).round();
      final avgCueType = avgCueLevel == 0
          ? 'None'
          : avgCueLevel == 1
              ? 'Function'
              : avgCueLevel == 2
                  ? 'Rhyming'
                  : 'Written';

      categoryMetrics[category] = {
        'count': categoryScores.length,
        'avgTimeComplete': '${avgTime}s',
        'totalTimeOnApp': '$totalTimeMin min',
        'questionDurations': questionDurationList,
        'cueNeededPerQuestion': cueNeededList,
        'avgCueType': avgCueType,
      };
    }

    if (categoryMetrics.isEmpty) {
      return Card(
        elevation: 2,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categoryMetrics.entries.map((entry) {
        final category = entry.key;
        final metrics = entry.value;
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Header
                Row(
                  children: [
                    Text(
                      _getCategoryEmoji(category),
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getCategoryName(category),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getCategoryColor(category),
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '${metrics['count']} exercises',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 12),
                // Metrics Grid
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        'Avg Time Complete',
                        metrics['avgTimeComplete'] as String,
                        Icons.timer,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        'Total Time on App',
                        metrics['totalTimeOnApp'] as String,
                        Icons.access_time,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildListMetricCard(
                        context,
                        'Question Duration',
                        metrics['questionDurations'] as List<String>,
                        Icons.schedule,
                        Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildListMetricCard(
                        context,
                        'Cue Needed per Question',
                        metrics['cueNeededPerQuestion'] as List<String>,
                        Icons.lightbulb,
                        Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildMetricCard(
                  context,
                  'Avg Cue Type',
                  metrics['avgCueType'] as String,
                  Icons.help_outline,
                  Colors.teal,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    MaterialColor color,
  ) {
    return Card(
      color: color.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListMetricCard(
    BuildContext context,
    String label,
    List<String> items,
    IconData icon,
    MaterialColor color,
  ) {
    return Card(
      color: color.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        'No data',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: Text(
                            items[index],
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                ),
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

  Color _getCategoryColor(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.animal:
        return Colors.orange;
      case ExerciseCategory.bodyParts:
        return Colors.pink;
      case ExerciseCategory.food:
        return Colors.green;
      case ExerciseCategory.verbs:
        return Colors.purple;
    }
  }
}

