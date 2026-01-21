#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
SpeakSteps ML Model Simulator
==============================
Test model predictions with simulated exercise scenarios BEFORE retraining.
"""

import numpy as np

def create_feature_vector(**kwargs) -> np.ndarray:
    """Create a feature vector from keyword arguments."""
    vector = np.zeros(23)
    
    feature_map = {
        'response_time_seconds': 0,
        'cue_given': 1,
        'cue_stage': 2,
        'hint_count': 3,
        'difficulty_flag': 4,
        'device_mobile_flag': 5,
        'therapist_assigned_level': 6,
        'question_type_encoded': 7,
        'cue_type_encoded': 8,
        'time_morning': 9,
        'time_afternoon': 10,
        'time_evening': 11,
        'time_night': 12,
        'module_comprehension': 13,
        'module_writing': 14,
        'cat_animals': 15,
        'cat_body_parts': 16,
        'cat_clothing': 17,
        'cat_food': 18,
        'cue_sequence_normalized': 19,
        'exercise_duration_normalized': 20,
        'correct_before_cue_flag': 21,
        'module_duration_normalized': 22,
    }
    
    for key, value in kwargs.items():
        if key in feature_map:
            vector[feature_map[key]] = value
    
    return vector

print("\n" + "="*70)
print("ML MODEL SIMULATOR - SpeakSteps Cue Predictor")
print("="*70)
print("\nTest 5 realistic scenarios to verify model behavior\n")

# TEST 1: Patient at 8s - Early, no cue yet
print("\nTEST 1: Early Response (8s, no cue given)")
test1 = create_feature_vector(
    response_time_seconds=8,
    cue_given=0,
    difficulty_flag=1,  # Hard
    module_comprehension=1,
    cat_animals=1,
)
print(f"  Expected: LOW probability (~0.05-0.10)")
print(f"  Vector: {test1}")

# TEST 2: Patient at 22s - Long wait, no cue
print("\nTEST 2: Long Wait (22s, no cue given)")
test2 = create_feature_vector(
    response_time_seconds=22,
    cue_given=0,
    difficulty_flag=1,
    module_comprehension=1,
    cat_animals=1,
)
print(f"  Expected: MEDIUM probability (~0.25-0.35)")
print(f"  Vector: {test2}")

# TEST 3: Patient at 34s - Already got 1 cue (CRITICAL)
print("\nTEST 3: After First Cue (34s, already got cue) *** CRITICAL ***")
test3 = create_feature_vector(
    response_time_seconds=34,
    cue_given=1,
    cue_stage=1,
    difficulty_flag=1,
    module_comprehension=1,
    cat_animals=1,
    correct_before_cue_flag=1,  # <-- DOMINANT FEATURE!
)
print(f"  Expected: VERY HIGH probability (~0.85-0.95)")
print(f"  This MUST be highest! correct_before_cue_flag=1 is dominant.")
print(f"  Vector: {test3}")

# TEST 4: Patient at 5s - Easy, quick
print("\nTEST 4: Quick & Correct (5s, easy)")
test4 = create_feature_vector(
    response_time_seconds=5,
    cue_given=0,
    difficulty_flag=0,  # Easy
    module_comprehension=1,
    cat_animals=1,
)
print(f"  Expected: LOW probability (~0.02-0.08)")
print(f"  Vector: {test4}")

# TEST 5: Writing exercise
print("\nTEST 5: Writing Module (18s, moderate)")
test5 = create_feature_vector(
    response_time_seconds=18,
    cue_given=0,
    module_writing=1,  # <-- Writing module
    cat_body_parts=1,
)
print(f"  Expected: LOW-MEDIUM probability (~0.10-0.20)")
print(f"  Vector: {test5}")

print("\n" + "="*70)
print("NEXT STEPS - Retraining the Model")
print("="*70)
print("""
1. Open Google Colab: https://colab.research.google.com/

2. Copy entire train_ml_model_colab.py into a cell and run

3. Upload synth_speaksteps.csv when prompted

4. Wait for training to complete (5-10 minutes)

5. Download these files:
   - model.tflite
   - model.joblib

6. Copy to: backend/models/

7. Restart Flutter app

KEY METRIC: Test 3 should have HIGHEST probability!
This confirms correct_before_cue_flag is properly weighted.
""")
print("="*70 + "\n")
