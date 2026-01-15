/**
 * Migration Script: Fix Exercise Types
 * 
 * This script fixes existing exercises that have incorrect type mappings.
 * It normalizes all exercise types to use 'writing' or 'comprehension'
 * instead of 'penulisan' or 'kefahaman'.
 * 
 * Usage:
 * node fix_exercise_types.js
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

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

// Type mapping - normalize all types
const typeMap = {
  'penulisan': 'writing',
  'kefahaman': 'comprehension',
  'writing': 'writing',
  'comprehension': 'comprehension',
};

async function fixExerciseTypes() {
  try {
    console.log('\n🔧 Fixing Exercise Types\n');

    // Get all exercises
    console.log('Step 1: Fetching all exercises...');
    const exercisesSnapshot = await db.collection('exercises').get();
    console.log(`✅ Found ${exercisesSnapshot.size} exercises\n`);

    // Group exercises needing fixing
    const needsFix = [];
    const alreadyCorrect = [];

    for (const doc of exercisesSnapshot.docs) {
      const data = doc.data();
      const currentType = data.type || data.exerciseType;
      const normalizedType = typeMap[currentType];

      if (!normalizedType) {
        console.warn(`⚠️  Unknown type for ${doc.id}: "${currentType}"`);
      } else if (normalizedType !== currentType) {
        needsFix.push({
          id: doc.id,
          title: data.title,
          currentType: currentType,
          newType: normalizedType,
        });
      } else {
        alreadyCorrect.push(doc.id);
      }
    }

    console.log(`📊 Analysis:`);
    console.log(`   ✅ Already correct: ${alreadyCorrect.length}`);
    console.log(`   ⚠️  Need fixing: ${needsFix.length}\n`);

    if (needsFix.length === 0) {
      console.log('✨ All exercises have correct types!');
      process.exit(0);
    }

    // Show which exercises will be fixed
    console.log('📝 Exercises to fix:');
    needsFix.forEach((ex) => {
      console.log(`   ${ex.id}`);
      console.log(`      Title: ${ex.title}`);
      console.log(`      Type: "${ex.currentType}" → "${ex.newType}"`);
    });

    console.log(`\n⏳ Updating ${needsFix.length} exercises...\n`);

    // Update exercises
    let successCount = 0;
    let errorCount = 0;

    for (const exercise of needsFix) {
      try {
        const normalizedType = typeMap[exercise.currentType];
        
        await db.collection('exercises').doc(exercise.id).update({
          type: normalizedType,
          exerciseType: normalizedType,
          module: normalizedType,  // Also normalize the module field
        });
        
        console.log(`✅ ${exercise.id} - Updated to "${normalizedType}"`);
        successCount++;
      } catch (error) {
        console.error(`❌ ${exercise.id} - Error: ${error.message}`);
        errorCount++;
      }
    }

    console.log(`\n📈 Summary:`);
    console.log(`   ✅ Successfully updated: ${successCount}`);
    console.log(`   ❌ Errors: ${errorCount}`);
    console.log(`   📊 Total: ${successCount + errorCount}`);

    if (successCount > 0) {
      console.log('\n✨ Exercise types fixed!');
      console.log('💡 Patients should now see all their exercises correctly');
    }

    process.exit(errorCount > 0 ? 1 : 0);
  } catch (error) {
    console.error('❌ Error during migration:', error);
    process.exit(1);
  }
}

// Run migration
fixExerciseTypes();
