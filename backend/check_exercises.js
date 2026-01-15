const admin = require('firebase-admin');
const credential = admin.credential.cert(require('./serviceAccountKey.json'));
admin.initializeApp({ credential, projectId: 'speaksteps-cursor' });
const db = admin.firestore();

async function checkExercises() {
  try {
    const snap = await db.collection('exercises').get();
    console.log('Total exercises:', snap.size);
    
    for (const doc of snap.docs) {
      const qSnap = await doc.ref.collection('questions').get();
      console.log(`Exercise ${doc.id}: ${qSnap.size} questions`);
    }
    
    process.exit(0);
  } catch (err) {
    console.error('Error:', err);
    process.exit(1);
  }
}

checkExercises();
