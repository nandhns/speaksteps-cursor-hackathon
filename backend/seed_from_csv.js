/**
 * Firestore Seed Script from CSV for SpeakSteps
 * 
 * This script reads exercises.csv and seeds the Firestore database with:
 * - Test therapist account
 * - Test patient accounts  
 * - All exercises from CSV
 * 
 * Usage:
 * 1. npm install firebase-admin csv-parser
 * 2. Download service account key from Firebase Console
 * 3. Set GOOGLE_APPLICATION_CREDENTIALS environment variable or place serviceAccountKey.json
 * 4. Run: node seed_from_csv.js
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');
const csv = require('csv-parser');

// Initialize Firebase Admin
let credential;

const serviceKeyPath = path.join(__dirname, 'serviceAccountKey.json');
if (fs.existsSync(serviceKeyPath)) {
  console.log('✅ Using serviceAccountKey.json');
  credential = admin.credential.cert(require(serviceKeyPath));
} else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  console.log('✅ Using GOOGLE_APPLICATION_CREDENTIALS');
  credential = admin.credential.applicationDefault();
} else {
  console.log('⚠️  No credentials found. Trying application default...');
  credential = admin.credential.applicationDefault();
}

admin.initializeApp({
  credential: credential,
  projectId: 'speaksteps-cursor',
});

const db = admin.firestore();

// Parse CSV and group by exercise_id
function parseExercisesFromCSV(csvPath) {
  return new Promise((resolve, reject) => {
    const exercises = {};
    const rows = [];

    fs.createReadStream(csvPath)
      .pipe(csv())
      .on('data', (row) => {
        rows.push(row);
      })
      .on('end', () => {
        // Group by exercise_id
        rows.forEach(row => {
          const exerciseId = row.exercise_id;
          
          // Skip empty rows or delimiter rows (like ////)
          if (!exerciseId || exerciseId.trim() === '' || exerciseId.includes('//')) {
            return;
          }
          
          if (!exercises[exerciseId]) {
            // Create new exercise
            exercises[exerciseId] = {
              id: exerciseId,
              module: row.module,
              title: row.title,
              description: row.description,
              category: row.category,
              difficulty: parseDifficulty(row.difficulty),
              type: row.module, // 'penulisan' or 'kefahaman'
              exerciseType: row.module === 'penulisan' ? 'writing' : 'comprehension',
              questions: []
            };
          }

          // Add question to exercise
          const question = {
            id: row.question_id,
            questionType: row.question_type,
            stimulusType: row.stimulus_type,
            stimulusValue: row.stimulus_value,
            correctAnswer: row.correct_answer,
            options: [],
            imageOptions: [],
            cueHierarchy: {}
          };

          // Handle different question types
          if (row.question_type === 'word_to_pic') {
            // Comprehension: correct_answer is a number (1-4) indicating which option is correct
            // Note: CSV has columns shifted - stimulus_value actually contains the stimulus_type for word_to_pic
            // and stimulus_type actually contains stimulus_value! We need to swap them.
            
            // The CSV structure for comprehension is:
            // question_type (word_to_pic), stimulus_value (instruction text), option_1-4 (image paths), correct_answer (index)
            // We need to extract the actual word from the instruction text
            
            // Build imageOptions array from option_1, option_2, option_3, option_4
            const imageOptions = [];
            if (row.option_1) {
              imageOptions.push(row.option_1);
              question.options.push(row.option_1);
            }
            if (row.option_2) {
              imageOptions.push(row.option_2);
              question.options.push(row.option_2);
            }
            if (row.option_3) {
              imageOptions.push(row.option_3);
              question.options.push(row.option_3);
            }
            if (row.option_4) {
              imageOptions.push(row.option_4);
              question.options.push(row.option_4);
            }
            question.imageOptions = imageOptions;
            
            // correct_answer is an image path - find its index in imageOptions
            const correctImagePath = row.correct_answer.trim();
            const correctIndex = imageOptions.findIndex(img => img.trim() === correctImagePath);
            question.correctAnswer = correctIndex >= 0 ? correctIndex : 0;
            
            // Extract the word from stimulus_value (e.g., "Pilih gambar: KUCING" -> "kucing")
            const match = row.stimulus_value.match(/:\s*(.+)$/);
            if (match) {
              question.audioUrl = match[1].toLowerCase().trim();
            }
            
            // Update stimulusType and stimulusValue for display
            question.stimulusType = row.stimulus_type || "text"; // CSV has stimulus_type as the actual stimulus value here
            question.stimulusValue = row.stimulus_value; // The instruction text like "Pilih gambar: KUCING"
          } else {
            // Writing exercises (pic_to_word): no image options, text options only
            if (row.option_1) question.options.push(row.option_1);
            if (row.option_2) question.options.push(row.option_2);
            if (row.option_3) question.options.push(row.option_3);
            if (row.option_4) question.options.push(row.option_4);
            
            // For writing exercises, stimulus_type is "image" and stimulus_value is the image path
            question.stimulusType = row.stimulus_type || "image";
            question.stimulusValue = row.stimulus_value;
          }

          // Build cue hierarchy
          if (row.cue_functional) question.cueHierarchy.functional = row.cue_functional;
          if (row.cue_rhyming) question.cueHierarchy.rhyming = row.cue_rhyming;
          if (row.cue_written_initial) question.cueHierarchy.written_initial = row.cue_written_initial;
          if (row.cue_spelling) question.cueHierarchy.spelling = row.cue_spelling;
          if (row.cue_sentence_completion) question.cueHierarchy.sentence_completion = row.cue_sentence_completion;
          if (row.cue_phonemic) question.cueHierarchy.phonemic = row.cue_phonemic;
          if (row.cue_modeling) question.cueHierarchy.modeling = row.cue_modeling;

          exercises[exerciseId].questions.push(question);
        });

        resolve(Object.values(exercises));
      })
      .on('error', reject);
  });
}

function parseDifficulty(difficultyStr) {
  if (!difficultyStr) return 1; // Default to easy if undefined
  const lower = difficultyStr.toLowerCase().trim();
  if (lower === 'easy') return 1;
  if (lower === 'medium') return 2;
  if (lower === 'hard') return 3;
  return 1; // Default to easy
}

// Sample therapist and patients
const sampleTherapist = {
  uid: 'therapist_demo_001',
  email: 'therapist@speaksteps.com',
  name: 'Dr. Sarah Ahmad',
  role: 'therapist',
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
};

const samplePatients = [
  {
    uid: 'patient_demo_001',
    email: 'patient1@speaksteps.com',
    name: 'Ahmad bin Ali',
    age: 45,
    role: 'patient',
    therapistId: 'therapist_demo_001',
    condition: 'Aphasia',
    severity: 'moderate',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    uid: 'patient_demo_002',
    email: 'patient2@speaksteps.com',
    name: 'Siti binti Abdullah',
    age: 52,
    role: 'patient',
    therapistId: 'therapist_demo_001',
    condition: 'Dysarthria',
    severity: 'mild',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
];

async function seedDatabase() {
  try {
    console.log('🌱 Starting database seed from CSV...\n');

    // Read and parse CSV
    const csvPath = path.join(__dirname, 'data', 'exercises.csv');
    console.log(`📖 Reading CSV from: ${csvPath}`);
    
    if (!fs.existsSync(csvPath)) {
      throw new Error(`CSV file not found at: ${csvPath}`);
    }

    const exercises = await parseExercisesFromCSV(csvPath);
    console.log(`✅ Parsed ${exercises.length} exercises from CSV\n`);

    // Seed therapist
    console.log('👨‍⚕️ Seeding therapist...');
    await db.collection('users').doc(sampleTherapist.uid).set(sampleTherapist);
    console.log(`✅ Created therapist: ${sampleTherapist.name}\n`);

    // Seed patients
    console.log('👤 Seeding patients...');
    for (const patient of samplePatients) {
      await db.collection('users').doc(patient.uid).set(patient);
      console.log(`✅ Created patient: ${patient.name}`);
    }
    console.log('');

    // Seed exercises
    console.log('📚 Seeding exercises...');
    let exerciseCount = 0;
    let questionCount = 0;

    for (const exercise of exercises) {
      // Create exercise document
      const exerciseRef = db.collection('exercises').doc(exercise.id);
      
      const exerciseData = {
        title: exercise.title,
        description: exercise.description,
        module: exercise.module,
        category: exercise.category,
        difficulty: exercise.difficulty,
        type: exercise.type,
        exerciseType: exercise.exerciseType,
        questions: exercise.questions.map(q => ({
          id: q.id,
          questionType: q.questionType,
          stimulusType: q.stimulusType,
          stimulusValue: q.stimulusValue,
          correctAnswer: q.correctAnswer,
          options: q.options,
          imageOptions: q.imageOptions,
          audioUrl: q.audioUrl || null,
          cueHierarchy: q.cueHierarchy,
        })),
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      await exerciseRef.set(exerciseData);
      exerciseCount++;
      questionCount += exercise.questions.length;

      console.log(`✅ ${exercise.id}: ${exercise.title} (${exercise.questions.length} questions)`);
    }

    console.log('');
    console.log('═══════════════════════════════════════════════════════════');
    console.log('✅ DATABASE SEEDED SUCCESSFULLY!');
    console.log('═══════════════════════════════════════════════════════════');
    console.log(`📊 Summary:`);
    console.log(`   - Therapists: 1`);
    console.log(`   - Patients: ${samplePatients.length}`);
    console.log(`   - Exercises: ${exerciseCount}`);
    console.log(`   - Questions: ${questionCount}`);
    console.log('═══════════════════════════════════════════════════════════');
    console.log('');
    console.log('🎯 Test Credentials:');
    console.log('   Therapist: therapist@speaksteps.com');
    console.log('   Patient 1: patient1@speaksteps.com');
    console.log('   Patient 2: patient2@speaksteps.com');
    console.log('');
    console.log('💡 Next steps:');
    console.log('   1. Set up Firebase Authentication for these users');
    console.log('   2. Test the app with the seeded data');
    console.log('   3. Verify exercises load correctly in the app');
    console.log('');

  } catch (error) {
    console.error('❌ Error seeding database:', error);
    process.exit(1);
  }
}

// Run seed
seedDatabase()
  .then(() => {
    console.log('✅ Seed completed. Exiting...');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Fatal error:', error);
    process.exit(1);
  });
