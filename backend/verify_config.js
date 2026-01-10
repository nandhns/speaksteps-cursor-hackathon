const fs = require('fs');

console.log('🔍 Verifying Firebase Configuration...\n');

// Check service account key
if (fs.existsSync('./serviceAccountKey.json')) {
  const serviceAccount = require('./serviceAccountKey.json');
  console.log('✅ Service Account Key found:');
  console.log(`   Project ID: ${serviceAccount.project_id}`);
  console.log(`   Client Email: ${serviceAccount.client_email}\n`);
} else {
  console.log('❌ serviceAccountKey.json not found!\n');
}

// Check Flutter Firebase options
const firebaseOptionsPath = '../frontend/lib/firebase_options.dart';
if (fs.existsSync(firebaseOptionsPath)) {
  const content = fs.readFileSync(firebaseOptionsPath, 'utf8');
  const projectIdMatch = content.match(/projectId: '([^']+)'/);
  const authDomainMatch = content.match(/authDomain: '([^']+)'/);
  
  if (projectIdMatch) {
    console.log('✅ Flutter Firebase Options found:');
    console.log(`   Project ID: ${projectIdMatch[1]}`);
    if (authDomainMatch) {
      console.log(`   Auth Domain: ${authDomainMatch[1]}`);
    }
  }
} else {
  console.log('❌ firebase_options.dart not found!');
}

console.log('\n📝 Notes:');
console.log('   - Both should have the same project ID: speaksteps-cursor');
console.log('   - If they don\'t match, regenerate firebase_options.dart');
console.log('   - Run: flutter pub run flutter_tools:configure_firebase');


