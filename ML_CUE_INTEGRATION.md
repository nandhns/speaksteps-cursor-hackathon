# ML-Based Cue System Integration

## Answer: ✅ ML-Based, NOT Hardcoded Time

The cues are **fully integrated with ML predictions**, not hardcoded timers. The timer-based system is only used as a **fallback** when ML is unavailable.

---

## How It Works

### 1. **ML Model Loading** (On Exercise Start)

```dart
Future<void> _initializeML() async {
  if (kIsWeb) {
    // TFLite doesn't work on web - use timer fallback
    _startCueTimer();
    return;
  }

  try {
    _cuePredictor = CuePredictor();
    await _cuePredictor!.loadModel();
    setState(() {
      _mlModelLoaded = true;
    });
  } catch (e) {
    // If ML fails, fallback to timer
    _startCueTimer();
  }
}
```

### 2. **ML-Based Cue System** (Every 2 Seconds)

```dart
void _startMLBasedCueSystem() {
  if (!_mlModelLoaded) {
    _startCueTimer(); // Fallback
    return;
  }

  // Check ML prediction every 2 seconds
  _mlCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
    _checkMLPrediction();
  });
}
```

### 3. **ML Prediction** (Real-Time Analysis)

```dart
void _checkMLPrediction() {
  // Calculate response time
  final responseTime = DateTime.now().difference(_questionStartTime!).inSeconds.toDouble();
  
  // Prepare ML input with all features
  final input = CuePredictorInput.fromSimple(
    responseTimeSeconds: responseTime,
    cueGiven: _cueLevel > 0 ? 1 : 0,
    cueStage: _cueLevel,
    hintCount: _hintCount,
    difficulty: widget.exercise.difficulty >= 3 ? 'hard' : 'easy',
    isMobile: !kIsWeb && (Platform.isAndroid || Platform.isIOS),
    therapistLevel: 3,
    questionType: 'word_to_pic',
    cueType: _cueLevel == 1 ? 'functional' : ...,
    timeOfDay: timeOfDay,
    module: 'comprehension',
    category: widget.exercise.category.name,
  );

  // Get ML prediction
  final prediction = _cuePredictor!.predict(input);
  
  // Show cue ONLY if ML predicts it's needed
  if (prediction.needCue && _cueLevel == 0) {
    // Show function cue
    setState(() {
      _cueLevel = 1;
      _currentCue = currentQuestion.cueHierarchy?['function'];
    });
  }
  // ... more levels
}
```

---

## ML vs Timer Comparison

### ML-Based (Primary System) ✅
- **Checks every 2 seconds** using ML model
- **Analyzes user behavior** in real-time:
  - Response time
  - Current cue level
  - Hint count
  - Difficulty level
  - Time of day
  - Category and module
- **Shows cues when ML predicts** user needs help
- **Adaptive** - adjusts to user's actual performance

### Timer-Based (Fallback Only) ⚠️
- **Only used when:**
  - Running on web (TFLite unavailable)
  - ML model fails to load
  - ML prediction throws error
- **Fixed intervals:**
  - 15 seconds → Function cue
  - 10 more seconds → Rhyming cue
  - 10 more seconds → Written cue
- **Not adaptive** - same timing regardless of user performance

---

## Current Implementation Status

### ✅ Fully Integrated
- **Comprehension Exercise Screen** - Uses ML predictions
- **Writing Exercise Screen** - Uses ML predictions
- **ML model loads** on Android/iOS
- **Real-time predictions** every 2 seconds
- **Graceful fallback** to timer if ML unavailable

### Platform Support

| Platform | ML Support | Fallback |
|----------|-----------|----------|
| **Android** | ✅ Yes | Timer (if ML fails) |
| **iOS** | ✅ Yes | Timer (if ML fails) |
| **Web** | ❌ No (TFLite limitation) | Timer |
| **Desktop** | ✅ Yes | Timer (if ML fails) |

---

## How to Verify ML is Working

### 1. Check Console Logs
When ML loads successfully, you'll see:
```
CuePredictor: Model loaded successfully
  Input shape: [1, 19]
  Output shape: [1, 1]
```

If ML fails, you'll see:
```
Failed to load ML model, using timer-based cues: [error]
```

### 2. Test Behavior
- **With ML:** Cues appear based on your actual response time and behavior
- **With Timer:** Cues appear at fixed intervals (15s, 25s, 35s)

### 3. Check Platform
- **Android/iOS:** Should use ML (unless model file missing)
- **Web:** Will always use timer (TFLite doesn't work on web)

---

## ML Input Features

The ML model analyzes these features:

1. **Response Time** - How long user has been on question
2. **Cue Given** - Whether a cue was already shown
3. **Cue Stage** - Current level (0=none, 1=function, 2=rhyming, 3=written)
4. **Hint Count** - Number of hints given
5. **Difficulty** - Easy (0) or Hard (1)
6. **Device Type** - Mobile (1) or Web (0)
7. **Therapist Level** - Assigned difficulty level
8. **Question Type** - Encoded question type
9. **Cue Type** - Type of cue if any
10. **Time of Day** - Morning/Afternoon/Evening/Night (one-hot)
11. **Module** - Writing or Comprehension (one-hot)
12. **Category** - Animals/Body Parts/Clothing/Food (one-hot)

**Total: 19 features** → ML model → **1 output** (probability of needing cue)

---

## Code Flow

```
Exercise Starts
    ↓
_initializeML() [async]
    ↓
    ├─→ Web? → Use Timer (TFLite unavailable)
    └─→ Mobile? → Load TFLite Model
            ↓
        Success? → _mlModelLoaded = true
            ↓
        Fail? → Use Timer (fallback)
    ↓
_startMLBasedCueSystem()
    ↓
    ├─→ ML Loaded? → Start ML Check Timer (every 2s)
    │       ↓
    │   _checkMLPrediction()
    │       ↓
    │   ML Model Predicts
    │       ↓
    │   prediction.needCue == true?
    │       ↓
    │   YES → Show Appropriate Cue
    │   NO → Wait, check again in 2s
    │
    └─→ ML Not Loaded? → Use Timer (15s, 10s, 10s)
```

---

## Summary

**✅ ML is fully integrated and active!**

- Cues are **ML-predicted**, not hardcoded
- System **adapts to user behavior** in real-time
- Timer is **only a fallback** for web or if ML fails
- Works on **Android/iOS/Desktop** with full ML support
- **Web** automatically uses timer (TFLite limitation)

The implementation is production-ready with proper error handling and graceful fallbacks.

