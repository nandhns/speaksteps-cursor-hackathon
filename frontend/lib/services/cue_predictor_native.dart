/// SpeakSteps Native Cue Predictor (TFLite)
/// 
/// Uses the trained TFLite model for cue prediction on native platforms
/// (Android, iOS, Desktop)
/// 
/// NOTE: This file is NOT compiled for web. On web, cue_predictor_native_web.dart
/// is used instead (which is just a stub that uses CuePredictorWeb).

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'cue_predictor_interface.dart';

class CuePredictorNative implements ICuePredictor {
  Interpreter? _interpreter;
  bool _isLoaded = false;
  List<double>? _mean;
  List<double>? _scale;

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

      // Load scaler parameters to mirror training StandardScaler
      final scalerJson = await rootBundle.loadString('assets/ml/scaler_params.json');
      final scaler = json.decode(scalerJson) as Map<String, dynamic>;
      _mean = (scaler['mean'] as List<dynamic>).map((e) => (e as num).toDouble()).toList();
      _scale = (scaler['scale'] as List<dynamic>).map((e) => (e as num).toDouble()).toList();
      if (_mean!.length != ICuePredictor.inputFeatureCount || _scale!.length != ICuePredictor.inputFeatureCount) {
        throw StateError(
          'Scaler length mismatch: expected ${ICuePredictor.inputFeatureCount}, '
          'got mean=${_mean!.length}, scale=${_scale!.length}',
        );
      }
      if (_scale!.any((v) => v == 0)) {
        throw StateError('Scaler scale contains zero; cannot standardize features.');
      }
      
      // Verify input/output shapes
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      
      print('CuePredictorNative: Model loaded successfully');
      print('  Input shape: $inputShape');
      print('  Output shape: $outputShape');
      print('  Expected features: ${ICuePredictor.inputFeatureCount}');
      print('  Scaler loaded: ${_mean!.length} means, ${_scale!.length} scales');
      
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

    if (_mean == null || _scale == null) {
      throw StateError('Scaler not loaded. Ensure loadModel() completed successfully.');
    }

    if (features.length != ICuePredictor.inputFeatureCount) {
      throw ArgumentError(
        'Invalid feature count: expected ${ICuePredictor.inputFeatureCount}, '
        'got ${features.length}'
      );
    }

    final stopwatch = Stopwatch()..start();

    try {
      // Standardize features to match training scaler: z = (x - mean) / scale
      final standardized = List<double>.generate(
        features.length,
        (i) => (features[i] - _mean![i]) / _scale![i],
        growable: false,
      );

      // Prepare input: Shape [1, 24]
      final input = [standardized];
      
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
    _mean = null;
    _scale = null;
    _isLoaded = false;
    print('CuePredictorNative: Disposed');
  }
}
