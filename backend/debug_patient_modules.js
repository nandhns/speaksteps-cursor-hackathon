/**
 * Debug Script: Check Patient Module Assignments in Firebase
 * 
 * This script checks what module assignments exist for a specific patient
 * in Firebase Firestore.
 * 
 * Usage:
 * node debug_patient_modules.js <patient-email>
 * 
 * Example:
 * node debug_patient_modules.js patient@example.com
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

async function debugPatientModules() {
  const patientEmail = process.argv[2];

  if (!patientEmail) {
    console.error('❌ Please provide a patient email');
    console.error('Usage: node debug_patient_modules.js <patient-email>');
    process.exit(1);
  }

  try {
    console.log(`\n🔍 Debugging modules for: ${patientEmail}\n`);

    // Step 1: Get user by email from Firestore
    console.log('Step 1: Finding user in Firestore...');
    const userQuery = await db.collection('users').where('email', '==', patientEmail).get();
    
    if (userQuery.empty) {
      console.error(`❌ User not found in Firestore with email: ${patientEmail}`);
      process.exit(1);
    }

    const userDoc = userQuery.docs[0];

    if (!userDoc.exists) {
      console.error('❌ User document not found in Firestore');
      process.exit(1);
    }

    const userData = userDoc.data();
    console.log('✅ User document found');
    console.log(`   User ID: ${userDoc.id}`);
    console.log(`   Email: ${userData.email}`);
    console.log(`   Name: ${userData.name}`);
    console.log(`   Role: ${userData.role}`);


    // Step 3: Check assignedModules specifically
    console.log('\n🎯 MODULE INFORMATION:');
    if (userData.assignedModules) {
      console.log(`✅ assignedModules field exists`);
      console.log(`   Type: ${Array.isArray(userData.assignedModules) ? 'Array' : 'Other'}`);
      console.log(`   Value: ${JSON.stringify(userData.assignedModules)}`);
      console.log(`   Length: ${userData.assignedModules.length}`);

      if (userData.assignedModules.length === 0) {
        console.warn('   ⚠️  Array is EMPTY - Patient has no assigned modules!');
      }

      userData.assignedModules.forEach((mod, idx) => {
        console.log(`   [${idx}]: "${mod}" (type: ${typeof mod})`);
      });
    } else {
      console.error('❌ assignedModules field is NULL or missing');
      console.log('   This is likely the issue - the frontend expects this field!');
    }

    // Step 4: Check if user has therapistId
    console.log('\n👨‍⚕️ THERAPIST INFORMATION:');
    if (userData.therapistId) {
      console.log(`✅ Therapist ID: ${userData.therapistId}`);
      
      // Try to fetch therapist info
      const therapistDoc = await db.collection('users').doc(userData.therapistId).get();
      if (therapistDoc.exists) {
        const therapistData = therapistDoc.data();
        console.log(`   Therapist Name: ${therapistData.name}`);
        console.log(`   Therapist Email: ${therapistData.email}`);
      }
    } else {
      console.error('❌ No therapist ID assigned');
    }

    // Step 5: Recommendations
    console.log('\n📝 RECOMMENDATIONS:');
    if (!userData.assignedModules || userData.assignedModules.length === 0) {
      console.log('1. ⚠️  Patient has NO modules assigned');
      console.log('2. This is why they see no exercises');
      console.log('3. Solutions:');
      console.log('   a) Assign modules via therapist dashboard');
      console.log('   b) Manually update Firestore with:');
      console.log('      assignedModules: ["writing"] or ["comprehension"] or both');
      console.log('4. Valid module values: "writing", "comprehension"');
    } else {
      console.log('✅ Patient has modules assigned correctly');
      console.log('💡 If still not seeing exercises, check:');
      console.log('   1. Exercises collection is populated (run cleanup_firestore.js)');
      console.log('   2. Firebase rules allow patient to read exercises');
      console.log('   3. Check browser console for debug logs');
    }

    console.log('\n✨ Debug complete!\n');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error during debug:', error);
    process.exit(1);
  }
}

// Run debug
debugPatientModules();
