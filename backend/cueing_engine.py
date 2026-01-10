"""
SpeakSteps Hybrid Cueing Decision Engine
=========================================
A rule-based + ML hybrid system for adaptive cue delivery in Broca's aphasia therapy.

Cue Types (ordered by support level):
    0. no_cue              - No assistance needed
    1. functional          - Describes item's function/use
    2. rhyming             - Provides a rhyming word hint
    3. sentence_completion - Item in sentence context
    4. written_initial     - Shows first letter(s)
    5. spelling            - Spelling hints/breakdown
    6. phonemic            - Sound/phoneme cue
    7. modeling            - Full model of correct answer

Cue Stages: 0 (no cue) to 7 (maximum support)
"""

from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass
from enum import Enum
import numpy as np


# =============================================================================
# CONSTANTS & ENUMS
# =============================================================================

class CueType(Enum):
    NO_CUE = "no_cue"
    FUNCTIONAL = "functional"
    RHYMING = "rhyming"
    WRITTEN_INITIAL = "written_initial"
    SPELLING = "spelling"
    SENTENCE_COMPLETION = "sentence_completion"
    PHONEMIC = "phonemic"
    MODELING = "modeling"


# Cue hierarchy (lower index = less support)
# Based on therapeutic hierarchy: Function → Rhyme → Written → Spelling → Sentence → Phonemic → Model
CUE_HIERARCHY = [
    CueType.NO_CUE,           # 0 - No assistance
    CueType.FUNCTIONAL,       # 1 - "you use this to buy things"
    CueType.RHYMING,          # 2 - "it rhymes with honey"
    CueType.WRITTEN_INITIAL,  # 3 - "m _ _ _ _"
    CueType.SPELLING,         # 4 - "m-o-n-e-y"
    CueType.SENTENCE_COMPLETION,  # 5 - "I need to earn some ______"
    CueType.PHONEMIC,         # 6 - "It starts with muh..."
    CueType.MODELING,         # 7 - Full word "money"
]

# Timing for each cue level (in seconds from start or previous cue)
CUE_TIMING = {
    CueType.NO_CUE: 0,
    CueType.FUNCTIONAL: 10,       # Show after 10 seconds
    CueType.RHYMING: 8,           # Show 8 seconds after function cue
    CueType.WRITTEN_INITIAL: 8,   # Show 8 seconds after rhyming cue
    CueType.SPELLING: 8,          # Show 8 seconds after written cue
    CueType.SENTENCE_COMPLETION: 8,  # Show 8 seconds after spelling
    CueType.PHONEMIC: 8,          # Show 8 seconds after sentence
    CueType.MODELING: 8,          # Show 8 seconds after phonemic
}

CUE_TYPE_TO_STAGE = {cue: idx for idx, cue in enumerate(CUE_HIERARCHY)}


# =============================================================================
# FEATURE DICT TYPE
# =============================================================================

@dataclass
class FeatureDict:
    """Input features for cueing decision."""
    response_time_seconds: float
    attempts_so_far: int
    correctness_last_n: List[int]  # List of 0/1, most recent last
    difficulty_label: str  # "easy" or "hard"
    item_familiarity_score: float  # 0-1
    time_since_start_seconds: float


# =============================================================================
# ML PREDICTION FUNCTION
# =============================================================================

# Try to import real ML predictor
try:
    from ml_predictor import create_predictor
    _ml_predictor = create_predictor(use_real_ml=True)
    ML_AVAILABLE = True
except Exception as e:
    print(f"⚠️  ML predictor not available: {e}")
    _ml_predictor = None
    ML_AVAILABLE = False


def ml_predict_need_cue(features: Dict) -> int:
    """
    ML prediction function using trained TFLite model.
    Falls back to rule-based heuristic if ML not available.
    
    Args:
        features: Dictionary of input features
        
    Returns:
        0 (no cue needed) or 1 (cue needed)
    """
    # Test override flags for demonstration/testing
    if features.get('_force_ml_cue'):
        return 1
    if features.get('_force_ml_no_cue'):
        return 0
    
    # Try to use real ML model
    if ML_AVAILABLE and _ml_predictor is not None:
        try:
            # Prepare features for ML model
            ml_features = {
                'response_time_seconds': features.get('response_time_seconds', 0),
                'cue_given': 1 if features.get('attempts_so_far', 0) > 0 else 0,
                'cue_stage': features.get('current_cue_stage', 0),
                'hint_count': features.get('attempts_so_far', 0),
                'difficulty_label': features.get('difficulty_label', 'easy'),
                'device_type': 'mobile' if features.get('is_mobile', False) else 'web',
                'therapist_assigned_level': features.get('therapist_level', 3),
                'question_type': features.get('question_type', 'pic_to_word'),
                'cue_type': features.get('cue_type', 'none'),
                'time_of_day': features.get('time_of_day', 'morning'),
                'module': features.get('module', 'writing'),
                'category': features.get('category', 'animals'),
            }
            
            # Get ML prediction
            probability, binary_prediction = _ml_predictor.predict(ml_features)
            return binary_prediction
            
        except Exception as e:
            print(f"⚠️  ML prediction error: {e}, falling back to heuristic")
    
    # Fallback: Simple heuristic mimicking ML model behavior
    response_time = features.get('response_time_seconds', 0)
    attempts = features.get('attempts_so_far', 0)
    correctness = features.get('correctness_last_n', [])
    difficulty = features.get('difficulty_label', 'easy')
    familiarity = features.get('item_familiarity_score', 0.5)
    
    # Calculate a simple "need cue" probability
    prob = 0.0
    
    # Response time factor
    if response_time > 30:
        prob += 0.4
    elif response_time > 15:
        prob += 0.2
    
    # Attempts factor
    prob += min(attempts * 0.15, 0.3)
    
    # Recent correctness factor
    if correctness:
        recent_accuracy = sum(correctness[-3:]) / len(correctness[-3:])
        prob += (1 - recent_accuracy) * 0.3
    
    # Difficulty factor
    if difficulty == "hard":
        prob += 0.1
    
    # Familiarity factor
    prob += (1 - familiarity) * 0.2
    
    # Threshold decision
    return 1 if prob >= 0.5 else 0


# =============================================================================
# RULE-BASED CUEING LOGIC
# =============================================================================

def get_last_correctness(correctness_last_n: List[int]) -> Optional[int]:
    """Get the most recent correctness value."""
    if correctness_last_n:
        return correctness_last_n[-1]
    return None


def get_recent_accuracy(correctness_last_n: List[int], n: int = 3) -> float:
    """Calculate accuracy over the last n attempts."""
    if not correctness_last_n:
        return 1.0  # Assume good if no history
    recent = correctness_last_n[-n:]
    return sum(recent) / len(recent)


def decide_cue_rules(feature_dict: Dict) -> Tuple[str, int, str]:
    """
    Rule-based cueing decision logic with hierarchical progression.
    
    Hierarchy: Function → Rhyme → Written → Spelling → Sentence → Phonemic → Model
    
    Args:
        feature_dict: Dictionary with input features
        
    Returns:
        Tuple of (cue_type, cue_stage, reasoning)
    """
    # Extract features
    response_time = feature_dict.get('response_time_seconds', 0)
    attempts = feature_dict.get('attempts_so_far', 0)
    correctness = feature_dict.get('correctness_last_n', [])
    difficulty = feature_dict.get('difficulty_label', 'easy')
    familiarity = feature_dict.get('item_familiarity_score', 0.5)
    time_since_start = feature_dict.get('time_since_start_seconds', 0)
    current_cue_stage = feature_dict.get('current_cue_stage', 0)  # Track current cue level
    
    last_correct = get_last_correctness(correctness)
    recent_accuracy = get_recent_accuracy(correctness)
    
    # =========================================================================
    # RULE 1: Quick correct response → No cue needed
    # =========================================================================
    if response_time < 6 and last_correct == 1:
        return (CueType.NO_CUE.value, 0, "Quick correct response - no cue needed")
    
    # =========================================================================
    # RULE 2: Progressive cue escalation based on response time
    # Wait 10 seconds → Function cue
    # Wait 18 seconds total (10 + 8) → Rhyme cue
    # Wait 26 seconds total (10 + 8 + 8) → Written cue
    # And so on...
    # =========================================================================
    if response_time >= 10 and current_cue_stage == 0:
        return (CueType.FUNCTIONAL.value, 1, "10+ seconds - start with functional cue")
    
    if response_time >= 18 and current_cue_stage == 1:
        return (CueType.RHYMING.value, 2, "18+ seconds - escalate to rhyming cue")
    
    if response_time >= 26 and current_cue_stage == 2:
        return (CueType.WRITTEN_INITIAL.value, 3, "26+ seconds - escalate to written cue")
    
    if response_time >= 34 and current_cue_stage == 3:
        return (CueType.SPELLING.value, 4, "34+ seconds - escalate to spelling cue")
    
    if response_time >= 42 and current_cue_stage == 4:
        return (CueType.SENTENCE_COMPLETION.value, 5, "42+ seconds - escalate to sentence completion")
    
    if response_time >= 50 and current_cue_stage == 5:
        return (CueType.PHONEMIC.value, 6, "50+ seconds - escalate to phonemic cue")
    
    if response_time >= 58 and current_cue_stage == 6:
        return (CueType.MODELING.value, 7, "58+ seconds - provide full model")
    
    # =========================================================================
    # RULE 3: Failed attempts → Start or escalate cue hierarchy
    # =========================================================================
    if attempts >= 1 and last_correct == 0:
        if current_cue_stage == 0:
            return (CueType.FUNCTIONAL.value, 1, "Failed attempt - start with functional cue")
        else:
            # Escalate to next level
            next_cue, next_stage = get_next_cue_level(current_cue_stage)
            return (next_cue, next_stage, f"Failed attempt - escalate to stage {next_stage}")
    
    # =========================================================================
    # RULE 4: Hard item with low familiarity → Start with stronger cue
    # =========================================================================
    if difficulty == "hard" and familiarity < 0.3 and current_cue_stage == 0:
        return (CueType.WRITTEN_INITIAL.value, 3, "Hard unfamiliar item - skip to written cue")
    
    # =========================================================================
    # RULE 5: Moderate difficulty with struggle
    # =========================================================================
    if recent_accuracy < 0.5 and current_cue_stage == 0:
        return (CueType.FUNCTIONAL.value, 1, "Low recent accuracy - provide functional cue")
    
    if recent_accuracy < 0.7 and response_time > 10 and current_cue_stage == 0:
        return (CueType.FUNCTIONAL.value, 1, "Moderate struggle - provide functional cue")
    
    # =========================================================================
    # RULE 6: Session fatigue → More supportive cues
    # =========================================================================
    if time_since_start > 900 and response_time > 8 and current_cue_stage == 0:
        return (CueType.FUNCTIONAL.value, 1, "Session fatigue - provide early support")
    
    # =========================================================================
    # DEFAULT: No cue needed (or maintain current level)
    # =========================================================================
    if current_cue_stage > 0:
        # Already showing a cue, maintain it
        current_cue_type = CUE_HIERARCHY[current_cue_stage]
        return (current_cue_type.value, current_cue_stage, "Maintaining current cue level")
    
    return (CueType.NO_CUE.value, 0, "No cue needed yet")


# =============================================================================
# MAIN CUEING FUNCTION (Rule-Based Only)
# =============================================================================

def decide_cue(feature_dict: Dict) -> Tuple[str, int]:
    """
    Determine the appropriate cue type and stage based on rules.
    
    Args:
        feature_dict: Dictionary containing:
            - response_time_seconds: float
            - attempts_so_far: int
            - correctness_last_n: List[int] (0/1 values)
            - difficulty_label: str ("easy" or "hard")
            - item_familiarity_score: float (0-1)
            - time_since_start_seconds: float
            
    Returns:
        Tuple of (cue_type, cue_stage)
        - cue_type: str from CueType enum values
        - cue_stage: int from 0 to 7
    """
    cue_type, cue_stage, _ = decide_cue_rules(feature_dict)
    return (cue_type, cue_stage)


# =============================================================================
# HYBRID CUEING FUNCTION (Rules + ML)
# =============================================================================

def decide_cue_hybrid(feature_dict: Dict) -> Dict:
    """
    Hybrid cueing decision combining rule-based logic with ML predictions.
    
    Safety-first approach:
    - If ML says "need cue" AND rules say "no_cue" → choose minimal cue (conservative)
    - If ML says "no_cue" AND rules say "need cue" → follow rules (safety-first)
    - Otherwise follow rule-based normally
    
    Args:
        feature_dict: Dictionary containing input features
        
    Returns:
        Dictionary with:
            - cue_type: str
            - cue_stage: int  
            - source: 'rule' | 'ml' | 'hybrid'
            - reasoning: str (explanation)
            - ml_prediction: int (0 or 1)
            - rule_cue_type: str
            - rule_cue_stage: int
    """
    # Get rule-based decision
    rule_cue_type, rule_cue_stage, rule_reasoning = decide_cue_rules(feature_dict)
    
    # Get ML prediction
    ml_prediction = ml_predict_need_cue(feature_dict)
    ml_needs_cue = (ml_prediction == 1)
    
    # Determine if rules think cue is needed
    rules_need_cue = (rule_cue_type != CueType.NO_CUE.value)
    
    # Initialize result
    result = {
        'ml_prediction': ml_prediction,
        'rule_cue_type': rule_cue_type,
        'rule_cue_stage': rule_cue_stage,
        'rule_reasoning': rule_reasoning,
    }
    
    # =========================================================================
    # HYBRID DECISION LOGIC
    # =========================================================================
    
    # Case 1: Agreement - both say no cue
    if not ml_needs_cue and not rules_need_cue:
        result.update({
            'cue_type': CueType.NO_CUE.value,
            'cue_stage': 0,
            'source': 'rule',
            'reasoning': f"Agreement: No cue needed. {rule_reasoning}"
        })
    
    # Case 2: Agreement - both say cue needed
    elif ml_needs_cue and rules_need_cue:
        result.update({
            'cue_type': rule_cue_type,
            'cue_stage': rule_cue_stage,
            'source': 'rule',
            'reasoning': f"Agreement: {rule_reasoning}"
        })
    
    # Case 3: ML says cue needed, rules say no cue → Conservative: minimal cue
    elif ml_needs_cue and not rules_need_cue:
        result.update({
            'cue_type': CueType.FUNCTIONAL.value,
            'cue_stage': 1,
            'source': 'hybrid',
            'reasoning': f"ML override: ML predicts cue needed, providing minimal support (functional)"
        })
    
    # Case 4: ML says no cue, rules say cue needed → Safety-first: follow rules
    elif not ml_needs_cue and rules_need_cue:
        result.update({
            'cue_type': rule_cue_type,
            'cue_stage': rule_cue_stage,
            'source': 'hybrid',
            'reasoning': f"Safety-first: Following rules despite ML disagreement. {rule_reasoning}"
        })
    
    return result


# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

def get_cue_description(cue_type: str) -> str:
    """Get human-readable description of a cue type."""
    descriptions = {
        'no_cue': "No assistance provided",
        'functional': "Describes what the item is used for (e.g., 'you use this to buy things')",
        'rhyming': "Provides a word that rhymes with the target (e.g., 'it rhymes with honey')",
        'written_initial': "Shows first letter(s) with blanks (e.g., 'm _ _ _ _')",
        'spelling': "Word spelled out letter by letter (e.g., 'm-o-n-e-y')",
        'sentence_completion': "Target word in a sentence context (e.g., 'I need to earn some ______')",
        'phonemic': "Provides the initial sound/syllable (e.g., 'It starts with muh...')",
        'modeling': "Full model of the correct answer (e.g., 'money')",
    }
    return descriptions.get(cue_type, "Unknown cue type")


def get_next_cue_level(current_stage: int) -> Tuple[str, int]:
    """
    Get the next cue level in the hierarchy.
    
    Args:
        current_stage: Current cue stage (0-7)
        
    Returns:
        Tuple of (cue_type, cue_stage) for the next level
    """
    if current_stage >= len(CUE_HIERARCHY) - 1:
        # Already at maximum support
        return (CueType.MODELING.value, len(CUE_HIERARCHY) - 1)
    
    next_stage = current_stage + 1
    next_cue_type = CUE_HIERARCHY[next_stage]
    return (next_cue_type.value, next_stage)


def get_cue_timing_seconds(cue_type: str) -> int:
    """
    Get the recommended timing (in seconds) for when to show this cue level.
    
    Args:
        cue_type: The cue type string
        
    Returns:
        Number of seconds to wait before showing this cue
    """
    try:
        cue_enum = CueType(cue_type)
        return CUE_TIMING.get(cue_enum, 10)  # Default to 10 seconds
    except ValueError:
        return 10  # Default fallback


def format_decision_result(result: Dict) -> str:
    """Format hybrid decision result for display."""
    lines = [
        "=" * 60,
        "CUEING DECISION RESULT",
        "=" * 60,
        f"Cue Type:    {result['cue_type']}",
        f"Cue Stage:   {result['cue_stage']}",
        f"Source:      {result['source']}",
        f"Reasoning:   {result['reasoning']}",
        "-" * 60,
        f"ML Prediction:     {'Cue needed' if result['ml_prediction'] == 1 else 'No cue'}",
        f"Rule Cue Type:     {result['rule_cue_type']}",
        f"Rule Cue Stage:    {result['rule_cue_stage']}",
        "=" * 60,
    ]
    return "\n".join(lines)


# =============================================================================
# TEST CASES
# =============================================================================

def run_test_cases():
    """Run 6 example test cases demonstrating the hybrid cueing engine."""
    
    print("\n" + "=" * 70)
    print("SPEAKSTEPS HYBRID CUEING ENGINE - TEST CASES")
    print("=" * 70)
    
    test_cases = [
        # =====================================================================
        # TEST 1: Easy item, good performance
        # =====================================================================
        {
            'name': "Test 1: Easy item, good performance",
            'description': "User answers quickly and correctly on an easy, familiar item",
            'features': {
                'response_time_seconds': 4.5,
                'attempts_so_far': 0,
                'correctness_last_n': [1, 1, 1, 1],
                'difficulty_label': 'easy',
                'item_familiarity_score': 0.85,
                'time_since_start_seconds': 120,
            },
            'expected_cue': 'no_cue',
        },
        
        # =====================================================================
        # TEST 2: Slow response
        # =====================================================================
        {
            'name': "Test 2: Slow response",
            'description': "User takes >30 seconds to respond, indicating struggle",
            'features': {
                'response_time_seconds': 35.0,
                'attempts_so_far': 0,
                'correctness_last_n': [1, 1, 0],
                'difficulty_label': 'easy',
                'item_familiarity_score': 0.6,
                'time_since_start_seconds': 300,
            },
            'expected_cue': 'phonemic or written_initial',
        },
        
        # =====================================================================
        # TEST 3: Multiple failed attempts
        # =====================================================================
        {
            'name': "Test 3: Multiple failed attempts",
            'description': "User has failed 3 times on this item",
            'features': {
                'response_time_seconds': 12.0,
                'attempts_so_far': 3,
                'correctness_last_n': [0, 0, 0],
                'difficulty_label': 'easy',
                'item_familiarity_score': 0.5,
                'time_since_start_seconds': 180,
            },
            'expected_cue': 'written_initial (escalated)',
        },
        
        # =====================================================================
        # TEST 4: Unfamiliar hard item
        # =====================================================================
        {
            'name': "Test 4: Unfamiliar hard item",
            'description': "Hard item with low familiarity score",
            'features': {
                'response_time_seconds': 8.0,
                'attempts_so_far': 0,
                'correctness_last_n': [1, 0, 1],
                'difficulty_label': 'hard',
                'item_familiarity_score': 0.2,
                'time_since_start_seconds': 240,
            },
            'expected_cue': 'written_initial',
        },
        
        # =====================================================================
        # TEST 5: ML disagrees (ML says cue, rules say no)
        # =====================================================================
        {
            'name': "Test 5: ML disagreement - ML wants cue, rules don't",
            'description': "Quick correct response but ML detects underlying struggle pattern",
            'features': {
                'response_time_seconds': 5.5,
                'attempts_so_far': 0,
                'correctness_last_n': [1],  # Just correct (rules say no cue)
                'difficulty_label': 'hard',
                'item_familiarity_score': 0.05,  # Extremely unfamiliar - triggers ML
                'time_since_start_seconds': 600,
                '_force_ml_cue': True,  # Test flag to force ML disagreement
            },
            'expected_cue': 'functional (hybrid conservative)',
        },
        
        # =====================================================================
        # TEST 6: ML disagrees (ML says no cue, rules say cue)
        # =====================================================================
        {
            'name': "Test 6: ML disagreement - Rules override ML",
            'description': "ML optimistic but rules detect failure pattern - safety first",
            'features': {
                'response_time_seconds': 18.0,
                'attempts_so_far': 2,
                'correctness_last_n': [1, 1, 0, 0],  # Recent failures (rules want cue)
                'difficulty_label': 'easy',
                'item_familiarity_score': 0.9,  # Very familiar
                'time_since_start_seconds': 150,
                '_force_ml_no_cue': True,  # Force ML to say no cue
            },
            'expected_cue': 'rhyming (rules override for safety)',
        },
    ]
    
    # Run each test case
    for i, test in enumerate(test_cases, 1):
        print(f"\n{'─' * 70}")
        print(f"📋 {test['name']}")
        print(f"{'─' * 70}")
        print(f"Description: {test['description']}")
        print(f"Expected: {test['expected_cue']}")
        print(f"\nInput Features:")
        for key, value in test['features'].items():
            print(f"  • {key}: {value}")
        
        # Run hybrid decision
        result = decide_cue_hybrid(test['features'])
        
        print(f"\n📊 Result:")
        print(f"  ├─ Cue Type:   {result['cue_type']}")
        print(f"  ├─ Cue Stage:  {result['cue_stage']}")
        print(f"  ├─ Source:     {result['source']}")
        print(f"  ├─ ML Said:    {'Cue needed' if result['ml_prediction'] == 1 else 'No cue'}")
        print(f"  ├─ Rules Said: {result['rule_cue_type']} (stage {result['rule_cue_stage']})")
        print(f"  └─ Reasoning:  {result['reasoning']}")
        
        # Also show simple decide_cue output
        simple_result = decide_cue(test['features'])
        print(f"\n  Simple decide_cue(): {simple_result}")
    
    print(f"\n{'=' * 70}")
    print("✅ All test cases completed!")
    print(f"{'=' * 70}\n")


# =============================================================================
# MAIN
# =============================================================================

if __name__ == "__main__":
    run_test_cases()
    
    # Interactive example
    print("\n" + "=" * 70)
    print("INTERACTIVE EXAMPLE")
    print("=" * 70)
    
    example_features = {
        'response_time_seconds': 22.0,
        'attempts_so_far': 1,
        'correctness_last_n': [1, 1, 0],
        'difficulty_label': 'hard',
        'item_familiarity_score': 0.4,
        'time_since_start_seconds': 420,
    }
    
    print("\nInput features:")
    for k, v in example_features.items():
        print(f"  {k}: {v}")
    
    print("\n" + "-" * 40)
    print("Simple API: decide_cue()")
    print("-" * 40)
    cue_type, cue_stage = decide_cue(example_features)
    print(f"  cue_type:  {cue_type}")
    print(f"  cue_stage: {cue_stage}")
    
    print("\n" + "-" * 40)
    print("Hybrid API: decide_cue_hybrid()")
    print("-" * 40)
    result = decide_cue_hybrid(example_features)
    print(format_decision_result(result))

