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
    SENTENCE_COMPLETION = "sentence_completion"
    WRITTEN_INITIAL = "written_initial"
    SPELLING = "spelling"
    PHONEMIC = "phonemic"
    MODELING = "modeling"


# Cue hierarchy (lower index = less support)
CUE_HIERARCHY = [
    CueType.NO_CUE,
    CueType.FUNCTIONAL,
    CueType.RHYMING,
    CueType.SENTENCE_COMPLETION,
    CueType.WRITTEN_INITIAL,
    CueType.SPELLING,
    CueType.PHONEMIC,
    CueType.MODELING,
]

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
# MOCK ML PREDICTION FUNCTION
# =============================================================================

def ml_predict_need_cue(features: Dict) -> int:
    """
    Mock ML prediction function.
    In production, this would load the TFLite model and run inference.
    
    Args:
        features: Dictionary of input features
        
    Returns:
        0 (no cue needed) or 1 (cue needed)
    """
    # Test override flag for demonstration
    if features.get('_force_ml_cue'):
        return 1
    if features.get('_force_ml_no_cue'):
        return 0
    
    # Simple heuristic mimicking ML model behavior
    # In production: load model.tflite and run inference
    
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
    Rule-based cueing decision logic.
    
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
    
    last_correct = get_last_correctness(correctness)
    recent_accuracy = get_recent_accuracy(correctness)
    
    # =========================================================================
    # RULE 1: Quick correct response → No cue needed
    # =========================================================================
    if response_time < 6 and last_correct == 1:
        return (CueType.NO_CUE.value, 0, "Quick correct response - no cue needed")
    
    # =========================================================================
    # RULE 2: Previous attempt failed → Start with functional cue
    # =========================================================================
    if attempts >= 1 and last_correct == 0:
        # Escalate based on number of failed attempts
        if attempts == 1:
            return (CueType.FUNCTIONAL.value, 1, "First failed attempt - functional cue")
        elif attempts == 2:
            return (CueType.RHYMING.value, 2, "Second failed attempt - rhyming cue")
        elif attempts == 3:
            return (CueType.WRITTEN_INITIAL.value, 4, "Third failed attempt - written initial")
        elif attempts >= 4:
            return (CueType.PHONEMIC.value, 6, "Multiple failures - phonemic cue")
    
    # =========================================================================
    # RULE 3: Slow response → Escalate quickly
    # =========================================================================
    if response_time > 30:
        # Very slow - go straight to stronger cues
        if difficulty == "hard":
            return (CueType.WRITTEN_INITIAL.value, 4, "Slow response on hard item - written initial")
        else:
            return (CueType.PHONEMIC.value, 6, "Very slow response - phonemic cue")
    
    if response_time > 20:
        return (CueType.SENTENCE_COMPLETION.value, 3, "Moderately slow - sentence completion")
    
    # =========================================================================
    # RULE 4: Hard item with low familiarity → Prefer written_initial
    # =========================================================================
    if difficulty == "hard" and familiarity < 0.3:
        return (CueType.WRITTEN_INITIAL.value, 4, "Hard unfamiliar item - written initial")
    
    # =========================================================================
    # RULE 5: Moderate difficulty with some struggle
    # =========================================================================
    if recent_accuracy < 0.5:
        return (CueType.FUNCTIONAL.value, 1, "Low recent accuracy - functional cue")
    
    if recent_accuracy < 0.7 and response_time > 10:
        return (CueType.RHYMING.value, 2, "Moderate struggle - rhyming cue")
    
    # =========================================================================
    # RULE 6: Session fatigue check
    # =========================================================================
    if time_since_start > 900 and response_time > 15:  # 15+ minutes in session
        return (CueType.FUNCTIONAL.value, 1, "Session fatigue detected - light support")
    
    # =========================================================================
    # DEFAULT: No cue needed
    # =========================================================================
    return (CueType.NO_CUE.value, 0, "Default - no cue needed")


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
        'functional': "Describes what the item is used for",
        'rhyming': "Provides a word that rhymes with the target",
        'sentence_completion': "Target word in a sentence context",
        'written_initial': "Shows the first letter(s) of the word",
        'spelling': "Provides spelling breakdown or hints",
        'phonemic': "Provides the initial sound/phoneme",
        'modeling': "Full model of the correct answer",
    }
    return descriptions.get(cue_type, "Unknown cue type")


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

