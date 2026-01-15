const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin
const serviceKeyPath = path.join(__dirname, 'serviceAccountKey.json');
const credential = admin.credential.cert(require(serviceKeyPath));

admin.initializeApp({
  credential: credential,
  projectId: 'speaksteps-cursor',
});

const db = admin.firestore();

async function verifyPatientExercises() {
  console.log('\n🔍 Verifying Patient Exercises\n');

  // Test patient email
  const patientEmail = 'test1.15jan.patient@speaksteps.com';

  // Step 1: Get patient modules
  const patientsRef = db.collection('patients');
  const patientQuery = await patientsRef.where('email', '==', patientEmail).get();

  if (patientQuery.empty) {
    console.log('❌ Patient not found!');
    return;
  }

  const patientDoc = patientQuery.docs[0];
  const patientData = patientDoc.data();
  console.log(`✅ Patient found: ${patientData.name}`);
  console.log(`   Assigned modules: ${JSON.stringify(patientData.modulesAssigned)}`);

  // Step 2: Get exercises for patient's modules
  console.log('\n📚 Checking exercises:');
  
  for (const moduleType of patientData.modulesAssigned || []) {
    const exercisesRef = db.collection('exercises');
    const exercisesQuery = await exercisesRef.where('type', '==', moduleType).get();
    
    console.log(`\n  Module: ${moduleType}`);
    console.log(`  Total exercises: ${exercisesQuery.size}`);
    
    // Group by category
    const byCategory = {};
    exercisesQuery.forEach(doc => {
      const data = doc.data();
      const category = data.category || 'unknown';
      byCategory[category] = (byCategory[category] || 0) + 1;
    });
    
    console.log(`  By category:`, byCategory);
  }

  // Step 3: Check all exercises
  console.log('\n\n📋 All Exercises:');
  const allExercises = await db.collection('exercises').get();
  console.log(`  Total: ${allExercises.size} exercises`);
  
  const byType = {};
  const byCategory = {};
  allExercises.forEach(doc => {
    const data = doc.data();
    byType[data.type || 'unknown'] = (byType[data.type || 'unknown'] || 0) + 1;
    byCategory[data.category || 'unknown'] = (byCategory[data.category || 'unknown'] || 0) + 1;
  });
  
  console.log(`  By type:`, byType);
  console.log(`  By category:`, byCategory);

  process.exit(0);
}

verifyPatientExercises().catch(error => {
  console.error('Error:', error);
  process.exit(1);
});
