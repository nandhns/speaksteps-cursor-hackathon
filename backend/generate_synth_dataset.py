"""
SpeakSteps Synthetic Dataset Generator
======================================
Generates a synthetic CSV dataset for Broca's-aphasia therapy exercises.
Random Seed: 42 (for reproducibility)

Columns Description:
--------------------
- question_id: Unique identifier for each question (format: Q_XXXXX)
- exercise_id: Exercise identifier (format: EX_MODULE_CATEGORY_LEVEL_###)
- exercise_name: Human-readable exercise name (e.g., "Writing: Animals Easy #1")
- exercise_start_at_iso: When exercise session started
- exercise_end_at_iso: When exercise session ended
- exercise_duration_seconds: Total seconds spent on entire exercise
- module_start_at_iso: When module session started (groups multiple exercises)
- module_end_at_iso: When module session ended
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
- correct_before_cue: Was answer correct before any cue given (1=yes, 0=no)
- cue_given: Binary indicator (1=cue was provided, 0=no cue)
- cue_type: Type of cue given (functional, rhyming, written_initial, etc.)
- cue_stage: Cue hierarchy stage (0=no cue, 1-7=progressive cue stages)
- cue_sequence_number: Position in cue sequence (1st, 2nd, 3rd cue within exercise)
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
QUESTIONS_PER_EXERCISE = 1  # Each row is one question

# Load actual exercises from exercises.csv
print("Loading exercises from exercises.csv...")
exercises_df = pd.read_csv('data/exercises.csv')

# Map category names for internal use
category_mapping = {
    'haiwan': 'animals',
    'makanan': 'food',
    'anggota_badan': 'body_parts',
    'kata_kerja': 'verbs'
}
exercises_df['category_mapped'] = exercises_df['category'].map(category_mapping)

# Group exercises by category and difficulty for easier selection
EXERCISES_BY_CATEGORY = {}
for category in exercises_df['category_mapped'].unique():
    EXERCISES_BY_CATEGORY[category] = exercises_df[exercises_df['category_mapped'] == category].to_dict('records')

print(f"Loaded {len(exercises_df)} exercises")
print(f"   Categories: {list(EXERCISES_BY_CATEGORY.keys())}")
for cat, exs in EXERCISES_BY_CATEGORY.items():
    print(f"   - {cat}: {len(exs)} exercises")

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

def generate_dataset():
    """Generate the synthetic dataset using REAL exercises from exercises.csv."""
    data = []
    
    # Pre-generate user and session IDs
    user_ids = [f"USER_{i:03d}" for i in range(1, NUM_USERS + 1)]
    
    # Generate user metadata
    user_therapist_levels = {uid: random.randint(1, 5) for uid in user_ids}
    user_preferred_device = {uid: random.choice(DEVICE_TYPES) for uid in user_ids}
    
    # Base timestamp for dataset
    base_time = datetime(2024, 1, 1, 8, 0, 0)
    
    # Track sessions and exercises per user
    user_session_count = {uid: 0 for uid in user_ids}
    user_exercise_count = {uid: 0 for uid in user_ids}
    current_session = {}
    current_exercise = {}
    session_start_times = {}
    exercise_start_times = {}
    module_start_times = {}  # Track module start per session
    current_module_per_session = {}  # Track which module is active
    
    # Track cue sequences within each exercise
    exercise_cue_counts = {}  # exercise_id -> number of cues given so far
    
    exercise_counter = 0
    
    for i in range(NUM_ROWS):
        # Select user
        user_id = random.choice(user_ids)
        
        # Manage sessions
        if user_id not in current_session or random.random() < 0.05:
            user_session_count[user_id] += 1
            current_session[user_id] = f"SESS_{user_id}_{user_session_count[user_id]:03d}"
            session_start_times[user_id] = base_time + timedelta(
                days=random.randint(0, 365),
                hours=random.randint(0, 14),
                minutes=random.randint(0, 59)
            )
            # Reset module tracking for new session
            current_module_per_session[current_session[user_id]] = None
        
        session_id = current_session[user_id]
        
        # Balance across modules
        module = MODULES[i % len(MODULES)]
        
        # Track module start time per session
        if current_module_per_session.get(session_id) != module:
            current_module_per_session[session_id] = module
            module_start_times[f"{session_id}_{module}"] = session_start_times[user_id] + timedelta(seconds=i * 30)
        
        # Select a real exercise from exercises.csv
        module_exercises = exercises_df[exercises_df['module'] == module]
        if len(module_exercises) == 0:
            continue
        
        selected_exercise = module_exercises.sample(1).iloc[0]
        exercise_id = selected_exercise['exercise_id']
        question_id = selected_exercise['question_id']
        exercise_name = selected_exercise['title']
        category = selected_exercise['category_mapped']
        difficulty = selected_exercise['difficulty']
        question_type = selected_exercise['question_type']
        stimulus_value = selected_exercise['stimulus_value']
        correct_answer = selected_exercise['correct_answer']
        
        # Manage exercises (group by real exercise_id)
        if exercise_id not in exercise_start_times:
            user_exercise_count[user_id] += 1
            exercise_start_times[exercise_id] = session_start_times[user_id] + timedelta(seconds=i * 30 + random.randint(0, 10))
            exercise_cue_counts[exercise_id] = 0
        
        # Decide if cue is given
        cue_probability = 0.3 if difficulty == "easy" else 0.55
        cue_given = 1 if random.random() < cue_probability else 0
        cue_sequence_number = 0
        
        # Track if answer was correct BEFORE cue
        correct_before_cue = 1 if random.random() < (0.80 if difficulty == "easy" else 0.45) else 0
        
        if cue_given:
            cue_type = random.choice(CUE_TYPES)
            cue_stage = random.randint(1, 7)
            cue_wait_seconds = round(random.uniform(5, 60), 2)
            hint_count = random.randint(1, cue_stage)
            
            # Increment cue sequence counter for this exercise
            exercise_cue_counts[exercise_id] += 1
            cue_sequence_number = exercise_cue_counts[exercise_id]
            
            # After cue, correctness improves based on cue effectiveness
            if correct_before_cue == 0:
                cue_effectiveness = CUE_EFFECTIVENESS.get(cue_type, 0.8)
                improvement_prob = min(0.95, cue_stage * 0.1 * cue_effectiveness)
                correct = 1 if random.random() < improvement_prob else 0
            else:
                correct = 1
        else:
            cue_type = None
            cue_stage = 0
            cue_wait_seconds = None
            hint_count = 0
            cue_sequence_number = 0
            correct = correct_before_cue
        
        # Calculate response time
        response_time = round(generate_response_time(difficulty, cue_given, cue_stage), 2)
        
        # Generate timestamps
        presented_at = exercise_start_times[exercise_id] + timedelta(seconds=i * 15 + random.randint(0, 5))
        response_at = presented_at + timedelta(seconds=response_time)
        created_at = response_at + timedelta(seconds=random.uniform(0.1, 2.0))
        
        # Exercise end time (updated on each question in exercise)
        exercise_end_time = response_at
        exercise_duration = (exercise_end_time - exercise_start_times[exercise_id]).total_seconds()
        
        # Module end time (updated per session/module combo)
        module_key = f"{session_id}_{module}"
        module_end_time = response_at
        
        # Generate answers using REAL correct answer from exercise
        if correct:
            user_answer = correct_answer
        else:
            # Generate a wrong answer from category
            category_items = [ex['correct_answer'] for ex in EXERCISES_BY_CATEGORY.get(category, [])]
            alternatives = [item for item in category_items if item != correct_answer]
            user_answer = random.choice(alternatives) if alternatives else correct_answer + "_wrong"
        
        # Device type
        if random.random() < 0.85:
            device_type = user_preferred_device[user_id]
        else:
            device_type = random.choice(DEVICE_TYPES)
        
        # Build row with REAL exercise data from exercises.csv
        row = {
            "question_id": question_id,  # REAL question_id from exercises.csv
            "exercise_id": exercise_id,  # REAL exercise_id from exercises.csv
            "exercise_name": exercise_name,  # REAL exercise name from exercises.csv
            "exercise_start_at_iso": exercise_start_times[exercise_id].isoformat(),
            "exercise_end_at_iso": exercise_end_time.isoformat(),
            "exercise_duration_seconds": round(exercise_duration, 2),
            "module_start_at_iso": module_start_times.get(module_key, session_start_times[user_id]).isoformat(),
            "module_end_at_iso": module_end_time.isoformat(),
            "module": module,
            "category": category,
            "item": correct_answer,  # REAL item from exercises.csv
            "item_image_filename": stimulus_value,  # REAL image path from exercises.csv
            "difficulty_label": difficulty,
            "question_type": question_type,  # REAL question type from exercises.csv
            "presented_at_iso": presented_at.isoformat(),
            "response_at_iso": response_at.isoformat(),
            "response_time_seconds": response_time,
            "user_answer": user_answer,
            "correct_answer": correct_answer,
            "correct": correct,
            "correct_before_cue": correct_before_cue,
            "cue_given": cue_given,
            "cue_type": cue_type if cue_type else "",
            "cue_stage": cue_stage,
            "cue_sequence_number": cue_sequence_number,
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
    
    print("\n--- Exercise-Level Metadata ---")
    print(f"  Total exercises: {df['exercise_id'].nunique()}")
    print(f"  Avg questions per exercise: {len(df) / df['exercise_id'].nunique():.1f}")
    print(f"  Avg exercise duration: {df['exercise_duration_seconds'].mean():.1f}s")
    
    print("\n--- Cue Sequence Tracking ---")
    cue_seq = df[df['cue_given'] == 1]
    print(f"  Cue sequence numbers in use: {cue_seq['cue_sequence_number'].max()}")
    print(f"  Distribution of cues per exercise:")
    print(cue_seq.groupby('exercise_id')['cue_sequence_number'].max().value_counts().head(10))
    
    print("\n--- Correctness Before/After Cue ---")
    print(f"  Correct before cue: {df[df['cue_given']==1]['correct_before_cue'].mean()*100:.1f}%")
    print(f"  Correct after cue: {df[df['cue_given']==1]['correct'].mean()*100:.1f}%")
    improvement = (df[df['cue_given']==1]['correct'].sum() - df[df['cue_given']==1]['correct_before_cue'].sum())
    print(f"  Improvement from cue: {improvement} questions")
    
    print("\n--- Module-Level Metadata ---")
    print(f"  Unique module sessions: {df.groupby(['session_id', 'module']).ngroups}")
    avg_module_duration = df.groupby(['session_id', 'module']).apply(
        lambda x: (x['module_end_at_iso'].max() if 'module_end_at_iso' in x else x['response_at_iso'].max())
    )
    print(f"  Avg module duration: {len(avg_module_duration)} sessions tracked")

if __name__ == "__main__":
    print("Generating SpeakSteps synthetic dataset...")
    print(f"Random seed: {RANDOM_SEED}")
    
    # Generate dataset
    df = generate_dataset()
    
    # Save to CSV in data directory
    output_file = "data/synth_speaksteps.csv"
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

