import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../models/exercise_model.dart';
import '../../models/exercise_score_model.dart';
import '../../models/question_response_model.dart';
import '../../models/exercise_session_model.dart';
import '../../utils/image_helper.dart';
import '../../services/cue_predictor_factory.dart';
import '../../services/app_service.dart';
import '../../l10n/app_strings.dart';

class ComprehensionExerciseScreen extends StatefulWidget {
  final Exercise exercise;
  final String patientId;
  final String? therapistId;
  final Function(ExerciseScore) onComplete;

  const ComprehensionExerciseScreen({
    super.key,
    required this.exercise,
    required this.patientId,
    this.therapistId,
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
  DateTime? _questionStartTime;
  Timer? _cueTimer;
  Timer? _mlCheckTimer;
  int _cueLevel = 0;
  String? _currentCue;
  String? _currentCueType;
  int? _cueWaitSeconds;
  DateTime? _cueDisplayedAt;
  bool _isPlayingAudio = false;
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  List<bool> _questionResults = [];
  CuePredictor? _cuePredictor;
  bool _mlModelLoaded = false;
  int _hintCount = 0;
  DateTime? _lastCueShownAt;
  
  // Session tracking
  late String _sessionId;
  late AppService _appService;
  final List<QuestionResponse> _questionResponses = [];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _questionStartTime = DateTime.now();
    
    // Initialize session tracking
    _sessionId = '${widget.patientId}_${widget.exercise.id}_${DateTime.now().millisecondsSinceEpoch}';
    _appService = ServiceFactory.createService();
    
    final questions = widget.exercise.questions;
    if (questions.isEmpty) {
      _questionResults = [false];
    } else {
      _questionResults = List.filled(questions.length, false);
    }
    _initializeML().then((_) {
      // Start ML-based system after model loads (or fallback to timer)
      _startMLBasedCueSystem();
    });
    // Auto-play audio on start
    _playAudio();
  }

  Future<void> _initializeML() async {
    // CuePredictor now works on ALL platforms (web uses rule-based prediction)
    try {
      _cuePredictor = CuePredictor();
      await _cuePredictor!.loadModel();
      setState(() {
        _mlModelLoaded = true;
      });
    } catch (e) {
      print('Failed to load predictor, using timer-based cues: $e');
      // Fallback to timer-based if predictor fails
      _startCueTimer();
    }
  }

  ExerciseQuestion? _getCurrentQuestion() {
    final questions = widget.exercise.questions;
    if (questions.isEmpty || _currentQuestionIndex >= questions.length) {
      return null;
    }
    return questions[_currentQuestionIndex];
  }

  /// Generate a fallback cue when cue hierarchy is incomplete
  String _generateFallbackCue(String cueType, String correctAnswer) {
    // Sanitize the correct answer
    final word = correctAnswer.toLowerCase().trim();
    
    switch (cueType) {
      case 'functional':
        return 'This word describes an action or thing you can use.';
      case 'rhyming':
        // Generate rhyming hint - find words that rhyme with the answer
        if (word.length >= 2) {
          final lastTwoChars = word.substring(word.length - 2);
          return 'It rhymes with words ending in "-$lastTwoChars"';
        }
        return 'Think of a word that rhymes with this sound.';
      case 'written_initial':
        // Provide partial spelling hint
        if (word.isNotEmpty) {
          final firstLetter = word[0].toLowerCase();
          final underscores = '_ ' * (word.length - 1);
          return '$firstLetter $underscores'.trim();
        }
        return 'Look at the first letter of the word.';
      case 'spelling':
        // Spell out the word
        if (word.isNotEmpty) {
          return word.split('').join('-');
        }
        return 'Listen to how the word is spelled.';
      case 'sentence_completion':
        return 'Try to use this word in a sentence.';
      case 'phonemic':
        // First sound/syllable
        if (word.isNotEmpty) {
          final firstChar = word[0];
          return 'It starts with "$firstChar"...';
        }
        return 'Think about the first sound.';
      default:
        return 'Try to remember the word we practiced.';
    }
  }

  @override

  void dispose() {
    _cueTimer?.cancel();
    _mlCheckTimer?.cancel();
    _cuePredictor?.dispose();
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

    final currentQuestion = _getCurrentQuestion();
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

    // Prepare ML input with category/difficulty mapping
    String categoryName = widget.exercise.category.name;
    // Map frontend categories to backend canonical names
    const categoryMap = {
      'haiwan': 'animals',
      'animal': 'animals',
      'bodyParts': 'body_parts',
      'makanan': 'food',
      'verbs': 'verbs',
      'kata_kerja': 'verbs',
    };
    categoryName = categoryMap[categoryName] ?? categoryName;

    final input = CuePredictorInput.fromSimple(
      responseTimeSeconds: responseTime,
      cueGiven: _cueLevel > 0 ? 1 : 0,
      cueStage: _cueLevel,
      hintCount: _hintCount,
      difficulty: widget.exercise.difficulty >= 3 ? 'hard' : 'easy',
      isMobile: !kIsWeb && (Platform.isAndroid || Platform.isIOS),
      therapistLevel: 3, // Default level
      questionType: 'word_to_pic', // Comprehension exercise
      cueType: _cueLevel == 0 ? 'none' : 
               _cueLevel == 1 ? 'functional' : 
               _cueLevel == 2 ? 'rhyming' : 
               _cueLevel == 3 ? 'written_initial' :
               _cueLevel == 4 ? 'spelling' :
               _cueLevel == 5 ? 'sentence_completion' :
               _cueLevel == 6 ? 'phonemic' : null,
      timeOfDay: timeOfDay,
      module: 'comprehension',
      category: categoryName,
    );

    try {
      final prediction = _cuePredictor!.predict(input);
      
      print('DEBUG: ML Prediction - probability: ${prediction.probability.toStringAsFixed(3)}, needCue: ${prediction.needCue}, responseTime: ${responseTime}s, currentLevel: $_cueLevel');
      
      // ML-based cue progression: Show next cue when ML predicts patient needs help
      // Enforce minimum time delays before showing cues
      if (!prediction.needCue) {
        return; // ML says patient doesn't need help yet
      }
      
      // Enforce minimum wait time before first cue (30 seconds)
      if (_cueLevel == 0 && responseTime < 30) {
        return; // Don't show first cue until at least 30 seconds
      }
      
      // Enforce minimum gap between cues (20 seconds)
      if (_lastCueShownAt != null) {
        final timeSinceLastCue = DateTime.now().difference(_lastCueShownAt!).inSeconds;
        if (timeSinceLastCue < 20) {
          return; // Wait at least 20 seconds between cues
        }
      }
      
      if (_cueLevel == 0) {
        // Level 1: Functional cue (ML predicts need)
        setState(() {
          _cueLevel = 1;
          _currentCue = currentQuestion.cueHierarchy?['functional'] ?? 
                        _generateFallbackCue('functional', currentQuestion.correctAnswer);
          _hintCount++;
          _lastCueShownAt = DateTime.now();
        });
        if (_currentCue != null && _currentCue!.isNotEmpty) {
          _showCue('Functional Cue', _currentCue!);
          print('DEBUG: Level 1 - Functional cue shown (time: ${responseTime}s, ML prob: ${prediction.probability.toStringAsFixed(3)})'); 
        }
      } else if (_cueLevel == 1) {
        // Level 2: Rhyming cue (ML predicts need)
        setState(() {
          _cueLevel = 2;
          _currentCue = currentQuestion.cueHierarchy?['rhyming'] ?? 
                        _generateFallbackCue('rhyming', currentQuestion.correctAnswer);
          _hintCount++;
          _lastCueShownAt = DateTime.now();
        });
        if (_currentCue != null) {
          _showCue('Rhyming Cue', _currentCue!);
          print('DEBUG: Level 2 - Rhyming cue shown (time: ${responseTime}s, ML prob: ${prediction.probability.toStringAsFixed(3)})');
        }
      } else if (_cueLevel == 2) {
        // Level 3: Written initial cue (ML predicts need)
        setState(() {
          _cueLevel = 3;
          _currentCue = currentQuestion.cueHierarchy?['written_initial'] ?? 
                        _generateFallbackCue('written_initial', currentQuestion.correctAnswer);
          _hintCount++;
          _lastCueShownAt = DateTime.now();
        });
        if (_currentCue != null) {
          _showCue('Written Cue', _currentCue!);
          print('DEBUG: Level 3 - Written initial cue shown (time: ${responseTime}s, ML prob: ${prediction.probability.toStringAsFixed(3)})');
        }
      } else if (_cueLevel == 3) {
        // Level 4: Spelling cue (ML predicts need)
        setState(() {
          _cueLevel = 4;
          _currentCue = currentQuestion.cueHierarchy?['spelling'] ?? 
                        _generateFallbackCue('spelling', currentQuestion.correctAnswer);
          _hintCount++;
          _lastCueShownAt = DateTime.now();
        });
        if (_currentCue != null) {
          _showCue('Spelling Cue', _currentCue!);
          print('DEBUG: Level 4 - Spelling cue shown (time: ${responseTime}s, ML prob: ${prediction.probability.toStringAsFixed(3)})');
        }
      } else if (_cueLevel == 4) {
        // Level 5: Sentence completion cue (ML predicts need)
        setState(() {
          _cueLevel = 5;
          _currentCue = currentQuestion.cueHierarchy?['sentence_completion'] ?? 
                        _generateFallbackCue('sentence_completion', currentQuestion.correctAnswer);
          _hintCount++;
          _lastCueShownAt = DateTime.now();
        });
        if (_currentCue != null) {
          _showCue('Sentence Completion', _currentCue!);
          print('DEBUG: Level 5 - Sentence completion cue shown (time: ${responseTime}s, ML prob: ${prediction.probability.toStringAsFixed(3)})');
        }
      } else if (_cueLevel == 5) {
        // Level 6: Phonemic/First sound cue (ML predicts need)
        setState(() {
          _cueLevel = 6;
          _currentCue = currentQuestion.cueHierarchy?['phonemic'] ?? 
                        _generateFallbackCue('phonemic', currentQuestion.correctAnswer);
          _hintCount++;
          _lastCueShownAt = DateTime.now();
        });
        if (_currentCue != null) {
          _showCue('First Sound', _currentCue!);
          print('DEBUG: Level 6 - Phonemic cue shown (time: ${responseTime}s, ML prob: ${prediction.probability.toStringAsFixed(3)})');
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
    final currentQuestion = _getCurrentQuestion();
    if (currentQuestion == null) return;
    
    _cueTimer = Timer(const Duration(seconds: 15), () {
      if (!_isSubmitted && mounted && _currentQuestionIndex < widget.exercise.questions.length) {
        setState(() {
          _cueLevel = 1;
          _currentCue = currentQuestion.cueHierarchy?['function'];
          _currentCueType = 'functional';
          _cueWaitSeconds = 15; // First cue after 15 seconds
          _hintCount++;
        });
        if (_currentCue != null) {
          _showCue('Function Cue', _currentCue!);
        }

        _cueTimer = Timer(const Duration(seconds: 10), () {
          if (!_isSubmitted && mounted && _currentQuestionIndex < widget.exercise.questions.length) {
            setState(() {
              _cueLevel = 2;
              _currentCue = currentQuestion.cueHierarchy?['rhyming'];
              _currentCueType = 'rhyming';
              _hintCount++;
            });
            if (_currentCue != null) {
              _showCue('Rhyming Cue', _currentCue!);
            }

            _cueTimer = Timer(const Duration(seconds: 10), () {
              if (!_isSubmitted && mounted && _currentQuestionIndex < widget.exercise.questions.length) {
                setState(() {
                  _cueLevel = 3;
                  _currentCue = currentQuestion.cueHierarchy?['written'];
                  _currentCueType = 'written_initial';
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
    print('_showCue called: title=$title, cue=$cue, mounted=$mounted');
    if (!mounted) {
      print('Widget not mounted, cannot show cue');
      return;
    }
    
    // Track when cue was displayed
    _cueDisplayedAt = DateTime.now();
    
    // Schedule the SnackBar to show after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        print('Widget not mounted in postFrameCallback, cannot show cue');
        return;
      }
      try {
        print('Attempting to show SnackBar...');
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cue,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.blue.shade700,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            elevation: 6,
          ),
        );
        print('SnackBar shown successfully');
      } catch (e, stackTrace) {
        print('Error showing cue: $e');
        print('Stack trace: $stackTrace');
      }
    });
  }

  /// Build image widget with fallback to placeholder
  Widget _buildImageWidget(String item) {
    final imagePath = ImageHelper.getImagePathFromCategory(
      widget.exercise.category,
      item,
    ) ?? ImageHelper.getImagePathFromItem(item);

    if (imagePath != null) {
      return Image.asset(
        imagePath,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }
    
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image,
        size: 36,
        color: Colors.grey.shade600,
      ),
    );
  }

  void _handleSubmit() {
    if (_selectedImage == null) {
      final strings = AppStrings(Localizations.localeOf(context).languageCode);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.pleaseSelectImage),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final currentQuestion = _getCurrentQuestion();
    if (currentQuestion == null) return;

    _cueTimer?.cancel();
    
    // Calculate response time for this question
    final responseTime = DateTime.now().difference(_questionStartTime!).inSeconds;
    
    // Check if answer is correct
    final isCorrect = _selectedImage == currentQuestion.correctAnswer;
    _questionResults[_currentQuestionIndex] = isCorrect;
    if (isCorrect) {
      _correctAnswers++;
    }
    
    // Create and save per-question response data
    // Calculate time after cue was displayed (if cue was given)
    int? timeAfterCue;
    if (_cueDisplayedAt != null) {
      timeAfterCue = DateTime.now().difference(_cueDisplayedAt!).inSeconds;
    }
    
    final questionResponse = QuestionResponse(
      id: '${_sessionId}_q$_currentQuestionIndex',
      sessionId: _sessionId,
      patientId: widget.patientId,
      therapistId: widget.therapistId ?? '',
      exerciseId: widget.exercise.id,
      questionIndex: _currentQuestionIndex,
      questionText: currentQuestion.correctAnswer, // Use correctAnswer as the question text
      questionImageUrl: currentQuestion.imageUrl,
      userAnswer: _selectedImage,
      correctAnswer: currentQuestion.correctAnswer,
      isCorrect: isCorrect,
      presentedAt: _questionStartTime!,
      respondedAt: DateTime.now(),
      responseTimeSeconds: responseTime,
      cueGiven: _cueLevel > 0,
      cueType: _currentCueType,
      cueStage: _cueLevel,
      cueWaitSeconds: _cueWaitSeconds,
      timeAfterCueDisplayed: timeAfterCue,
      hintCount: _hintCount,
      difficulty: widget.exercise.difficulty.toString(), // Convert int to String
      category: widget.exercise.category.name,
      module: 'comprehension',
    );
    
    _questionResponses.add(questionResponse);
    
    // Save to database asynchronously
    _appService.saveQuestionResponse(questionResponse.toMap());

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
          _currentCueType = null;
          _cueWaitSeconds = null;
          _cueDisplayedAt = null;
          _hintCount = 0;
          _lastCueShownAt = null;
          _questionStartTime = DateTime.now();
        });
        _startMLBasedCueSystem();
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
          exerciseModule: _getModuleName(widget.exercise.type),
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
        
        // Save comprehensive session data
        _saveSessionData(timeTaken, totalQuestions);

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            final strings = AppStrings(Localizations.localeOf(context).languageCode);
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(_correctAnswers == totalQuestions ? strings.excellent : strings.goodJob),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${strings.youGotCorrect} $_correctAnswers ${strings.outOf} $totalQuestions ${strings.questionsCorrectSuffix}',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${strings.score}: $_correctAnswers/$totalQuestions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _correctAnswers == totalQuestions ? Colors.green : Colors.orange,
                            ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text(strings.done),
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
                      ? 'Petunjuk Fungsi'
                      : _cueLevel == 2
                          ? 'Petunjuk Rimba'
                          : 'Petunjuk Bertulis',
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
                            color: borderColor ?? Colors.grey,
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
                              // Actual image from assets
                              SizedBox(
                                width: 70,
                                height: 70,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: _buildImageWidget(option),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Flexible(
                                child: Text(
                                  option,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                                  ? 'Petunjuk Fungsi'
                                  : _cueLevel == 2
                                      ? 'Petunjuk Rimba'
                                      : 'Petunjuk Bertulis',
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
  
  /// Save comprehensive session data including timing and cue usage
  void _saveSessionData(int totalTimeSeconds, int totalQuestions) {
    // Calculate cue statistics
    final totalCuesGiven = _questionResponses.fold<int>(
      0, (sum, response) => sum + response.hintCount
    );
    final questionsWithCues = _questionResponses.where((r) => r.cueGiven).length;
    
    // Count cue types used
    final cueTypeCount = <String, int>{};
    for (final response in _questionResponses) {
      if (response.cueType != null) {
        cueTypeCount[response.cueType!] = (cueTypeCount[response.cueType!] ?? 0) + 1;
      }
    }
    
    final session = ExerciseSession(
      id: _sessionId,
      patientId: widget.patientId,
      therapistId: widget.therapistId ?? '',
      exerciseId: widget.exercise.id,
      exerciseTitle: widget.exercise.title,
      module: 'comprehension',
      category: widget.exercise.category.name,
      startTime: _startTime!,
      endTime: DateTime.now(),
      totalTimeSeconds: totalTimeSeconds,
      activeTimeSeconds: totalTimeSeconds, // For now, assume all time is active
      totalQuestions: totalQuestions,
      correctAnswers: _correctAnswers,
      incorrectAnswers: totalQuestions - _correctAnswers,
      questionsSkipped: 0,
      accuracyPercentage: (_correctAnswers / totalQuestions * 100),
      totalCuesGiven: totalCuesGiven,
      questionsWithCues: questionsWithCues,
      cueTypeCount: cueTypeCount,
      deviceType: kIsWeb ? 'web' : (Platform.isAndroid ? 'android' : Platform.isIOS ? 'ios' : 'other'),
      metadata: {
        'mlModelUsed': _mlModelLoaded,
        'exerciseDifficulty': widget.exercise.difficulty,
      },
    );
    
    // Save session data asynchronously
    _appService.saveExerciseSession(session.toMap());
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