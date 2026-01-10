"""
Real TFLite ML Predictor for SpeakSteps
========================================
Loads and runs inference with the trained TFLite model.
"""

import numpy as np
import os
from typing import Dict, Tuple

try:
    import tensorflow as tf
    TFLITE_AVAILABLE = True
except ImportError:
    TFLITE_AVAILABLE = False
    print("⚠️  TensorFlow not available. Using fallback predictor.")

try:
    import joblib
    JOBLIB_AVAILABLE = True
except ImportError:
    JOBLIB_AVAILABLE = False
    print("⚠️  Joblib not available. Scaler will not be loaded.")


class MLCuePredictor:
    """Real ML-based cue predictor using TFLite model."""
    
    def __init__(self, model_path='models/model.tflite', scaler_path='models/model.joblib'):
        self.model_path = model_path
        self.scaler_path = scaler_path
        self.interpreter = None
        self.scaler = None
        self.input_details = None
        self.output_details = None
        self.is_loaded = False
        
        # Feature order (must match training)
        self.feature_columns = [
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
    
    def load_model(self) -> bool:
        """Load the TFLite model and scaler."""
        if not TFLITE_AVAILABLE:
            print("❌ TensorFlow not available. Cannot load TFLite model.")
            return False
        
        # Check if model file exists
        if not os.path.exists(self.model_path):
            print(f"❌ Model file not found: {self.model_path}")
            return False
        
        try:
            # Load TFLite model
            self.interpreter = tf.lite.Interpreter(model_path=self.model_path)
            self.interpreter.allocate_tensors()
            
            self.input_details = self.interpreter.get_input_details()
            self.output_details = self.interpreter.get_output_details()
            
            print(f"✅ Loaded TFLite model from {self.model_path}")
            
            # Load scaler if available
            if JOBLIB_AVAILABLE and os.path.exists(self.scaler_path):
                loaded_obj = joblib.load(self.scaler_path)
                # Check if it's a scaler or a model dict
                if hasattr(loaded_obj, 'transform'):
                    self.scaler = loaded_obj
                    print(f"✅ Loaded scaler from {self.scaler_path}")
                elif isinstance(loaded_obj, dict) and 'scaler' in loaded_obj:
                    self.scaler = loaded_obj['scaler']
                    print(f"✅ Loaded scaler from {self.scaler_path}")
                else:
                    print(f"⚠️  Loaded object is not a scaler: {type(loaded_obj)}")
                    self.scaler = None
            else:
                print("⚠️  Scaler not loaded. Features will not be normalized.")
            
            self.is_loaded = True
            return True
            
        except Exception as e:
            print(f"❌ Error loading model: {e}")
            return False
    
    def prepare_features(self, feature_dict: Dict) -> np.ndarray:
        """
        Prepare feature vector from input dictionary.
        
        Args:
            feature_dict: Dictionary with input features
            
        Returns:
            Numpy array of shape (1, 19) ready for inference
        """
        # Extract and encode features
        features = []
        
        # 0. response_time_seconds
        features.append(feature_dict.get('response_time_seconds', 0.0))
        
        # 1. cue_given
        features.append(1 if feature_dict.get('cue_given', 0) > 0 else 0)
        
        # 2. cue_stage
        features.append(feature_dict.get('cue_stage', 0))
        
        # 3. hint_count
        features.append(feature_dict.get('hint_count', 0))
        
        # 4. difficulty_flag
        difficulty = feature_dict.get('difficulty_label', 'easy')
        features.append(1 if difficulty == 'hard' else 0)
        
        # 5. device_mobile_flag
        device = feature_dict.get('device_type', 'web')
        features.append(1 if device == 'mobile' else 0)
        
        # 6. therapist_assigned_level
        features.append(feature_dict.get('therapist_assigned_level', 3))
        
        # 7. question_type_encoded
        question_type_map = {
            'pic_to_word': 0,
            'word_to_pic': 1,
            'fill_in_blank': 2,
            'audio_to_pic': 3
        }
        q_type = feature_dict.get('question_type', 'pic_to_word')
        features.append(question_type_map.get(q_type, 0))
        
        # 8. cue_type_encoded
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
        c_type = feature_dict.get('cue_type', 'none')
        features.append(cue_type_map.get(c_type, 0))
        
        # 9-12. time_of_day (one-hot)
        time_of_day = feature_dict.get('time_of_day', 'morning')
        features.append(1 if time_of_day == 'morning' else 0)
        features.append(1 if time_of_day == 'afternoon' else 0)
        features.append(1 if time_of_day == 'evening' else 0)
        features.append(1 if time_of_day == 'night' else 0)
        
        # 13-14. module (one-hot)
        module = feature_dict.get('module', 'writing')
        features.append(1 if module == 'comprehension' else 0)
        features.append(1 if module == 'writing' else 0)
        
        # 15-18. category (one-hot)
        category = feature_dict.get('category', 'animals')
        features.append(1 if category == 'animals' else 0)
        features.append(1 if category == 'body_parts' else 0)
        features.append(1 if category == 'clothing' else 0)
        features.append(1 if category == 'food' else 0)
        
        # Convert to numpy array
        feature_array = np.array(features, dtype=np.float32).reshape(1, -1)
        
        # Apply scaler if available
        if self.scaler is not None:
            feature_array = self.scaler.transform(feature_array)
        
        return feature_array
    
    def predict(self, feature_dict: Dict) -> Tuple[float, int]:
        """
        Predict whether user needs a cue.
        
        Args:
            feature_dict: Dictionary with input features
            
        Returns:
            Tuple of (probability, binary_prediction)
            - probability: float between 0 and 1
            - binary_prediction: 0 (no cue) or 1 (need cue)
        """
        if not self.is_loaded:
            raise RuntimeError("Model not loaded. Call load_model() first.")
        
        # Prepare features
        features = self.prepare_features(feature_dict)
        
        # Set input tensor
        self.interpreter.set_tensor(
            self.input_details[0]['index'],
            features.astype(np.float32)
        )
        
        # Run inference
        self.interpreter.invoke()
        
        # Get output
        probability = self.interpreter.get_tensor(
            self.output_details[0]['index']
        )[0][0]
        
        # Binary prediction (threshold = 0.5)
        binary_prediction = 1 if probability > 0.5 else 0
        
        return float(probability), int(binary_prediction)


# ============================================================================
# Fallback Mock Predictor (if TFLite not available)
# ============================================================================

class MockCuePredictor:
    """Fallback rule-based predictor when TFLite is not available."""
    
    def __init__(self, model_path=None, scaler_path=None):
        self.is_loaded = False
    
    def load_model(self) -> bool:
        """Mock load."""
        self.is_loaded = True
        print("⚠️  Using mock predictor (TFLite not available)")
        return True
    
    def predict(self, feature_dict: Dict) -> Tuple[float, int]:
        """Simple rule-based prediction."""
        prob = 0.0
        
        response_time = feature_dict.get('response_time_seconds', 0)
        difficulty = feature_dict.get('difficulty_label', 'easy')
        cue_given = feature_dict.get('cue_given', 0)
        hint_count = feature_dict.get('hint_count', 0)
        
        # Response time factor
        if response_time > 30:
            prob += 0.45
        elif response_time > 20:
            prob += 0.25
        elif response_time > 15:
            prob += 0.15
        elif response_time > 10:
            prob += 0.08
        
        # Difficulty factor
        if difficulty == 'hard':
            prob += 0.15
        
        # Cue history
        if cue_given:
            prob += 0.05 + (hint_count * 0.03)
        
        prob = min(max(prob, 0.0), 1.0)
        binary = 1 if prob > 0.5 else 0
        
        return prob, binary


# ============================================================================
# Factory Function
# ============================================================================

def create_predictor(use_real_ml=True) -> MLCuePredictor:
    """
    Create appropriate predictor based on availability.
    
    Args:
        use_real_ml: If True, try to use real TFLite model
        
    Returns:
        Predictor instance (real or mock)
    """
    if use_real_ml and TFLITE_AVAILABLE:
        predictor = MLCuePredictor()
        if predictor.load_model():
            return predictor
    
    # Fallback to mock
    predictor = MockCuePredictor()
    predictor.load_model()
    return predictor


# ============================================================================
# Test Function
# ============================================================================

if __name__ == "__main__":
    print("="*70)
    print("Testing ML Cue Predictor")
    print("="*70)
    
    # Create predictor
    predictor = create_predictor(use_real_ml=True)
    
    # Test cases
    test_cases = [
        {
            'name': 'Quick correct response',
            'features': {
                'response_time_seconds': 5.0,
                'cue_given': 0,
                'cue_stage': 0,
                'hint_count': 0,
                'difficulty_label': 'easy',
                'device_type': 'mobile',
                'therapist_assigned_level': 3,
                'question_type': 'pic_to_word',
                'cue_type': 'none',
                'time_of_day': 'morning',
                'module': 'writing',
                'category': 'animals',
            }
        },
        {
            'name': 'Slow response on hard item',
            'features': {
                'response_time_seconds': 35.0,
                'cue_given': 0,
                'cue_stage': 0,
                'hint_count': 0,
                'difficulty_label': 'hard',
                'device_type': 'web',
                'therapist_assigned_level': 3,
                'question_type': 'pic_to_word',
                'cue_type': 'none',
                'time_of_day': 'evening',
                'module': 'writing',
                'category': 'body_parts',
            }
        },
        {
            'name': 'Already received cues',
            'features': {
                'response_time_seconds': 15.0,
                'cue_given': 1,
                'cue_stage': 2,
                'hint_count': 2,
                'difficulty_label': 'easy',
                'device_type': 'mobile',
                'therapist_assigned_level': 2,
                'question_type': 'word_to_pic',
                'cue_type': 'rhyming',
                'time_of_day': 'afternoon',
                'module': 'comprehension',
                'category': 'food',
            }
        },
    ]
    
    print("\n🧪 Running test cases...\n")
    for i, test in enumerate(test_cases, 1):
        print(f"Test {i}: {test['name']}")
        prob, prediction = predictor.predict(test['features'])
        print(f"  Probability: {prob:.4f}")
        print(f"  Prediction: {'Need Cue' if prediction == 1 else 'No Cue'}")
        print()
    
    print("="*70)
    print("✅ Testing complete!")
    print("="*70)

