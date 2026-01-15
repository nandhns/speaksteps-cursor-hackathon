/**
 * Firestore Cleanup Script for SpeakSteps
 * 
 * This script:
 * 1. Deletes all existing exercises from Firestore
 * 2. Re-seeds with clean data from exercises.csv (mapped to proper structure)
 * 3. Removes duplicates and miscategorized exercises
 * 
 * Usage:
 * node cleanup_firestore.js
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');
const { parse } = require('csv-parse/sync');

// Initialize Firebase Admin
let credential;
const serviceKeyPath = path.join(__dirname, 'serviceAccountKey.json');

if (fs.existsSync(serviceKeyPath)) {
  console.log('✅ Using serviceAccountKey.json');
  credential = admin.credential.cert(require(serviceKeyPath));
} else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  console.log('✅ Using GOOGLE_APPLICATION_CREDENTIALS');
  credential = admin.credential.applicationDefault();
} else {
  console.error('❌ Service account key not found!');
  console.error('Please place serviceAccountKey.json in the backend folder');
  process.exit(1);
}

admin.initializeApp({
  credential: credential,
  projectId: 'speaksteps-cursor',
});

const db = admin.firestore();

// Map CSV categories to database categories
const categoryMap = {
  'haiwan': 'animal',
  'makanan': 'food',
  'anggota_badan': 'bodyParts',
  'badan': 'bodyParts', // Alternative category name
  'kata_kerja': 'verbs',
};

// Map CSV modules to exercise types
const moduleMap = {
  'penulisan': 'writing',
  'kefahaman': 'comprehension',
};

// Map CSV difficulty to numeric level
const difficultyMap = {
  'easy': 1,
  'medium': 2,
  'hard': 3,
};

async function cleanupFirestore() {
  try {
    console.log('🧹 Starting Firestore cleanup...\n');

    // Step 1: Delete all existing exercises
    console.log('Step 1: Deleting existing exercises...');
    const exercisesSnapshot = await db.collection('exercises').get();
    console.log(`  Found ${exercisesSnapshot.size} exercises to delete`);
    
    for (const doc of exercisesSnapshot.docs) {
      await db.collection('exercises').doc(doc.id).delete();
    }
    console.log('✅ All exercises deleted\n');

    // Step 2: Load and parse CSV data
    console.log('Step 2: Loading exercises from CSV...');
    const csvPath = path.join(__dirname, 'data', 'exercises.csv');
    const csvContent = fs.readFileSync(csvPath, 'utf-8');
    
    // Parse CSV using csv-parse library to handle quoted fields correctly
    const records = parse(csvContent, {
      columns: true,
      skip_empty_lines: true,
      trim: true,
      relax_column_count: true, // Allow inconsistent column count
    });
    
    console.log(`  Loaded ${records.length} records from CSV\n`);

    // Step 3: Group and transform exercises
    console.log('Step 3: Processing and validating exercises...');
    
    // Group by exercise_id to avoid duplicates
    const exercisesMap = new Map();
    const skipped = [];
    
    for (const record of records) {
      // Skip empty rows
      if (!record.exercise_id) continue;
      
      // Skip clothing category (miscategorization)
      if (record.category && record.category.toLowerCase() === 'pakaian') {
        skipped.push(`${record.exercise_id} (clothing category)`);
        continue;
      }
      
      // Only process known categories
      const normalizedCategory = record.category?.toLowerCase() || '';
      if (!categoryMap[normalizedCategory]) {
        skipped.push(`${record.exercise_id} (unknown category: ${record.category})`);
        continue;
      }
      
      // If we haven't seen this exercise_id yet, add it
      if (!exercisesMap.has(record.exercise_id)) {
        exercisesMap.set(record.exercise_id, record);
      }
    }
    
    console.log(`  Processing ${exercisesMap.size} unique exercises`);
    if (skipped.length > 0) {
      console.log(`  Skipped ${skipped.length} problematic exercises:`);
      skipped.forEach(s => console.log(`    - ${s}`));
    }
    console.log('');

    // Step 4: Upload cleaned exercises
    console.log('Step 4: Uploading cleaned exercises to Firestore...');
    
    let uploadCount = 0;
    let batchCount = 0;
    const BATCH_SIZE = 10;
    let batch = db.batch();
    
    for (const [exerciseId, record] of exercisesMap.entries()) {
      const moduleType = moduleMap[record.module?.toLowerCase()] || 'unknown';
      const category = categoryMap[record.category?.toLowerCase()] || 'unknown';
      const difficulty = difficultyMap[record.difficulty?.toLowerCase()] || 1;
      
      // Create exercise document
      const exerciseData = {
        id: exerciseId,
        title: record.title || '',
        description: record.description || '',
        module: record.module || '',
        type: moduleType,
        exerciseType: moduleType,
        category: category,
        difficulty: difficulty,
        questionType: record.question_type || 'pic_to_word',
        questions: [
          {
            id: record.question_id || `q_${exerciseId}`,
            questionText: record.stimulus_value || '',
            questionType: record.question_type || 'pic_to_word',
            stimulusType: record.stimulus_type || 'image',
            stimulusValue: record.stimulus_value || '',
            options: [
              record.option_1,
              record.option_2,
              record.option_3,
              record.option_4,
            ].filter(o => o && o.trim()),
            correctAnswer: record.correct_answer || '',
            cueHierarchy: {
              functional: record.cue_functional || '',
              rhyming: record.cue_rhyming || '',
              written_initial: record.cue_written_initial || '',
              spelling: record.cue_spelling || '',
              sentence_completion: record.cue_sentence_completion || '',
              phonemic: record.cue_phonemic || '',
              modeling: record.cue_modeling || '',
            },
            imageOptions: [],
            audioUrl: record.correct_answer?.toLowerCase() || '',
          },
        ],
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      // Add to batch
      const docRef = db.collection('exercises').doc(exerciseId);
      batch.set(docRef, exerciseData);
      
      uploadCount++;
      batchCount++;
      
      // Commit batch when it reaches size and create new batch
      if (batchCount >= BATCH_SIZE) {
        await batch.commit();
        console.log(`  ✓ Uploaded ${uploadCount}/${exercisesMap.size} exercises`);
        batch = db.batch(); // Create new batch
        batchCount = 0;
      }
    }
    
    // Commit remaining batch
    if (batchCount > 0) {
      await batch.commit();
    }
    
    console.log(`✅ Successfully uploaded ${uploadCount} cleaned exercises\n`);

    // Step 5: Verify upload
    console.log('Step 5: Verifying Firestore data...');
    const finalSnapshot = await db.collection('exercises').get();
    console.log(`  Final exercise count: ${finalSnapshot.size}`);
    
    // Show summary by category
    const categorySummary = new Map();
    const typeSummary = new Map();
    
    for (const doc of finalSnapshot.docs) {
      const data = doc.data();
      const cat = data.category || 'unknown';
      const typ = data.type || 'unknown';
      
      categorySummary.set(cat, (categorySummary.get(cat) || 0) + 1);
      typeSummary.set(typ, (typeSummary.get(typ) || 0) + 1);
    }
    
    console.log('\n  By Category:');
    for (const [cat, count] of categorySummary.entries()) {
      console.log(`    - ${cat}: ${count}`);
    }
    
    console.log('\n  By Type:');
    for (const [typ, count] of typeSummary.entries()) {
      console.log(`    - ${typ}: ${count}`);
    }

    console.log('\n✅ Firestore cleanup completed successfully!');
    console.log('\n📋 Summary:');
    console.log(`  • Deleted all old exercises`);
    console.log(`  • Loaded and processed ${exercisesMap.size} unique exercises from CSV`);
    console.log(`  • Skipped ${skipped.length} problematic/duplicate entries`);
    console.log(`  • Successfully uploaded ${uploadCount} cleaned exercises`);
    console.log('\n✨ Database is now clean and ready for Firebase authentication!');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error during cleanup:', error);
    process.exit(1);
  }
}

// Run cleanup
cleanupFirestore();
