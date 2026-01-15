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

async function checkComprehensionStructure() {
  console.log('\n🔍 Checking Comprehension Exercise Structure in Firestore\n');

  const doc = await db.collection('exercises').doc('EX_C_ANI_E_001').get();
  
  if (!doc.exists) {
    console.log('❌ Exercise not found!');
    process.exit(1);
  }

  const data = doc.data();
  console.log(`📄 Exercise: ${data.id} - ${data.title}`);
  console.log(`   Type: ${data.type}`);
  console.log(`   Category: ${data.category}`);
  console.log(`   Questions: ${data.questions?.length || 0}`);

  if (data.questions && data.questions.length > 0) {
    const q = data.questions[0];
    console.log(`\n📋 First Question:`);
    console.log(`   ID: ${q.id}`);
    console.log(`   Question Type: ${q.questionType}`);
    console.log(`   Stimulus Type: ${q.stimulusType}`);
    console.log(`   Stimulus Value: ${q.stimulusValue}`);
    console.log(`   Correct Answer: ${q.correctAnswer}`);
    console.log(`   Options: ${JSON.stringify(q.options)}`);
    console.log(`   Image Options: ${JSON.stringify(q.imageOptions || [])}`);
    
    console.log(`\n✅ Verification:`);
    console.log(`   - Stimulus is the question text: ${q.stimulusValue === 'Haiwan ini mengeong dan suka bermain.' ? '✓' : '✗'}`);
    console.log(`   - Correct answer is image path: ${q.correctAnswer === 'images/kucing.png' ? '✓' : '✗'}`);
    console.log(`   - Options contain 4 images: ${q.options?.length === 4 ? '✓' : '✗'}`);
    console.log(`   - First option is correct image: ${q.options?.[0] === 'images/kucing.png' ? '✓' : '✗'}`);
  }

  process.exit(0);
}

checkComprehensionStructure().catch(error => {
  console.error('Error:', error);
  process.exit(1);
});
