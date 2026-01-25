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
  
  // Tracking for 24-feature ML model: rolling window features
  final List<double> _responseTimes = [];        // Track all response times for rolling avg
  final List<int> _correctnessHistory = [];      // Track all correctness (0/1) for accuracy calc
  int _totalQuestionsInSession = 0;              // Total questions in this exercise
  int _cumulativeHints = 0;                      // Total hints used in session

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

  /// ============================================================================
  /// 24-FEATURE ML MODEL HELPERS
  /// ============================================================================

  /// Calculate rolling average of last N response times
  double _getResponseTimeRollingAvg({int windowSize = 5}) {
    if (_responseTimes.isEmpty) return 0.0;
    
    final startIndex = (_responseTimes.length > windowSize) 
        ? _responseTimes.length - windowSize 
        : 0;
    final recentTimes = _responseTimes.sublist(startIndex);
    
    if (recentTimes.isEmpty) return 0.0;
    final sum = recentTimes.fold<double>(0, (a, b) => a + b);
    return sum / recentTimes.length;
  }

  /// Calculate hints used ratio (normalized by typical max of 3 hints per question)
  double _getHintsUsedRatio() {
    if (_totalQuestionsInSession <= 0) return 0.0;
    final ratio = _cumulativeHints / _totalQuestionsInSession;
    return (ratio / 3.0).clamp(0.0, 1.0); // Normalize: max ~3 hints/question
  }

  /// Calculate normalized consecutive incorrect streak (0-1)
  double _getConsecutiveIncorrect() {
    if (_correctnessHistory.isEmpty) return 0.0;
    
    // Count consecutive zeros (incorrect) from the end
    int streak = 0;
    for (int i = _correctnessHistory.length - 1; i >= 0; i--) {
      if (_correctnessHistory[i] == 0) {
        streak++;
      } else {
        break;
      }
    }
    
    // Normalize by max typical streak (5 questions)
    return (streak / 5.0).clamp(0.0, 1.0);
  }

  /// Calculate normalized consecutive correct streak (0-1)
  double _getConsecutiveCorrect() {
    if (_correctnessHistory.isEmpty) return 0.0;
    
    // Count consecutive ones (correct) from the end
    int streak = 0;
    for (int i = _correctnessHistory.length - 1; i >= 0; i--) {
      if (_correctnessHistory[i] == 1) {
        streak++;
      } else {
        break;
      }
    }
    
    // Normalize by max typical streak (5 questions)
    return (streak / 5.0).clamp(0.0, 1.0);
  }

  /// Calculate session progress ratio (0-1)
  double _getSessionProgressRatio() {
    if (_totalQuestionsInSession <= 0) return 0.0;
    return (_currentQuestionIndex / _totalQuestionsInSession).clamp(0.0, 1.0);
  }

  /// Calculate recent accuracy rate (last 5 questions, default 0.5 if none answered)
  double _getRecentAccuracyRate({int windowSize = 5}) {
    if (_correctnessHistory.isEmpty) return 0.5; // Default before any answers
    
    final startIndex = (_correctnessHistory.length > windowSize) 
        ? _correctnessHistory.length - windowSize 
        : 0;
    final recentCorrectness = _correctnessHistory.sublist(startIndex);
    
    if (recentCorrectness.isEmpty) return 0.5;
    final correct = recentCorrectness.fold<int>(0, (a, b) => a + b);
    return correct / recentCorrectness.length;
  }

  /// ============================================================================
  /// ML PREDICTION & CUE DISPLAY
  /// ============================================================================

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

    final input = CuePredictorInput(
      // Performance features
      responseTimeSeconds: responseTime,
      responseTimeRollingAvg: _getResponseTimeRollingAvg(),
      
      // Hint usage features
      hintCount: _hintCount,
      hintsUsedRatio: _getHintsUsedRatio(),
      
      // Streak/consistency features
      consecutiveIncorrect: _getConsecutiveIncorrect(),
      consecutiveCorrect: _getConsecutiveCorrect(),
      
      // Question difficulty and context
      difficultyFlag: widget.exercise.difficulty >= 3 ? 1 : 0,
      deviceMobileFlag: !kIsWeb && (Platform.isAndroid || Platform.isIOS) ? 1 : 0,
      therapistAssignedLevel: 3,
      questionTypeEncoded: CuePredictorInput.encodeQuestionType('word_to_pic'),
      cueTypeEncoded: CuePredictorInput.encodeCueType(_cueLevel == 0 ? 'none' : 
             _cueLevel == 1 ? 'functional' : 
             _cueLevel == 2 ? 'rhyming' : 
             _cueLevel == 3 ? 'written_initial' :
             _cueLevel == 4 ? 'spelling' :
             _cueLevel == 5 ? 'sentence_completion' :
             _cueLevel == 6 ? 'phonemic' : null),
      
      // Time of day (one-hot encoded)
      timeMorning: timeOfDay == 'morning' ? 1 : 0,
      timeAfternoon: timeOfDay == 'afternoon' ? 1 : 0,
      timeEvening: timeOfDay == 'evening' ? 1 : 0,
      timeNight: timeOfDay == 'night' ? 1 : 0,
      
      // Module type (one-hot encoded)
      moduleComprehension: 1,
      moduleWriting: 0,
      
      // Category (one-hot encoded)
      catAnimals: categoryName == 'animals' ? 1 : 0,
      catBodyParts: categoryName == 'body_parts' ? 1 : 0,
      catClothing: categoryName == 'clothing' ? 1 : 0,
      catFood: categoryName == 'food' ? 1 : 0,
      
      // Session/exercise features
      exerciseDurationNormalized: (responseTime / 300.0).clamp(0.0, 1.0), // 300s typical max
      sessionProgressRatio: _getSessionProgressRatio(),
      recentAccuracyRate: _getRecentAccuracyRate(),
    );

    try {
      final prediction = _cuePredictor!.predict(input);
      
      print('DEBUG: ML Prediction (24 features) - difficulty_score: ${prediction.probability.toStringAsFixed(3)}, needCue: ${prediction.needCue}, responseTime: ${responseTime.toStringAsFixed(1)}s, rollingAvg: ${input.responseTimeRollingAvg.toStringAsFixed(1)}s, recentAcc: ${input.recentAccuracyRate.toStringAsFixed(3)}, currentLevel: $_cueLevel');
      
      // ML-based cue progression: Show next cue when ML predicts patient needs help
      // Enforce minimum time delays before showing cues
      if (!prediction.needCue) {
        return; // ML says patient doesn't need help yet
      }
      
      // Enforce minimum wait time before first cue (10 seconds - hierarchical timing)
      if (_cueLevel == 0 && responseTime < 10) {
        return; // Don't show first cue until at least 10 seconds
      }
      
      // Enforce minimum gap between cues (10 seconds - hierarchical timing)
      if (_lastCueShownAt != null) {
        final timeSinceLastCue = DateTime.now().difference(_lastCueShownAt!).inSeconds;
        if (timeSinceLastCue < 10) {
          return; // Wait at least 10 seconds between cues
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
    
    // Calculate performance level for dynamic timing
    final performance = _calculatePerformanceLevel();
    final delay1 = _getCueTimingForPerformance(performance, 1);
    final delay2 = _getCueTimingForPerformance(performance, 2);
    final delay3 = _getCueTimingForPerformance(performance, 3);
    
    print('DEBUG: Cue timing for $performance performance: ${delay1}s → ${delay2}s → ${delay3}s');
    
    _cueTimer = Timer(Duration(seconds: delay1), () {
      if (!_isSubmitted && mounted && _currentQuestionIndex < widget.exercise.questions.length) {
        setState(() {
          _cueLevel = 1;
          _currentCue = currentQuestion.cueHierarchy?['function'];
          _currentCueType = 'functional';
          _cueWaitSeconds = delay1;
          _hintCount++;
        });
        if (_currentCue != null) {
          _showCue('Function Cue', _currentCue!);
        }

        _cueTimer = Timer(Duration(seconds: delay2), () {
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

            _cueTimer = Timer(Duration(seconds: delay3), () {
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

  /// Calculate performance level based on recent accuracy
  String _calculatePerformanceLevel() {
    if (_correctnessHistory.isEmpty) return 'high';
    
    // Use last 10 attempts (or all if fewer)
    final recentAttempts = _correctnessHistory.length >= 10
        ? _correctnessHistory.sublist(_correctnessHistory.length - 10)
        : _correctnessHistory;
    
    final accuracy = recentAttempts.fold<int>(0, (sum, x) => sum + x) / recentAttempts.length;
    
    if (accuracy < 0.6) return 'low';      // <60% = low performance
    if (accuracy < 0.8) return 'mild';     // 60-80% = mild performance
    return 'high';                          // >80% = high performance
  }

  /// Get cue timing based on performance level (in seconds)
  int _getCueTimingForPerformance(String performanceLevel, int cueLevel) {
    // Define timing for each performance level
    final timingConfigs = {
      'low': {1: 15, 2: 15, 3: 15, 4: 15, 5: 15, 6: 15, 7: 15},       // 15s intervals
      'mild': {1: 30, 2: 30, 3: 30, 4: 30, 5: 30, 6: 30, 7: 30},     // 30s intervals
      'high': {1: 10, 2: 8, 3: 8, 4: 8, 5: 8, 6: 8, 7: 8},           // Normal: 10s then 8s
    };
    
    final config = timingConfigs[performanceLevel] ?? timingConfigs['high']!;
    return config[cueLevel] ?? 10;
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
    // Check if item is already a full path (starts with "images/")
    if (item.startsWith('images/')) {
      // It's already a full asset path, use it directly
      return Image.asset(
        item,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image from path: $item');
          return _buildPlaceholder();
        },
      );
    }
    
    // Otherwise, try to map it using ImageHelper
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
    final strings = AppStrings(Localizations.localeOf(context).languageCode);
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
                    ? strings.wellDone
                    : '${strings.incorrect}. ${strings.theCorrectAnswerWas}: ${currentQuestion.correctAnswer}',
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
              barrierDismissible: false,
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
    final strings = AppStrings(Localizations.localeOf(context).languageCode);
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
                          strings.hint,
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
                        strings.matchTheWord,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                      ),
                      const SizedBox(height: 16),
                      // Display the image to match
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.purple.shade300, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(
                          currentQuestion?.correctAnswer ?? widget.exercise.correctAnswer ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                'Image not found',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            );
                          },
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