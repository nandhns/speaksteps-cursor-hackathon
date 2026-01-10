/// SpeakSteps Web-Compatible Cue Predictor
/// 
/// Uses rule-based logic to simulate ML predictions for web platform
/// where TFLite is not available.

import 'dart:math';

/// Input features for the cue prediction (same interface as TFLite version)
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

/// Web-compatible cue predictor using rule-based logic
/// 
/// This mimics the behavior of the TFLite model but uses
/// deterministic rules, making it suitable for web deployment.
class CuePredictorWeb {
  bool _isLoaded = false;
  
  bool get isLoaded => _isLoaded;
  
  static const int inputFeatureCount = 19;
  static const double threshold = 0.5;

  /// Simulate model loading (instant for web)
  Future<void> loadModel() async {
    // Simulate a small delay like real model loading
    await Future.delayed(const Duration(milliseconds: 100));
    _isLoaded = true;
    print('CuePredictorWeb: Rule-based predictor ready (web mode)');
  }

  /// Predict using rule-based logic that mimics ML behavior
  CuePredictionResult predict(CuePredictorInput input) {
    if (!_isLoaded) {
      throw StateError('Model not loaded. Call loadModel() first.');
    }

    final stopwatch = Stopwatch()..start();
    
    // Calculate probability using rules that match our training data generation
    double probability = _calculateProbability(input);
    
    stopwatch.stop();

    return CuePredictionResult(
      probability: probability,
      needCue: probability > threshold,
      inferenceTimeMs: stopwatch.elapsedMilliseconds,
    );
  }

  /// Calculate cue probability using rule-based logic
  /// This mirrors the logic used in synthetic data generation
  double _calculateProbability(CuePredictorInput input) {
    double prob = 0.0;
    
    // Response time is the strongest predictor
    // Matches: need_cue_next = (response_time > 30) OR (correct == 0)
    if (input.responseTimeSeconds > 30) {
      prob += 0.45;
    } else if (input.responseTimeSeconds > 20) {
      prob += 0.25;
    } else if (input.responseTimeSeconds > 15) {
      prob += 0.15;
    } else if (input.responseTimeSeconds > 10) {
      prob += 0.08;
    }
    
    // Difficulty factor
    if (input.difficultyFlag == 1) {
      prob += 0.15;  // Hard items have lower base accuracy
    }
    
    // Cue history suggests struggle
    if (input.cueGiven == 1) {
      prob += 0.05 + (input.cueStage * 0.02);
    }
    
    // Hint count indicates progressive difficulty
    prob += input.hintCount * 0.03;
    
    // Therapist level (higher level = more challenging content)
    prob += (input.therapistAssignedLevel - 1) * 0.02;
    
    // Time of day factor (evening/night slightly higher)
    if (input.timeEvening == 1 || input.timeNight == 1) {
      prob += 0.03;
    }
    
    // Add small random variation to simulate ML uncertainty
    final random = Random();
    prob += (random.nextDouble() - 0.5) * 0.1;
    
    // Clamp to valid probability range
    return prob.clamp(0.0, 1.0);
  }

  /// Predict from raw feature vector
  CuePredictionResult predictFromVector(List<double> features) {
    if (!_isLoaded) {
      throw StateError('Model not loaded. Call loadModel() first.');
    }

    if (features.length != inputFeatureCount) {
      throw ArgumentError(
        'Expected $inputFeatureCount features, got ${features.length}'
      );
    }

    // Reconstruct input from vector
    final input = CuePredictorInput(
      responseTimeSeconds: features[0],
      cueGiven: features[1].toInt(),
      cueStage: features[2].toInt(),
      hintCount: features[3].toInt(),
      difficultyFlag: features[4].toInt(),
      deviceMobileFlag: features[5].toInt(),
      therapistAssignedLevel: features[6].toInt(),
      questionTypeEncoded: features[7].toInt(),
      cueTypeEncoded: features[8].toInt(),
      timeMorning: features[9].toInt(),
      timeAfternoon: features[10].toInt(),
      timeEvening: features[11].toInt(),
      timeNight: features[12].toInt(),
      moduleComprehension: features[13].toInt(),
      moduleWriting: features[14].toInt(),
      catAnimals: features[15].toInt(),
      catBodyParts: features[16].toInt(),
      catClothing: features[17].toInt(),
      catFood: features[18].toInt(),
    );

    return predict(input);
  }

  void dispose() {
    _isLoaded = false;
    print('CuePredictorWeb: Disposed');
  }
}

