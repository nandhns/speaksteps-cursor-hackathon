"""
SpeakSteps ML Model Training for Google Colab
==============================================
Complete pipeline to train TFLite model for hierarchical cueing prediction.

Copy this entire file into a Google Colab cell and run it!

Steps:
1. Upload synth_speaksteps.csv when prompted
2. Model trains automatically
3. Downloads trained model files
4. Copy downloaded files to backend/models/
"""

# ============================================================================
# STEP 1: Install Dependencies
# ============================================================================
print("📦 Installing dependencies...")
!pip install -q tensorflow scikit-learn pandas numpy matplotlib seaborn

# ============================================================================
# STEP 2: Imports
# ============================================================================
print("\n📚 Importing libraries...")
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime
import warnings
warnings.filterwarnings('ignore')

# Scikit-learn
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.preprocessing import StandardScaler
from sklearn.tree import DecisionTreeClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score,
    roc_auc_score, classification_report, confusion_matrix
)

# TensorFlow
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, models

# Model persistence
import joblib
import json

# Google Colab file upload
from google.colab import files

# Set random seed
RANDOM_STATE = 42
np.random.seed(RANDOM_STATE)
tf.random.set_seed(RANDOM_STATE)

print("✅ All libraries imported!")

# ============================================================================
# STEP 3: Upload Data
# ============================================================================
print("\n📤 Please upload synth_speaksteps.csv...")
uploaded = files.upload()

# Load the dataset
df = pd.read_csv('synth_speaksteps.csv')
print(f"\n✅ Dataset loaded: {df.shape[0]} rows, {df.shape[1]} columns")

# ============================================================================
# STEP 4: Feature Engineering (24-Feature Difficulty Estimator)
# ============================================================================
print("\n🔧 Engineering features for difficulty estimation...")

data = df.copy()

# Sort by session and time for rolling calculations
data['presented_at'] = pd.to_datetime(data['presented_at_iso'], format='ISO8601')
data = data.sort_values(['session_id', 'presented_at']).reset_index(drop=True)

# --- Basic Categorical Encodings ---
data['difficulty_flag'] = (data['difficulty_label'] == 'hard').astype(int)
data['device_mobile_flag'] = (data['device_type'] == 'mobile').astype(int)

# Encode question_type
question_type_map = {
    'pic_to_word': 0,
    'word_to_pic': 1,
    'fill_in_blank': 2,
    'audio_to_pic': 3,
    'spelling_choice': 4,
    'word_completion': 5,
    'sentence_matching': 6,
    'category_sorting': 7,
    'yes_no_question': 8
}
data['question_type_encoded'] = data['question_type'].map(question_type_map).fillna(0)

# Encode cue_type (for current cue context, not as leakage)
cue_type_map = {
    'none': 0,
    'functional': 1,
    'rhyming': 2,
    'written_initial': 3,
    'spelling': 4,
    'sentence_completion': 5,
    'phonemic': 6,
    'modeling': 7
}
data['cue_type_encoded'] = data['cue_type'].fillna('none').map(cue_type_map)

# --- Time of Day Features ---
data['hour'] = data['presented_at'].dt.hour
data['time_morning'] = ((data['hour'] >= 6) & (data['hour'] < 12)).astype(int)
data['time_afternoon'] = ((data['hour'] >= 12) & (data['hour'] < 17)).astype(int)
data['time_evening'] = ((data['hour'] >= 17) & (data['hour'] < 21)).astype(int)
data['time_night'] = ((data['hour'] >= 21) | (data['hour'] < 6)).astype(int)

# --- Module One-Hot Encoding ---
data['module_comprehension'] = (data['module'] == 'comprehension').astype(int)
data['module_writing'] = (data['module'] == 'writing').astype(int)

# --- Category One-Hot Encoding ---
data['cat_animals'] = (data['category'] == 'animals').astype(int)
data['cat_body_parts'] = (data['category'] == 'body_parts').astype(int)
data['cat_clothing'] = (data['category'] == 'clothing').astype(int)
data['cat_food'] = (data['category'] == 'food').astype(int)

# --- Exercise Duration (normalized) ---
data['exercise_duration_normalized'] = np.clip(data['exercise_duration_seconds'].fillna(0) / 300.0, 0, 1)  # 5 min max

# --- NEW: Rolling/Session-Based Features (no data leakage) ---
print("   Computing rolling features within sessions...")

# 1. response_time_rolling_avg: Rolling average of last 5 response times within session
data['response_time_rolling_avg'] = data.groupby('session_id')['response_time_seconds'].transform(
    lambda x: x.shift(1).rolling(window=5, min_periods=1).mean()
).fillna(data['response_time_seconds'].median())

# 2. hints_used_ratio: Cumulative hints used / questions answered so far in session
data['cumulative_hints'] = data.groupby('session_id')['hint_count'].cumsum()
data['question_number_in_session'] = data.groupby('session_id').cumcount() + 1
data['hints_used_ratio'] = (data['cumulative_hints'] / data['question_number_in_session']).fillna(0)
data['hints_used_ratio'] = np.clip(data['hints_used_ratio'] / 3.0, 0, 1)  # Normalize (max ~3 hints/question)

# 3. consecutive_incorrect: Running count of consecutive wrong answers (reset on correct)
def calc_consecutive(group, target_val):
    """Calculate consecutive streak of target_val, resetting on opposite."""
    streaks = []
    count = 0
    for val in group:
        if val == target_val:
            count += 1
        else:
            count = 0
        streaks.append(count)
    return streaks

data['consecutive_incorrect'] = data.groupby('session_id')['correct'].transform(
    lambda x: calc_consecutive(x.shift(1).fillna(1).values, 0)  # Shift to avoid leakage
).fillna(0).astype(int)
data['consecutive_incorrect'] = np.clip(data['consecutive_incorrect'] / 5.0, 0, 1)  # Normalize (max 5)

# 4. consecutive_correct: Running count of consecutive correct answers (reset on incorrect)
data['consecutive_correct'] = data.groupby('session_id')['correct'].transform(
    lambda x: calc_consecutive(x.shift(1).fillna(0).values, 1)  # Shift to avoid leakage
).fillna(0).astype(int)
data['consecutive_correct'] = np.clip(data['consecutive_correct'] / 5.0, 0, 1)  # Normalize (max 5)

# 5. session_progress_ratio: Current question / total questions in session
data['total_questions_in_session'] = data.groupby('session_id')['question_id'].transform('count')
data['session_progress_ratio'] = data['question_number_in_session'] / data['total_questions_in_session']
data['session_progress_ratio'] = data['session_progress_ratio'].fillna(0.5)

# 6. recent_accuracy_rate: Rolling accuracy over last 5 questions (shifted to avoid leakage)
data['recent_accuracy_rate'] = data.groupby('session_id')['correct'].transform(
    lambda x: x.shift(1).rolling(window=5, min_periods=1).mean()
).fillna(0.5)  # Default to 50% if no history

# --- Target Variable: Difficulty Score (0-1) ---
# Logic: Higher score = patient is struggling more = needs more cue support
# Combine multiple signals into a continuous difficulty score
data['difficulty_score'] = (
    # Slow response contributes to difficulty (normalized: 15s+ is high difficulty)
    np.clip(data['response_time_seconds'] / 30.0, 0, 1) * 0.3 +
    # Incorrect answer is strong signal of difficulty
    (1 - data['correct']) * 0.4 +
    # Hard exercises are inherently more difficult
    data['difficulty_flag'] * 0.15 +
    # Low recent accuracy indicates struggling
    (1 - data['recent_accuracy_rate']) * 0.15
).clip(0, 1)

# Also keep binary target for classification metrics
data['need_cue_next'] = (
    (data['response_time_seconds'] > 15) |  # Slow response
    (data['correct'] == 0) |                 # Wrong answer
    (data['recent_accuracy_rate'] < 0.6)     # Recent struggling
).astype(int)

print("✅ Features engineered (24 features for difficulty estimation)!")

# ============================================================================
# STEP 5: Prepare Training Data
# ============================================================================
print("\n📊 Preparing training data...")

# Select features for model (24 features - difficulty estimator, NO data leakage)
feature_columns = [
    'response_time_seconds',           # 0  - Current response time
    'response_time_rolling_avg',       # 1  - Rolling avg of last 5 response times
    'hint_count',                      # 2  - Hints used on current question
    'hints_used_ratio',                # 3  - Cumulative hints / questions in session
    'consecutive_incorrect',           # 4  - Streak of wrong answers (normalized)
    'consecutive_correct',             # 5  - Streak of correct answers (normalized)
    'difficulty_flag',                 # 6  - Is this a hard exercise?
    'device_mobile_flag',              # 7  - Mobile vs web
    'therapist_assigned_level',        # 8  - Therapist-set difficulty level (1-5)
    'question_type_encoded',           # 9  - Type of question
    'cue_type_encoded',                # 10 - Type of cue if any given previously
    'time_morning',                    # 11 - Time of day: morning
    'time_afternoon',                  # 12 - Time of day: afternoon
    'time_evening',                    # 13 - Time of day: evening
    'time_night',                      # 14 - Time of day: night
    'module_comprehension',            # 15 - Comprehension module
    'module_writing',                  # 16 - Writing module
    'cat_animals',                     # 17 - Category: animals
    'cat_body_parts',                  # 18 - Category: body parts
    'cat_clothing',                    # 19 - Category: clothing
    'cat_food',                        # 20 - Category: food
    'exercise_duration_normalized',    # 21 - Time spent on exercise so far
    'session_progress_ratio',          # 22 - Progress through session (0-1)
    'recent_accuracy_rate',            # 23 - Accuracy over last 5 questions
]

X = data[feature_columns].fillna(0).values
y = data['need_cue_next'].values

# Split data
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=RANDOM_STATE, stratify=y
)

print(f"✅ Training set: {X_train.shape[0]} samples")
print(f"✅ Test set: {X_test.shape[0]} samples")
print(f"✅ Target distribution: {np.bincount(y_train)} (train)")

# ============================================================================
# STEP 6: Train Neural Network (for TFLite)
# ============================================================================
print("\n🧠 Training Neural Network...")

# Normalize features
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Build model (24 features - difficulty estimator)
# Output is sigmoid (0-1) representing difficulty score / cue need probability
model = models.Sequential([
    layers.Input(shape=(24,)),  # 24 features
    layers.Dense(64, activation='relu'),
    layers.BatchNormalization(),
    layers.Dropout(0.3),
    layers.Dense(32, activation='relu'),
    layers.BatchNormalization(),
    layers.Dropout(0.2),
    layers.Dense(16, activation='relu'),
    layers.Dropout(0.2),
    layers.Dense(8, activation='relu'),
    layers.Dense(1, activation='sigmoid')  # Output: difficulty score 0-1
])

model.compile(
    optimizer='adam',
    loss='binary_crossentropy',
    metrics=['accuracy', tf.keras.metrics.AUC(name='auc')]
)

print("\n📋 Model Architecture:")
model.summary()

# Train model
print("\n🏋️ Training...")
history = model.fit(
    X_train_scaled, y_train,
    validation_split=0.2,
    epochs=30,
    batch_size=32,
    verbose=1
)

# ============================================================================
# STEP 7: Evaluate Model
# ============================================================================
print("\n📊 Evaluating model...")

# Predictions
y_pred_proba = model.predict(X_test_scaled)
y_pred = (y_pred_proba > 0.5).astype(int).flatten()

# Metrics
accuracy = accuracy_score(y_test, y_pred)
precision = precision_score(y_test, y_pred)
recall = recall_score(y_test, y_pred)
f1 = f1_score(y_test, y_pred)
auc = roc_auc_score(y_test, y_pred_proba)

print(f"\n✅ Test Accuracy: {accuracy:.4f}")
print(f"✅ Precision: {precision:.4f}")
print(f"✅ Recall: {recall:.4f}")
print(f"✅ F1 Score: {f1:.4f}")
print(f"✅ AUC-ROC: {auc:.4f}")

print("\n📋 Classification Report:")
print(classification_report(y_test, y_pred, target_names=['No Cue', 'Need Cue']))

# Confusion Matrix
cm = confusion_matrix(y_test, y_pred)
plt.figure(figsize=(8, 6))
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues')
plt.title('Confusion Matrix')
plt.ylabel('True Label')
plt.xlabel('Predicted Label')
plt.show()

# Training history
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

ax1.plot(history.history['accuracy'], label='Train Accuracy')
ax1.plot(history.history['val_accuracy'], label='Val Accuracy')
ax1.set_title('Model Accuracy')
ax1.set_xlabel('Epoch')
ax1.set_ylabel('Accuracy')
ax1.legend()
ax1.grid(True)

ax2.plot(history.history['loss'], label='Train Loss')
ax2.plot(history.history['val_loss'], label='Val Loss')
ax2.set_title('Model Loss')
ax2.set_xlabel('Epoch')
ax2.set_ylabel('Loss')
ax2.legend()
ax2.grid(True)

plt.tight_layout()
plt.show()

# ============================================================================
# STEP 8: Convert to TFLite
# ============================================================================
print("\n🔄 Converting to TFLite...")

# Save full model first
model.export('saved_model')
print("✅ Saved full model to 'saved_model' directory")

# Convert to TFLite (float32)
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

with open('model.tflite', 'wb') as f:
    f.write(tflite_model)
print("✅ Saved model.tflite")

# Convert to TFLite (float16 - smaller size)
converter_fp16 = tf.lite.TFLiteConverter.from_keras_model(model)
converter_fp16.optimizations = [tf.lite.Optimize.DEFAULT]
converter_fp16.target_spec.supported_types = [tf.float16]
tflite_model_fp16 = converter_fp16.convert()

with open('model_float16.tflite', 'wb') as f:
    f.write(tflite_model_fp16)
print("✅ Saved model_float16.tflite")

# ============================================================================
# STEP 9: Save Scaler and Metadata
# ============================================================================
print("\n💾 Saving scaler and metadata...")

# Save scaler
joblib.dump(scaler, 'model.joblib')
print("✅ Saved model.joblib (scaler)")

# Save metadata with cue thresholds for difficulty-based cue decisions
metadata = {
    'feature_columns': feature_columns,
    'feature_count': len(feature_columns),
    'model_type': 'difficulty_estimator',
    'output_type': 'difficulty_score',
    'output_range': [0.0, 1.0],
    'cue_thresholds': {
        'no_cue': {'min': 0.0, 'max': 0.3},
        'light_cue': {'min': 0.3, 'max': 0.5},
        'moderate_cue': {'min': 0.5, 'max': 0.7},
        'strong_cue': {'min': 0.7, 'max': 1.0}
    },
    'cue_decision_rules': {
        'description': 'Score >= threshold triggers cue. Higher score = more assistance needed.',
        'default_threshold': 0.4,
        'adaptive_threshold': True
    },
    'accuracy': float(accuracy),
    'precision': float(precision),
    'recall': float(recall),
    'f1_score': float(f1),
    'auc_roc': float(auc),
    'trained_at': datetime.now().isoformat(),
    'training_samples': int(X_train.shape[0]),
    'test_samples': int(X_test.shape[0]),
    'random_state': RANDOM_STATE,
    'feature_descriptions': {
        'response_time_seconds': 'Time taken to respond to current question',
        'response_time_rolling_avg': 'Rolling average of last 5 response times',
        'hints_used_ratio': 'Hints used / hints available in session',
        'consecutive_incorrect': 'Number of consecutive wrong answers (normalized)',
        'consecutive_correct': 'Number of consecutive correct answers (normalized)',
        'session_progress_ratio': 'Current question / total questions in session',
        'recent_accuracy_rate': 'Accuracy over last 5 questions (0-1)'
    }
}

with open('model_metadata.json', 'w') as f:
    json.dump(metadata, f, indent=2)
print("✅ Saved model_metadata.json")

# ============================================================================
# STEP 10: Test TFLite Model
# ============================================================================
print("\n🧪 Testing TFLite model...")

# Load TFLite model
interpreter = tf.lite.Interpreter(model_path='model.tflite')
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# Test on a few samples
test_samples = X_test_scaled[:5]
print("\nTesting 5 samples:")
for i, sample in enumerate(test_samples):
    # Set input
    interpreter.set_tensor(input_details[0]['index'], sample.reshape(1, -1).astype(np.float32))
    
    # Run inference
    interpreter.invoke()
    
    # Get output
    output = interpreter.get_tensor(output_details[0]['index'])[0][0]
    
    print(f"Sample {i+1}: Probability = {output:.4f}, Prediction = {'Need Cue' if output > 0.5 else 'No Cue'}, True = {'Need Cue' if y_test[i] == 1 else 'No Cue'}")

print("\n✅ TFLite model working correctly!")

# ============================================================================
# STEP 11: Download Files
# ============================================================================
print("\n📥 Downloading model files...")

files_to_download = [
    'model.tflite',
    'model_float16.tflite',
    'model.joblib',
    'model_metadata.json'
]

for filename in files_to_download:
    files.download(filename)
    print(f"✅ Downloaded {filename}")

print("\n" + "="*70)
print("🎉 TRAINING COMPLETE!")
print("="*70)
print("\n📋 Next Steps:")
print("1. Copy downloaded files to: backend/models/")
print("2. Also download the 'saved_model' folder (if needed)")
print("3. Update backend code to load the real TFLite model")
print("\n✅ Model Features (24 total - Difficulty Estimator):")
print("   - Performance: response_time, response_time_rolling_avg, recent_accuracy_rate")
print("   - Hints: hint_count, hints_used_ratio")
print("   - Streaks: consecutive_incorrect, consecutive_correct")
print("   - Context: difficulty_flag, device, therapist_level, question_type, cue_type")
print("   - Time: morning, afternoon, evening, night")
print("   - Module: comprehension, writing")
print("   - Category: animals, body_parts, clothing, food")
print("   - Session: exercise_duration, session_progress_ratio")
print("\n🎯 Cue Decision Thresholds:")
print("   - No cue needed:    score < 0.3")
print("   - Light cue:        0.3 <= score < 0.5")
print("   - Moderate cue:     0.5 <= score < 0.7")
print("   - Strong cue:       score >= 0.7")
print("   - Default threshold: 0.4")
print("\n✅ Model Performance:")
print(f"   - Accuracy: {accuracy:.2%}")
print(f"   - Precision: {precision:.2%}")
print(f"   - Recall: {recall:.2%}")
print(f"   - F1 Score: {f1:.2%}")
print(f"   - AUC-ROC: {auc:.2%}")
print("\n🎯 Your ML model is ready to use!")
print("="*70)

# ============================================================================
# FEATURE IMPORTANCE ANALYSIS
# ============================================================================
print("\n🔍 Analyzing Feature Importance (Permutation-based)...")
print("   This shows which patient response patterns matter most for cue prediction\n")

from sklearn.inspection import permutation_importance
from sklearn.base import BaseEstimator, ClassifierMixin

# Wrap Keras model to work with sklearn's permutation_importance
class KerasClassifierWrapper(BaseEstimator, ClassifierMixin):
    def __init__(self, model):
        self.model = model
    
    def fit(self, X, y):
        # Already trained, just return self
        return self
    
    def predict(self, X):
        return (self.model.predict(X, verbose=0) > 0.5).astype(int).flatten()
    
    def score(self, X, y):
        predictions = self.predict(X)
        return accuracy_score(y, predictions)

# Wrap the model
wrapped_model = KerasClassifierWrapper(model)

# Calculate permutation importance
result = permutation_importance(
    wrapped_model,
    X_test_scaled, 
    y_test, 
    n_repeats=10, 
    random_state=RANDOM_STATE,
    scoring='accuracy'
)

# Create importance dataframe
importance_df = pd.DataFrame({
    'Feature': feature_columns,
    'Importance': result.importances_mean,
    'Std': result.importances_std
}).sort_values('Importance', ascending=False)

print("📊 TOP 10 MOST IMPORTANT FEATURES FOR CUE PREDICTION:")
print("=" * 70)
for idx, row in importance_df.head(10).iterrows():
    print(f"{row['Feature']:30s} | Importance: {row['Importance']:.4f} ± {row['Std']:.4f}")

print("\n" + "=" * 70)
print("What this means:")
print("  - Higher importance = more critical for predicting if patient needs cue")
print("  - response_time: How quickly patient responds")
print("  - correct_before_cue: Whether answer was correct BEFORE cue")
print("  - difficulty: Difficulty level affects cue prediction")
print("  - Category flags: Type of exercise (animals, body_parts, etc.)")
print("=" * 70 + "\n")

# Plot feature importance
plt.figure(figsize=(12, 8))
top_n = 15
top_features = importance_df.head(top_n)
plt.barh(range(len(top_features)), top_features['Importance'].values)
plt.yticks(range(len(top_features)), top_features['Feature'].values)
plt.xlabel('Importance Score')
plt.title(f'Top {top_n} Features for Cue Prediction')
plt.gca().invert_yaxis()  # Highest at top
plt.tight_layout()
plt.show()

# Save feature importance to file
importance_df.to_csv('feature_importance.csv', index=False)
print(f"✅ Saved feature_importance.csv with all {len(importance_df)} features")

# Also download it
files.download('feature_importance.csv')
print("✅ Downloaded feature_importance.csv")



