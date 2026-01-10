# Bahasa Melayu Exercise Implementation

## Overview
This document describes the implementation of Bahasa Melayu exercises with hierarchical cueing system for SpeakSteps aphasia therapy application.

## Changes Made

### 1. Exercise Structure - Two Modules

#### Module 1: COMPREHENSION (Pemahaman)
Two types of comprehension exercises:
- **a. Picture → Audio Word**: User hears the word and selects the correct picture
- **b. Picture → Written Word**: User sees written word and selects the correct picture

**Difficulty Levels:**
- **Easy (Mudah)**: 
  - 4 options from different contexts
  - Example: "kucing" with options: kucing, tangan, baju, nasi (animal, body part, clothing, food)
  
- **Hard (Sukar)**:
  - 4 options from same context
  - Example: "burung" with options: burung, ayam, itik, helang (all birds)
  - More challenging because options are semantically similar

#### Module 2: NAMING/WRITING (Penamaan/Penulisan)
- Fill in the blank / type the word
- User sees picture and types the Bahasa Melayu word

**Difficulty Levels:**
- **Easy (Mudah)**: 
  - 2-3 syllables
  - Familiar words (kucing, ayam, ikan, tangan, mata)
  
- **Medium (Sederhana)**:
  - 3-4 syllables  
  - Moderately familiar (lembu, itik)
  
- **Hard (Sukar)**:
  - 4+ syllables or complex words
  - Less familiar (kuda, katak, siku, lengan)

### 2. Categories (Kategori)

Four main categories with exercises:

1. **Animals (Haiwan)**
   - Easy: kucing, anjing, burung, ikan, ayam
   - Medium: lembu, itik
   - Hard: kuda, katak
   - Complex: kambing

2. **Body Parts (Anggota Badan)**
   - Easy: tangan, mata, hidung, telinga
   - Hard: lutut, siku, lengan

3. **Food (Makanan)**
   - Easy: nasi, roti, susu, telur
   - Hard: pisang, lobak

4. **Clothing (Pakaian)**
   - Easy: baju, seluar, kasut, topi
   - Hard: jaket, sarung tangan

### 3. Hierarchical Cueing System

The new cueing hierarchy follows therapeutic best practices:

#### Cue Progression (with timing):
```
0. No Cue (0 seconds)
   ↓ (wait 10 seconds)
1. Functional Cue: "Haiwan ini mengeong dan menangkap tikus"
   ↓ (wait 8 seconds)
2. Rhyming Cue: "Ia berima dengan 'gasing'"
   ↓ (wait 8 seconds)  
3. Written Initial: "k_ _ _ _ _"
   ↓ (wait 8 seconds)
4. Spelling: "k-u-c-i-n-g"
   ↓ (wait 8 seconds)
5. Sentence Completion: "Saya ada seekor _____ di rumah"
   ↓ (wait 8 seconds)
6. Phonemic Cue: "Ia bermula dengan bunyi 'ku'"
   ↓ (wait 8 seconds)
7. Modeling: "kucing" (full answer)
```

#### Key Features:
- **Progressive Support**: Cues start with less support (function) and gradually increase
- **Timed Delivery**: Each cue appears after a specific interval (not all at once)
- **Therapeutic Hierarchy**: Follows evidence-based order from semantic to phonological to direct modeling

### 4. Difficulty Factors

#### For Comprehension:
1. **Number of Options**: More options = harder
2. **Context Similarity**: 
   - Different contexts (easy): kucing vs tangan vs baju
   - Same context (hard): burung vs ayam vs itik
3. **Object Familiarity**: Common vs uncommon objects

#### For Naming/Writing:
1. **Number of Syllables**: 
   - 2 syllables (easy): ma-ta, i-kan
   - 3+ syllables (hard): te-li-nga
2. **Word Complexity**: Simple vs complex phonology
3. **Familiarity**: Common vs uncommon words

### 5. Technical Implementation

#### Backend Changes:

**cueing_engine.py**:
- Updated `CUE_HIERARCHY` to match therapeutic order
- Added `CUE_TIMING` dictionary with timing for each cue level
- Updated `decide_cue_rules()` to implement progressive cue escalation:
  - 10 seconds → Functional
  - 18 seconds → Rhyming
  - 26 seconds → Written
  - 34 seconds → Spelling
  - 42 seconds → Sentence
  - 50 seconds → Phonemic
  - 58 seconds → Modeling
- Added `get_next_cue_level()` helper function
- Added `get_cue_timing_seconds()` helper function

**seed_firestore.js**:
- Created 16 new exercise sets in Bahasa Melayu
- All exercises include complete cue hierarchy (7 levels)
- Organized by:
  - Module (comprehension vs writing)
  - Category (animals, body, food, clothing)
  - Difficulty (easy, medium, hard)

### 6. Exercise Examples

#### Comprehension - Easy Example:
```javascript
{
  id: 'comprehension_animals_easy',
  title: 'Haiwan - Mudah',
  questionText: 'kucing',
  correctAnswer: 'kucing',
  options: ['kucing', 'tangan', 'baju', 'nasi'], // Different contexts
  cueHierarchy: {
    functional: 'Haiwan ini mengeong dan menangkap tikus',
    rhyming: 'Ia berima dengan "gasing"',
    written_initial: 'k_ _ _ _ _',
    spelling: 'k-u-c-i-n-g',
    sentence_completion: 'Saya ada seekor _____ di rumah',
    phonemic: 'Ia bermula dengan bunyi "ku"',
    modeling: 'kucing',
  }
}
```

#### Comprehension - Hard Example:
```javascript
{
  id: 'comprehension_animals_hard',
  title: 'Haiwan - Sukar',
  questionText: 'burung',
  correctAnswer: 'burung',
  options: ['burung', 'ayam', 'itik', 'helang'], // Same context - all birds!
  // ... same cue hierarchy structure
}
```

#### Writing - Easy Example:
```javascript
{
  id: 'writing_animals_easy',
  title: 'Nama Haiwan - Mudah',
  questionText: 'Apakah nama haiwan ini?',
  imageUrl: 'animals_cat.png',
  correctAnswer: 'kucing', // 2 syllables, familiar
  // ... complete cue hierarchy
}
```

#### Writing - Hard Example:
```javascript
{
  id: 'writing_clothing_hard',
  questionText: 'Apakah nama pakaian ini?',
  imageUrl: 'clothing_glove.png',
  correctAnswer: 'sarung tangan', // 4 syllables, complex, two words
  // ... complete cue hierarchy
}
```

## Next Steps

### To Deploy These Changes:

1. **Update Database**:
   ```bash
   cd backend
   node seed_firestore.js
   ```
   This will populate Firestore with all new Bahasa Melayu exercises.

2. **Frontend Updates** (if needed):
   - The existing frontend should work with the new exercises
   - The cue timing logic may need adjustment to use the progressive timing
   - Consider adding visual indicators for cue progression

3. **Image Assets**:
   - Ensure images exist for all items:
     - `animals_cat.png`, `animals_dog.png`, etc.
     - `body_parts_hand.png`, `body_parts_eye.png`, etc.
     - `food_rice.png`, `food_bread.png`, etc.
     - `clothing_shirt.png`, `clothing_pants.png`, etc.
   - Images should be placed in the `images/` folder

4. **Testing Recommendations**:
   - Test comprehension easy vs hard (verify difficulty difference)
   - Test writing easy vs hard (verify syllable/complexity difference)
   - Test cue progression timing (10s → 18s → 26s, etc.)
   - Verify all 7 cue levels appear correctly
   - Test with actual users to validate difficulty levels

## Benefits

### Therapeutic Benefits:
1. **Progressive Support**: Users receive appropriate level of help
2. **Evidence-Based**: Follows hierarchy from semantic to phonological cues
3. **Prevents Frustration**: Automatic support prevents prolonged struggle
4. **Promotes Learning**: Less intrusive cues first encourage self-retrieval

### Clinical Benefits:
1. **Better Data**: Track which cue levels are most effective
2. **Individualization**: Adjust timing/thresholds per patient
3. **Progress Monitoring**: See reduction in cue needs over time
4. **Difficulty Calibration**: Multiple difficulty levels for progression

### Cultural Benefits:
1. **Language Appropriate**: Bahasa Melayu content for Malaysian users
2. **Familiar Context**: Local foods, animals, clothing
3. **Accessible**: Common, everyday vocabulary

## Technical Notes

- All exercises maintain backward compatibility with existing database structure
- Cue hierarchy is comprehensive (all 7 levels for every question)
- Timing can be adjusted in `CUE_TIMING` dictionary in `cueing_engine.py`
- Image paths follow convention: `category_item.png`
- Difficulty rating: 1 (easy), 2 (medium), 3 (hard)

## Summary

✅ Created comprehensive Bahasa Melayu exercise sets
✅ Implemented two modules: Comprehension and Writing
✅ Designed difficulty levels based on context and complexity
✅ Implemented hierarchical cueing with progressive timing
✅ Updated backend cueing engine
✅ All exercises include complete 7-level cue hierarchy
✅ Organized by category and difficulty

The system now provides culturally appropriate, therapeutically sound, and technically robust aphasia therapy exercises in Bahasa Melayu.



