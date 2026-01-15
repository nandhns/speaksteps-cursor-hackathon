import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../models/exercise_score_model.dart';
import '../../models/exercise_model.dart';
import '../../services/app_service.dart';
import '../../theme/app_theme.dart';
import 'edit_patient_dialog.dart';
import 'view_questions_dialog.dart';

class PatientDetailsTab extends StatefulWidget {
  final UserModel patient;
  final List<ExerciseScore> scores;
  final VoidCallback? onPatientUpdated;

  const PatientDetailsTab({
    super.key,
    required this.patient,
    required this.scores,
    this.onPatientUpdated,
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
                  Flexible(
                    child: CircleAvatar(
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
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.patient.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            SizedBox(
                              width: 36,
                              height: 36,
                              child: IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                style: IconButton.styleFrom(
                                  backgroundColor: AppTheme.primaryPurpleLight,
                                ),
                                onPressed: () async {
                                  await showDialog(
                                    context: context,
                                    builder: (context) => EditPatientDialog(
                                      patient: widget.patient,
                                      onSaved: () {
                                        // Dialog will close and parent will refresh
                                      },
                                    ),
                                  );
                                  // Refresh the view after dialog closes
                                  if (mounted) {
                                    widget.onPatientUpdated?.call();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Patient Information List - Always show all fields
                        _buildInfoItem(
                          context,
                          Icons.email,
                          'Email',
                          widget.patient.email,
                        ),
                        const SizedBox(height: 10),
                        _buildInfoItem(
                          context,
                          Icons.phone,
                          'Phone Number',
                          widget.patient.patientPhone ?? 'Not provided',
                        ),
                        const SizedBox(height: 10),
                        _buildInfoItem(
                          context,
                          Icons.medical_services,
                          'Diagnosis',
                          widget.patient.diagnosis ?? 'Not provided',
                        ),
                        const SizedBox(height: 10),
                        _buildInfoItem(
                          context,
                          Icons.people,
                          'Caregiver Name',
                          widget.patient.caregiverName ?? 'Not provided',
                        ),
                        const SizedBox(height: 10),
                        _buildInfoItem(
                          context,
                          Icons.phone,
                          'Caregiver Phone Number',
                          widget.patient.caregiverPhone ?? 'Not provided',
                        ),
                        const SizedBox(height: 10),
                        _buildInfoItem(
                          context,
                          Icons.school,
                          'Assigned Modules',
                          widget.patient.assignedModules == null || widget.patient.assignedModules!.isEmpty
                              ? 'None assigned'
                              : widget.patient.assignedModules!
                                  .map((m) => m.name == 'writing' ? 'Writing' : 'Comprehension')
                                  .join(', '),
                        ),
                        const SizedBox(height: 12),
                        Divider(color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text(
                          'Total Modules Completed: ${widget.scores.length}',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Exercise Scores',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showAllExercisesDialog(),
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('View All Exercises'),
              ),
            ],
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
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${score.score}/${score.maxScore}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isPassing
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${((score.score / score.maxScore) * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => _showExerciseQuestions(
                          score.exerciseId,
                          score.exerciseTitle,
                        ),
                        icon: const Icon(Icons.quiz_outlined, size: 16),
                        label: const Text('View Questions'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: const Size(0, 32),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

          // Performance by Module Section
          if (widget.scores.isNotEmpty) ...[
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
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    if (widget.scores.isEmpty) return const SizedBox.shrink();

    // Calculate statistics
    final totalScores = widget.scores.length;
    // Calculate success rate based on percentage: (score/maxScore) >= 70%
    final correctAnswers = widget.scores.where((s) {
      final percentage = s.maxScore > 0 ? (s.score / s.maxScore * 100) : 0;
      return percentage >= 70;
    }).length;
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

    // Calculate average score as percentage
    final avgScore = widget.scores.isEmpty
        ? 0.0
        : widget.scores.map((s) => s.maxScore > 0 ? (s.score / s.maxScore * 100) : 0).reduce((a, b) => a + b) / widget.scores.length;

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

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey.shade700,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade900,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showExerciseQuestions(
    String exerciseId,
    String exerciseTitle,
  ) async {
    setState(() => _isLoading = true);
    try {
      final exercise = await _service.getExercise(exerciseId);
      setState(() => _isLoading = false);

      if (!mounted) return;

      if (exercise == null || exercise.questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No questions available for $exerciseTitle',
            ),
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => ViewQuestionsDialog(
          questions: exercise.questions,
          exerciseTitle: exercise.title,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading questions: $e')),
      );
    }
  }

  Future<void> _showAllExercisesDialog() async {
    setState(() => _isLoading = true);
    try {
      final exercises = await _service.getExercises();
      setState(() => _isLoading = false);

      if (!mounted) return;

      // Group exercises by module -> category -> exercises
      final groupedByModule = <String, Map<String, List<Exercise>>>{};
      for (var exercise in exercises) {
        final module = _getModuleName(exercise.type);
        final category = _getCategoryName(exercise.category);
        
        groupedByModule.putIfAbsent(module, () => {});
        groupedByModule[module]!.putIfAbsent(category, () => []).add(exercise);
      }

      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Container(
            width: 700,
            constraints: const BoxConstraints(maxHeight: 750),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.1),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.quiz, color: AppTheme.primaryPurple),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'All Exercises',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryPurple,
                              ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Exercise list with hierarchy
                Flexible(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: groupedByModule.entries.map((moduleEntry) {
                      return _buildModuleSection(context, moduleEntry.key, moduleEntry.value);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading exercises: $e')),
        );
      }
    }
  }

  Widget _buildModuleSection(BuildContext context, String moduleName, Map<String, List<Exercise>> categories) {
    return ExpansionTile(
      initiallyExpanded: false,
      leading: Icon(
        moduleName == 'Menulis' ? Icons.edit : Icons.hearing,
        color: AppTheme.primaryPurple,
      ),
      title: Text(
        moduleName,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryPurple,
        ),
      ),
      subtitle: Text(
        '${categories.values.fold<int>(0, (sum, list) => sum + list.length)} exercises',
        style: TextStyle(color: Colors.grey.shade600),
      ),
      children: categories.entries.map((categoryEntry) {
        return _buildCategorySection(context, categoryEntry.key, categoryEntry.value);
      }).toList(),
    );
  }

  Widget _buildCategorySection(BuildContext context, String categoryName, List<Exercise> exercises) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: Icon(Icons.folder, color: AppTheme.warning, size: 20),
        title: Text(
          categoryName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.warning,
          ),
        ),
        subtitle: Text(
          '${exercises.length} exercises',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        children: exercises.map((exercise) {
          return Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: ExpansionTile(
              initiallyExpanded: false,
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryPurple.withOpacity(0.2),
                radius: 18,
                child: Text(
                  exercise.questions.length.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryPurple,
                    fontSize: 12,
                  ),
                ),
              ),
              title: Text(
                exercise.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                '${exercise.questions.length} questions',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              children: exercise.questions.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final question = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  color: Colors.grey.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question $index',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (question.imageUrl != null) ...[
                          Text('Image: ${question.imageUrl}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          'Correct Answer: ${question.correctAnswer}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (question.options != null && question.options!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Options: ${question.options!.join(", ")}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getModuleName(String type) {
    final moduleMap = {
      'penulisan': 'Menulis',
      'kefahaman': 'Kefahaman',
      'writing': 'Menulis',
      'comprehension': 'Kefahaman',
    };
    return moduleMap[type.toLowerCase()] ?? type;
  }

  Widget _buildModulePerformanceCards() {
    // Calculate module statistics
    final menulistScores = widget.scores.where((s) => s.exerciseModule == 'Menulis').toList();
    final kefahamanScores = widget.scores.where((s) => s.exerciseModule == 'Kefahaman').toList();

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

