import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../models/exercise_model.dart';
import '../../models/exercise_score_model.dart';
import '../../utils/image_helper.dart';
import '../../services/cue_predictor.dart';

class WritingExerciseScreen extends StatefulWidget {
  final Exercise exercise;
  final String patientId;
  final Function(ExerciseScore) onComplete;

  const WritingExerciseScreen({
    super.key,
    required this.exercise,
    required this.patientId,
    required this.onComplete,
  });

  @override
  State<WritingExerciseScreen> createState() => _WritingExerciseScreenState();
}

class _WritingExerciseScreenState extends State<WritingExerciseScreen> {
  final TextEditingController _answerController = TextEditingController();
  bool _isSubmitted = false;
  DateTime? _startTime;
  DateTime? _questionStartTime;
  Timer? _cueTimer;
  Timer? _mlCheckTimer;
  int _cueLevel = 0; // 0 = none, 1 = function, 2 = rhyming, 3 = written
  String? _currentCue;
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  List<bool> _questionResults = [];
  CuePredictor? _cuePredictor;
  bool _mlModelLoaded = false;
  int _hintCount = 0;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _questionStartTime = DateTime.now();
    final questions = widget.exercise.questions;
    if (questions.isEmpty) {
      // Fallback: create a single question from exercise data
      _questionResults = [false];
    } else {
      _questionResults = List.filled(questions.length, false);
    }
    _initializeML().then((_) {
      // Start ML-based system after model loads (or fallback to timer)
      _startMLBasedCueSystem();
    });
  }

  Future<void> _initializeML() async {
    // Only load ML model on mobile devices (TFLite doesn't work on web)
    if (kIsWeb) {
      // Fallback to timer-based on web
      _startCueTimer();
      return;
    }

    try {
      _cuePredictor = CuePredictor();
      await _cuePredictor!.loadModel();
      setState(() {
        _mlModelLoaded = true;
      });
    } catch (e) {
      print('Failed to load ML model, using timer-based cues: $e');
      // Fallback to timer-based if ML fails
      _startCueTimer();
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    _cueTimer?.cancel();
    _mlCheckTimer?.cancel();
    _cuePredictor?.dispose();
    super.dispose();
  }

  ExerciseQuestion? get _currentQuestion {
    final questions = widget.exercise.questions;
    if (questions.isEmpty || _currentQuestionIndex >= questions.length) {
      return null;
    }
    return questions[_currentQuestionIndex];
  }

  /// Start ML-based cue system (checks every 2 seconds)
  void _startMLBasedCueSystem() {
    if (!_mlModelLoaded) {
      // Fallback to timer if ML not loaded
      _startCueTimer();
      return;
    }

    _mlCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isSubmitted || !mounted) {
        timer.cancel();
        return;
      }

      _checkMLPrediction();
    });
  }

  /// Check ML prediction and show cue if needed
  void _checkMLPrediction() {
    if (_cuePredictor == null || !_mlModelLoaded || _isSubmitted) return;

    final currentQuestion = _currentQuestion;
    if (currentQuestion == null) return;

    // Calculate response time
    final responseTime = DateTime.now().difference(_questionStartTime!).inSeconds.toDouble();
    
    // Get current time of day
    final hour = DateTime.now().hour;
    String timeOfDay;
    if (hour >= 6 && hour < 12) {
      timeOfDay = 'morning';
    } else if (hour >= 12 && hour < 17) {
      timeOfDay = 'afternoon';
    } else if (hour >= 17 && hour < 21) {
      timeOfDay = 'evening';
    } else {
      timeOfDay = 'night';
    }

    // Prepare ML input
    final input = CuePredictorInput.fromSimple(
      responseTimeSeconds: responseTime,
      cueGiven: _cueLevel > 0 ? 1 : 0,
      cueStage: _cueLevel,
      hintCount: _hintCount,
      difficulty: widget.exercise.difficulty >= 3 ? 'hard' : 'easy',
      isMobile: !kIsWeb && (Platform.isAndroid || Platform.isIOS),
      therapistLevel: 3, // Default level
      questionType: 'pic_to_word', // Writing exercise
      cueType: _cueLevel == 1 ? 'functional' : _cueLevel == 2 ? 'rhyming' : _cueLevel == 3 ? 'written_initial' : null,
      timeOfDay: timeOfDay,
      module: 'writing',
      category: widget.exercise.category.name,
    );

    try {
      final prediction = _cuePredictor!.predict(input);
      
      // If ML predicts cue is needed and we haven't shown this level yet
      if (prediction.needCue && _cueLevel == 0) {
        // Show function cue
        setState(() {
          _cueLevel = 1;
          _currentCue = currentQuestion.cueHierarchy?['function'];
          _hintCount++;
        });
        if (_currentCue != null) {
          _showCue('Function Cue', _currentCue!);
        }
      } else if (prediction.needCue && _cueLevel == 1 && responseTime > 10) {
        // Show rhyming cue after function cue
        setState(() {
          _cueLevel = 2;
          _currentCue = currentQuestion.cueHierarchy?['rhyming'];
          _hintCount++;
        });
        if (_currentCue != null) {
          _showCue('Rhyming Cue', _currentCue!);
        }
      } else if (prediction.needCue && _cueLevel == 2 && responseTime > 20) {
        // Show written cue after rhyming cue
        setState(() {
          _cueLevel = 3;
          _currentCue = currentQuestion.cueHierarchy?['written'];
          _hintCount++;
        });
        if (_currentCue != null) {
          _showCue('Written Cue', _currentCue!);
        }
      }
    } catch (e) {
      print('ML prediction error: $e');
      // Fallback to timer if ML fails
      if (_cueLevel == 0) {
        _startCueTimer();
      }
    }
  }

  /// Fallback timer-based cue system (for web or if ML fails)
  void _startCueTimer() {
    final currentQuestion = _currentQuestion;
    if (currentQuestion == null) return;
    
    // Show Function cue after 15 seconds
    _cueTimer = Timer(const Duration(seconds: 15), () {
      if (!_isSubmitted && mounted && _currentQuestionIndex < widget.exercise.questions.length) {
        setState(() {
          _cueLevel = 1;
          _currentCue = currentQuestion.cueHierarchy?['function'];
          _hintCount++;
        });
        if (_currentCue != null) {
          _showCue('Function Cue', _currentCue!);
        }
        
        // Show Rhyming cue after another 10 seconds
        _cueTimer = Timer(const Duration(seconds: 10), () {
          if (!_isSubmitted && mounted && _currentQuestionIndex < widget.exercise.questions.length) {
            setState(() {
              _cueLevel = 2;
              _currentCue = currentQuestion.cueHierarchy?['rhyming'];
              _hintCount++;
            });
            if (_currentCue != null) {
              _showCue('Rhyming Cue', _currentCue!);
            }
            
            // Show Written cue after another 10 seconds
            _cueTimer = Timer(const Duration(seconds: 10), () {
              if (!_isSubmitted && mounted && _currentQuestionIndex < widget.exercise.questions.length) {
                setState(() {
                  _cueLevel = 3;
                  _currentCue = currentQuestion.cueHierarchy?['written'];
                  _hintCount++;
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
    if (!mounted) return;
    
    // Use a post-frame callback to ensure context is valid
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      // Clear any existing SnackBar first
      scaffoldMessenger.clearSnackBars();
      scaffoldMessenger.showSnackBar(
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
    });
  }

  /// Build image widget with fallback to placeholder
  Widget _buildImageWidget(ExerciseQuestion? question) {
    final answer = question?.correctAnswer ?? widget.exercise.correctAnswer;
    if (answer == null) {
      return _buildPlaceholder('N/A');
    }

    // Try to get image path from exercise category and answer
    final imagePath = ImageHelper.getImagePathFromCategory(
      widget.exercise.category,
      answer,
    ) ?? ImageHelper.getImagePathFromItem(answer);

    if (imagePath != null) {
      return Image.asset(
        imagePath,
        width: 300,
        height: 300,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(answer);
        },
      );
    }

    return _buildPlaceholder(answer);
  }

  Widget _buildPlaceholder(String answer) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Image: $answer',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    final answer = _answerController.text.trim();
    if (answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please type your answer'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final currentQuestion = _currentQuestion;
    if (currentQuestion == null) return;

    _cueTimer?.cancel();
    
    // Check if answer is correct
    final isCorrect = answer.toLowerCase() == currentQuestion.correctAnswer.toLowerCase();
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
          _answerController.clear();
          _isSubmitted = false;
          _cueLevel = 0;
          _currentCue = null;
          _hintCount = 0;
          _questionStartTime = DateTime.now();
        });
        _startMLBasedCueSystem();
      } else {
        // All questions completed
        final timeTaken = DateTime.now().difference(_startTime!).inSeconds;
        final totalQuestions = widget.exercise.questions.length;

        // Create score object
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

        // Show final result
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
    final currentQuestion = _currentQuestion;
    final totalQuestions = widget.exercise.questions.length;
    final questionNumber = _currentQuestionIndex + 1;
    
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
            // Display Image
            Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildImageWidget(currentQuestion),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Type the word you see:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _answerController,
              enabled: !_isSubmitted,
              decoration: InputDecoration(
                labelText: 'Your answer',
                hintText: 'Type here...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.edit),
                suffixIcon: _answerController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _answerController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              textCapitalization: TextCapitalization.none,
              autofocus: true,
              onChanged: (_) => setState(() {}),
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
                  onPressed: _answerController.text.trim().isEmpty
                      ? null
                      : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit Answer',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

