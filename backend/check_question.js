const admin = require('firebase-admin');
const credential = admin.credential.cert(require('./serviceAccountKey.json'));
admin.initializeApp({ credential, projectId: 'speaksteps-cursor' });
const db = admin.firestore();

db.collection('exercises').doc('EX_C_ANI_E_001').collection('questions').doc('Q_C_ANI_E_001').get()
  .then(doc => {
    const data = doc.data();
    console.log('\n=== Corrected Question Data ===');
    console.log('Correct Answer:', data.correctAnswer);
    console.log('Image Options:', JSON.stringify(data.imageOptions, null, 2));
    console.log('Audio URL:', data.audioUrl);
    console.log('Stimulus Type:', data.stimulusType);
    console.log('Stimulus Value:', data.stimulusValue);
    console.log('\nCue Hierarchy:');
    Object.keys(data.cueHierarchy || {}).forEach(k => {
      console.log(`  ${k}: ${data.cueHierarchy[k]}`);
    });
    process.exit(0);
  })
  .catch(err => {
    console.error('Error:', err);
    process.exit(1);
  });
