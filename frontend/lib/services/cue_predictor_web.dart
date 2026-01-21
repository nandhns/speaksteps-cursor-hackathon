/// SpeakSteps Web-Compatible Cue Predictor
/// 
/// Uses rule-based logic to simulate ML predictions for web platform
/// where TFLite is not available.

import 'dart:math';
import 'cue_predictor_interface.dart';

/// Web-based implementation of the cue predictor

/// Web-compatible cue predictor using rule-based logic
class CuePredictorWeb implements ICuePredictor {
  bool _isLoaded = false;
  
  @override
  bool get isLoaded => _isLoaded;
  
  @override
  String get platformName => 'Web (Rule-based)';

  @override
  Future<void> loadModel() async {
    // Simulate a small delay like real model loading
    await Future.delayed(const Duration(milliseconds: 100));
    _isLoaded = true;
    print('CuePredictorWeb: Rule-based predictor ready (web mode)');
  }

  @override
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
      needCue: probability > ICuePredictor.threshold,
      inferenceTimeMs: stopwatch.elapsedMilliseconds,
    );
  }

  /// Calculate cue probability using rule-based logic
  /// For the 24-feature difficulty-estimator model:
  /// - Primary signals: response_time_rolling_avg, recent_accuracy_rate, consecutive_incorrect
  /// - Secondary signals: consecutiveCorrect, hintsUsedRatio, responseTimeSeconds
  /// - Context signals: difficultyFlag, therapistAssignedLevel, time of day
  double _calculateProbability(CuePredictorInput input) {
    double prob = 0.0;
    
    // PRIMARY SIGNAL: Rolling average response time (most predictive of struggle)
    // High rolling response time indicates consistent difficulty
    if (input.responseTimeRollingAvg > 25) {
      prob += 0.30; // Strong signal: patient consistently slow
    } else if (input.responseTimeRollingAvg > 18) {
      prob += 0.20;
    } else if (input.responseTimeRollingAvg > 12) {
      prob += 0.10;
    }
    
    // PRIMARY SIGNAL: Recent accuracy rate (reversed logic: low accuracy = high need)
    // If recent accuracy < 0.6, patient is struggling
    if (input.recentAccuracyRate < 0.4) {
      prob += 0.28; // Very high need: patient getting most questions wrong
    } else if (input.recentAccuracyRate < 0.6) {
      prob += 0.18; // Moderate need: below 60% accuracy
    } else if (input.recentAccuracyRate < 0.8) {
      prob += 0.08; // Mild need: below 80% accuracy
    }
    
    // SECONDARY SIGNAL: Consecutive incorrect streak
    // High streak of wrong answers indicates they need help
    if (input.consecutiveIncorrect > 0.7) {
      prob += 0.15; // Very high: 70%+ recent questions wrong
    } else if (input.consecutiveIncorrect > 0.4) {
      prob += 0.08;
    }
    
    // SECONDARY SIGNAL: Consecutive correct (inverse relationship)
    // High correct streak means they don't need help
    if (input.consecutiveCorrect > 0.7) {
      prob -= 0.10; // Reduce: patient on a roll
    }
    
    // SECONDARY SIGNAL: Current response time (immediate feedback)
    if (input.responseTimeSeconds > 30) {
      prob += 0.12; // Strong: this question is taking very long
    } else if (input.responseTimeSeconds > 20) {
      prob += 0.07;
    } else if (input.responseTimeSeconds > 12) {
      prob += 0.03;
    }
    
    // CONTEXT: Difficulty factor
    if (input.difficultyFlag == 1) {
      prob += 0.08; // Hard items have higher inherent difficulty
    }
    
    // CONTEXT: Hint usage
    // hintsUsedRatio is already normalized (0-1)
    if (input.hintsUsedRatio > 0.3) {
      prob += 0.05; // Using many hints suggests struggle
    }
    
    // CONTEXT: Therapist assigned level (higher = harder content)
    if (input.therapistAssignedLevel >= 4) {
      prob += 0.06;
    } else if (input.therapistAssignedLevel == 3) {
      prob += 0.03;
    }
    
    // CONTEXT: Time of day (evening/night slightly higher fatigue)
    if (input.timeEvening == 1 || input.timeNight == 1) {
      prob += 0.04;
    }
    
    // CONTEXT: Session progress (beginning of session = fresher, later = more fatigued)
    if (input.sessionProgressRatio > 0.8) {
      prob += 0.04; // Later in session, more fatigue
    }
    
    // Add small random variation to simulate ML uncertainty
    final random = Random();
    prob += (random.nextDouble() - 0.5) * 0.03;
    
    // Clamp to valid probability range
    return prob.clamp(0.0, 1.0);
  }

  /// Predict from raw feature vector
  @override
  CuePredictionResult predictFromVector(List<double> features) {
    if (!_isLoaded) {
      throw StateError('Model not loaded. Call loadModel() first.');
    }

    if (features.length != ICuePredictor.inputFeatureCount) {
      throw ArgumentError(
        'Expected ${ICuePredictor.inputFeatureCount} features, got ${features.length}'
      );
    }

    // Reconstruct input from vector (24 features)
    // Order must match model_metadata.json feature_columns
    final input = CuePredictorInput(
      responseTimeSeconds: features[0],
      responseTimeRollingAvg: features[1],
      hintCount: features[2].toInt(),
      hintsUsedRatio: features[3],
      consecutiveIncorrect: features[4],
      consecutiveCorrect: features[5],
      difficultyFlag: features[6].toInt(),
      deviceMobileFlag: features[7].toInt(),
      therapistAssignedLevel: features[8].toInt(),
      questionTypeEncoded: features[9].toInt(),
      cueTypeEncoded: features[10].toInt(),
      timeMorning: features[11].toInt(),
      timeAfternoon: features[12].toInt(),
      timeEvening: features[13].toInt(),
      timeNight: features[14].toInt(),
      moduleComprehension: features[15].toInt(),
      moduleWriting: features[16].toInt(),
      catAnimals: features[17].toInt(),
      catBodyParts: features[18].toInt(),
      catClothing: features[19].toInt(),
      catFood: features[20].toInt(),
      exerciseDurationNormalized: features[21],
      sessionProgressRatio: features[22],
      recentAccuracyRate: features[23],
    );

    return predict(input);
  }

  @override
  void dispose() {
    _isLoaded = false;
    print('CuePredictorWeb: Disposed');
  }
}

