/// SpeakSteps Cue Predictor Interface
/// 
/// Platform-agnostic interface for cue prediction.
/// Implementations: TFLite (native) and Web (rule-based)

/// Input features for the cue prediction
class CuePredictorInput {
  final double responseTimeSeconds;
  final int cueGiven;
  final int cueStage;
  final int hintCount;
  final int difficultyFlag;
  final int deviceMobileFlag;
  final int therapistAssignedLevel;
  final int questionTypeEncoded;
  final int cueTypeEncoded;
  final int timeMorning;
  final int timeAfternoon;
  final int timeEvening;
  final int timeNight;
  final int moduleComprehension;
  final int moduleWriting;
  final int catAnimals;
  final int catBodyParts;
  final int catClothing;
  final int catFood;

  const CuePredictorInput({
    required this.responseTimeSeconds,
    required this.cueGiven,
    required this.cueStage,
    required this.hintCount,
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
  });

  /// Create input from a simplified feature map
  factory CuePredictorInput.fromSimple({
    required double responseTimeSeconds,
    required int cueGiven,
    required int cueStage,
    required int hintCount,
    required String difficulty,
    required bool isMobile,
    required int therapistLevel,
    required String questionType,
    required String? cueType,
    required String timeOfDay,
    required String module,
    required String category,
  }) {
    return CuePredictorInput(
      responseTimeSeconds: responseTimeSeconds,
      cueGiven: cueGiven,
      cueStage: cueStage,
      hintCount: hintCount,
      difficultyFlag: difficulty == 'hard' ? 1 : 0,
      deviceMobileFlag: isMobile ? 1 : 0,
      therapistAssignedLevel: therapistLevel,
      questionTypeEncoded: _encodeQuestionType(questionType),
      cueTypeEncoded: _encodeCueType(cueType),
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
    );
  }

  static int _encodeQuestionType(String type) {
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

  static int _encodeCueType(String? type) {
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

  List<double> toFeatureVector() {
    return [
      responseTimeSeconds,
      cueGiven.toDouble(),
      cueStage.toDouble(),
      hintCount.toDouble(),
      difficultyFlag.toDouble(),
      deviceMobileFlag.toDouble(),
      therapistAssignedLevel.toDouble(),
      questionTypeEncoded.toDouble(),
      cueTypeEncoded.toDouble(),
      timeMorning.toDouble(),
      timeAfternoon.toDouble(),
      timeEvening.toDouble(),
      timeNight.toDouble(),
      moduleComprehension.toDouble(),
      moduleWriting.toDouble(),
      catAnimals.toDouble(),
      catBodyParts.toDouble(),
      catClothing.toDouble(),
      catFood.toDouble(),
    ];
  }
}

/// Result from cue prediction
class CuePredictionResult {
  final double probability;
  final bool needCue;
  final int inferenceTimeMs;

  const CuePredictionResult({
    required this.probability,
    required this.needCue,
    required this.inferenceTimeMs,
  });

  @override
  String toString() {
    return 'CuePredictionResult(probability: ${probability.toStringAsFixed(4)}, '
           'needCue: $needCue, inferenceTimeMs: $inferenceTimeMs)';
  }
}

/// Abstract interface for cue predictor implementations
abstract class ICuePredictor {
  bool get isLoaded;
  String get platformName;
  static const int inputFeatureCount = 19;
  static const double threshold = 0.5;
  
  Future<void> loadModel();
  CuePredictionResult predict(CuePredictorInput input);
  CuePredictionResult predictFromVector(List<double> features);
  void dispose();
}
