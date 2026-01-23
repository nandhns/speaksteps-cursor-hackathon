import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/exercise_score_model.dart';
import '../theme/app_theme.dart';

class PatientDashboardCard extends StatelessWidget {
  final List<ExerciseScore> scores;
  final String patientName;

  const PatientDashboardCard({
    super.key,
    required this.scores,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context) {
    final isBM = Localizations.localeOf(context).languageCode == 'ms';
    if (scores.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.insights, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No activity yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start practicing to see your progress here!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate stats
    final totalExercises = scores.length;
    final totalCorrect = scores.fold<int>(0, (sum, s) => sum + s.score);
    final totalQuestions = scores.fold<int>(0, (sum, s) => sum + s.maxScore);
    final accuracy = totalQuestions > 0 ? (totalCorrect / totalQuestions * 100) : 0.0;
    
    final recentScores = scores.take(5).toList();
    final lastPracticed = scores.isNotEmpty 
        ? DateFormat('MMM d, yyyy').format(scores.first.completedAt)
        : 'Never';

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: AppTheme.primaryPurple),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isBM ? 'Kemajuan Saya' : 'My Progress',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: isBM ? 'Tutup' : 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Exercises',
                    '$totalExercises',
                    Icons.assignment,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Accuracy',
                    '${accuracy.toStringAsFixed(0)}%',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...recentScores.map((score) => _buildRecentItem(context, score)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  'Last practiced: $lastPracticed',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentItem(BuildContext context, ExerciseScore score) {
    final isBM = Localizations.localeOf(context).languageCode == 'ms';
    final label = isBM ? 'Markah Terkini' : 'Recent Score';
    final percentage = score.maxScore > 0 ? (score.score / score.maxScore * 100) : 0;
    final isPassing = percentage >= 70;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isPassing ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isPassing ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              score.exerciseTitle,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$label: ${score.score}/${score.maxScore}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isPassing ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
