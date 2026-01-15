/**
 * Fix Script: Assign Default Modules to Patients Without Modules
 * 
 * This script finds all patients without assigned modules and assigns them
 * the 'writing' module as a default.
 * 
 * Usage:
 * node fix_patient_modules.js [--email=patient@example.com] [--assign-modules module1,module2]
 * 
 * Examples:
 * node fix_patient_modules.js --assign-modules writing,comprehension
 * node fix_patient_modules.js --email=patient@example.com --assign-modules writing
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

async function fixPatientModules() {
  try {
    console.log('\n🔧 Patient Module Assignment Fix\n');

    // Parse command line arguments
    const args = process.argv.slice(2);
    let targetEmail = null;
    let assignModules = ['writing']; // Default to writing module

    for (const arg of args) {
      if (arg.startsWith('--email=')) {
        targetEmail = arg.split('=')[1];
      } else if (arg.startsWith('--assign-modules=')) {
        assignModules = arg.split('=')[1].split(',').map(m => m.trim());
      }
    }

    console.log(`📋 Configuration:`);
    console.log(`   Target: ${targetEmail ? `Single patient: ${targetEmail}` : 'All patients without modules'}`);
    console.log(`   Will assign: ${assignModules.join(', ')}`);
    console.log('');

    let query = db.collection('users').where('role', '==', 'patient');

    if (targetEmail) {
      query = query.where('email', '==', targetEmail);
    }

    // Find patients without modules OR with empty modules array
    const snapshot = await query.get();

    if (snapshot.empty) {
      console.log('ℹ️  No patients found matching criteria');
      process.exit(0);
    }

    const patientsDocs = snapshot.docs;
    const patientsNeedingFix = patientsDocs.filter(doc => {
      const data = doc.data();
      return !data.assignedModules || data.assignedModules.length === 0;
    });

    console.log(`📊 Found ${patientsDocs.size} total patients`);
    console.log(`⚠️  ${patientsNeedingFix.length} need module assignment\n`);

    if (patientsNeedingFix.length === 0) {
      console.log('✅ All patients already have modules assigned!');
      process.exit(0);
    }

    // Show which patients will be updated
    console.log('👥 Patients to update:');
    patientsNeedingFix.forEach((doc, idx) => {
      const data = doc.data();
      console.log(`   ${idx + 1}. ${data.name} (${data.email})`);
      console.log(`      Current modules: ${data.assignedModules ? data.assignedModules.length : 0}`);
    });

    console.log(`\n⏳ Updating ${patientsNeedingFix.length} patients...\n`);

    let successCount = 0;
    let errorCount = 0;

    for (const doc of patientsNeedingFix) {
      const data = doc.data();
      try {
        await db.collection('users').doc(doc.id).update({
          assignedModules: assignModules,
          updatedAt: new Date(),
        });
        console.log(`✅ ${data.name} - Assigned: ${assignModules.join(', ')}`);
        successCount++;
      } catch (error) {
        console.error(`❌ ${data.name} - Error: ${error.message}`);
        errorCount++;
      }
    }

    console.log(`\n📈 Summary:`);
    console.log(`   ✅ Successfully updated: ${successCount}`);
    console.log(`   ❌ Errors: ${errorCount}`);
    console.log(`   📊 Total: ${successCount + errorCount}`);

    if (successCount > 0) {
      console.log('\n✨ Module assignment complete!');
      console.log('💡 Patients can now log in and see their exercises');
    }

    process.exit(errorCount > 0 ? 1 : 0);
  } catch (error) {
    console.error('❌ Error during fix:', error);
    process.exit(1);
  }
}

// Run fix
fixPatientModules();
