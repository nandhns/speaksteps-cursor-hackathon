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
# STEP 4: Feature Engineering
# ============================================================================
print("\n🔧 Engineering features...")

data = df.copy()

# Create target variable: need_cue_next
# Logic: User needs cue if they struggled (took long time, got wrong, or needed cue)
data['need_cue_next'] = (
    (data['response_time_seconds'] > 15) |  # Slow response
    (data['correct'] == 0) |                 # Incorrect answer
    (data['cue_given'] == 1)                 # Already needed cue
).astype(int)

# Encode categorical variables
data['difficulty_flag'] = (data['difficulty_label'] == 'hard').astype(int)
data['device_mobile_flag'] = (data['device_type'] == 'mobile').astype(int)

# Encode question_type
question_type_map = {
    'pic_to_word': 0,
    'word_to_pic': 1,
    'fill_in_blank': 2,
    'audio_to_pic': 3
}
data['question_type_encoded'] = data['question_type'].map(question_type_map).fillna(0)

# Encode cue_type
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

# Time of day features (from presented_at_iso)
data['presented_at'] = pd.to_datetime(data['presented_at_iso'])
data['hour'] = data['presented_at'].dt.hour
data['time_morning'] = ((data['hour'] >= 6) & (data['hour'] < 12)).astype(int)
data['time_afternoon'] = ((data['hour'] >= 12) & (data['hour'] < 17)).astype(int)
data['time_evening'] = ((data['hour'] >= 17) & (data['hour'] < 21)).astype(int)
data['time_night'] = ((data['hour'] >= 21) | (data['hour'] < 6)).astype(int)

# Module one-hot encoding
data['module_comprehension'] = (data['module'] == 'comprehension').astype(int)
data['module_writing'] = (data['module'] == 'writing').astype(int)

# Category one-hot encoding
data['cat_animals'] = (data['category'] == 'animals').astype(int)
data['cat_body_parts'] = (data['category'] == 'body_parts').astype(int)
data['cat_clothing'] = (data['category'] == 'clothing').astype(int)
data['cat_food'] = (data['category'] == 'food').astype(int)

print("✅ Features engineered!")

# ============================================================================
# STEP 5: Prepare Training Data
# ============================================================================
print("\n📊 Preparing training data...")

# Select features for model (19 features total)
feature_columns = [
    'response_time_seconds',      # 0
    'cue_given',                   # 1
    'cue_stage',                   # 2
    'hint_count',                  # 3
    'difficulty_flag',             # 4
    'device_mobile_flag',          # 5
    'therapist_assigned_level',    # 6
    'question_type_encoded',       # 7
    'cue_type_encoded',            # 8
    'time_morning',                # 9
    'time_afternoon',              # 10
    'time_evening',                # 11
    'time_night',                  # 12
    'module_comprehension',        # 13
    'module_writing',              # 14
    'cat_animals',                 # 15
    'cat_body_parts',              # 16
    'cat_clothing',                # 17
    'cat_food',                    # 18
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

# Build model
model = models.Sequential([
    layers.Input(shape=(19,)),
    layers.Dense(32, activation='relu'),
    layers.Dropout(0.3),
    layers.Dense(16, activation='relu'),
    layers.Dropout(0.2),
    layers.Dense(8, activation='relu'),
    layers.Dense(1, activation='sigmoid')
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
model.save('saved_model')
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

# Save metadata
metadata = {
    'feature_columns': feature_columns,
    'feature_count': len(feature_columns),
    'model_type': 'neural_network',
    'accuracy': float(accuracy),
    'precision': float(precision),
    'recall': float(recall),
    'f1_score': float(f1),
    'auc_roc': float(auc),
    'trained_at': datetime.now().isoformat(),
    'training_samples': int(X_train.shape[0]),
    'test_samples': int(X_test.shape[0]),
    'random_state': RANDOM_STATE,
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
print("\n✅ Model Performance:")
print(f"   - Accuracy: {accuracy:.2%}")
print(f"   - Precision: {precision:.2%}")
print(f"   - Recall: {recall:.2%}")
print(f"   - F1 Score: {f1:.2%}")
print(f"   - AUC-ROC: {auc:.2%}")
print("\n🎯 Your ML model is ready to use!")
print("="*70)



