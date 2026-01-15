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

async function createTestPatient() {
  console.log('\n👤 Creating test patient\n');

  const patientData = {
    name: 'Test Patient',
    email: 'test1.15jan.patient@speaksteps.com',
    modulesAssigned: ['writing', 'comprehension'],
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  const patientRef = await db.collection('patients').add(patientData);
  console.log(`✅ Created patient with ID: ${patientRef.id}`);
  console.log(`   Email: ${patientData.email}`);
  console.log(`   Modules: ${JSON.stringify(patientData.modulesAssigned)}`);

  process.exit(0);
}

createTestPatient().catch(error => {
  console.error('Error:', error);
  process.exit(1);
});
