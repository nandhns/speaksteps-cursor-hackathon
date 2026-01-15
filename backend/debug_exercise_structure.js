const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin SDK
const serviceAccountPath = path.join(__dirname, 'serviceAccountKey.json');
const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://speaksteps-cursor-default-rtdb.asia-southeast1.firebaserealtimedb.app',
});

const db = admin.firestore();

async function debugExerciseStructure() {
  console.log('Checking exercise structure in Firestore...\n');
  
  // Get one comprehension exercise
  const compExercise = await db.collection('exercises').doc('EX_C_ANI_E_001').get();
  console.log('Comprehension Exercise: EX_C_ANI_E_001');
  console.log('Data:', JSON.stringify(compExercise.data(), null, 2));
  
  console.log('\n' + '='.repeat(60) + '\n');
  
  // Get one writing exercise
  const writeExercise = await db.collection('exercises').doc('EX_W_ANI_E_001').get();
  console.log('Writing Exercise: EX_W_ANI_E_001');
  console.log('Data:', JSON.stringify(writeExercise.data(), null, 2));
  
  process.exit(0);
}

debugExerciseStructure().catch(err => {
  console.error('Error:', err);
  process.exit(1);
});
