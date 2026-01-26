#!/usr/bin/env python3
"""
Unit Tests for SpeakSteps Cueing Engine
========================================
Tests the cueing decision logic, timing calculations, and performance levels.
"""

import unittest
import sys
from cueing_engine import (
    decide_cue_rules,
    calculate_performance_level,
    get_cue_timing_seconds,
    get_cue_timing_config,
    CueType,
    CUE_HIERARCHY
)


class TestCueingEngine(unittest.TestCase):
    """Unit tests for cueing engine logic."""
    
    def test_performance_level_low(self):
        """Test low performance detection (<60%)."""
        correctness = [0, 0, 1, 0, 0, 0, 1, 0]  # 25% accuracy
        level = calculate_performance_level(correctness)
        self.assertEqual(level, 'low')
        
    def test_performance_level_mild(self):
        """Test mild performance detection (60-80%)."""
        correctness = [1, 0, 1, 1, 0, 1, 1, 0]  # 62.5% accuracy
        level = calculate_performance_level(correctness)
        self.assertEqual(level, 'mild')
        
    def test_performance_level_high(self):
        """Test high performance detection (>80%)."""
        correctness = [1, 1, 1, 1, 1, 1, 1, 0]  # 87.5% accuracy
        level = calculate_performance_level(correctness)
        self.assertEqual(level, 'high')
        
    def test_performance_level_empty(self):
        """Test empty correctness history defaults to high."""
        level = calculate_performance_level([])
        self.assertEqual(level, 'high')
        
    def test_cue_timing_low_performance(self):
        """Test 15s timing for low performers."""
        timing = get_cue_timing_seconds('functional', 'low')
        self.assertEqual(timing, 15)
        timing = get_cue_timing_seconds('rhyming', 'low')
        self.assertEqual(timing, 15)
        
    def test_cue_timing_mild_performance(self):
        """Test 30s timing for mild performers."""
        timing = get_cue_timing_seconds('functional', 'mild')
        self.assertEqual(timing, 30)
        timing = get_cue_timing_seconds('rhyming', 'mild')
        self.assertEqual(timing, 30)
        
    def test_cue_timing_high_performance(self):
        """Test faster timing for high performers."""
        timing = get_cue_timing_seconds('functional', 'high')
        self.assertEqual(timing, 10)
        timing = get_cue_timing_seconds('rhyming', 'high')
        self.assertEqual(timing, 8)
        
    def test_cue_hierarchy_order(self):
        """Test cue hierarchy is correctly ordered."""
        self.assertEqual(CUE_HIERARCHY[0], CueType.NO_CUE)
        self.assertEqual(CUE_HIERARCHY[1], CueType.FUNCTIONAL)
        self.assertEqual(CUE_HIERARCHY[7], CueType.MODELING)
        
    def test_decide_cue_no_cue_needed(self):
        """Test decision when no cue is needed (quick response)."""
        features = {
            'response_time_seconds': 3,
            'attempts_so_far': 0,
            'correctness_last_n': [1, 1, 1],
            'difficulty_label': 'easy',
            'item_familiarity_score': 0.8,
            'time_since_start_seconds': 60,
            'current_cue_stage': 0,
        }
        cue_type, cue_stage, reasoning = decide_cue_rules(features)
        self.assertEqual(cue_type, 'no_cue')
        self.assertEqual(cue_stage, 0)
        
    def test_decide_cue_functional_needed(self):
        """Test decision when functional cue is needed."""
        features = {
            'response_time_seconds': 12,
            'attempts_so_far': 0,
            'correctness_last_n': [1, 0, 1],
            'difficulty_label': 'easy',
            'item_familiarity_score': 0.5,
            'time_since_start_seconds': 120,
            'current_cue_stage': 0,
        }
        cue_type, cue_stage, reasoning = decide_cue_rules(features)
        self.assertEqual(cue_stage, 1)
        
    def test_decide_cue_escalation(self):
        """Test cue escalation with failed attempts."""
        for attempt in range(1, 4):
            features = {
                'response_time_seconds': 8,
                'attempts_so_far': attempt,
                'correctness_last_n': [0] * attempt,
                'difficulty_label': 'easy',
                'item_familiarity_score': 0.5,
                'time_since_start_seconds': 180,
                'current_cue_stage': attempt - 1,
            }
            cue_type, cue_stage, reasoning = decide_cue_rules(features)
            self.assertGreaterEqual(cue_stage, attempt)
            
    def test_cue_config_completeness(self):
        """Test all performance levels have complete timing configs."""
        for perf_level in ['low', 'mild', 'high']:
            config = get_cue_timing_config(perf_level)
            self.assertIsInstance(config, dict)
            self.assertGreater(len(config), 0)


class TestCueProgression(unittest.TestCase):
    """Integration tests for cue progression scenarios."""
    
    def test_struggling_user_progression(self):
        """Test full cue progression for struggling user."""
        time_points = [0, 15, 30, 45, 60, 75, 90]
        expected_stages = [0, 1, 2, 3, 4, 5, 6]
        
        for time_elapsed, expected_stage in zip(time_points, expected_stages):
            features = {
                'response_time_seconds': time_elapsed,
                'attempts_so_far': 0,
                'correctness_last_n': [0, 0, 0, 0],
                'difficulty_label': 'hard',
                'item_familiarity_score': 0.3,
                'time_since_start_seconds': 180,
                'current_cue_stage': expected_stage - 1 if expected_stage > 0 else 0,
            }
            _, cue_stage, _ = decide_cue_rules(features)
            self.assertGreaterEqual(cue_stage, expected_stage - 1)
            
    def test_quick_response_no_cues(self):
        """Test that quick responses don't trigger cues."""
        for time_elapsed in [2, 4, 6]:
            features = {
                'response_time_seconds': time_elapsed,
                'attempts_so_far': 0,
                'correctness_last_n': [1, 1, 1],
                'difficulty_label': 'easy',
                'item_familiarity_score': 0.9,
                'time_since_start_seconds': 60,
                'current_cue_stage': 0,
            }
            cue_type, cue_stage, _ = decide_cue_rules(features)
            self.assertEqual(cue_stage, 0)


def run_tests():
    """Run all tests with detailed output."""
    print("\n" + "="*70)
    print("SPEAKSTEPS CUEING ENGINE - UNIT TESTS")
    print("="*70 + "\n")
    
    # Create test suite
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()
    
    # Add all test classes
    suite.addTests(loader.loadTestsFromTestCase(TestCueingEngine))
    suite.addTests(loader.loadTestsFromTestCase(TestCueProgression))
    
    # Run tests with verbose output
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    # Print summary
    print("\n" + "="*70)
    print("TEST SUMMARY")
    print("="*70)
    print(f"Tests run: {result.testsRun}")
    print(f"Successes: {result.testsRun - len(result.failures) - len(result.errors)}")
    print(f"Failures: {len(result.failures)}")
    print(f"Errors: {len(result.errors)}")
    
    if result.wasSuccessful():
        print("\n✅ All tests passed!")
    else:
        print("\n❌ Some tests failed.")
    
    return result.wasSuccessful()


if __name__ == '__main__':
    success = run_tests()
    sys.exit(0 if success else 1)
