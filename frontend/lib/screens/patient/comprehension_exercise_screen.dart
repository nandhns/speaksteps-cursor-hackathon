import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/exercise_model.dart';
import '../../models/exercise_score_model.dart';

class ComprehensionExerciseScreen extends StatefulWidget {
  final Exercise exercise;
  final String patientId;
  final Function(ExerciseScore) onComplete;

  const ComprehensionExerciseScreen({
    super.key,
    required this.exercise,
    required this.patientId,
    required this.onComplete,
  });

  @override
  State<ComprehensionExerciseScreen> createState() =>
      _ComprehensionExerciseScreenState();
}

class _ComprehensionExerciseScreenState
    extends State<ComprehensionExerciseScreen> {
  String? _selectedImage;
  bool _isSubmitted = false;
  DateTime? _startTime;
  Timer? _cueTimer;
  int _cueLevel = 0;
  String? _currentCue;
  bool _isPlayingAudio = false;
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  List<bool> _questionResults = [];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    final questions = widget.exercise.questions;
    if (questions.isEmpty) {
      _questionResults = [false];
    } else {
      _questionResults = List.filled(questions.length, false);
    }
    _startCueTimer();
    // Auto-play audio on start
    _playAudio();
  }

  ExerciseQuestion? _getCurrentQuestion() {
    final questions = widget.exercise.questions;
    if (questions.isEmpty || _currentQuestionIndex >= questions.length) {
      return null;
    }
    return questions[_currentQuestionIndex];
  }

  @override
  void dispose() {
    _cueTimer?.cancel();
    super.dispose();
  }

  void _playAudio() {
    if (widget.exercise.audioUrl != null) {
      setState(() => _isPlayingAudio = true);
      // Simulate audio playback
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isPlayingAudio = false);
        }
      });
    }
  }

  void _startCueTimer() {
    final currentQuestion = _getCurrentQuestion();
    if (currentQuestion == null) return;
    
    _cueTimer = Timer(const Duration(seconds: 15), () {
      if (!_isSubmitted && mounted && _currentQuestionIndex < widget.exercise.questions.length) {
        setState(() {
          _cueLevel = 1;
          _currentCue = currentQuestion.cueHierarchy?['function'];
        });
        if (_currentCue != null) {
          _showCue('Function Cue', _currentCue!);
        }

        _cueTimer = Timer(const Duration(seconds: 10), () {
          if (!_isSubmitted && mounted && _currentQuestionIndex < widget.exercise.questions.length) {
            setState(() {
              _cueLevel = 2;
              _currentCue = currentQuestion.cueHierarchy?['rhyming'];
            });
            if (_currentCue != null) {
              _showCue('Rhyming Cue', _currentCue!);
            }

            _cueTimer = Timer(const Duration(seconds: 10), () {
              if (!_isSubmitted && mounted && _currentQuestionIndex < widget.exercise.questions.length) {
                setState(() {
                  _cueLevel = 3;
                  _currentCue = currentQuestion.cueHierarchy?['written'];
                });
                if (_currentCue != null) {
                  _showCue('Written Cue', _currentCue!);
                }
              }
            });
          }
        });
      }
    });
  }

  void _showCue(String title, String cue) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(cue),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _handleSubmit() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final currentQuestion = _getCurrentQuestion();
    if (currentQuestion == null) return;

    _cueTimer?.cancel();
    
    // Check if answer is correct
    final isCorrect = _selectedImage == currentQuestion.correctAnswer;
    _questionResults[_currentQuestionIndex] = isCorrect;
    if (isCorrect) {
      _correctAnswers++;
    }

    // Show feedback
    setState(() => _isSubmitted = true);
    
    // Show feedback message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isCorrect 
                    ? 'Correct! Well done! 🎉'
                    : 'Incorrect. The correct answer is: ${currentQuestion.correctAnswer}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );

    // Move to next question or finish after showing feedback
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      if (_currentQuestionIndex < widget.exercise.questions.length - 1) {
        // Move to next question
        setState(() {
          _currentQuestionIndex++;
          _selectedImage = null;
          _isSubmitted = false;
          _cueLevel = 0;
          _currentCue = null;
        });
        _startCueTimer();
        _playAudio();
      } else {
        // All questions completed
        final timeTaken = DateTime.now().difference(_startTime!).inSeconds;
        final totalQuestions = widget.exercise.questions.length;

        final exerciseScore = ExerciseScore(
          id: '${widget.patientId}_${widget.exercise.id}_${DateTime.now().millisecondsSinceEpoch}',
          patientId: widget.patientId,
          exerciseId: widget.exercise.id,
          exerciseTitle: widget.exercise.title,
          score: _correctAnswers,
          maxScore: totalQuestions,
          answer: '${_correctAnswers}/$totalQuestions',
          correctAnswer: '${_correctAnswers}/$totalQuestions',
          completedAt: DateTime.now(),
          metadata: {
            'timeTaken': timeTaken,
            'difficulty': widget.exercise.difficulty,
            'cueLevel': _cueLevel,
            'category': widget.exercise.category.name,
          },
        );

        widget.onComplete(exerciseScore);

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(_correctAnswers == totalQuestions ? 'Excellent! 🎉' : 'Good Job! 💪'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'You got $_correctAnswers out of $totalQuestions questions correct!',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Score: $_correctAnswers/$totalQuestions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _correctAnswers == totalQuestions ? Colors.green : Colors.orange,
                          ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _getCurrentQuestion();
    final totalQuestions = widget.exercise.questions.length;
    final questionNumber = _currentQuestionIndex + 1;
    // For easy level, show different category images
    final imageOptions = currentQuestion?.imageOptions ?? 
                        currentQuestion?.options ?? 
                        widget.exercise.imageOptions ?? 
                        widget.exercise.options;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.exercise.title),
            if (totalQuestions > 1)
              Text(
                'Question $questionNumber of $totalQuestions',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        actions: [
          if (_cueLevel > 0)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                label: Text(
                  _cueLevel == 1
                      ? 'Function Cue'
                      : _cueLevel == 2
                          ? 'Rhyming Cue'
                          : 'Written Cue',
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: Colors.blue.shade100,
              ),
            ),
        ],
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
            // Display the word to match
            Center(
              child: Card(
                color: Colors.purple.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        'Match this word:',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentQuestion?.correctAnswer ?? widget.exercise.correctAnswer ?? '',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade900,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Audio button
            if (widget.exercise.audioUrl != null)
              Center(
                child: ElevatedButton.icon(
                  onPressed: _isPlayingAudio ? null : _playAudio,
                  icon: _isPlayingAudio
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.volume_up),
                  label: Text(_isPlayingAudio ? 'Playing...' : 'Play Audio'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 32),
            Text(
              'Select the matching image:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            // Image options in a single row - fit page width
            Row(
              children: imageOptions.map((option) {
                final isSelected = _selectedImage == option;
                final isCorrect = option == (currentQuestion?.correctAnswer ?? widget.exercise.correctAnswer);
                final showResult = _isSubmitted && _currentQuestionIndex >= widget.exercise.questions.length - 1;

                Color? borderColor;
                if (showResult) {
                  borderColor = isCorrect
                      ? Colors.green
                      : (isSelected && !isCorrect)
                          ? Colors.red
                          : Colors.grey.shade300;
                } else {
                  borderColor = isSelected ? Colors.blue : Colors.grey.shade300;
                }

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: imageOptions.indexOf(option) < imageOptions.length - 1 ? 12.0 : 0.0,
                    ),
                    child: Card(
                      elevation: isSelected ? 4 : 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: borderColor!,
                          width: 3,
                        ),
                      ),
                      child: InkWell(
                        onTap: _isSubmitted ? null : () {
                          setState(() => _selectedImage = option);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 140,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: showResult && isCorrect
                                ? Colors.green.shade50
                                : showResult && isSelected && !isCorrect
                                    ? Colors.red.shade50
                                    : isSelected
                                        ? Colors.blue.shade50
                                        : Colors.grey.shade50,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Image placeholder
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.image,
                                  size: 36,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                option,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (showResult && isCorrect)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.green.shade700,
                                    size: 20,
                                  ),
                                )
                              else if (showResult && isSelected && !isCorrect)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Icon(
                                    Icons.cancel,
                                    color: Colors.red.shade700,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_currentCue != null && _cueLevel > 0) ...[
              const SizedBox(height: 24),
              Card(
                color: Colors.blue.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _cueLevel == 1
                                  ? 'Function Cue'
                                  : _cueLevel == 2
                                      ? 'Rhyming Cue'
                                      : 'Written Cue',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentCue!,
                              style: TextStyle(color: Colors.blue.shade900),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            if (!_isSubmitted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedImage == null ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit Answer',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

