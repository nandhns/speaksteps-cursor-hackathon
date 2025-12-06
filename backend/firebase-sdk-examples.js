/**
 * SpeakSteps Firebase SDK Examples
 * ================================
 * 
 * Using Firebase Modular SDK (v9+)
 * 
 * This file demonstrates:
 *   1. Firebase initialization
 *   2. Creating therapist/patient documents
 *   3. Uploading question images to Storage
 *   4. Creating question documents with image references
 *   5. Recording session trials
 *   6. Querying data
 */

// =============================================================================
// 1. FIREBASE INITIALIZATION
// =============================================================================

import { initializeApp } from 'firebase/app';
import { 
  getFirestore, 
  collection, 
  doc, 
  setDoc, 
  addDoc, 
  getDoc, 
  getDocs,
  query, 
  where, 
  orderBy,
  serverTimestamp,
  Timestamp 
} from 'firebase/firestore';
import { 
  getStorage, 
  ref, 
  uploadBytes, 
  getDownloadURL 
} from 'firebase/storage';
import { 
  getAuth, 
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword 
} from 'firebase/auth';

// Firebase configuration (replace with your project config)
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "speaksteps.firebaseapp.com",
  projectId: "speaksteps",
  storageBucket: "speaksteps.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef123456"
};

// Initialize Firebase app
const app = initializeApp(firebaseConfig);

// Get service instances
const db = getFirestore(app);       // Firestore database
const storage = getStorage(app);    // Cloud Storage
const auth = getAuth(app);          // Authentication


// =============================================================================
// 2. THERAPIST MANAGEMENT
// =============================================================================

/**
 * Create a new therapist profile after signup
 * 
 * @param {string} therapistId - Firebase Auth UID
 * @param {Object} therapistData - Therapist profile data
 */
async function createTherapistProfile(therapistId, therapistData) {
  // Reference to the therapist document
  // Path: /therapists/{therapistId}
  const therapistRef = doc(db, 'therapists', therapistId);
  
  // Prepare document data with server timestamp
  const data = {
    name: therapistData.name,
    email: therapistData.email,
    clinic: therapistData.clinic || null,
    created_at: serverTimestamp()  // Firestore sets this server-side
  };
  
  // Create the document
  await setDoc(therapistRef, data);
  
  console.log(`✅ Therapist profile created: ${therapistId}`);
  return therapistRef;
}

// Example usage:
// await createTherapistProfile(auth.currentUser.uid, {
//   name: 'Dr. Jane Smith',
//   email: 'jane.smith@clinic.com',
//   clinic: 'Speech Therapy Center'
// });


// =============================================================================
// 3. PATIENT MANAGEMENT
// =============================================================================

/**
 * Create a new patient assigned to a therapist
 * 
 * @param {Object} patientData - Patient profile data
 * @returns {Promise<DocumentReference>} Reference to created document
 */
async function createPatient(patientData) {
  // Reference to patients collection
  // Path: /patients/{auto-generated-id}
  const patientsRef = collection(db, 'patients');
  
  // Prepare document data
  const data = {
    name: patientData.name || null,           // Optional real name
    alias: patientData.alias,                  // Required display alias
    assigned_therapist: patientData.therapistId, // Must be the creating therapist
    created_at: serverTimestamp()
  };
  
  // Add document with auto-generated ID
  const docRef = await addDoc(patientsRef, data);
  
  console.log(`✅ Patient created: ${docRef.id}`);
  return docRef;
}

// Example usage:
// await createPatient({
//   alias: 'Patient A',
//   name: 'John Doe',  // Optional
//   therapistId: auth.currentUser.uid
// });


// =============================================================================
// 4. UPLOAD IMAGE AND CREATE QUESTION
// =============================================================================

/**
 * Upload an image file to Firebase Storage
 * 
 * @param {string} questionId - The question document ID
 * @param {File|Blob} imageFile - The image file to upload
 * @param {string} filename - Filename for storage (e.g., 'item.jpg')
 * @returns {Promise<string>} Download URL of uploaded image
 */
async function uploadQuestionImage(questionId, imageFile, filename) {
  // Create storage reference
  // Path: questions/{questionId}/{filename}
  const imageRef = ref(storage, `questions/${questionId}/${filename}`);
  
  // Upload the file
  // uploadBytes handles File, Blob, or Uint8Array
  const snapshot = await uploadBytes(imageRef, imageFile, {
    contentType: imageFile.type || 'image/jpeg'  // Set MIME type
  });
  
  console.log(`📤 Image uploaded: ${snapshot.metadata.fullPath}`);
  
  // Get the public download URL
  const downloadURL = await getDownloadURL(imageRef);
  
  console.log(`🔗 Download URL: ${downloadURL}`);
  return downloadURL;
}

/**
 * Create a new question document with optional image upload
 * 
 * @param {Object} questionData - Question metadata
 * @param {File|Blob|null} imageFile - Optional image file
 * @returns {Promise<string>} Created question ID
 */
async function createQuestion(questionData, imageFile = null) {
  // Generate a new document reference to get the ID first
  // This allows us to use the ID in the storage path
  const questionRef = doc(collection(db, 'questions'));
  const questionId = questionRef.id;
  
  console.log(`📝 Creating question: ${questionId}`);
  
  // Upload image if provided
  let imagePath = null;
  let imageUrl = null;
  
  if (imageFile) {
    // Upload image to storage
    const filename = `${questionData.item}.jpg`;
    imageUrl = await uploadQuestionImage(questionId, imageFile, filename);
    imagePath = `questions/${questionId}/${filename}`;
  }
  
  // Prepare question document
  const data = {
    // Required fields
    module: questionData.module,           // 'writing' or 'comprehension'
    category: questionData.category,       // 'animals', 'body_parts', 'clothing', 'food'
    item: questionData.item,               // Target word (e.g., 'dog', 'hand')
    difficulty_label: questionData.difficulty, // 'easy' or 'hard'
    
    // Image reference (if uploaded)
    image_path: imagePath,                 // Storage path
    image_url: imageUrl,                   // Download URL for quick access
    
    // Metadata
    created_by: questionData.createdBy || auth.currentUser?.uid || 'admin',
    tags: questionData.tags || [],         // Optional tags for filtering
    created_at: serverTimestamp()
  };
  
  // Create the document with our pre-generated ID
  await setDoc(questionRef, data);
  
  console.log(`✅ Question created: ${questionId}`);
  return questionId;
}

// Example usage:
// 
// // With image upload (browser environment)
// const fileInput = document.getElementById('imageInput');
// const imageFile = fileInput.files[0];
// 
// await createQuestion({
//   module: 'writing',
//   category: 'animals',
//   item: 'dog',
//   difficulty: 'easy',
//   tags: ['common', 'pet']
// }, imageFile);
//
// // Without image
// await createQuestion({
//   module: 'comprehension',
//   category: 'body_parts',
//   item: 'hand',
//   difficulty: 'easy'
// });


// =============================================================================
// 5. SESSION AND TRIAL RECORDING
// =============================================================================

/**
 * Start a new therapy session
 * 
 * @param {string} patientId - Patient document ID
 * @param {string} therapistId - Therapist document ID
 * @param {string} deviceType - 'mobile' or 'web'
 * @returns {Promise<string>} Created session ID
 */
async function startSession(patientId, therapistId, deviceType) {
  // Create session document
  // Path: /sessions/{auto-generated-id}
  const sessionsRef = collection(db, 'sessions');
  
  const data = {
    patient_id: patientId,
    therapist_id: therapistId,
    start_time: serverTimestamp(),
    device_type: deviceType,  // 'mobile' or 'web'
    end_time: null,           // Set when session ends
    trial_count: 0            // Updated as trials are added
  };
  
  const sessionRef = await addDoc(sessionsRef, data);
  
  console.log(`🎬 Session started: ${sessionRef.id}`);
  return sessionRef.id;
}

/**
 * Record a trial (question attempt) within a session
 * 
 * @param {string} sessionId - Parent session ID
 * @param {Object} trialData - Trial result data
 * @returns {Promise<string>} Created trial ID
 */
async function recordTrial(sessionId, trialData) {
  // Create trial in subcollection
  // Path: /sessions/{sessionId}/trials/{auto-generated-id}
  const trialsRef = collection(db, 'sessions', sessionId, 'trials');
  
  const data = {
    question_id: trialData.questionId,
    response_time_seconds: trialData.responseTime,
    correct: trialData.correct,              // boolean or 0/1
    cue_given: trialData.cueGiven || false,
    cue_type: trialData.cueType || null,     // 'functional', 'phonemic', etc.
    cue_stage: trialData.cueStage || 0,      // 0-7
    user_answer: trialData.userAnswer || null,
    timestamp: serverTimestamp()
  };
  
  const trialRef = await addDoc(trialsRef, data);
  
  console.log(`📊 Trial recorded: ${trialRef.id}`);
  return trialRef.id;
}

// Example usage:
//
// const sessionId = await startSession('patient123', 'therapist456', 'mobile');
//
// await recordTrial(sessionId, {
//   questionId: 'question789',
//   responseTime: 15.5,
//   correct: true,
//   cueGiven: false
// });
//
// await recordTrial(sessionId, {
//   questionId: 'question101',
//   responseTime: 45.2,
//   correct: false,
//   cueGiven: true,
//   cueType: 'phonemic',
//   cueStage: 3,
//   userAnswer: 'cat'
// });


// =============================================================================
// 6. QUERYING DATA
// =============================================================================

/**
 * Get all questions for a specific module and category
 * 
 * @param {string} module - 'writing' or 'comprehension'
 * @param {string} category - 'animals', 'body_parts', 'clothing', 'food'
 * @returns {Promise<Array>} Array of question documents
 */
async function getQuestionsByCategory(module, category) {
  // Build query with filters
  const questionsRef = collection(db, 'questions');
  const q = query(
    questionsRef,
    where('module', '==', module),
    where('category', '==', category),
    orderBy('created_at', 'desc')
  );
  
  // Execute query
  const snapshot = await getDocs(q);
  
  // Map documents to data array
  const questions = snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));
  
  console.log(`📚 Found ${questions.length} questions`);
  return questions;
}

/**
 * Get all sessions for a patient
 * 
 * @param {string} patientId - Patient document ID
 * @returns {Promise<Array>} Array of session documents
 */
async function getPatientSessions(patientId) {
  const sessionsRef = collection(db, 'sessions');
  const q = query(
    sessionsRef,
    where('patient_id', '==', patientId),
    orderBy('start_time', 'desc')
  );
  
  const snapshot = await getDocs(q);
  
  return snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));
}

/**
 * Get all trials for a session
 * 
 * @param {string} sessionId - Session document ID
 * @returns {Promise<Array>} Array of trial documents
 */
async function getSessionTrials(sessionId) {
  // Query subcollection
  const trialsRef = collection(db, 'sessions', sessionId, 'trials');
  const q = query(trialsRef, orderBy('timestamp', 'asc'));
  
  const snapshot = await getDocs(q);
  
  return snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  }));
}


// =============================================================================
// 7. COMPLETE WORKFLOW EXAMPLE
// =============================================================================

/**
 * Complete example: Sign in, create question with image, start session, record trials
 */
async function completeWorkflowExample() {
  try {
    // Step 1: Sign in as therapist
    console.log('🔐 Signing in...');
    const userCredential = await signInWithEmailAndPassword(
      auth, 
      'therapist@example.com', 
      'password123'
    );
    const therapistId = userCredential.user.uid;
    console.log(`✅ Signed in as: ${therapistId}`);
    
    // Step 2: Create a patient (if new)
    console.log('\n👤 Creating patient...');
    const patientRef = await createPatient({
      alias: 'Patient Alpha',
      therapistId: therapistId
    });
    const patientId = patientRef.id;
    
    // Step 3: Create a question (simulated image)
    console.log('\n📝 Creating question...');
    // In browser: const imageFile = document.getElementById('imageInput').files[0];
    // For demo, we'll skip the image
    const questionId = await createQuestion({
      module: 'writing',
      category: 'animals',
      item: 'elephant',
      difficulty: 'hard',
      tags: ['large', 'zoo']
    });
    
    // Step 4: Start a therapy session
    console.log('\n🎬 Starting session...');
    const sessionId = await startSession(patientId, therapistId, 'mobile');
    
    // Step 5: Record some trials
    console.log('\n📊 Recording trials...');
    
    // Trial 1: Correct answer, no cue needed
    await recordTrial(sessionId, {
      questionId: questionId,
      responseTime: 8.5,
      correct: true,
      cueGiven: false
    });
    
    // Trial 2: Incorrect, needed a cue
    await recordTrial(sessionId, {
      questionId: questionId,
      responseTime: 35.2,
      correct: false,
      cueGiven: true,
      cueType: 'phonemic',
      cueStage: 2,
      userAnswer: 'elefant'  // Misspelled
    });
    
    // Trial 3: Correct after cue
    await recordTrial(sessionId, {
      questionId: questionId,
      responseTime: 12.0,
      correct: true,
      cueGiven: true,
      cueType: 'written_initial',
      cueStage: 4
    });
    
    // Step 6: Query results
    console.log('\n📈 Fetching session data...');
    const trials = await getSessionTrials(sessionId);
    console.log(`Session has ${trials.length} trials`);
    
    const correctCount = trials.filter(t => t.correct).length;
    const accuracy = (correctCount / trials.length * 100).toFixed(1);
    console.log(`Accuracy: ${accuracy}%`);
    
    console.log('\n✅ Workflow complete!');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    throw error;
  }
}


// =============================================================================
// EXPORTS (for use as module)
// =============================================================================

export {
  // Firebase instances
  app,
  db,
  storage,
  auth,
  
  // Therapist functions
  createTherapistProfile,
  
  // Patient functions
  createPatient,
  
  // Question functions
  uploadQuestionImage,
  createQuestion,
  getQuestionsByCategory,
  
  // Session functions
  startSession,
  recordTrial,
  getPatientSessions,
  getSessionTrials,
  
  // Example
  completeWorkflowExample
};

