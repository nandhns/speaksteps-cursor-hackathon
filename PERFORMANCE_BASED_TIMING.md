# Performance-Based Cue Timing Implementation ✅

## Overview
Implemented adaptive cue timing based on patient performance, responding to therapist feedback: **15s intervals for low performers, 30s for mild performers, normal 10s/8s for high performers**.

## What Changed

### Backend (`cueing_engine.py`)

#### 1. **Three Performance-Based Timing Tables**
```python
CUE_TIMING_LOW   # <60% accuracy → 15s intervals
CUE_TIMING_MILD  # 60-80% accuracy → 30s intervals  
CUE_TIMING_HIGH  # >80% accuracy → 10s/8s intervals (normal)
```

#### 2. **New Functions**
- `calculate_performance_level(correctness_last_n: List[int]) -> str`
  - Analyzes recent accuracy (last 10 attempts)
  - Returns: 'low', 'mild', or 'high'
  - Classification: <60%, 60-80%, >80%

- `get_cue_timing_seconds(cue_type: str, performance_level: str) -> int`
  - Returns timing for specific cue based on performance
  - Can be called from backend/frontend

- `get_cue_timing_config(performance_level: str) -> Dict`
  - Returns entire timing config for a performance level
  - Can be sent to frontend for batch application

#### 3. **Backward Compatibility**
- Default `CUE_TIMING` still works for legacy code
- All new functions have sensible defaults

### Frontend - Writing Exercise Screen (`writing_exercise_screen.dart`)

#### 1. **Performance Calculation**
```dart
String _calculatePerformanceLevel() {
  // Uses _correctnessHistory (0/1 values)
  // Calculates accuracy from last 10 attempts
  // Returns 'low', 'mild', or 'high'
}
```

#### 2. **Dynamic Timing**
```dart
int _getCueTimingForPerformance(String performanceLevel, int cueLevel) {
  // Maps performance level → timing config
  // Returns seconds to wait for specific cue level
}
```

#### 3. **Updated Timer**
```dart
void _startCueTimer() {
  final performance = _calculatePerformanceLevel();
  final delay1 = _getCueTimingForPerformance(performance, 1);
  final delay2 = _getCueTimingForPerformance(performance, 2);
  final delay3 = _getCueTimingForPerformance(performance, 3);
  
  // Use dynamic delays instead of hardcoded constants
  _cueTimer = Timer(Duration(seconds: delay1), () {
    // Show cue...
  });
}
```

### Frontend - Comprehension Exercise Screen (`comprehension_exercise_screen.dart`)
- Applied identical changes as writing screen
- Same `_calculatePerformanceLevel()` and `_getCueTimingForPerformance()` functions
- Same dynamic timer logic

## Performance Thresholds

| Level | Accuracy | Timing Pattern |
|-------|----------|----------------|
| 🔴 Low | < 60% | 15s → 15s → 15s → ... |
| 🟡 Mild | 60-80% | 30s → 30s → 30s → ... |
| 🟢 High | > 80% | 10s → 8s → 8s → ... |

## How It Works

1. **During Exercise**: System tracks correct/incorrect responses in `_correctnessHistory`
2. **At Each Question**: When a new cue is needed, calculate current performance level
3. **Dynamic Delays**: Apply appropriate timing based on performance
4. **Automatic Progression**: As patient improves, timing automatically speeds up (or slows down)

## Testing

✅ Backend tests passed:
- Low performance (25% accuracy) → 15s timing
- Mild performance (62.5% accuracy) → 30s timing
- High performance (87.5% accuracy) → 10s/8s timing

✅ Build successful:
- Flutter APK compiles with new functions
- Web build deploys successfully
- No ML model changes required

## ML Impact

**Zero impact on ML model performance** ✅

- ML model only predicts: "Does patient need a cue?"
- Performance-based timing controls: "When should we check?"
- These are completely independent layers
- No retraining needed
- Model accuracy unchanged

## Deployment

- ✅ Backend: `cueing_engine.py` updated with performance functions
- ✅ Frontend: Both exercise screens updated with dynamic timing
- ✅ Web: Deployed to https://speaksteps-cursor.web.app
- ✅ APK: Built for Android testing

## Debug Output

When patients use the app, you'll see console logs like:
```
DEBUG: Cue timing for low performance: 15s → 15s → 15s
DEBUG: Cue timing for mild performance: 30s → 30s → 30s
DEBUG: Cue timing for high performance: 10s → 8s → 8s
```

This helps therapists verify the timing is working correctly!

## Next Steps (Optional)

1. **Therapist Dashboard**: Show current performance level + timing in real-time
2. **Analytics**: Track how many patients fall into each performance category
3. **Tuning**: Adjust thresholds (currently 60% and 80%) based on clinical feedback
4. **Per-Category Timing**: Different timings for different exercise categories

---

**Implementation Complete** ✅  
Ready for clinical testing and therapist feedback!
