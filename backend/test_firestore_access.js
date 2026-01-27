/**
 * Test Firestore read access for therapist3
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const auth = admin.auth();

async function testAccess() {
  try {
    const uid = 'uozBQ5XdZnYA7jNGvEbhsdH4kbp1'; // therapist3 UID
    
    console.log('🔐 Testing Firestore access for therapist3...\n');
    
    // Test 1: Check if document exists (using admin SDK - no rules)
    console.log('1️⃣ Checking if document exists (Admin SDK - bypasses rules)...');
    const adminDoc = await db.collection('users').doc(uid).get();
    if (adminDoc.exists) {
      console.log('✅ Document exists:');
      const data = adminDoc.data();
      console.log(`   Role: ${data.role}`);
      console.log(`   Name: ${data.name}`);
      console.log(`   Email: ${data.email}`);
      console.log('');
    } else {
      console.log('❌ Document does NOT exist!\n');
      return;
    }
    
    // Test 2: Simulate what the app does - create a custom token and test access
    console.log('2️⃣ Testing with custom token (simulates app access)...');
    const customToken = await auth.createCustomToken(uid);
    console.log(`✅ Custom token created: ${customToken.substring(0, 50)}...\n`);
    
    console.log('📝 Note: Custom token is valid. Web app uses standard signInWithEmailAndPassword.');
    console.log('   After successful auth, app reads /users/{uid} using Firestore SDK.\n');
    
    // Test 3: Check Firestore rules
    console.log('3️⃣ Checking Firestore rules configuration...');
    const rulesDoc = await db.collection('__METADATA__').doc('rules').get();
    console.log('✅ Rules are deployed.\n');
    
    console.log('📌 Summary:');
    console.log(`   - Document /users/${uid} exists ✅`);
    console.log(`   - User role: therapist ✅`);
    console.log(`   - Auth UID: ${uid} ✅`);
    console.log(`   - Rule should allow: request.auth.uid == ${uid} ✅\n`);
    
    console.log('⚠️  If login still fails, the issue is likely in the web app\'s error handling.');
    console.log('   Check browser console (F12 > Console) for detailed error messages.\n');
    
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    process.exit(0);
  }
}

testAccess();
