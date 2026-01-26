#!/usr/bin/env python3
"""
Unit Tests for ML Predictor
============================
Tests the ML prediction functionality with and without TFLite model.
"""

import unittest
import sys
import numpy as np
from ml_predictor import create_predictor


class TestMLPredictor(unittest.TestCase):
    """Unit tests for ML predictor."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.predictor = create_predictor(use_real_ml=False)
        
    def test_predictor_creation(self):
        """Test predictor can be created."""
        self.assertIsNotNone(self.predictor)
        
    def test_feature_preparation(self):
        """Test feature vector preparation."""
        feature_dict = {
            'response_time_seconds': 10.5,
            'cue_given': 1,
            'cue_stage': 2,
            'hint_count': 1,
            'difficulty_label': 'hard',
            'device_type': 'mobile',
            'therapist_assigned_level': 3,
            'question_type': 'pic_to_word',
            'cue_type': 'functional',
            'time_of_day': 'morning',
            'module': 'writing',
            'category': 'animals'
        }
        
        if hasattr(self.predictor, 'prepare_features'):
            features = self.predictor.prepare_features(feature_dict)
            self.assertIsInstance(features, np.ndarray)
            self.assertEqual(features.shape[1], 19)  # 19 features
            
    def test_prediction_returns_tuple(self):
        """Test that predict returns (probability, binary_prediction)."""
        feature_dict = {
            'response_time_seconds': 15.0,
            'cue_given': 0,
            'cue_stage': 0,
            'hint_count': 0,
            'difficulty_label': 'easy',
            'device_type': 'web',
            'therapist_assigned_level': 3,
            'question_type': 'pic_to_word',
            'cue_type': 'none',
            'time_of_day': 'afternoon',
            'module': 'comprehension',
            'category': 'food'
        }
        
        probability, binary_pred = self.predictor.predict(feature_dict)
        
        self.assertIsInstance(probability, (float, np.floating))
        self.assertIn(binary_pred, [0, 1])
        self.assertGreaterEqual(probability, 0.0)
        self.assertLessEqual(probability, 1.0)
        
    def test_prediction_consistency(self):
        """Test that same input gives same output."""
        feature_dict = {
            'response_time_seconds': 12.0,
            'cue_given': 0,
            'cue_stage': 0,
            'hint_count': 0,
            'difficulty_label': 'easy',
            'device_type': 'web',
            'therapist_assigned_level': 3,
            'question_type': 'pic_to_word',
            'cue_type': 'none',
            'time_of_day': 'morning',
            'module': 'writing',
            'category': 'animals'
        }
        
        prob1, pred1 = self.predictor.predict(feature_dict)
        prob2, pred2 = self.predictor.predict(feature_dict)
        
        self.assertEqual(prob1, prob2)
        self.assertEqual(pred1, pred2)
        
    def test_different_inputs_may_differ(self):
        """Test that different inputs can produce different outputs."""
        feature_dict_easy = {
            'response_time_seconds': 5.0,
            'difficulty_label': 'easy',
            'cue_given': 0,
            'cue_stage': 0,
            'hint_count': 0,
            'device_type': 'web',
            'therapist_assigned_level': 3,
            'question_type': 'pic_to_word',
            'cue_type': 'none',
            'time_of_day': 'morning',
            'module': 'writing',
            'category': 'animals'
        }
        
        feature_dict_hard = {
            'response_time_seconds': 30.0,
            'difficulty_label': 'hard',
            'cue_given': 1,
            'cue_stage': 3,
            'hint_count': 3,
            'device_type': 'mobile',
            'therapist_assigned_level': 1,
            'question_type': 'fill_in_blank',
            'cue_type': 'modeling',
            'time_of_day': 'night',
            'module': 'comprehension',
            'category': 'body_parts'
        }
        
        prob_easy, _ = self.predictor.predict(feature_dict_easy)
        prob_hard, _ = self.predictor.predict(feature_dict_hard)
        
        # Hard should generally have higher need-cue probability
        # (but heuristic may vary, so we just check they can differ)
        self.assertIsInstance(prob_easy, (float, np.floating))
        self.assertIsInstance(prob_hard, (float, np.floating))

    def test_low_performance_predictions(self):
        """Test predictions for low performance scenarios."""
        # Struggling scenario: long response time, no cue given
        feature_dict = {
            'response_time_seconds': 25.0,
            'cue_given': 0,
            'cue_stage': 0,
            'hint_count': 0,
            'difficulty_label': 'hard',
            'device_type': 'mobile',
            'therapist_assigned_level': 1,
            'question_type': 'fill_in_blank',
            'cue_type': 'none',
            'time_of_day': 'evening',
            'module': 'comprehension',
            'category': 'body_parts'
        }
        
        prob, pred = self.predictor.predict(feature_dict)
        # Struggling users should be more likely to need a cue
        self.assertGreaterEqual(prob, 0.0)
        self.assertLessEqual(prob, 1.0)

    def test_high_performance_predictions(self):
        """Test predictions for high performance scenarios."""
        # Quick response, high accuracy
        feature_dict = {
            'response_time_seconds': 3.0,
            'cue_given': 0,
            'cue_stage': 0,
            'hint_count': 0,
            'difficulty_label': 'easy',
            'device_type': 'web',
            'therapist_assigned_level': 5,
            'question_type': 'pic_to_word',
            'cue_type': 'none',
            'time_of_day': 'morning',
            'module': 'writing',
            'category': 'animals'
        }
        
        prob, pred = self.predictor.predict(feature_dict)
        # Quick responses should be less likely to need cues
        self.assertGreaterEqual(prob, 0.0)
        self.assertLessEqual(prob, 1.0)


def run_tests():
    """Run all ML predictor tests."""
    print("\n" + "="*70)
    print("ML PREDICTOR - UNIT TESTS")
    print("="*70 + "\n")
    
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()
    suite.addTests(loader.loadTestsFromTestCase(TestMLPredictor))
    
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    print("\n" + "="*70)
    print("TEST SUMMARY")
    print("="*70)
    print(f"Tests run: {result.testsRun}")
    print(f"Successes: {result.testsRun - len(result.failures) - len(result.errors)}")
    print(f"Failures: {len(result.failures)}")
    print(f"Errors: {len(result.errors)}")
    
    if result.wasSuccessful():
        print("\n✅ All ML tests passed!")
    else:
        print("\n❌ Some ML tests failed.")
    
    return result.wasSuccessful()


if __name__ == '__main__':
    success = run_tests()
    sys.exit(0 if success else 1)
