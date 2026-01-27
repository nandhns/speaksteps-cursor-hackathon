/**
 * Fix therapist3 account - verify email and ensure auth matches firestore
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const auth = admin.auth();
const db = admin.firestore();

async function fixTherapist3() {
  try {
    console.log('🔧 Fixing therapist3 account...\n');
    
    const email = 'therapist3@speaksteps.com';
    
    // Get the user
    const userRecord = await auth.getUserByEmail(email);
    const uid = userRecord.uid;
    
    console.log(`📧 Email: ${email}`);
    console.log(`🆔 UID: ${uid}`);
    console.log(`✉️ Email Verified: ${userRecord.emailVerified}`);
    console.log(`👤 Display Name: ${userRecord.displayName || 'NOT SET'}\n`);
    
    // Fix 1: Ensure email is verified
    if (!userRecord.emailVerified) {
      console.log('✅ Setting email as verified...');
      await auth.updateUser(uid, {
        emailVerified: true
      });
    }
    
    // Fix 2: Ensure Firestore document has proper structure
    console.log('✅ Ensuring Firestore document is complete...');
    const userDoc = await db.collection('users').doc(uid).get();
    
    if (userDoc.exists) {
      const data = userDoc.data();
      console.log('   Current Firestore data:');
      console.log(`   - Role: ${data.role}`);
      console.log(`   - Name: ${data.name}`);
      console.log(`   - Email: ${data.email}`);
      
      // Ensure all required fields exist
      await db.collection('users').doc(uid).update({
        uid: uid,
        email: email,
        name: data.name || 'Dr. Michael Chen',
        role: 'therapist',
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      console.log('   ✅ Document updated\n');
    } else {
      console.log('   ❌ Document does not exist! Creating...');
      await db.collection('users').doc(uid).set({
        uid: uid,
        email: email,
        name: 'Dr. Michael Chen',
        role: 'therapist',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      console.log('   ✅ Document created\n');
    }
    
    console.log('✨ SUCCESS! therapist3 account fixed.\n');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📧 Email:    therapist3@speaksteps.com');
    console.log('🔑 Password: therapist123');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    console.log('Try logging in again at: https://speaksteps-cursor.web.app\n');
    
  } catch (error) {
    console.error('❌ Error fixing therapist3:', error);
    process.exit(1);
  } finally {
    process.exit(0);
  }
}

fixTherapist3();
