/// SpeakSteps Cue Predictor Interface
/// 
/// Platform-agnostic interface for cue prediction.
/// Implementations: TFLite (native) and Web (rule-based)
/// 
/// Model Type: 24-Feature Difficulty Estimator
/// Output: Continuous difficulty score (0-1) where 0.4+ indicates need for cue

/// Input features for the cue prediction (24 features - new difficulty estimator model)
class CuePredictorInput {
  // Performance features
  final double responseTimeSeconds;           // Current response time
  final double responseTimeRollingAvg;        // Rolling average of last 5 response times
  
  // Hint usage features
  final int hintCount;                        // Hints used on current question
  final double hintsUsedRatio;                // Cumulative hints / total questions (normalized)
  
  // Streak/consistency features
  final double consecutiveIncorrect;          // Normalized streak of incorrect (0-1)
  final double consecutiveCorrect;            // Normalized streak of correct (0-1)
  
  // Question difficulty and context
  final int difficultyFlag;                   // 0=easy, 1=hard
  final int deviceMobileFlag;                 // 0=web, 1=mobile
  final int therapistAssignedLevel;           // 1-5 difficulty level
  final int questionTypeEncoded;              // 0-8 question type mapping
  final int cueTypeEncoded;                   // 0-7 cue type mapping (not used as input, but kept for compatibility)
  
  // Time of day (one-hot encoded)
  final int timeMorning;
  final int timeAfternoon;
  final int timeEvening;
  final int timeNight;
  
  // Module type (one-hot encoded)
  final int moduleComprehension;
  final int moduleWriting;
  
  // Category (one-hot encoded)
  final int catAnimals;
  final int catBodyParts;
  final int catClothing;
  final int catFood;
  
  // Session/exercise features
  final double exerciseDurationNormalized;    // Seconds / 300 (clipped 0-1)
  final double sessionProgressRatio;          // Current question / total in session
  final double recentAccuracyRate;            // Rolling accuracy last 5 (shifted)

  const CuePredictorInput({
    required this.responseTimeSeconds,
    required this.responseTimeRollingAvg,
    required this.hintCount,
    required this.hintsUsedRatio,
    required this.consecutiveIncorrect,
    required this.consecutiveCorrect,
    required this.difficultyFlag,
    required this.deviceMobileFlag,
    required this.therapistAssignedLevel,
    required this.questionTypeEncoded,
    required this.cueTypeEncoded,
    required this.timeMorning,
    required this.timeAfternoon,
    required this.timeEvening,
    required this.timeNight,
    required this.moduleComprehension,
    required this.moduleWriting,
    required this.catAnimals,
    required this.catBodyParts,
    required this.catClothing,
    required this.catFood,
    required this.exerciseDurationNormalized,
    required this.sessionProgressRatio,
    required this.recentAccuracyRate,
  });

  /// Create input from a simplified feature map
  /// 
  /// This factory is provided for backward compatibility but requires all 24 features
  factory CuePredictorInput.fromSimple({
    required double responseTimeSeconds,
    required double responseTimeRollingAvg,
    required int hintCount,
    required double hintsUsedRatio,
    required double consecutiveIncorrect,
    required double consecutiveCorrect,
    required String difficulty,
    required bool isMobile,
    required int therapistLevel,
    required String questionType,
    required String? cueType,
    required String timeOfDay,
    required String module,
    required String category,
    required double exerciseDurationNormalized,
    required double sessionProgressRatio,
    required double recentAccuracyRate,
  }) {
    return CuePredictorInput(
      responseTimeSeconds: responseTimeSeconds,
      responseTimeRollingAvg: responseTimeRollingAvg,
      hintCount: hintCount,
      hintsUsedRatio: hintsUsedRatio,
      consecutiveIncorrect: consecutiveIncorrect,
      consecutiveCorrect: consecutiveCorrect,
      difficultyFlag: difficulty == 'hard' ? 1 : 0,
      deviceMobileFlag: isMobile ? 1 : 0,
      therapistAssignedLevel: therapistLevel,
      questionTypeEncoded: encodeQuestionType(questionType),
      cueTypeEncoded: encodeCueType(cueType),
      timeMorning: timeOfDay == 'morning' ? 1 : 0,
      timeAfternoon: timeOfDay == 'afternoon' ? 1 : 0,
      timeEvening: timeOfDay == 'evening' ? 1 : 0,
      timeNight: timeOfDay == 'night' ? 1 : 0,
      moduleComprehension: module == 'comprehension' ? 1 : 0,
      moduleWriting: module == 'writing' ? 1 : 0,
      catAnimals: category == 'animals' ? 1 : 0,
      catBodyParts: category == 'body_parts' ? 1 : 0,
      catClothing: category == 'clothing' ? 1 : 0,
      catFood: category == 'food' ? 1 : 0,
      exerciseDurationNormalized: exerciseDurationNormalized,
      sessionProgressRatio: sessionProgressRatio,
      recentAccuracyRate: recentAccuracyRate,
    );
  }

  static int encodeQuestionType(String type) {
    const encoding = {
      'category_sorting': 0,
      'fill_in_blank': 1,
      'pic_to_word': 2,
      'sentence_matching': 3,
      'spelling_choice': 4,
      'word_completion': 5,
      'word_to_pic': 6,
      'yes_no_question': 7,
    };
    return encoding[type] ?? 0;
  }

  static int encodeCueType(String? type) {
    if (type == null || type.isEmpty) return 0;
    const encoding = {
      'none': 0,
      'functional': 1,
      'rhyming': 2,
      'written_initial': 3,
      'spelling': 4,
      'sentence_completion': 5,
      'phonemic': 6,
      'modeling': 7,
    };
    return encoding[type] ?? 0;
  }

  /// Convert to feature vector in the exact order expected by the model
  /// 
  /// Order must match model_metadata.json feature_columns:
  /// 0: response_time_seconds
  /// 1: response_time_rolling_avg
  /// 2: hint_count
  /// 3: hints_used_ratio
  /// 4: consecutive_incorrect
  /// 5: consecutive_correct
  /// 6: difficulty_flag
  /// 7: device_mobile_flag
  /// 8: therapist_assigned_level
  /// 9: question_type_encoded
  /// 10: cue_type_encoded
  /// 11-14: time_morning/afternoon/evening/night
  /// 15-16: module_comprehension/writing
  /// 17-20: cat_animals/body_parts/clothing/food
  /// 21: exercise_duration_normalized
  /// 22: session_progress_ratio
  /// 23: recent_accuracy_rate
  List<double> toFeatureVector() {
    return [
      responseTimeSeconds,                     // 0
      responseTimeRollingAvg,                  // 1
      hintCount.toDouble(),                    // 2
      hintsUsedRatio,                          // 3
      consecutiveIncorrect,                    // 4
      consecutiveCorrect,                      // 5
      difficultyFlag.toDouble(),               // 6
      deviceMobileFlag.toDouble(),             // 7
      therapistAssignedLevel.toDouble(),       // 8
      questionTypeEncoded.toDouble(),          // 9
      cueTypeEncoded.toDouble(),               // 10
      timeMorning.toDouble(),                  // 11
      timeAfternoon.toDouble(),                // 12
      timeEvening.toDouble(),                  // 13
      timeNight.toDouble(),                    // 14
      moduleComprehension.toDouble(),          // 15
      moduleWriting.toDouble(),                // 16
      catAnimals.toDouble(),                   // 17
      catBodyParts.toDouble(),                 // 18
      catClothing.toDouble(),                  // 19
      catFood.toDouble(),                      // 20
      exerciseDurationNormalized,              // 21
      sessionProgressRatio,                    // 22
      recentAccuracyRate,                      // 23
    ];
  }
}

/// Result from cue prediction
class CuePredictionResult {
  /// Continuous difficulty score (0-1) from model
  /// ≥ 0.4 indicates patient needs a cue
  final double probability;
  
  /// Boolean decision based on threshold (0.4)
  final bool needCue;
  
  /// Inference time in milliseconds
  final int inferenceTimeMs;

  const CuePredictionResult({
    required this.probability,
    required this.needCue,
    required this.inferenceTimeMs,
  });

  @override
  String toString() {
    return 'CuePredictionResult(difficulty: ${probability.toStringAsFixed(4)}, '
           'needCue: $needCue, inferenceTimeMs: $inferenceTimeMs)';
  }
}

/// Abstract interface for cue predictor implementations
abstract class ICuePredictor {
  bool get isLoaded;
  String get platformName;
  
  /// 24 features for new difficulty-estimator model
  /// Removed: cueGiven, cueStage, correctBeforeCueFlag, moduleDurationNormalized, cueSequenceNormalized
  /// Added: responseTimeRollingAvg, hintsUsedRatio, consecutiveIncorrect, consecutiveCorrect, sessionProgressRatio, recentAccuracyRate
  static const int inputFeatureCount = 24;
  
  /// Threshold for cue triggering: if model output ≥ 0.4, trigger cue
  /// Matches the trained model's difficulty_score threshold
  static const double threshold = 0.4;
  
  Future<void> loadModel();
  CuePredictionResult predict(CuePredictorInput input);
  CuePredictionResult predictFromVector(List<double> features);
  void dispose();
}