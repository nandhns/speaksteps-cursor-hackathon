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

async function checkCategories() {
  console.log('\n🔍 Checking Exercise Categories in Firestore\n');

  const snapshot = await db.collection('exercises').get();
  
  const byCategory = {};
  const byType = {};
  
  snapshot.forEach(doc => {
    const data = doc.data();
    const cat = data.category || 'unknown';
    const type = data.type || 'unknown';
    
    byCategory[cat] = (byCategory[cat] || 0) + 1;
    byType[type] = (byType[type] || 0) + 1;
  });

  console.log('✅ Total exercises:', snapshot.size);
  console.log('\n📊 By Category:');
  Object.entries(byCategory).sort().forEach(([cat, count]) => {
    console.log(`   ${cat}: ${count} exercises`);
  });
  
  console.log('\n📊 By Type:');
  Object.entries(byType).sort().forEach(([type, count]) => {
    console.log(`   ${type}: ${count} exercises`);
  });

  process.exit(0);
}

checkCategories().catch(error => {
  console.error('Error:', error);
  process.exit(1);
});
