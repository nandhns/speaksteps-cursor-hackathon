"""
SpeakSteps Synthetic Dataset Generator
======================================
Generates a synthetic CSV dataset for Broca's-aphasia therapy exercises.
Random Seed: 42 (for reproducibility)

Columns Description:
--------------------
- question_id: Unique identifier for each question (format: Q_XXXXX)
- module: Therapy module ("writing" or "comprehension")
- category: Item category ("animals", "body_parts", "clothing", "food")
- item: The target word/item being tested
- item_image_filename: Filename of the associated image asset
- difficulty_label: "easy" (different context stimuli) or "hard" (same-context stimuli)
- question_type: Type of question (pic_to_word, word_to_pic, fill_in_blank, etc.)
- presented_at_iso: ISO timestamp when question was shown
- response_at_iso: ISO timestamp when user responded
- response_time_seconds: Time taken to respond (2-240 seconds)
- user_answer: The answer provided by the user
- correct_answer: The correct answer expected
- correct: Binary indicator (1=correct, 0=incorrect)
- cue_given: Binary indicator (1=cue was provided, 0=no cue)
- cue_type: Type of cue given (functional, rhyming, written_initial, etc.)
- cue_stage: Cue hierarchy stage (0=no cue, 1-7=progressive cue stages)
- cue_wait_seconds: Seconds from presentation until cue shown (5-60)
- hint_count: Total number of cues shown during this trial
- session_id: Session identifier (format: SESS_XXXXX)
- user_id: User identifier (format: USER_XXX)
- therapist_assigned_level: Therapist-assigned difficulty level (1-5)
- device_type: Device used ("mobile" or "web")
- created_at_iso: ISO timestamp when record was created

Difficulty Logic:
-----------------
- "easy": Different context stimuli - items presented with varied/contrasting distractors
- "hard": Same-context stimuli - items presented with semantically similar distractors

Correctness Probabilities:
--------------------------
- Easy items without cue: ~80% base correct rate
- Hard items without cue: ~45% base correct rate
- Cue given increases probability based on cue_stage:
  - Stage 1: +5%, Stage 2: +10%, Stage 3: +15%, Stage 4: +20%
  - Stage 5: +25%, Stage 6: +30%, Stage 7: +35%
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random

# Set random seed for reproducibility
RANDOM_SEED = 42
np.random.seed(RANDOM_SEED)
random.seed(RANDOM_SEED)

# Configuration
NUM_ROWS = 5000
NUM_USERS = 50
NUM_SESSIONS_PER_USER = 20

# Define vocabulary items per category
ITEMS_BY_CATEGORY = {
    "animals": ["dog", "cat", "bird", "fish", "horse", "cow", "pig", "sheep", "lion", "elephant", 
                "tiger", "bear", "rabbit", "duck", "chicken", "frog", "snake", "turtle", "monkey", "zebra"],
    "body_parts": ["hand", "foot", "arm", "leg", "head", "eye", "ear", "nose", "mouth", "finger",
                   "toe", "knee", "elbow", "shoulder", "neck", "back", "stomach", "chest", "hair", "tooth"],
    "clothing": ["shirt", "pants", "dress", "shoe", "hat", "sock", "jacket", "coat", "glove", "scarf",
                 "belt", "tie", "skirt", "shorts", "sweater", "boot", "sandal", "cap", "vest", "blouse"],
    "food": ["apple", "bread", "milk", "egg", "rice", "meat", "fish", "cheese", "banana", "orange",
             "carrot", "potato", "tomato", "chicken", "soup", "salad", "cake", "cookie", "water", "juice"]
}

# Modules and question types per module
MODULES = ["writing", "comprehension"]
QUESTION_TYPES = {
    "writing": ["pic_to_word", "fill_in_blank", "spelling_choice", "word_completion"],
    "comprehension": ["word_to_pic", "sentence_matching", "category_sorting", "yes_no_question"]
}

# Cue types and their effectiveness (higher = more helpful)
CUE_TYPES = ["functional", "rhyming", "written_initial", "spelling", "sentence_completion", "phonemic", "modeling"]
CUE_EFFECTIVENESS = {
    "functional": 0.8,
    "rhyming": 0.7,
    "written_initial": 0.9,
    "spelling": 0.85,
    "sentence_completion": 0.75,
    "phonemic": 0.95,
    "modeling": 1.0
}

DIFFICULTIES = ["easy", "hard"]
DEVICE_TYPES = ["mobile", "web"]

def generate_response_time(difficulty, cue_given, cue_stage):
    """Generate realistic response times with long tails."""
    # Base times depend on difficulty
    if difficulty == "easy":
        base_mean = 8
        base_std = 4
    else:
        base_mean = 15
        base_std = 8
    
    # Cues add thinking time
    if cue_given:
        base_mean += cue_stage * 3
    
    # Generate with log-normal for long tail
    time = np.random.lognormal(mean=np.log(base_mean), sigma=0.6)
    
    # Clamp to realistic bounds
    return max(2.0, min(240.0, time))

def calculate_correct_probability(difficulty, cue_given, cue_stage, cue_type):
    """Calculate probability of correct answer based on difficulty and cues."""
    # Base probabilities
    if difficulty == "easy":
        base_prob = 0.80
    else:
        base_prob = 0.45
    
    # Cue boost based on stage
    if cue_given and cue_stage > 0:
        stage_boost = cue_stage * 0.05  # +5% per stage
        cue_effectiveness = CUE_EFFECTIVENESS.get(cue_type, 0.8)
        cue_boost = stage_boost * cue_effectiveness
        base_prob = min(0.98, base_prob + cue_boost)
    
    return base_prob

def generate_wrong_answer(correct_answer, category):
    """Generate a plausible wrong answer from the same category."""
    alternatives = [item for item in ITEMS_BY_CATEGORY[category] if item != correct_answer]
    return random.choice(alternatives) if alternatives else correct_answer + "_wrong"

def generate_dataset():
    """Generate the synthetic dataset."""
    data = []
    
    # Pre-generate user and session IDs
    user_ids = [f"USER_{i:03d}" for i in range(1, NUM_USERS + 1)]
    
    # Generate user metadata
    user_therapist_levels = {uid: random.randint(1, 5) for uid in user_ids}
    user_preferred_device = {uid: random.choice(DEVICE_TYPES) for uid in user_ids}
    
    # Base timestamp for dataset
    base_time = datetime(2024, 1, 1, 8, 0, 0)
    
    # Track sessions per user
    user_session_count = {uid: 0 for uid in user_ids}
    current_session = {}
    session_start_times = {}
    
    for i in range(NUM_ROWS):
        # Select user (weighted to create realistic distribution)
        user_id = random.choice(user_ids)
        
        # Manage sessions
        if user_id not in current_session or random.random() < 0.05:  # 5% chance of new session
            user_session_count[user_id] += 1
            current_session[user_id] = f"SESS_{user_id}_{user_session_count[user_id]:03d}"
            session_start_times[user_id] = base_time + timedelta(
                days=random.randint(0, 365),
                hours=random.randint(0, 14),
                minutes=random.randint(0, 59)
            )
        
        session_id = current_session[user_id]
        
        # Balance across modules, categories, difficulties
        module = MODULES[i % len(MODULES)]
        category = list(ITEMS_BY_CATEGORY.keys())[i % len(ITEMS_BY_CATEGORY)]
        difficulty = DIFFICULTIES[i % len(DIFFICULTIES)]
        
        # Select item and question type
        item = random.choice(ITEMS_BY_CATEGORY[category])
        question_type = random.choice(QUESTION_TYPES[module])
        
        # Generate image filename
        item_image_filename = f"{category}/{item}.png"
        
        # Decide if cue is given (more likely for hard items)
        cue_probability = 0.3 if difficulty == "easy" else 0.55
        cue_given = 1 if random.random() < cue_probability else 0
        
        if cue_given:
            cue_type = random.choice(CUE_TYPES)
            cue_stage = random.randint(1, 7)
            cue_wait_seconds = round(random.uniform(5, 60), 2)
            hint_count = random.randint(1, cue_stage)
        else:
            cue_type = None
            cue_stage = 0
            cue_wait_seconds = None
            hint_count = 0
        
        # Calculate response time
        response_time = round(generate_response_time(difficulty, cue_given, cue_stage), 2)
        
        # Calculate correctness
        correct_prob = calculate_correct_probability(difficulty, cue_given, cue_stage, cue_type)
        correct = 1 if random.random() < correct_prob else 0
        
        # Generate timestamps
        presented_at = session_start_times[user_id] + timedelta(seconds=i * 30 + random.randint(0, 10))
        response_at = presented_at + timedelta(seconds=response_time)
        created_at = response_at + timedelta(seconds=random.uniform(0.1, 2.0))
        
        # Generate answers
        correct_answer = item
        if correct:
            user_answer = correct_answer
        else:
            user_answer = generate_wrong_answer(correct_answer, category)
        
        # Device type (mostly consistent per user, but some variation)
        if random.random() < 0.85:
            device_type = user_preferred_device[user_id]
        else:
            device_type = random.choice(DEVICE_TYPES)
        
        # Build row
        row = {
            "question_id": f"Q_{i+1:05d}",
            "module": module,
            "category": category,
            "item": item,
            "item_image_filename": item_image_filename,
            "difficulty_label": difficulty,
            "question_type": question_type,
            "presented_at_iso": presented_at.isoformat(),
            "response_at_iso": response_at.isoformat(),
            "response_time_seconds": response_time,
            "user_answer": user_answer,
            "correct_answer": correct_answer,
            "correct": correct,
            "cue_given": cue_given,
            "cue_type": cue_type if cue_type else "",
            "cue_stage": cue_stage,
            "cue_wait_seconds": cue_wait_seconds if cue_wait_seconds else "",
            "hint_count": hint_count,
            "session_id": session_id,
            "user_id": user_id,
            "therapist_assigned_level": user_therapist_levels[user_id],
            "device_type": device_type,
            "created_at_iso": created_at.isoformat()
        }
        
        data.append(row)
    
    return pd.DataFrame(data)

def print_summary_stats(df):
    """Print summary statistics of the generated dataset."""
    print("\n" + "="*60)
    print("DATASET SUMMARY STATISTICS")
    print("="*60)
    
    print(f"\nTotal rows: {len(df)}")
    print(f"Random seed used: {RANDOM_SEED}")
    
    print("\n--- Distribution by Module ---")
    print(df['module'].value_counts())
    
    print("\n--- Distribution by Category ---")
    print(df['category'].value_counts())
    
    print("\n--- Distribution by Difficulty ---")
    print(df['difficulty_label'].value_counts())
    
    print("\n--- Correctness Rates ---")
    print(f"Overall: {df['correct'].mean()*100:.1f}%")
    for diff in DIFFICULTIES:
        subset = df[df['difficulty_label'] == diff]
        print(f"  {diff}: {subset['correct'].mean()*100:.1f}%")
    
    print("\n--- Correctness by Cue Status ---")
    no_cue = df[df['cue_given'] == 0]
    with_cue = df[df['cue_given'] == 1]
    print(f"  Without cue: {no_cue['correct'].mean()*100:.1f}%")
    print(f"  With cue: {with_cue['correct'].mean()*100:.1f}%")
    
    print("\n--- Response Time Statistics ---")
    print(f"  Mean: {df['response_time_seconds'].mean():.2f}s")
    print(f"  Median: {df['response_time_seconds'].median():.2f}s")
    print(f"  Min: {df['response_time_seconds'].min():.2f}s")
    print(f"  Max: {df['response_time_seconds'].max():.2f}s")
    
    print("\n--- Cue Usage ---")
    print(f"  Trials with cue: {df['cue_given'].sum()} ({df['cue_given'].mean()*100:.1f}%)")
    print(f"  Cue type distribution:")
    cue_df = df[df['cue_given'] == 1]
    print(cue_df['cue_type'].value_counts())
    
    print("\n--- Device Distribution ---")
    print(df['device_type'].value_counts())
    
    print("\n--- Unique Counts ---")
    print(f"  Users: {df['user_id'].nunique()}")
    print(f"  Sessions: {df['session_id'].nunique()}")
    print(f"  Questions: {df['question_id'].nunique()}")

if __name__ == "__main__":
    print("Generating SpeakSteps synthetic dataset...")
    print(f"Random seed: {RANDOM_SEED}")
    
    # Generate dataset
    df = generate_dataset()
    
    # Save to CSV
    output_file = "synth_speaksteps.csv"
    df.to_csv(output_file, index=False)
    print(f"\nDataset saved to: {output_file}")
    
    # Print summary
    print_summary_stats(df)
    
    # Show first 10 rows
    print("\n" + "="*60)
    print("FIRST 10 ROWS (Preview)")
    print("="*60)
    pd.set_option('display.max_columns', None)
    pd.set_option('display.width', None)
    print(df.head(10).to_string())

