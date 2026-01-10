/**
 * Quick Demo Data Seeder
 * Populates Firebase with sample therapist, patients, and exercise progress
 *
 * Run: node seed_demo_data.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const auth = admin.auth();
const defaultTherapistPassword = 'demo123456';
const defaultPatientPassword = 'patient123';

async function getOrCreateAuthUser({ email, password, displayName, role }) {
  try {
    const existing = await auth.getUserByEmail(email);
    console.log(`ℹ️ Using existing ${role} auth user: ${email}`);
    return existing;
  } catch (error) {
    if (error.code === 'auth/user-not-found') {
      const created = await auth.createUser({ email, password, displayName });
      console.log(`✅ Created ${role} auth user: ${email}`);
      return created;
    }
    throw error;
  }
}

async function seedDemoData() {
  console.log('🌱 Seeding demo data...\n');

  // Demo therapist credentials (use existing or create)
  const therapistEmail = 'therapist@speaksteps.com';
  const therapistAuth = await getOrCreateAuthUser({
    email: therapistEmail,
    password: defaultTherapistPassword,
    displayName: 'Dr. Sarah Ahmad',
    role: 'therapist'
  });
  const therapistId = therapistAuth.uid;

  // Create/update therapist profile
  await db.collection('users').doc(therapistId).set({
    id: therapistId,
    name: 'Dr. Sarah Ahmad',
    email: therapistEmail,
    role: 'therapist',
    clinic: 'SpeakSteps Rehabilitation Center',
    created_at: admin.firestore.FieldValue.serverTimestamp()
  }, { merge: true });
  console.log('✅ Therapist profile upserted: Dr. Sarah Ahmad');

  // Create demo patients with varied progress
  const patients = [
    {
      name: 'John Patient',
      email: 'john.patient@speaksteps.com',
      diagnosis: 'Anomic Aphasia',
      totalExercises: 28,
      avgScore: 75.8,
      recentActivity: 1 // days ago
    },
    {
      name: 'Ahmad bin Hassan',
      email: 'ahmad@example.com',
      diagnosis: 'Broca\'s Aphasia',
      totalExercises: 24,
      avgScore: 78.5,
      recentActivity: 2 // days ago
    },
    {
      name: 'Siti Nur Aisyah',
      email: 'siti@example.com',
      diagnosis: 'Wernicke\'s Aphasia',
      totalExercises: 18,
      avgScore: 65.3,
      recentActivity: 1
    },
    {
      name: 'Kumar Selvam',
      email: 'kumar@example.com',
      diagnosis: 'Global Aphasia',
      totalExercises: 31,
      avgScore: 82.1,
      recentActivity: 0 // today
    }
  ];

  for (const patient of patients) {
    try {
      const patientAuth = await getOrCreateAuthUser({
        email: patient.email,
        password: defaultPatientPassword,
        displayName: patient.name,
        role: 'patient'
      });
      const patientId = patientAuth.uid;

      // Create/merge patient profile tied to therapist UID
      await db.collection('users').doc(patientId).set({
        id: patientId,
        name: patient.name,
        email: patient.email,
        role: 'patient',
        diagnosis: patient.diagnosis,
        therapistId: therapistId,
        preferredLanguage: 'ms',
        created_at: admin.firestore.Timestamp.fromDate(
          new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) // 30 days ago
        )
      }, { merge: true });

      // Generate exercise scores
      const modules = ['writing', 'comprehension'];
      const categories = ['animals', 'body_parts', 'food', 'clothing'];
      
      for (let i = 0; i < patient.totalExercises; i++) {
        const module = modules[i % 2];
        const category = categories[i % 4];
        const daysAgo = Math.floor(Math.random() * 30);
        const score = Math.floor(patient.avgScore + (Math.random() * 20 - 10));
        const maxScore = 10;
        
        const scoreDoc = {
          id: `score_${patientId}_${i}`,
          patientId: patientId,
          exerciseId: `${module}_${category}_${i % 2 === 0 ? 'easy' : 'hard'}`,
          exerciseTitle: `${category.charAt(0).toUpperCase() + category.slice(1)} - ${module === 'writing' ? 'Penulisan' : 'Kefahaman'}`,
          score: Math.min(score, maxScore),
          maxScore: maxScore,
          completedAt: admin.firestore.Timestamp.fromDate(
            new Date(Date.now() - daysAgo * 24 * 60 * 60 * 1000)
          ),
          metadata: {
            timeSpent: Math.floor(Math.random() * 300 + 60), // 1-5 mins
            cuesGiven: Math.floor(Math.random() * 3),
            attempts: Math.floor(Math.random() * 2 + 1)
          }
        };

        await db.collection('exercise_scores').add(scoreDoc);
      }

      // Create recent session
      const sessionDoc = {
        id: `session_${patientId}_recent`,
        patientId: patientId,
        therapistId: therapistId,
        exerciseId: 'writing_animals_easy',
        exerciseTitle: 'Haiwan - Mudah',
        module: 'writing',
        category: 'animals',
        startTime: admin.firestore.Timestamp.fromDate(
          new Date(Date.now() - patient.recentActivity * 24 * 60 * 60 * 1000)
        ),
        endTime: admin.firestore.Timestamp.fromDate(
          new Date(Date.now() - patient.recentActivity * 24 * 60 * 60 * 1000 + 15 * 60 * 1000)
        ),
        totalTimeSeconds: 900,
        activeTimeSeconds: 850,
        totalQuestions: 10,
        correctAnswers: Math.floor(patient.avgScore / 10),
        incorrectAnswers: 10 - Math.floor(patient.avgScore / 10),
        accuracyPercentage: patient.avgScore,
        totalCuesGiven: Math.floor(Math.random() * 5),
        questionsWithCues: Math.floor(Math.random() * 3),
        cueTypeCount: {
          functional: 2,
          rhyming: 1,
          written_initial: 1
        }
      };

      await db.collection('exercise_sessions').add(sessionDoc);

      console.log(`✅ Patient created: ${patient.name} (${patient.totalExercises} exercises)`);
    } catch (error) {
      console.error(`❌ Error creating patient ${patient.name}:`, error.message);
      throw error;
    }
  }

  console.log('\n🎉 Demo data seeded successfully!');
  console.log('\n📋 Demo Credentials:');
  console.log('   Therapist: therapist@speaksteps.com');
  console.log(`   Password: ${defaultTherapistPassword}`);
  console.log('\n   Patients: john.patient@speaksteps.com, ahmad@example.com, siti@example.com, kumar@example.com');
  console.log(`   Password: ${defaultPatientPassword}\n`);
  
  process.exit(0);
}

seedDemoData().catch(error => {
  console.error('❌ Error seeding data:', error);
  process.exit(1);
});
