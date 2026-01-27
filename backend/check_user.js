/**
 * Check specific user in Firestore
 * Usage: node check_user.js <email>
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const auth = admin.auth();
const db = admin.firestore();

const email = process.argv[2] || 'therapist3@speaksteps.com';

async function checkUser() {
  try {
    console.log(`🔍 Checking user: ${email}\n`);
    
    // Check Auth
    console.log('1️⃣ Checking Firebase Auth...');
    try {
      const userRecord = await auth.getUserByEmail(email);
      console.log('✅ Auth user exists:');
      console.log(`   UID: ${userRecord.uid}`);
      console.log(`   Name: ${userRecord.displayName || 'N/A'}`);
      console.log(`   Verified: ${userRecord.emailVerified}`);
      console.log(`   Last Sign In: ${userRecord.metadata.lastSignInTime || 'Never'}\n`);
      
      // Check Firestore
      console.log('2️⃣ Checking Firestore document...');
      const userDoc = await db.collection('users').doc(userRecord.uid).get();
      
      if (userDoc.exists) {
        console.log('✅ Firestore document exists:');
        const data = userDoc.data();
        console.log(`   Role: ${data.role}`);
        console.log(`   Name: ${data.name}`);
        console.log(`   Email: ${data.email}`);
        if (data.therapistId) console.log(`   TherapistId: ${data.therapistId}`);
        if (data.modules) console.log(`   Modules: ${JSON.stringify(data.modules)}`);
        console.log('');
      } else {
        console.log('❌ Firestore document does NOT exist!');
        console.log('   This user can login but won\'t have proper access.\n');
      }
      
    } catch (authError) {
      if (authError.code === 'auth/user-not-found') {
        console.log('❌ Auth user does NOT exist!\n');
      } else {
        throw authError;
      }
    }
    
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  } finally {
    process.exit(0);
  }
}

checkUser();
