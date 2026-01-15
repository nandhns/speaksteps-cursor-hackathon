import 'package:flutter/material.dart';
import '../../models/exercise_model.dart';
import '../../models/exercise_score_model.dart';
import '../../l10n/app_strings.dart';

class ExerciseScreen extends StatefulWidget {
  final Exercise exercise;
  final String patientId;
  final Function(ExerciseScore) onComplete;

  const ExerciseScreen({
    super.key,
    required this.exercise,
    required this.patientId,
    required this.onComplete,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  String? _selectedAnswer;
  bool _isSubmitted = false;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  void _handleSubmit() {
    if (_selectedAnswer == null) {
      final strings = AppStrings(Localizations.localeOf(context).languageCode);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.pleaseSelectAnswer),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitted = true);

    // Calculate score
    final isCorrect = _selectedAnswer == widget.exercise.correctAnswer;
    final score = isCorrect ? 100 : 0;
    final timeTaken = DateTime.now().difference(_startTime!).inSeconds;

    // Create score object
    final exerciseScore = ExerciseScore(
      id: '${widget.patientId}_${widget.exercise.id}_${DateTime.now().millisecondsSinceEpoch}',
      patientId: widget.patientId,
      exerciseId: widget.exercise.id,
      exerciseTitle: widget.exercise.title,
      exerciseModule: _getModuleName(widget.exercise.type),
      score: score,
      maxScore: 100,
      answer: _selectedAnswer,
      correctAnswer: widget.exercise.correctAnswer,
      completedAt: DateTime.now(),
      metadata: {
        'timeTaken': timeTaken,
        'difficulty': widget.exercise.difficulty,
      },
    );

    // Call completion callback
    widget.onComplete(exerciseScore);

    // Show result
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        final strings = AppStrings(Localizations.localeOf(context).languageCode);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(isCorrect ? strings.greatJobExclaim : strings.keepPracticingExclaim),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isCorrect
                      ? strings.youGotItRight
                      : '${strings.theCorrectAnswerWas}: ${widget.exercise.correctAnswer}',
                ),
                const SizedBox(height: 16),
                Text(
                  '${strings.score}: $score/100',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isCorrect ? Colors.green : Colors.orange,
                      ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to home
                },
                child: Text(strings.done),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Instructions',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.exercise.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Select your answer:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...widget.exercise.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = _selectedAnswer == option;
              final isCorrect = option == widget.exercise.correctAnswer;
              final showResult = _isSubmitted;

              Color? cardColor;
              if (showResult) {
                if (isCorrect) {
                  cardColor = Colors.green.shade50;
                } else if (isSelected && !isCorrect) {
                  cardColor = Colors.red.shade50;
                }
              } else if (isSelected) {
                cardColor = Colors.blue.shade50;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: cardColor,
                elevation: isSelected ? 4 : 1,
                child: InkWell(
                  onTap: _isSubmitted ? null : () {
                    setState(() => _selectedAnswer = option);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? (showResult && isCorrect
                                    ? Colors.green
                                    : showResult && !isCorrect
                                        ? Colors.red
                                        : Colors.blue)
                                : Colors.grey.shade300,
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + index), // A, B, C, D
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            option,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                          ),
                        ),
                        if (showResult && isCorrect)
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade700,
                          )
                        else if (showResult && isSelected && !isCorrect)
                          Icon(
                            Icons.cancel,
                            color: Colors.red.shade700,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 32),
            if (!_isSubmitted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedAnswer == null ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppStrings(Localizations.localeOf(context).languageCode).submit,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
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
}

