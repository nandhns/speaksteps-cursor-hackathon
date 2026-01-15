/**
 * Deep Cleanup Script: Remove Duplicates and Old Exercises
 * 
 * This script:
 * 1. Deletes ALL exercises from Firestore
 * 2. Re-seeds ONLY from the CSV (clean data)
 * 3. Removes duplicates
 * 4. Ensures proper module and category mapping
 * 
 * Usage:
 * node deep_cleanup_exercises.js
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
  'badan': 'bodyParts',
  'kata_kerja': 'verbs',
};

// Map CSV modules to exercise types
const moduleMap = {
  'penulisan': 'writing',
  'kefahaman': 'comprehension',
  'writing': 'writing',       // Already in English
  'comprehension': 'comprehension', // Already in English
};

// Map CSV difficulty to numeric level
const difficultyMap = {
  'easy': 1,
  'medium': 2,
  'hard': 3,
};

async function deepCleanup() {
  try {
    console.log('\n🧹 DEEP CLEANUP: Removing old/duplicate exercises\n');

    // Step 1: Delete ALL exercises
    console.log('Step 1: Deleting ALL exercises...');
    const exercisesSnapshot = await db.collection('exercises').get();
    console.log(`  Found ${exercisesSnapshot.size} exercises to delete`);
    
    let deleteCount = 0;
    for (const doc of exercisesSnapshot.docs) {
      await db.collection('exercises').doc(doc.id).delete();
      deleteCount++;
      if (deleteCount % 10 === 0) {
        console.log(`  ✓ Deleted ${deleteCount}/${exercisesSnapshot.size}`);
      }
    }
    console.log(`✅ All ${deleteCount} exercises deleted\n`);

    // Step 2: Load and parse CSV
    console.log('Step 2: Loading exercises from CSV...');
    const csvPath = path.join(__dirname, 'data', 'exercises.csv');
    const csvContent = fs.readFileSync(csvPath, 'utf-8');
    
    const records = parse(csvContent, {
      columns: true,
      skip_empty_lines: true,
      trim: true,
      relax_column_count: true,
    });
    
    console.log(`  Loaded ${records.length} records from CSV\n`);

    // Step 3: Process and deduplicate
    console.log('Step 3: Processing exercises and removing duplicates...');
    
    const exercisesMap = new Map();
    const skipped = [];
    
    for (const record of records) {
      // Skip empty rows
      if (!record.exercise_id) continue;
      
      // Validate required fields
      if (!record.module || !record.category || !record.title) {
        skipped.push(`${record.exercise_id} (missing required fields)`);
        continue;
      }
      
      // Skip if already processed (deduplication)
      if (exercisesMap.has(record.exercise_id)) {
        skipped.push(`${record.exercise_id} (duplicate)`);
        continue;
      }
      
      // Skip unknown categories
      const normalizedCategory = record.category?.toLowerCase() || '';
      if (!categoryMap[normalizedCategory]) {
        skipped.push(`${record.exercise_id} (unknown category: ${record.category})`);
        continue;
      }
      
      // Skip unknown modules
      const normalizedModule = record.module?.toLowerCase() || '';
      if (!moduleMap[normalizedModule]) {
        skipped.push(`${record.exercise_id} (unknown module: ${record.module})`);
        continue;
      }

      // Add to map
      exercisesMap.set(record.exercise_id, record);
    }
    
    console.log(`  Processing ${exercisesMap.size} unique, valid exercises`);
    if (skipped.length > 0) {
      console.log(`  Skipped ${skipped.length} exercises:`);
      skipped.slice(0, 10).forEach(s => console.log(`    - ${s}`));
      if (skipped.length > 10) {
        console.log(`    ... and ${skipped.length - 10} more`);
      }
    }
    console.log('');

    // Step 4: Upload cleaned exercises
    console.log('Step 4: Uploading cleaned exercises to Firestore...');
    
    let uploadCount = 0;
    let batchCount = 0;
    const BATCH_SIZE = 10;
    let batch = db.batch();
    
    for (const [exerciseId, record] of exercisesMap.entries()) {
      const moduleType = moduleMap[record.module?.toLowerCase()];
      const category = categoryMap[record.category?.toLowerCase()];
      const difficulty = difficultyMap[record.difficulty?.toLowerCase()] || 1;
      
      // Create exercise document
      const exerciseData = {
        id: exerciseId,
        title: record.title || '',
        description: record.description || '',
        module: moduleType,  // Store the mapped type, not the CSV name
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
      
      // Commit batch when it reaches size
      if (batchCount >= BATCH_SIZE) {
        await batch.commit();
        console.log(`  ✓ Uploaded ${uploadCount}/${exercisesMap.size} exercises`);
        batch = db.batch();
        batchCount = 0;
      }
    }
    
    // Commit remaining batch
    if (batchCount > 0) {
      await batch.commit();
    }
    
    console.log(`✅ Successfully uploaded ${uploadCount} clean exercises\n`);

    // Step 5: Verify
    console.log('Step 5: Verifying upload...');
    const finalSnapshot = await db.collection('exercises').get();
    console.log(`  Final exercise count: ${finalSnapshot.size}\n`);
    
    // Show summary
    const categorySummary = new Map();
    const typeSummary = new Map();
    
    for (const doc of finalSnapshot.docs) {
      const data = doc.data();
      const cat = data.category || 'unknown';
      const typ = data.type || 'unknown';
      
      categorySummary.set(cat, (categorySummary.get(cat) || 0) + 1);
      typeSummary.set(typ, (typeSummary.get(typ) || 0) + 1);
    }
    
    console.log('  By Type:');
    for (const [typ, count] of typeSummary.entries()) {
      console.log(`    - ${typ}: ${count}`);
    }
    
    console.log('\n  By Category:');
    for (const [cat, count] of categorySummary.entries()) {
      console.log(`    - ${cat}: ${count}`);
    }

    console.log('\n✨ Deep cleanup completed successfully!');
    console.log('\n📋 Summary:');
    console.log(`  • Deleted all old/duplicate exercises`);
    console.log(`  • Loaded ${records.length} records from CSV`);
    console.log(`  • Processed ${exercisesMap.size} unique, valid exercises`);
    console.log(`  • Skipped ${skipped.length} problematic entries`);
    console.log(`  • Successfully uploaded ${uploadCount} clean exercises`);
    console.log('\n💡 Next steps:');
    console.log(`  1. Patient should see only ${uploadCount} exercises (no duplicates)`);
    console.log(`  2. Categories should be properly organized`);
    console.log(`  3. All exercises should have correct module types`);

    process.exit(0);
  } catch (error) {
    console.error('❌ Error during cleanup:', error);
    process.exit(1);
  }
}

// Run cleanup
deepCleanup();
