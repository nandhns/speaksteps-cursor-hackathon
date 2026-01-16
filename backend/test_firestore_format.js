/**
 * Test script to verify exactly what Firestore returns for assignedModules
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function testFirestoreFormat() {
  try {
    // Get the test patient
    const doc = await db.collection('users').doc('NQVL4tqAVXOKtZBfFnkjeSgmFW53').get();
    
    if (doc.exists) {
      const data = doc.data();
      console.log('\n✅ Document found!\n');
      console.log('Full document data:');
      console.log(JSON.stringify(data, null, 2));
      
      console.log('\n' + '='.repeat(60) + '\n');
      
      console.log('assignedModules field:');
      console.log('  Value:', JSON.stringify(data.assignedModules));
      console.log('  Type:', typeof data.assignedModules);
      console.log('  Is Array:', Array.isArray(data.assignedModules));
      console.log('  Length:', Array.isArray(data.assignedModules) ? data.assignedModules.length : 'N/A');
      
      if (Array.isArray(data.assignedModules)) {
        console.log('  Elements:');
        data.assignedModules.forEach((elem, idx) => {
          console.log(`    [${idx}] "${elem}" (type: ${typeof elem})`);
        });
      }
      
      console.log('\n' + '='.repeat(60) + '\n');
      
      // Try to parse it the way Flutter would
      console.log('How Flutter SDK would see it:');
      const modules = data.assignedModules;
      if (modules && Array.isArray(modules)) {
        const modulesAsString = modules.map(m => `"${m}"`).join(', ');
        console.log(`  List<dynamic>: [${modulesAsString}]`);
      } else {
        console.log('  Not a valid array');
      }
      
    } else {
      console.log('❌ Document not found');
    }
  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    await admin.app().delete();
  }
}

testFirestoreFormat();
