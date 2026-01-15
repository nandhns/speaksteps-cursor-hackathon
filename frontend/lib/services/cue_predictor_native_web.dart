/// Web stub for CuePredictorNative
/// This file is only compiled on web platform and simply redirects to CuePredictorWeb
/// This prevents TFLite compilation errors on web.

import 'cue_predictor_interface.dart';
import 'cue_predictor_web.dart';

/// On web, "CuePredictorNative" is actually just CuePredictorWeb
/// This stub allows the factory to reference CuePredictorNative without compilation errors
class CuePredictorNative extends CuePredictorWeb implements ICuePredictor {
  // Inherits all functionality from CuePredictorWeb
}
