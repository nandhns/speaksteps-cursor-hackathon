/**
 * Script to verify and fix assignedModules for all patients
 * Run: node verify_and_fix_modules.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function verifyAndFixModules() {
  try {
    console.log('\n🔍 Starting module verification and fix...\n');

    const usersSnapshot = await db.collection('users')
      .where('role', '==', 'patient')
      .get();

    if (usersSnapshot.empty) {
      console.log('❌ No patients found in the database');
      return;
    }

    console.log(`📊 Found ${usersSnapshot.size} patients\n`);

    let patientsWithoutModules = 0;
    let patientsWithModules = 0;
    let updated = 0;

    for (const doc of usersSnapshot.docs) {
      const patientData = doc.data();
      const patientEmail = patientData.email;
      const assignedModules = patientData.assignedModules;

      console.log(`\n👤 Patient: ${patientEmail}`);
      console.log(`   ID: ${doc.id}`);
      console.log(`   assignedModules: ${JSON.stringify(assignedModules)}`);
      console.log(`   Type: ${Array.isArray(assignedModules) ? 'Array' : typeof assignedModules}`);

      if (!assignedModules || (Array.isArray(assignedModules) && assignedModules.length === 0)) {
        console.log(`   ⚠️  No modules assigned - FIXING...`);
        
        // Fix: Add default modules
        try {
          await db.collection('users').doc(doc.id).update({
            assignedModules: ['writing', 'comprehension'],
          });
          console.log(`   ✅ Fixed! Added default modules: ["writing", "comprehension"]`);
          updated++;
          patientsWithoutModules++;
        } catch (error) {
          console.error(`   ❌ Error updating: ${error.message}`);
        }
      } else if (Array.isArray(assignedModules) && assignedModules.length > 0) {
        console.log(`   ✅ Has modules: ${assignedModules.join(', ')}`);
        patientsWithModules++;
      } else {
        console.log(`   ⚠️  Unexpected data type for assignedModules`);
      }
    }

    console.log(`\n📊 SUMMARY:`);
    console.log(`   Total patients: ${usersSnapshot.size}`);
    console.log(`   With modules: ${patientsWithModules}`);
    console.log(`   Without modules (fixed): ${patientsWithoutModules}`);
    console.log(`   Total updated: ${updated}`);
    console.log(`\n✅ Verification and fix complete!\n`);

    // Additional check: Verify the patient by email that user is testing
    console.log('\n🔎 Detailed check of test patient...\n');
    
    const testPatientSnapshot = await db.collection('users')
      .where('email', '==', 'test1.16jan.patient@speaksteps.com')
      .get();

    if (!testPatientSnapshot.empty) {
      const testPatient = testPatientSnapshot.docs[0];
      const testData = testPatient.data();
      console.log(`✅ Found test patient: ${testData.email}`);
      console.log(`   Name: ${testData.name}`);
      console.log(`   ID: ${testPatient.id}`);
      console.log(`   assignedModules: ${JSON.stringify(testData.assignedModules)}`);
      console.log(`   Type: ${Array.isArray(testData.assignedModules) ? 'Array' : typeof testData.assignedModules}`);
      console.log(`   Length: ${Array.isArray(testData.assignedModules) ? testData.assignedModules.length : 'N/A'}`);
      
      if (Array.isArray(testData.assignedModules)) {
        testData.assignedModules.forEach((module, idx) => {
          console.log(`     [${idx}] ${module} (type: ${typeof module})`);
        });
      }
    } else {
      console.log('❌ Test patient not found');
    }

  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await admin.app().delete();
  }
}

verifyAndFixModules();
