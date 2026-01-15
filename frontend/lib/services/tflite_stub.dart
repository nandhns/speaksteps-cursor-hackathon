/// Stub implementation of tflite_flutter classes for web platform
/// This prevents compilation errors when running on web/Chrome

/// Stub Interpreter class - never actually used on web
class Interpreter {
  static Future<Interpreter> fromAsset(String path) async {
    throw UnsupportedError('TFLite is not supported on web platform. Use CuePredictorWeb instead.');
  }
  
  void close() {}
  
  dynamic getInputTensor(int index) {
    return _StubTensor();
  }
  
  dynamic getOutputTensor(int index) {
    return _StubTensor();
  }
  
  void run(Object inputs, Object outputs) {
    throw UnsupportedError('TFLite is not supported on web platform.');
  }
}

/// Stub Tensor class
class _StubTensor {
  List<int> get shape => [1, 23]; // Match expected shape
}
