/// SpeakSteps Native Cue Predictor (TFLite)
/// 
/// Uses the trained TFLite model for cue prediction on native platforms
/// (Android, iOS, Desktop)
/// 
/// NOTE: This file is NOT compiled for web. On web, cue_predictor_native_web.dart
/// is used instead (which is just a stub that uses CuePredictorWeb).

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'cue_predictor_interface.dart';

class CuePredictorNative implements ICuePredictor {
  Interpreter? _interpreter;
  bool _isLoaded = false;

  @override
  bool get isLoaded => _isLoaded;

  @override
  String get platformName => 'Native (TFLite)';

  @override
  Future<void> loadModel() async {
    if (_isLoaded) return;

    try {
      print('CuePredictorNative: Loading TFLite model...');
      
      // Load the optimized float16 model
      _interpreter = await Interpreter.fromAsset('assets/ml/model_float16.tflite');
      
      // Verify input/output shapes
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      
      print('CuePredictorNative: Model loaded successfully');
      print('  Input shape: $inputShape');
      print('  Output shape: $outputShape');
      print('  Expected features: ${ICuePredictor.inputFeatureCount}');
      
      if (inputShape[1] != ICuePredictor.inputFeatureCount) {
        throw StateError(
          'Model input shape mismatch: expected ${ICuePredictor.inputFeatureCount}, '
          'got ${inputShape[1]}'
        );
      }

      _isLoaded = true;
    } catch (e) {
      print('CuePredictorNative: Error loading model: $e');
      rethrow;
    }
  }

  @override
  CuePredictionResult predict(CuePredictorInput input) {
    return predictFromVector(input.toFeatureVector());
  }

  @override
  CuePredictionResult predictFromVector(List<double> features) {
    if (!_isLoaded || _interpreter == null) {
      throw StateError('Model not loaded. Call loadModel() first.');
    }

    if (features.length != ICuePredictor.inputFeatureCount) {
      throw ArgumentError(
        'Invalid feature count: expected ${ICuePredictor.inputFeatureCount}, '
        'got ${features.length}'
      );
    }

    final stopwatch = Stopwatch()..start();

    try {
      // Prepare input: Shape [1, 23]
      final input = [features];
      
      // Prepare output: Shape [1, 1]
      final output = List.filled(1, List.filled(1, 0.0));
      
      // Run inference
      _interpreter!.run(input, output);
      
      stopwatch.stop();
      
      final probability = output[0][0] as double;
      
      return CuePredictionResult(
        probability: probability,
        needCue: probability > ICuePredictor.threshold,
        inferenceTimeMs: stopwatch.elapsedMilliseconds,
      );
    } catch (e) {
      stopwatch.stop();
      print('CuePredictorNative: Inference error: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
    print('CuePredictorNative: Disposed');
  }
}
