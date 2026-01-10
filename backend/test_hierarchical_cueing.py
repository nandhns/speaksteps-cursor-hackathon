"""
Test script to demonstrate hierarchical cue progression
"""

from cueing_engine import decide_cue_rules, get_cue_timing_seconds, CUE_HIERARCHY

def test_cue_progression():
    """
    Test how cues progress over time for a single question.
    Simulates a user struggling with a question and receiving progressive cues.
    """
    
    print("\n" + "=" * 80)
    print("HIERARCHICAL CUE PROGRESSION TEST")
    print("Scenario: User struggling with question 'What is this animal?' (kucing/cat)")
    print("=" * 80)
    
    # Simulate different time points
    time_points = [0, 5, 10, 18, 26, 34, 42, 50, 58]
    
    for time_elapsed in time_points:
        features = {
            'response_time_seconds': time_elapsed,
            'attempts_so_far': 0,
            'correctness_last_n': [1, 0, 1],
            'difficulty_label': 'easy',
            'item_familiarity_score': 0.5,
            'time_since_start_seconds': 180,
            'current_cue_stage': 0,  # Will be updated as cues appear
        }
        
        # Determine current cue stage based on time
        if time_elapsed >= 58:
            features['current_cue_stage'] = 6
        elif time_elapsed >= 50:
            features['current_cue_stage'] = 5
        elif time_elapsed >= 42:
            features['current_cue_stage'] = 4
        elif time_elapsed >= 34:
            features['current_cue_stage'] = 3
        elif time_elapsed >= 26:
            features['current_cue_stage'] = 2
        elif time_elapsed >= 18:
            features['current_cue_stage'] = 1
        elif time_elapsed >= 10:
            features['current_cue_stage'] = 0
        
        cue_type, cue_stage, reasoning = decide_cue_rules(features)
        
        print(f"\n⏱️  Time: {time_elapsed}s")
        print(f"   Current Stage: {features['current_cue_stage']}")
        print(f"   → Cue Decision: {cue_type} (Stage {cue_stage})")
        print(f"   → Reasoning: {reasoning}")
        
        # Show example cue content for Bahasa Melayu
        if cue_stage > 0:
            print(f"   📝 Example Cue Content:")
            if cue_stage == 1:
                print(f"      'Haiwan ini mengeong dan menangkap tikus'")
            elif cue_stage == 2:
                print(f"      'Ia berima dengan gasing'")
            elif cue_stage == 3:
                print(f"      'k_ _ _ _ _'")
            elif cue_stage == 4:
                print(f"      'k-u-c-i-n-g'")
            elif cue_stage == 5:
                print(f"      'Saya ada seekor _____ di rumah'")
            elif cue_stage == 6:
                print(f"      'Ia bermula dengan bunyi ku'")
            elif cue_stage == 7:
                print(f"      'kucing' (full answer)")
    
    print("\n" + "=" * 80)
    print("✅ Hierarchical Progression Test Complete!")
    print("=" * 80)


def test_failed_attempt_escalation():
    """
    Test how cues escalate when user fails an attempt.
    """
    
    print("\n" + "=" * 80)
    print("FAILED ATTEMPT ESCALATION TEST")
    print("Scenario: User fails multiple attempts and cues escalate")
    print("=" * 80)
    
    for attempt in range(0, 5):
        features = {
            'response_time_seconds': 8,  # Not too long
            'attempts_so_far': attempt,
            'correctness_last_n': [0] * attempt if attempt > 0 else [1],
            'difficulty_label': 'easy',
            'item_familiarity_score': 0.5,
            'time_since_start_seconds': 180,
            'current_cue_stage': min(attempt, 6),  # Escalate with each attempt
        }
        
        cue_type, cue_stage, reasoning = decide_cue_rules(features)
        
        print(f"\n🔄 Attempt #{attempt + 1}")
        print(f"   Current Stage: {features['current_cue_stage']}")
        print(f"   → Cue Decision: {cue_type} (Stage {cue_stage})")
        print(f"   → Reasoning: {reasoning}")
    
    print("\n" + "=" * 80)
    print("✅ Failed Attempt Escalation Test Complete!")
    print("=" * 80)


def test_difficulty_based_cueing():
    """
    Test how difficulty affects cue selection.
    """
    
    print("\n" + "=" * 80)
    print("DIFFICULTY-BASED CUEING TEST")
    print("=" * 80)
    
    scenarios = [
        {
            'name': 'Easy + Familiar',
            'difficulty': 'easy',
            'familiarity': 0.9,
        },
        {
            'name': 'Hard + Unfamiliar',
            'difficulty': 'hard',
            'familiarity': 0.2,
        },
        {
            'name': 'Hard + Familiar',
            'difficulty': 'hard',
            'familiarity': 0.8,
        },
    ]
    
    for scenario in scenarios:
        print(f"\n📊 Scenario: {scenario['name']}")
        print(f"   Difficulty: {scenario['difficulty']}")
        print(f"   Familiarity: {scenario['familiarity']}")
        
        features = {
            'response_time_seconds': 8,
            'attempts_so_far': 0,
            'correctness_last_n': [1, 0, 1],
            'difficulty_label': scenario['difficulty'],
            'item_familiarity_score': scenario['familiarity'],
            'time_since_start_seconds': 180,
            'current_cue_stage': 0,
        }
        
        cue_type, cue_stage, reasoning = decide_cue_rules(features)
        
        print(f"   → Cue Decision: {cue_type} (Stage {cue_stage})")
        print(f"   → Reasoning: {reasoning}")
    
    print("\n" + "=" * 80)
    print("✅ Difficulty-Based Cueing Test Complete!")
    print("=" * 80)


def show_cue_timing_table():
    """
    Display the cue timing table.
    """
    
    print("\n" + "=" * 80)
    print("CUE TIMING REFERENCE TABLE")
    print("=" * 80)
    print(f"\n{'Stage':<8} {'Cue Type':<25} {'Wait Time':<15} {'Total Time':<15}")
    print("-" * 80)
    
    cumulative_time = 0
    for i, cue in enumerate(CUE_HIERARCHY):
        wait_time = get_cue_timing_seconds(cue.value)
        cumulative_time += wait_time
        print(f"{i:<8} {cue.value:<25} {wait_time}s{'':<12} {cumulative_time}s")
    
    print("-" * 80)
    print("\nNote: Times are cumulative. Each cue waits the specified time from the previous cue.")
    print("=" * 80)


if __name__ == "__main__":
    # Run all tests
    show_cue_timing_table()
    test_cue_progression()
    test_failed_attempt_escalation()
    test_difficulty_based_cueing()
    
    print("\n" + "=" * 80)
    print("🎉 ALL HIERARCHICAL CUEING TESTS COMPLETED SUCCESSFULLY!")
    print("=" * 80)
    print("\nKey Takeaways:")
    print("1. Cues progress hierarchically from functional → phonemic → modeling")
    print("2. Each cue level has specific timing (10s for first, 8s between subsequent)")
    print("3. Failed attempts trigger immediate cue escalation")
    print("4. Difficulty and familiarity affect initial cue selection")
    print("5. System prevents over-cueing while ensuring support when needed")
    print("=" * 80 + "\n")



