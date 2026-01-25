#!/usr/bin/env python3
"""
Test script for performance-based cue timing
Verifies that the therapist feedback (15s for low, 30s for mild) is correctly implemented
"""

from cueing_engine import calculate_performance_level, get_cue_timing_seconds, get_cue_timing_config

print("\n" + "="*70)
print("PERFORMANCE-BASED CUE TIMING - TEST CASES")
print("="*70)

# Test 1: Low performance
print("\n" + "─"*70)
print("TEST 1: Low Performance (<60% accuracy)")
print("─"*70)
low_correctness = [0, 0, 1, 0, 0, 0, 1, 0]  # 2/8 = 25%
perf = calculate_performance_level(low_correctness)
print(f"Correctness history: {low_correctness}")
print(f"Accuracy: 2/8 = 25%")
print(f"Performance Level: {perf}")
print(f"  • Functional cue:  {get_cue_timing_seconds('functional', perf)}s (expected: 15s)")
print(f"  • Rhyming cue:     {get_cue_timing_seconds('rhyming', perf)}s (expected: 15s)")
print(f"  • Written cue:     {get_cue_timing_seconds('written_initial', perf)}s (expected: 15s)")
assert perf == 'low', f"Expected 'low' performance, got '{perf}'"
assert get_cue_timing_seconds('functional', perf) == 15, "Low performance should have 15s timing"

# Test 2: Mild performance
print("\n" + "─"*70)
print("TEST 2: Mild Performance (60-80% accuracy)")
print("─"*70)
mild_correctness = [1, 0, 1, 1, 0, 1, 1, 0]  # 5/8 = 62.5%
perf = calculate_performance_level(mild_correctness)
print(f"Correctness history: {mild_correctness}")
print(f"Accuracy: 5/8 = 62.5%")
print(f"Performance Level: {perf}")
print(f"  • Functional cue:  {get_cue_timing_seconds('functional', perf)}s (expected: 30s)")
print(f"  • Rhyming cue:     {get_cue_timing_seconds('rhyming', perf)}s (expected: 30s)")
print(f"  • Written cue:     {get_cue_timing_seconds('written_initial', perf)}s (expected: 30s)")
assert perf == 'mild', f"Expected 'mild' performance, got '{perf}'"
assert get_cue_timing_seconds('functional', perf) == 30, "Mild performance should have 30s timing"

# Test 3: High performance
print("\n" + "─"*70)
print("TEST 3: High Performance (>80% accuracy)")
print("─"*70)
high_correctness = [1, 1, 1, 1, 1, 1, 1, 0]  # 7/8 = 87.5%
perf = calculate_performance_level(high_correctness)
print(f"Correctness history: {high_correctness}")
print(f"Accuracy: 7/8 = 87.5%")
print(f"Performance Level: {perf}")
print(f"  • Functional cue:  {get_cue_timing_seconds('functional', perf)}s (expected: 10s)")
print(f"  • Rhyming cue:     {get_cue_timing_seconds('rhyming', perf)}s (expected: 8s)")
print(f"  • Written cue:     {get_cue_timing_seconds('written_initial', perf)}s (expected: 8s)")
assert perf == 'high', f"Expected 'high' performance, got '{perf}'"
assert get_cue_timing_seconds('functional', perf) == 10, "High performance should have 10s timing"

# Test 4: Full timing configs
print("\n" + "─"*70)
print("TEST 4: Full Timing Configurations")
print("─"*70)
configs = {
    'low': get_cue_timing_config('low'),
    'mild': get_cue_timing_config('mild'),
    'high': get_cue_timing_config('high'),
}

for perf_level, config in configs.items():
    print(f"\n{perf_level.upper()} Performance Timing:")
    for cue_type, timing in config.items():
        print(f"  {str(cue_type).split('.')[-1]:20s}: {timing}s")

print("\n" + "="*70)
print("✅ All performance-based timing tests passed!")
print("="*70 + "\n")
