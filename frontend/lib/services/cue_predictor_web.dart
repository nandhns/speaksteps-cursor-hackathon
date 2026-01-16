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
  /// This mirrors the logic used in synthetic data generation
  double _calculateProbability(CuePredictorInput input) {
    double prob = 0.0;
    
    // ===== CRITICAL FIX: correctBeforeCueFlag is the DOMINANT predictor (46% feature importance) =====
    // If user already received a cue, probability is much higher they'll need another
    if (input.correctBeforeCueFlag == 1) {
      // User already received at least one cue
      prob += 0.46; // This is the dominant feature from feature importance
    }
    
    // Response time is the secondary predictor (after correctBeforeCueFlag)
    // But also very important - long response times indicate difficulty
    if (input.responseTimeSeconds > 30) {
      prob += 0.35; // Strong signal they need help
    } else if (input.responseTimeSeconds > 20) {
      prob += 0.20;
    } else if (input.responseTimeSeconds > 15) {
      prob += 0.12;
    } else if (input.responseTimeSeconds > 10) {
      prob += 0.06;
    }
    
    // Difficulty factor
    if (input.difficultyFlag == 1) {
      prob += 0.08; // Hard items have lower base accuracy
    }
    
    // Cue history suggests struggle (only applies if no cue given yet)
    if (input.cueGiven == 0) {
      prob += input.hintCount * 0.02;
    }
    
    // Therapist level (higher level = more challenging content)
    prob += (input.therapistAssignedLevel - 1) * 0.01;
    
    // Time of day factor (evening/night slightly higher fatigue)
    if (input.timeEvening == 1 || input.timeNight == 1) {
      prob += 0.02;
    }
    
    // Add small random variation to simulate ML uncertainty
    final random = Random();
    prob += (random.nextDouble() - 0.5) * 0.05;
    
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

    // Reconstruct input from vector (23 features)
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
      cueSequenceNormalized: features[19],
      exerciseDurationNormalized: features[20],
      correctBeforeCueFlag: features[21].toInt(),
      moduleDurationNormalized: features[22],
    );

    return predict(input);
  }

  @override
  void dispose() {
    _isLoaded = false;
    print('CuePredictorWeb: Disposed');
  }
}

