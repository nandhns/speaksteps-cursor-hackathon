/**
 * Debug Script: Check Exercises in Firestore
 * 
 * This script checks what exercises exist in Firestore
 * and shows their module/type information.
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

async function debugExercises() {
  try {
    console.log('\n📚 Debugging Exercises in Firestore\n');

    // Get all exercises
    console.log('Step 1: Fetching all exercises...');
    const exercisesSnapshot = await db.collection('exercises').get();

    console.log(`✅ Found ${exercisesSnapshot.size} exercises\n`);

    if (exercisesSnapshot.size === 0) {
      console.error('❌ NO EXERCISES FOUND!');
      console.log('💡 Solution: Run this command to populate exercises:');
      console.log('   node backend/cleanup_firestore.js');
      process.exit(1);
    }

    // Group by type
    const byType = {};
    const byCategory = {};

    for (const doc of exercisesSnapshot.docs) {
      const data = doc.data();
      const type = data.type || data.exerciseType || 'unknown';
      const category = data.category || 'unknown';

      if (!byType[type]) byType[type] = [];
      if (!byCategory[category]) byCategory[category] = [];

      byType[type].push({ id: doc.id, title: data.title });
      byCategory[category].push({ id: doc.id, title: data.title });
    }

    // Show summary
    console.log('📊 EXERCISES BY TYPE:');
    for (const [type, exercises] of Object.entries(byType)) {
      console.log(`\n   ${type}: ${exercises.length} exercises`);
      exercises.slice(0, 3).forEach(ex => {
        console.log(`      • ${ex.title} (${ex.id})`);
      });
      if (exercises.length > 3) {
        console.log(`      ... and ${exercises.length - 3} more`);
      }
    }

    console.log('\n📂 EXERCISES BY CATEGORY:');
    for (const [cat, exercises] of Object.entries(byCategory)) {
      console.log(`   ${cat}: ${exercises.length} exercises`);
    }

    // Show first exercise data structure
    console.log('\n🔍 SAMPLE EXERCISE DATA:');
    const firstDoc = exercisesSnapshot.docs[0];
    const firstData = firstDoc.data();
    console.log(`   ID: ${firstDoc.id}`);
    console.log(`   Title: ${firstData.title}`);
    console.log(`   Type: ${firstData.type}`);
    console.log(`   ExerciseType: ${firstData.exerciseType}`);
    console.log(`   Category: ${firstData.category}`);
    console.log(`   Module: ${firstData.module}`);
    console.log(`   Questions: ${firstData.questions?.length || 0}`);

    // Check if types match expected values
    console.log('\n✅ VERIFICATION:');
    const types = Object.keys(byType);
    const hasWriting = types.some(t => t.includes('writing'));
    const hasComprehension = types.some(t => t.includes('comprehension'));

    if (hasWriting) console.log('   ✅ Writing exercises found');
    else console.log('   ❌ Writing exercises NOT found');

    if (hasComprehension) console.log('   ✅ Comprehension exercises found');
    else console.log('   ❌ Comprehension exercises NOT found');

    if (!hasWriting || !hasComprehension) {
      console.log('\n💡 The exercises exist, but may need to run cleanup_firestore.js');
    }

    console.log('\n✨ Debug complete!\n');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error during debug:', error);
    process.exit(1);
  }
}

// Run debug
debugExercises();
