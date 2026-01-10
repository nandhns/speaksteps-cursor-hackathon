const admin = require('firebase-admin');
const fs = require('fs');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function exportData() {
  const collections = ['exercises', 'users', 'sessions', 'question_responses'];
  const backup = {};

  for (const collectionName of collections) {
    console.log(`Exporting ${collectionName}...`);
    const snapshot = await db.collection(collectionName).get();
    backup[collectionName] = [];

    snapshot.forEach(doc => {
      backup[collectionName].push({
        id: doc.id,
        data: doc.data(),
      });
    });
  }

  // Save to JSON file
  fs.writeFileSync(
    'firestore-backup.json',
    JSON.stringify(backup, null, 2)
  );

  console.log('✅ Export complete: firestore-backup.json');
  process.exit(0);
}

exportData().catch(err => {
  console.error('Export failed:', err);
  process.exit(1);
});