# Quick Reference: Performance-Based Cue Timing

## Patient Performance Scenarios

### 🔴 Low Performers (< 60% Accuracy)
**Example**: 2 correct out of 5 questions
- **Therapist feedback addressed**: "Cues are too fast" → Give them MORE time
- **Cue Timing**: 15 seconds between each cue
- **Rationale**: Struggling patients need longer to think before each new hint

```
Question start
    ↓ (15s wait)
Function cue shows
    ↓ (15s wait)
Rhyming cue shows
    ↓ (15s wait)
Written cue shows
```

### 🟡 Mild Performers (60-80% Accuracy)
**Example**: 3 correct out of 5 questions
- **Therapist feedback**: "Finding middle ground"
- **Cue Timing**: 30 seconds between each cue
- **Rationale**: Moderate performers benefit from longer reflection time

```
Question start
    ↓ (30s wait)
Function cue shows
    ↓ (30s wait)
Rhyming cue shows
    ↓ (30s wait)
Written cue shows
```

### 🟢 High Performers (> 80% Accuracy)
**Example**: 4 correct out of 5 questions
- **Therapist feedback**: "Normal pace"
- **Cue Timing**: 10s initial, then 8s intervals
- **Rationale**: Confident patients process cues quickly

```
Question start
    ↓ (10s wait)
Function cue shows
    ↓ (8s wait)
Rhyming cue shows
    ↓ (8s wait)
Written cue shows
```

## Real-World Example

**Patient Timeline for Low Performers:**

```
9:00 AM - Question 1: "Name this animal"
         [Patient struggling...]
9:15 AM - First cue: "You ride this"
         [Still thinking...]
9:30 AM - Second cue: "It has 4 legs"
         [Finally answers]
         ✓ Correct! Recorded.

9:32 AM - Question 2: "Name this animal"
         [Getting better at thinking...]
9:47 AM - First cue shows (if needed)
```

Patient gets **full 15 seconds** before each cue - no rushing!

## How Performance Level is Calculated

The system looks at:
- **Last 10 exercise attempts** (or fewer if less than 10 completed)
- **Accuracy**: Correct answers ÷ Total attempts
- **Result**: Dynamic performance level

```
Attempts: [✓, ✗, ✓, ✓, ✗, ✗, ✓, ✗, ✓, ✓]
Correct:  7/10 = 70% accuracy
Level:    MILD (because 60% ≤ 70% < 80%)
Timing:   30 seconds intervals
```

## Key Benefits

✅ **No ML Model Changes** - Completely separate from prediction logic  
✅ **Automatic Adaptation** - Timing changes as patient improves/declines  
✅ **Therapist-Approved** - 15s/30s requests honored  
✅ **Data-Driven** - Based on actual recent performance  
✅ **Transparent** - Console logs show current level and timing  

## Monitoring

Watch console for debug messages:
```
DEBUG: Cue timing for low performance: 15s → 15s → 15s
DEBUG: Cue timing for mild performance: 30s → 30s → 30s
DEBUG: Cue timing for high performance: 10s → 8s → 8s
```

These indicate the system is correctly adapting to each patient's performance level!
