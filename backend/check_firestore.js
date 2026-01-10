const admin = require('firebase-admin');
const fs = require('fs');

// Initialize Firebase Admin
let serviceAccount;

// Try to find service account key
if (fs.existsSync('./serviceAccountKey.json')) {
  serviceAccount = require('./serviceAccountKey.json');
  console.log('✅ Using serviceAccountKey.json\n');
} else {
  console.error('❌ serviceAccountKey.json not found!');
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function checkFirestore() {
  console.log('🔍 Checking Firestore database...\n');

  // Check exercises
  console.log('📚 Checking exercises collection:');
  const exercisesSnapshot = await db.collection('exercises').get();
  console.log(`  Total exercises: ${exercisesSnapshot.size}`);
  
  if (exercisesSnapshot.size > 0) {
    // Check first exercise structure
    const firstExercise = exercisesSnapshot.docs[0].data();
    console.log('\n  Sample exercise structure:');
    console.log('  - id:', firstExercise.id);
    console.log('  - title:', firstExercise.title);
    console.log('  - type:', firstExercise.type);
    console.log('  - exerciseType:', firstExercise.exerciseType);
    console.log('  - category:', firstExercise.category);
    console.log('  - questions count:', firstExercise.questions?.length || 0);
    
    if (firstExercise.questions && firstExercise.questions.length > 0) {
      const firstQuestion = firstExercise.questions[0];
      console.log('\n  Sample question structure:');
      console.log('  - Keys:', Object.keys(firstQuestion));
      console.log('  - Has questionText?:', 'questionText' in firstQuestion);
    }
  }

  // Check users
  console.log('\n\n👥 Checking users collection:');
  const usersSnapshot = await db.collection('users').get();
  console.log(`  Total users: ${usersSnapshot.size}`);
  
  usersSnapshot.docs.forEach(doc => {
    const user = doc.data();
    console.log(`\n  User: ${user.name}`);
    console.log(`  - Document ID: ${doc.id}`);
    console.log(`  - Email: ${user.email}`);
    console.log(`  - Role: ${user.role}`);
  });

  // Check specific user
  console.log('\n\n🔎 Checking john.patient@speaksteps.com:');
  const johnDoc = await db.collection('users').doc('g8KEOA79AiR8Gq5BAIvkBbXHjJI2').get();
  
  if (johnDoc.exists) {
    const johnData = johnDoc.data();
    console.log('  ✅ User document exists!');
    console.log('  - Name:', johnData.name);
    console.log('  - Email:', johnData.email);
    console.log('  - Role:', johnData.role);
    console.log('  - All fields:', Object.keys(johnData));
  } else {
    console.log('  ❌ User document NOT found!');
  }

  process.exit(0);
}

checkFirestore().catch((error) => {
  console.error('Error checking Firestore:', error);
  process.exit(1);
});


