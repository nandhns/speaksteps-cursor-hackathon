/**
 * Create therapist3 account in Firebase
 * Usage: node create_therapist3.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const auth = admin.auth();
const db = admin.firestore();

// Therapist3 details
const THERAPIST_EMAIL = 'therapist3@speaksteps.com';
const THERAPIST_PASSWORD = 'therapist123';  // User should change this after first login
const THERAPIST_NAME = 'Dr. Michael Chen';

async function createTherapist3() {
  try {
    console.log('🏥 Creating therapist3 account...\n');
    
    // Step 1: Create Firebase Auth user
    console.log(`📧 Creating auth user: ${THERAPIST_EMAIL}`);
    let userRecord;
    try {
      userRecord = await auth.createUser({
        email: THERAPIST_EMAIL,
        password: THERAPIST_PASSWORD,
        displayName: THERAPIST_NAME,
        emailVerified: true
      });
      console.log(`✅ Auth user created with UID: ${userRecord.uid}\n`);
    } catch (authError) {
      if (authError.code === 'auth/email-already-exists') {
        console.log('⚠️  Auth user already exists, fetching existing user...');
        userRecord = await auth.getUserByEmail(THERAPIST_EMAIL);
        console.log(`✅ Found existing user with UID: ${userRecord.uid}\n`);
      } else {
        throw authError;
      }
    }

    // Step 2: Create Firestore document
    console.log('💾 Creating Firestore user document...');
    const therapistData = {
      uid: userRecord.uid,
      email: THERAPIST_EMAIL,
      name: THERAPIST_NAME,
      role: 'therapist',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    };

    await db.collection('users').doc(userRecord.uid).set(therapistData, { merge: true });
    console.log('✅ Firestore document created\n');

    // Step 3: Summary
    console.log('✨ SUCCESS! Therapist3 account created:\n');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`👤 Name:     ${THERAPIST_NAME}`);
    console.log(`📧 Email:    ${THERAPIST_EMAIL}`);
    console.log(`🔑 Password: ${THERAPIST_PASSWORD}`);
    console.log(`🆔 UID:      ${userRecord.uid}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    console.log('⚠️  IMPORTANT: User should change password after first login!\n');
    console.log('🌐 Login at: https://speaksteps-cursor.web.app\n');

  } catch (error) {
    console.error('❌ Error creating therapist3:', error);
    process.exit(1);
  } finally {
    process.exit(0);
  }
}

createTherapist3();
