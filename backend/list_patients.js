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

async function listPatients() {
  console.log('\n👥 Listing all patients:\n');

  const patientsRef = db.collection('patients');
  const snapshot = await patientsRef.get();

  if (snapshot.empty) {
    console.log('No patients found!');
    process.exit(0);
  }

  console.log(`Found ${snapshot.size} patients:\n`);

  snapshot.forEach(doc => {
    const data = doc.data();
    console.log(`📌 ${doc.id}`);
    console.log(`   Name: ${data.name || 'N/A'}`);
    console.log(`   Email: ${data.email || 'N/A'}`);
    console.log(`   Modules: ${JSON.stringify(data.modulesAssigned || [])}`);
    console.log('');
  });

  process.exit(0);
}

listPatients().catch(error => {
  console.error('Error:', error);
  process.exit(1);
});
