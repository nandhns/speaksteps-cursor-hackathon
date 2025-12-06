# SpeakSteps Synthetic Dataset

## Overview
This synthetic dataset models question-level interactions for Broca's-aphasia therapy exercises in the SpeakSteps application. Each row represents one trial (one question shown to one user).

**File:** `synth_speaksteps.csv`  
**Rows:** 5,000  
**Random Seed:** 42 (for reproducibility)

---

## Column Descriptions

| Column | Type | Description |
|--------|------|-------------|
| `question_id` | string | Unique identifier for each question (format: `Q_XXXXX`) |
| `module` | string | Therapy module: `"writing"` or `"comprehension"` |
| `category` | string | Item category: `"animals"`, `"body_parts"`, `"clothing"`, `"food"` |
| `item` | string | The target word/item being tested |
| `item_image_filename` | string | Filename of the associated image asset (format: `category/item.png`) |
| `difficulty_label` | string | `"easy"` or `"hard"` (see Difficulty Logic below) |
| `question_type` | string | Type of question presented |
| `presented_at_iso` | ISO datetime | Timestamp when question was shown to user |
| `response_at_iso` | ISO datetime | Timestamp when user submitted response |
| `response_time_seconds` | float | Time taken to respond (2-240 seconds) |
| `user_answer` | string | The answer provided by the user |
| `correct_answer` | string | The expected correct answer |
| `correct` | int (0/1) | Binary: 1=correct, 0=incorrect |
| `cue_given` | int (0/1) | Binary: 1=cue was provided, 0=no cue |
| `cue_type` | string | Type of cue given (empty if no cue) |
| `cue_stage` | int (0-7) | Cue hierarchy stage: 0=no cue, 1-7=progressive stages |
| `cue_wait_seconds` | float | Seconds from presentation until cue shown (5-60, empty if no cue) |
| `hint_count` | int | Total number of cues shown during this trial |
| `session_id` | string | Session identifier (format: `SESS_USER_XXX_YYY`) |
| `user_id` | string | User identifier (format: `USER_XXX`) |
| `therapist_assigned_level` | int (1-5) | Therapist-assigned difficulty level |
| `device_type` | string | Device used: `"mobile"` or `"web"` |
| `created_at_iso` | ISO datetime | Timestamp when record was created |

---

## Difficulty Logic

| Label | Definition | Base Correct Rate |
|-------|------------|-------------------|
| **easy** | Different context stimuli — items presented with varied/contrasting distractors | ~80% without cue |
| **hard** | Same-context stimuli — items presented with semantically similar distractors | ~45% without cue |

---

## Question Types

### Writing Module
- `pic_to_word` — User sees picture, types the word
- `fill_in_blank` — User completes a sentence with missing word
- `spelling_choice` — User selects correct spelling
- `word_completion` — User completes a partially spelled word

### Comprehension Module
- `word_to_pic` — User sees word, selects matching picture
- `sentence_matching` — User matches sentence to meaning
- `category_sorting` — User sorts items into categories
- `yes_no_question` — User answers yes/no about an item

---

## Cue Types

| Cue Type | Description | Effectiveness |
|----------|-------------|---------------|
| `functional` | Describes the item's function/use | 80% |
| `rhyming` | Provides a rhyming word | 70% |
| `written_initial` | Shows the first letter(s) | 90% |
| `spelling` | Provides spelling hints | 85% |
| `sentence_completion` | Item in sentence context | 75% |
| `phonemic` | Provides sound/phoneme cue | 95% |
| `modeling` | Full model of correct answer | 100% |

---

## Cue Stage Hierarchy

Progressive cueing follows a 7-stage hierarchy:
- **Stage 0:** No cue given
- **Stage 1-7:** Increasingly supportive cues, each adding +5% to correct probability

---

## Correctness Model

```
base_probability = 0.80 (easy) or 0.45 (hard)

if cue_given:
    cue_boost = cue_stage × 0.05 × cue_effectiveness
    final_probability = min(0.98, base_probability + cue_boost)
```

---

## Dataset Statistics

| Metric | Value |
|--------|-------|
| Total rows | 5,000 |
| Unique users | 50 |
| Unique sessions | 280 |
| Module balance | 50% writing, 50% comprehension |
| Category balance | 25% each category |
| Difficulty balance | 50% easy, 50% hard |
| Overall correct rate | ~69.5% |
| Easy correct rate | ~85% |
| Hard correct rate | ~54% |
| Trials with cue | ~43% |
| Mean response time | ~20 seconds |
| Response time range | 2-240 seconds |

---

## Regenerating the Dataset

```bash
python generate_synth_dataset.py
```

To change the random seed, modify `RANDOM_SEED = 42` in the script.

---

## License

Synthetic data for development and testing purposes only.

