/**
 * List all Firebase Auth users
 * Usage: node list_auth_users.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const auth = admin.auth();

async function listAuthUsers() {
  try {
    console.log('👥 Listing all Firebase Auth users...\n');
    
    const listUsersResult = await auth.listUsers();
    
    console.log(`Found ${listUsersResult.users.length} users:\n`);
    
    listUsersResult.users.forEach((userRecord) => {
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      console.log(`📧 Email: ${userRecord.email}`);
      console.log(`👤 Name: ${userRecord.displayName || 'N/A'}`);
      console.log(`🆔 UID: ${userRecord.uid}`);
      console.log(`✅ Verified: ${userRecord.emailVerified}`);
      console.log(`📅 Created: ${userRecord.metadata.creationTime}`);
      console.log(`🔄 Last Sign In: ${userRecord.metadata.lastSignInTime || 'Never'}`);
      console.log('');
    });
    
  } catch (error) {
    console.error('❌ Error listing users:', error);
    process.exit(1);
  } finally {
    process.exit(0);
  }
}

listAuthUsers();
