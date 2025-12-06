# SpeakSteps Question Bank Labeling Protocol
**Version 1.0 | For Speech-Language Therapists**

---

## Overview

This protocol guides SLTs in annotating therapy questions for the SpeakSteps app. Your expert labels will train our adaptive cueing system to better support patients with Broca's aphasia.

**Time commitment:** ~2 minutes per item | **Target:** Complete all items in your assigned category

---

## Column Definitions

| Column | Format | Description |
|--------|--------|-------------|
| `question_id` | Text | Pre-filled unique ID (e.g., `Q_001_animals_dog`) |
| `module` | `writing` / `comprehension` | Therapy module this item belongs to |
| `category` | Text | Item category: `animals`, `body_parts`, `clothing`, `food` |
| `item` | Text | Target word (e.g., "dog", "hand", "shirt") |
| `correct_answer` | Text | Expected correct response (usually same as item) |
| `difficulty` | `easy` / `hard` | Your assessment (see guidelines below) |
| `expected_time_seconds` | Number | Typical response time for target population |
| `item_familiarity_score` | 0.0 – 1.0 | How familiar is this item to most patients? |
| `notes` | Text | Optional observations or edge cases |

---

## Labeling Guidelines

### 1. Difficulty Rating (`easy` / `hard`)

| Rating | Criteria | Examples |
|--------|----------|----------|
| **easy** | • High-frequency word (daily use)<br>• Simple phonology (1-2 syllables)<br>• Concrete, imageable noun<br>• Distinct from distractors | dog, hand, shoe, apple |
| **hard** | • Lower frequency word<br>• Complex phonology (3+ syllables, clusters)<br>• Abstract or less imageable<br>• Similar to common distractors | elephant, shoulder, jacket, banana |

**Decision rule:** When uncertain, ask: *"Would a patient with moderate Broca's aphasia recognize and produce this word within 15 seconds without support?"* If yes → `easy`. If likely to struggle → `hard`.

---

### 2. Expected Response Time (`expected_time_seconds`)

Estimate the time a **typical patient with moderate Broca's aphasia** would need to respond correctly **without cueing**.

| Difficulty | Typical Range | Use This Default If Unsure |
|------------|---------------|---------------------------|
| Easy items | 5 – 15 seconds | **10 seconds** |
| Hard items | 15 – 45 seconds | **25 seconds** |

**Factors that increase time:** Multisyllabic words, uncommon items, similar-sounding distractors, abstract concepts.

---

### 3. Item Familiarity Score (`0.0 – 1.0`)

Rate how familiar the average adult patient would be with this item based on **daily life exposure**.

| Score | Interpretation | Examples |
|-------|----------------|----------|
| **0.9 – 1.0** | Universal, daily exposure | dog, hand, water, bread |
| **0.7 – 0.8** | Very common, weekly exposure | cat, shirt, apple, car |
| **0.5 – 0.6** | Common but less frequent | horse, jacket, cheese |
| **0.3 – 0.4** | Somewhat familiar, occasional | frog, glove, carrot |
| **0.1 – 0.2** | Less common, limited exposure | specific breeds, specialized items |

**Tip:** Consider your patient population's demographics (age, culture, urban/rural).

---

## Example Row

| question_id | module | category | item | correct_answer | difficulty | expected_time_seconds | item_familiarity_score | notes |
|-------------|--------|----------|------|----------------|------------|----------------------|----------------------|-------|
| Q_001_animals_dog | writing | animals | dog | dog | easy | 8 | 0.95 | High-frequency, 1 syllable, highly imageable |
| Q_015_body_parts_shoulder | comprehension | body_parts | shoulder | shoulder | hard | 22 | 0.70 | 2 syllables, less prominent than "hand" or "arm" |
| Q_037_food_banana | writing | food | banana | banana | hard | 18 | 0.85 | 3 syllables, common word but phonologically complex |

---

## Quality Assurance (QA) Steps

### Step 1: Self-Review
Before submitting, check that:
- [ ] All cells are filled (no blanks except `notes`)
- [ ] `difficulty` is only `easy` or `hard` (no other values)
- [ ] `expected_time_seconds` is a number between 5–60
- [ ] `item_familiarity_score` is between 0.0 and 1.0

### Step 2: Cross-Check (Two-Reviewer Process)
1. **Primary reviewer** completes all rows in assigned category
2. **Secondary reviewer** independently labels **10% of rows** (randomly selected)
3. Compare ratings; discuss any discrepancies where:
   - Difficulty rating differs
   - Expected time differs by >10 seconds
   - Familiarity score differs by >0.2
4. Resolve disagreements through discussion; document rationale in `notes`

### Step 3: Final Validation
Project lead spot-checks 5 random items per category before export.

---

## Export Instructions

### From Google Sheets:

1. **File** → **Download** → **Comma Separated Values (.csv)**
2. Name the file: `speaksteps_questions_labeled_YYYY-MM-DD.csv`
3. Upload to the shared project folder: `/data/labeled/`

### Before Export Checklist:
- [ ] Remove any formatting (colors, bold) — CSV won't preserve it
- [ ] Ensure no commas within `notes` field (use semicolons instead)
- [ ] Verify column headers match exactly as shown above
- [ ] Check for accidental spaces in `difficulty` values

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────┐
│  DIFFICULTY                                             │
│  • Daily word + simple sounds → easy                    │
│  • Complex or less common → hard                        │
├─────────────────────────────────────────────────────────┤
│  EXPECTED TIME                                          │
│  • Easy: 5-15 sec (default: 10)                         │
│  • Hard: 15-45 sec (default: 25)                        │
├─────────────────────────────────────────────────────────┤
│  FAMILIARITY SCORE                                      │
│  • 0.9+ = daily use (dog, hand)                         │
│  • 0.7  = very common (shirt, apple)                    │
│  • 0.5  = common (horse, cheese)                        │
│  • 0.3  = occasional (frog, glove)                      │
└─────────────────────────────────────────────────────────┘
```

---

## Contact & Support

**Questions about this protocol?** Contact the project lead.

**Technical issues with the spreadsheet?** Contact the data team.

---

*Thank you for contributing your clinical expertise to improve adaptive therapy for patients with aphasia.*

---
**Document Version:** 1.0  
**Last Updated:** December 2024  
**Prepared for:** SpeakSteps Development Team

