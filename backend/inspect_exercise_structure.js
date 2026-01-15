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

async function inspectExercises() {
  console.log('\n🔍 Inspecting Exercise Structure\n');

  // Get a sample of writing animal exercises
  const exercisesRef = db.collection('exercises');
  const query = await exercisesRef
    .where('type', '==', 'writing')
    .where('category', '==', 'animal')
    .limit(2)
    .get();

  if (query.empty) {
    console.log('❌ No writing animal exercises found!');
    process.exit(1);
  }

  console.log(`Found ${query.size} sample exercises:\n`);

  query.forEach(doc => {
    const data = doc.data();
    console.log(`📄 Document ID: ${doc.id}`);
    console.log(`   Fields present:`);
    Object.keys(data).sort().forEach(key => {
      const value = data[key];
      const type = typeof value;
      const preview = type === 'string' ? (value.length > 50 ? value.substring(0, 50) + '...' : value) : value;
      console.log(`   - ${key}: ${type} = ${JSON.stringify(preview)}`);
    });
    console.log('');
  });

  process.exit(0);
}

inspectExercises().catch(error => {
  console.error('Error:', error);
  process.exit(1);
});
