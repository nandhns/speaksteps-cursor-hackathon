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

async function checkAnimalWritingExercises() {
  console.log('\n🔍 Checking Animal Writing Exercises\n');

  const exercisesRef = db.collection('exercises');
  const query = await exercisesRef
    .where('type', '==', 'writing')
    .where('category', '==', 'animal')
    .get();

  console.log(`Found ${query.size} animal writing exercises\n`);

  query.forEach((doc, index) => {
    const data = doc.data();
    console.log(`\n${index + 1}. ${doc.id} - ${data.title}`);
    console.log(`   Type: ${data.type}, Category: ${data.category}`);
    console.log(`   Questions: ${data.questions?.length || 0} questions`);
    
    if (data.questions && data.questions.length > 0) {
      const q = data.questions[0];
      console.log(`   First Question:`);
      console.log(`     - ID: ${q.id}`);
      console.log(`     - ImageURL: ${q.stimulusValue || q.imageUrl || 'missing'}`);
      console.log(`     - CorrectAnswer: ${q.correctAnswer || 'missing'}`);
      console.log(`     - CueHierarchy: ${q.cueHierarchy ? Object.keys(q.cueHierarchy).length + ' cues' : 'missing'}`);
      
      if (q.cueHierarchy) {
        console.log(`       Functional: ${q.cueHierarchy.functional ? '✓' : '✗'}`);
        console.log(`       Rhyming: ${q.cueHierarchy.rhyming ? '✓' : '✗'}`);
        console.log(`       Written Initial: ${q.cueHierarchy.written_initial ? '✓' : '✗'}`);
      }
    } else {
      console.log(`   ⚠️  NO QUESTIONS FOUND!`);
    }
  });

  process.exit(0);
}

checkAnimalWritingExercises().catch(error => {
  console.error('Error:', error);
  process.exit(1);
});
