/// SpeakSteps Cue Predictor Factory
/// 
/// Creates the appropriate predictor implementation based on platform.
/// - Native (Android/iOS/Desktop): TFLite trained model
/// - Web: Rule-based fallback
/// 
/// Uses conditional imports to avoid compiling TFLite code for web platform.

import 'dart:math';
import 'cue_predictor_interface.dart';

// Conditional import:
// - On native: imports the real cue_predictor_native.dart with TFLite
// - On web: imports cue_predictor_native_web.dart stub (which is just CuePredictorWeb)
import 'cue_predictor_native.dart'
    if (dart.library.html) 'cue_predictor_native_web.dart';

// Export the shared types
export 'cue_predictor_interface.dart';

/// Factory to create the appropriate predictor for the current platform
class CuePredictorFactory {
  static ICuePredictor create() {
    // CuePredictorNative resolves to:
    // - Real TFLite implementation on native platforms
    // - CuePredictorWeb stub on web platform
    return CuePredictorNative();
  }
}

/// Platform-aware cue predictor that delegates to the appropriate implementation
class CuePredictor implements ICuePredictor {
  late final ICuePredictor _implementation;
  
  CuePredictor() {
    _implementation = CuePredictorFactory.create();
  }
  
  @override
  bool get isLoaded => _implementation.isLoaded;
  
  @override
  String get platformName => _implementation.platformName;

  @override
  Future<void> loadModel() => _implementation.loadModel();

  @override
  CuePredictionResult predict(CuePredictorInput input) => _implementation.predict(input);

  @override
  CuePredictionResult predictFromVector(List<double> features) => 
      _implementation.predictFromVector(features);

  @override
  void dispose() => _implementation.dispose();
}
