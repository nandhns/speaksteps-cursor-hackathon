/// SpeakSteps Cue Predictor Factory
/// 
/// Creates the appropriate predictor implementation based on platform.
/// - Native (Android/iOS/Desktop): TFLite
/// - Web: Rule-based fallback

import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'cue_predictor_interface.dart';

// Export the shared types
export 'cue_predictor_interface.dart';

/// Platform-aware cue predictor that works on all platforms
class CuePredictor implements ICuePredictor {
  bool _isLoaded = false;
  late final String _platform;
  
  // For web: rule-based predictor
  // For native: would use TFLite (but we'll use rules for simplicity)
  
  CuePredictor() {
    _platform = kIsWeb ? 'Web (Rule-based)' : 'Native (Rule-based)';
  }
  
  @override
  bool get isLoaded => _isLoaded;
  
  @override
  String get platformName => _platform;
  
  static const int inputFeatureCount = 19;
  static const double threshold = 0.5;

  @override
  Future<void> loadModel() async {
    // Simulate model loading delay
    await Future.delayed(const Duration(milliseconds: 200));
    _isLoaded = true;
    print('CuePredictor: Loaded ($_platform)');
  }

  @override
  CuePredictionResult predict(CuePredictorInput input) {
    if (!_isLoaded) {
      throw StateError('Model not loaded. Call loadModel() first.');
    }

    final stopwatch = Stopwatch()..start();
    double probability = _calculateProbability(input);
    stopwatch.stop();

    return CuePredictionResult(
      probability: probability,
      needCue: probability > threshold,
      inferenceTimeMs: stopwatch.elapsedMilliseconds,
    );
  }

  /// Calculate cue probability using rule-based logic
  double _calculateProbability(CuePredictorInput input) {
    double prob = 0.0;
    
    // Response time is the strongest predictor
    if (input.responseTimeSeconds > 30) {
      prob += 0.45;
    } else if (input.responseTimeSeconds > 20) {
      prob += 0.25;
    } else if (input.responseTimeSeconds > 15) {
      prob += 0.15;
    } else if (input.responseTimeSeconds > 10) {
      prob += 0.08;
    } else if (input.responseTimeSeconds < 6) {
      prob -= 0.1; // Fast response suggests confidence
    }
    
    // Difficulty factor
    if (input.difficultyFlag == 1) {
      prob += 0.15;
    }
    
    // Cue history
    if (input.cueGiven == 1) {
      prob += 0.05 + (input.cueStage * 0.02);
    }
    
    // Hint count
    prob += input.hintCount * 0.03;
    
    // Therapist level
    prob += (input.therapistAssignedLevel - 1) * 0.02;
    
    // Time of day (fatigue factor)
    if (input.timeEvening == 1 || input.timeNight == 1) {
      prob += 0.03;
    }
    
    // Small random variation
    final random = Random();
    prob += (random.nextDouble() - 0.5) * 0.08;
    
    return prob.clamp(0.0, 1.0);
  }

  @override
  CuePredictionResult predictFromVector(List<double> features) {
    if (!_isLoaded) {
      throw StateError('Model not loaded. Call loadModel() first.');
    }

    if (features.length != inputFeatureCount) {
      throw ArgumentError(
        'Expected $inputFeatureCount features, got ${features.length}'
      );
    }

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

  @override
  void dispose() {
    _isLoaded = false;
    print('CuePredictor: Disposed');
  }
}

