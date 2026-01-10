"""
Validate Firestore backup JSON for cue hierarchy consistency and schema alignment.

- Ensures each question's `cueHierarchy` includes all expected cue types
- Reports missing or extra cue keys
- Highlights category and difficulty mismatches vs backend expectations

Run:
    python backend/validate_cue_data.py
"""

import json
import os
from typing import List, Dict, Tuple

EXPECTED_CUE_KEYS = [
    'functional',
    'rhyming',
    'written_initial',
    'spelling',
    'sentence_completion',
    'phonemic',
    'modeling',
]

# Mapping for known localized categories to canonical backend categories
CATEGORY_MAP = {
    'haiwan': 'animals',
    'bodyParts': 'body_parts',
    'pakaian': 'clothing',
    'makanan': 'food',
}

BACKUP_PATH = os.path.join(os.path.dirname(__file__), 'firestore-backup.json')


def load_backup(path: str) -> Dict:
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)


def validate_cue_hierarchy(cue_map: Dict[str, str]) -> Tuple[List[str], List[str]]:
    present = set(cue_map.keys())
    expected = set(EXPECTED_CUE_KEYS)
    missing = sorted(list(expected - present))
    extra = sorted(list(present - expected))
    return missing, extra


def main():
    if not os.path.exists(BACKUP_PATH):
        print(f"❌ Backup not found: {BACKUP_PATH}")
        return

    data = load_backup(BACKUP_PATH)
    exercises = data.get('exercises', [])

    total_questions = 0
    issues = []
    category_notes = []
    difficulty_notes = []

    for ex in exercises:
        ex_data = ex.get('data', {})
        ex_id = ex.get('id') or ex_data.get('id') or '(unknown_id)'
        module = ex_data.get('exerciseType') or ex_data.get('type')
        category = ex_data.get('category')
        difficulty_val = ex_data.get('difficulty')

        # Category mapping note
        if category in CATEGORY_MAP:
            canonical = CATEGORY_MAP[category]
            category_notes.append(f"ℹ️ Exercise {ex_id}: category '{category}' → canonical '{canonical}'")
        elif category and category not in {'animals', 'body_parts', 'clothing', 'food'}:
            category_notes.append(f"⚠️ Exercise {ex_id}: unknown category '{category}' (may need mapping)")

        # Difficulty mapping note
        if isinstance(difficulty_val, (int, float)):
            difficulty_notes.append(
                f"ℹ️ Exercise {ex_id}: numeric difficulty={difficulty_val} (backend rule engine expects 'easy'/'hard')"
            )

        for q in ex_data.get('questions', []):
            total_questions += 1
            q_id = q.get('id', '(unknown_question)')
            cue_map = q.get('cueHierarchy', {}) or {}
            missing, extra = validate_cue_hierarchy(cue_map)
            if missing or extra:
                issues.append({
                    'exerciseId': ex_id,
                    'questionId': q_id,
                    'missingCueKeys': missing,
                    'extraCueKeys': extra,
                })

    print("\n====== Cue Hierarchy Validation Report ======")
    print(f"Exercises: {len(exercises)} | Questions: {total_questions}")

    if not issues:
        print("✅ All questions have complete cueHierarchy keys.")
    else:
        print(f"⚠️ {len(issues)} question(s) with cue key issues:")
        for i, issue in enumerate(issues, 1):
            print(
                f"  {i}. Exercise {issue['exerciseId']} / Question {issue['questionId']}\n"
                f"     Missing: {', '.join(issue['missingCueKeys']) or '-'}\n"
                f"     Extra:   {', '.join(issue['extraCueKeys']) or '-'}"
            )

    print("\n====== Category Notes ======")
    if category_notes:
        for note in category_notes:
            print(f"{note}")
    else:
        print("✅ Categories look canonical.")

    print("\n====== Difficulty Notes ======")
    if difficulty_notes:
        for note in difficulty_notes:
            print(f"{note}")
    else:
        print("✅ Difficulty values look canonical.")

    print("\nSuggestions:")
    print("- Ensure frontend cue-type encoding matches backend (fixed in this patch).")
    print("- Map localized categories to canonical values before ML feature encoding.")
    print("- Convert numeric difficulty to 'easy'/'hard' before rule-engine decisions.")


if __name__ == '__main__':
    main()
