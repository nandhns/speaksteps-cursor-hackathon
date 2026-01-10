/**
 * Firestore Seed Script for SpeakSteps
 * 
 * This script seeds the Firestore database with:
 * - Test therapist account
 * - Test patient accounts  
 * - Sample exercises
 * 
 * Usage:
 * 1. npm install firebase-admin
 * 2. Download service account key from Firebase Console
 * 3. Set GOOGLE_APPLICATION_CREDENTIALS environment variable
 * 4. Run: node seed_firestore.js
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin
// Try multiple credential sources
let credential;

// 1. Try to load serviceAccountKey.json from current directory
const serviceKeyPath = path.join(__dirname, 'serviceAccountKey.json');
if (fs.existsSync(serviceKeyPath)) {
  console.log('✅ Using serviceAccountKey.json');
  credential = admin.credential.cert(require(serviceKeyPath));
}
// 2. Try GOOGLE_APPLICATION_CREDENTIALS environment variable
else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  console.log('✅ Using GOOGLE_APPLICATION_CREDENTIALS');
  credential = admin.credential.applicationDefault();
}
// 3. Fallback to application default (for Cloud environments)
else {
  console.log('⚠️  No credentials found. Trying application default...');
  console.log('');
  console.log('If this fails, please:');
  console.log('1. Download service account key from Firebase Console');
  console.log('2. Save as serviceAccountKey.json in backend folder');
  console.log('OR');
  console.log('3. Use seed_firestore_web.html in a browser instead');
  console.log('');
  credential = admin.credential.applicationDefault();
}

admin.initializeApp({
  credential: credential,
  projectId: 'speaksteps-cursor',
});

const db = admin.firestore();

// Sample exercises data - Bahasa Melayu
const exercises = [
  // ============================================================================
  // MODULE 1: COMPREHENSION - Picture matching with word (written/audio)
  // ============================================================================
  
  // Comprehension - Animals - Easy (different contexts)
  {
    id: 'comprehension_animals_easy',
    title: 'Haiwan - Mudah',
    description: 'Pilih gambar yang betul mengikut perkataan',
    type: 'comprehension',
    category: 'animal',
    exerciseType: 'comprehension',
    options: [],
    difficulty: 1,
    questions: [
      {
        id: 'c_animal_easy_1',
        correctAnswer: 'kucing',
        options: ['kucing', 'tangan', 'baju', 'nasi'], // Different contexts - easy
        imageOptions: [],
        audioUrl: 'kucing', // TTS will speak "kucing"
        cueHierarchy: {
          functional: 'Haiwan ini mengeong dan menangkap tikus',
          rhyming: 'Ia berima dengan "gasing"',
          written_initial: 'k_ _ _ _ _',
          spelling: 'k-u-c-i-n-g',
          sentence_completion: 'Saya ada seekor _____ di rumah',
          phonemic: 'Ia bermula dengan bunyi "ku"',
          modeling: 'kucing',
        },
      },
      {
        id: 'c_animal_easy_2',
        correctAnswer: 'ayam',
        options: ['ayam', 'mata', 'kasut', 'epal'], // Different contexts - easy
        imageOptions: [],
        audioUrl: 'ayam',
        cueHierarchy: {
          functional: 'Haiwan ini berkokok dan bertelur',
          rhyming: 'Ia berima dengan "ayam"',
          written_initial: 'a_ _ _',
          spelling: 'a-y-a-m',
          sentence_completion: 'Pagi tadi saya dengar bunyi _____ berkokok',
          phonemic: 'Ia bermula dengan bunyi "a"',
          modeling: 'ayam',
        },
      },
      {
        id: 'c_animal_easy_3',
        correctAnswer: 'ikan',
        options: ['ikan', 'hidung', 'topi', 'susu'], // Different contexts - easy
        imageOptions: [],
        audioUrl: 'ikan',
        cueHierarchy: {
          functional: 'Haiwan ini hidup dalam air dan mempunyai sisik',
          rhyming: 'Ia berima dengan "makan"',
          written_initial: 'i_ _ _',
          spelling: 'i-k-a-n',
          sentence_completion: 'Saya makan _____ goreng untuk makan malam',
          phonemic: 'Ia bermula dengan bunyi "i"',
          modeling: 'ikan',
        },
      },
    ],
  },
  
  // Comprehension - Animals - Hard (same context)
  {
    id: 'comprehension_animals_hard',
    title: 'Haiwan - Sukar',
    description: 'Pilih gambar yang betul mengikut perkataan',
    type: 'comprehension',
    category: 'animal',
    exerciseType: 'comprehension',
    options: [],
    difficulty: 3,
    questions: [
      {
        id: 'c_animal_hard_1',
        correctAnswer: 'burung',
        options: ['burung', 'ayam', 'itik', 'helang'], // Same context (all birds) - hard
        imageOptions: [],
        audioUrl: 'burung',
        cueHierarchy: {
          functional: 'Haiwan ini boleh terbang dan membuat sarang di pokok',
          rhyming: 'Ia berima dengan "sarung"',
          written_initial: 'b_ _ _ _ _',
          spelling: 'b-u-r-u-n-g',
          sentence_completion: 'Saya nampak seekor _____ terbang di langit',
          phonemic: 'Ia bermula dengan bunyi "bu"',
          modeling: 'burung',
        },
      },
      {
        id: 'c_animal_hard_2',
        correctAnswer: 'kambing',
        options: ['kambing', 'lembu', 'kerbau', 'biri-biri'], // Same context (livestock) - hard
        imageOptions: [],
        audioUrl: 'kambing',
        cueHierarchy: {
          functional: 'Haiwan ini mengembek dan mempunyai bulu tebal',
          rhyming: 'Ia berima dengan "gading"',
          written_initial: 'k_ _ _ _ _ _',
          spelling: 'k-a-m-b-i-n-g',
          sentence_completion: 'Pak Ali ternakan _____ di kampung',
          phonemic: 'Ia bermula dengan bunyi "kam"',
          modeling: 'kambing',
        },
      },
    ],
  },
  
  // Comprehension - Body Parts - Easy
  {
    id: 'comprehension_body_easy',
    title: 'Anggota Badan - Mudah',
    description: 'Pilih gambar yang betul mengikut perkataan',
    type: 'comprehension',
    category: 'bodyParts',
    exerciseType: 'comprehension',
    options: [],
    difficulty: 1,
    questions: [
      {
        id: 'c_body_easy_1',
        correctAnswer: 'tangan',
        options: ['tangan', 'kucing', 'baju', 'nasi'], // Different contexts - easy
        imageOptions: [],
        audioUrl: 'tangan',
        cueHierarchy: {
          functional: 'Bahagian badan ini digunakan untuk memegang',
          rhyming: 'Ia berima dengan "angan"',
          written_initial: 't_ _ _ _ _',
          spelling: 't-a-n-g-a-n',
          sentence_completion: 'Saya gunakan _____ untuk menulis',
          phonemic: 'Ia bermula dengan bunyi "ta"',
          modeling: 'tangan',
        },
      },
      {
        id: 'c_body_easy_2',
        correctAnswer: 'mata',
        options: ['mata', 'ayam', 'kasut', 'epal'], // Different contexts - easy
        imageOptions: [],
        audioUrl: 'mata',
        cueHierarchy: {
          functional: 'Bahagian badan ini digunakan untuk melihat',
          rhyming: 'Ia berima dengan "kata"',
          written_initial: 'm_ _ _',
          spelling: 'm-a-t-a',
          sentence_completion: 'Saya tutup _____ untuk tidur',
          phonemic: 'Ia bermula dengan bunyi "ma"',
          modeling: 'mata',
        },
      },
    ],
  },
  
  // Comprehension - Body Parts - Hard
  {
    id: 'comprehension_body_hard',
    title: 'Anggota Badan - Sukar',
    description: 'Pilih gambar yang betul mengikut perkataan',
    type: 'comprehension',
    category: 'bodyParts',
    exerciseType: 'comprehension',
    options: [],
    difficulty: 3,
    questions: [
      {
        id: 'c_body_hard_1',
        correctAnswer: 'siku',
        options: ['siku', 'pergelangan', 'lutut', 'bahu'], // Same context (joints) - hard
        imageOptions: [],
        audioUrl: 'siku',
        cueHierarchy: {
          functional: 'Bahagian badan ini menghubungkan lengan atas dengan lengan bawah',
          rhyming: 'Ia berima dengan "liku"',
          written_initial: 's_ _ _',
          spelling: 's-i-k-u',
          sentence_completion: 'Saya bengkokkan _____ untuk membawa beg',
          phonemic: 'Ia bermula dengan bunyi "si"',
          modeling: 'siku',
        },
      },
    ],
  },
  
  // Comprehension - Food - Easy
  {
    id: 'comprehension_food_easy',
    title: 'Makanan - Mudah',
    description: 'Pilih gambar yang betul mengikut perkataan',
    type: 'comprehension',
    category: 'food',
    exerciseType: 'comprehension',
    options: [],
    difficulty: 1,
    questions: [
      {
        id: 'c_food_easy_1',
        correctAnswer: 'nasi',
        options: ['nasi', 'tangan', 'baju', 'kucing'], // Different contexts - easy
        imageOptions: [],
        audioUrl: 'nasi',
        cueHierarchy: {
          functional: 'Makanan ini dibuat dari beras dan dimakan setiap hari',
          rhyming: 'Ia berima dengan "hati"',
          written_initial: 'n_ _ _',
          spelling: 'n-a-s-i',
          sentence_completion: 'Saya makan _____ untuk makan tengah hari',
          phonemic: 'Ia bermula dengan bunyi "na"',
          modeling: 'nasi',
        },
      },
      {
        id: 'c_food_easy_2',
        correctAnswer: 'roti',
        options: ['roti', 'mata', 'kasut', 'ayam'], // Different contexts - easy
        imageOptions: [],
        audioUrl: 'roti',
        cueHierarchy: {
          functional: 'Makanan ini dibuat dari tepung dan boleh disapu dengan mentega',
          rhyming: 'Ia berima dengan "doti"',
          written_initial: 'r_ _ _',
          spelling: 'r-o-t-i',
          sentence_completion: 'Saya makan _____ dengan kaya untuk sarapan',
          phonemic: 'Ia bermula dengan bunyi "ro"',
          modeling: 'roti',
        },
      },
    ],
  },
  
  // Comprehension - Food - Hard
  {
    id: 'comprehension_food_hard',
    title: 'Makanan - Sukar',
    description: 'Pilih gambar yang betul mengikut perkataan',
    type: 'comprehension',
    category: 'food',
    exerciseType: 'comprehension',
    options: [],
    difficulty: 3,
    questions: [
      {
        id: 'c_food_hard_1',
        correctAnswer: 'pisang',
        options: ['pisang', 'epal', 'oren', 'betik'], // Same context (fruits) - hard
        imageOptions: [],
        audioUrl: 'pisang',
        cueHierarchy: {
          functional: 'Buah ini panjang, kuning, dan monyet suka memakannya',
          rhyming: 'Ia berima dengan "pisang"',
          written_initial: 'p_ _ _ _ _',
          spelling: 'p-i-s-a-n-g',
          sentence_completion: 'Saya beli segugus _____ di pasar',
          phonemic: 'Ia bermula dengan bunyi "pi"',
          modeling: 'pisang',
        },
      },
    ],
  },
  
  // Comprehension - Clothing - Easy
  {
    id: 'comprehension_clothing_easy',
    title: 'Pakaian - Mudah',
    description: 'Pilih gambar yang betul mengikut perkataan',
    type: 'comprehension',
    category: 'clothing',
    exerciseType: 'comprehension',
    options: [],
    difficulty: 1,
    questions: [
      {
        id: 'c_clothing_easy_1',
        correctAnswer: 'baju',
        options: ['baju', 'tangan', 'nasi', 'kucing'], // Different contexts - easy
        imageOptions: [],
        audioUrl: 'baju',
        cueHierarchy: {
          functional: 'Pakaian ini dipakai di bahagian badan atas',
          rhyming: 'Ia berima dengan "laju"',
          written_initial: 'b_ _ _',
          spelling: 'b-a-j-u',
          sentence_completion: 'Saya pakai _____ baru untuk pergi kenduri',
          phonemic: 'Ia bermula dengan bunyi "ba"',
          modeling: 'baju',
        },
      },
      {
        id: 'c_clothing_easy_2',
        correctAnswer: 'kasut',
        options: ['kasut', 'mata', 'roti', 'ayam'], // Different contexts - easy
        imageOptions: [],
        audioUrl: 'kasut',
        cueHierarchy: {
          functional: 'Pakaian ini dipakai di kaki',
          rhyming: 'Ia berima dengan "kasut"',
          written_initial: 'k_ _ _ _',
          spelling: 'k-a-s-u-t',
          sentence_completion: 'Saya pakai _____ untuk pergi sekolah',
          phonemic: 'Ia bermula dengan bunyi "ka"',
          modeling: 'kasut',
        },
      },
    ],
  },
  
  // Comprehension - Clothing - Hard
  {
    id: 'comprehension_clothing_hard',
    title: 'Pakaian - Sukar',
    description: 'Pilih gambar yang betul mengikut perkataan',
    type: 'comprehension',
    category: 'clothing',
    exerciseType: 'comprehension',
    options: [],
    difficulty: 3,
    questions: [
      {
        id: 'c_clothing_hard_1',
        correctAnswer: 'jaket',
        options: ['jaket', 'kot', 'sweater', 'baju'], // Same context (upper wear) - hard
        imageOptions: [],
        audioUrl: 'jaket',
        cueHierarchy: {
          functional: 'Pakaian ini dipakai apabila sejuk untuk menutup baju',
          rhyming: 'Ia berima dengan "raket"',
          written_initial: 'j_ _ _ _',
          spelling: 'j-a-k-e-t',
          sentence_completion: 'Saya pakai _____ apabila pergi ke Cameron Highlands',
          phonemic: 'Ia bermula dengan bunyi "ja"',
          modeling: 'jaket',
        },
      },
    ],
  },
  
  // ============================================================================
  // MODULE 2: NAMING/WRITING - Fill in the blank (picture to word)
  // ============================================================================
  
  // Writing exercises - Animals - Easy (2-3 syllables, familiar)
  {
    id: 'writing_animals_easy',
    title: 'Nama Haiwan - Mudah',
    description: 'Taip nama haiwan yang ditunjukkan dalam gambar',
    type: 'writing',
    category: 'animal',
    exerciseType: 'writing',
    options: [],
    difficulty: 1,
    questions: [
      {
        id: 'w_animal_easy_1',
        imageUrl: 'animals_cat.png',
        correctAnswer: 'kucing',
        cueHierarchy: {
          functional: 'Haiwan ini mengeong dan menangkap tikus',
          rhyming: 'Ia berima dengan "gasing"',
          written_initial: 'k_ _ _ _ _',
          spelling: 'k-u-c-i-n-g',
          sentence_completion: 'Saya ada seekor _____ di rumah',
          phonemic: 'Ia bermula dengan bunyi "ku"',
          modeling: 'kucing',
        },
      },
      {
        id: 'w_animal_easy_2',
        imageUrl: 'animals_dog.png',
        correctAnswer: 'anjing',
        cueHierarchy: {
          functional: 'Haiwan ini menyalak dan setia kepada tuannya',
          rhyming: 'Ia berima dengan "ganjil" (tidak berima betul-betul)',
          written_initial: 'a_ _ _ _ _',
          spelling: 'a-n-j-i-n-g',
          sentence_completion: 'Jiran saya ada _____ yang besar',
          phonemic: 'Ia bermula dengan bunyi "an"',
          modeling: 'anjing',
        },
      },
      {
        id: 'w_animal_easy_3',
        imageUrl: 'animals_bird.png',
        correctAnswer: 'burung',
        cueHierarchy: {
          functional: 'Haiwan ini boleh terbang dan membuat sarang',
          rhyming: 'Ia berima dengan "sarung"',
          written_initial: 'b_ _ _ _ _',
          spelling: 'b-u-r-u-n-g',
          sentence_completion: 'Saya nampak seekor _____ terbang',
          phonemic: 'Ia bermula dengan bunyi "bu"',
          modeling: 'burung',
        },
      },
      {
        id: 'w_animal_easy_4',
        imageUrl: 'animals_fish.png',
        correctAnswer: 'ikan',
        cueHierarchy: {
          functional: 'Haiwan ini hidup dalam air dan ada sisik',
          rhyming: 'Ia berima dengan "makan"',
          written_initial: 'i_ _ _',
          spelling: 'i-k-a-n',
          sentence_completion: 'Saya beli _____ di pasar',
          phonemic: 'Ia bermula dengan bunyi "i"',
          modeling: 'ikan',
        },
      },
    ],
  },
  
  // Writing exercises - Animals - Medium (3-4 syllables, moderately familiar)
  {
    id: 'writing_animals_medium',
    title: 'Nama Haiwan - Sederhana',
    description: 'Taip nama haiwan yang ditunjukkan dalam gambar',
    type: 'writing',
    category: 'animal',
    exerciseType: 'writing',
    options: [],
    difficulty: 2,
    questions: [
      {
        id: 'w_animal_med_1',
        imageUrl: 'animals_cow.png',
        correctAnswer: 'lembu',
        cueHierarchy: {
          functional: 'Haiwan ini memberikan susu dan diternak di ladang',
          rhyming: 'Ia berima dengan "embu"',
          written_initial: 'l_ _ _ _',
          spelling: 'l-e-m-b-u',
          sentence_completion: 'Petani ternakan _____ untuk susu',
          phonemic: 'Ia bermula dengan bunyi "lem"',
          modeling: 'lembu',
        },
      },
      {
        id: 'w_animal_med_2',
        imageUrl: 'animals_duck.png',
        correctAnswer: 'itik',
        cueHierarchy: {
          functional: 'Haiwan ini seperti ayam tetapi boleh berenang',
          rhyming: 'Ia berima dengan "litik"',
          written_initial: 'i_ _ _',
          spelling: 'i-t-i-k',
          sentence_completion: 'Pak Mat ternakan _____ di sawah',
          phonemic: 'Ia bermula dengan bunyi "i"',
          modeling: 'itik',
        },
      },
    ],
  },
  
  // Writing exercises - Animals - Hard (4+ syllables, complex/unfamiliar)
  {
    id: 'writing_animals_hard',
    title: 'Nama Haiwan - Sukar',
    description: 'Taip nama haiwan yang ditunjukkan dalam gambar',
    type: 'writing',
    category: 'animal',
    exerciseType: 'writing',
    options: [],
    difficulty: 3,
    questions: [
      {
        id: 'w_animal_hard_1',
        imageUrl: 'animals_horse.png',
        correctAnswer: 'kuda',
        cueHierarchy: {
          functional: 'Haiwan ini boleh ditunggang dan berlari laju',
          rhyming: 'Ia berima dengan "muda"',
          written_initial: 'k_ _ _',
          spelling: 'k-u-d-a',
          sentence_completion: 'Raja naik _____ ke medan perang',
          phonemic: 'Ia bermula dengan bunyi "ku"',
          modeling: 'kuda',
        },
      },
      {
        id: 'w_animal_hard_2',
        imageUrl: 'animals_frog.png',
        correctAnswer: 'katak',
        cueHierarchy: {
          functional: 'Haiwan ini melompat dan hidup di dalam dan luar air',
          rhyming: 'Ia berima dengan "batak"',
          written_initial: 'k_ _ _ _',
          spelling: 'k-a-t-a-k',
          sentence_completion: 'Saya dengar bunyi _____ berbunyi di malam hari',
          phonemic: 'Ia bermula dengan bunyi "ka"',
          modeling: 'katak',
        },
      },
    ],
  },
  
  // Writing exercises - Body Parts - Easy
  {
    id: 'writing_body_easy',
    title: 'Anggota Badan - Mudah',
    description: 'Taip nama bahagian badan yang ditunjukkan',
    type: 'writing',
    category: 'bodyParts',
    exerciseType: 'writing',
    options: [],
    difficulty: 1,
    questions: [
      {
        id: 'w_body_easy_1',
        imageUrl: 'body_parts_hand.png',
        correctAnswer: 'tangan',
        cueHierarchy: {
          functional: 'Bahagian badan ini digunakan untuk memegang',
          rhyming: 'Ia berima dengan "angan"',
          written_initial: 't_ _ _ _ _',
          spelling: 't-a-n-g-a-n',
          sentence_completion: 'Saya gunakan _____ untuk menulis',
          phonemic: 'Ia bermula dengan bunyi "ta"',
          modeling: 'tangan',
        },
      },
      {
        id: 'w_body_easy_2',
        imageUrl: 'body_parts_eye.png',
        correctAnswer: 'mata',
        cueHierarchy: {
          functional: 'Bahagian badan ini digunakan untuk melihat',
          rhyming: 'Ia berima dengan "kata"',
          written_initial: 'm_ _ _',
          spelling: 'm-a-t-a',
          sentence_completion: 'Saya tutup _____ untuk tidur',
          phonemic: 'Ia bermula dengan bunyi "ma"',
          modeling: 'mata',
        },
      },
      {
        id: 'w_body_easy_3',
        imageUrl: 'body_parts_nose.png',
        correctAnswer: 'hidung',
        cueHierarchy: {
          functional: 'Bahagian badan ini digunakan untuk bau',
          rhyming: 'Ia berima dengan "hidung"',
          written_initial: 'h_ _ _ _ _',
          spelling: 'h-i-d-u-n-g',
          sentence_completion: 'Saya guna _____ untuk bau bunga',
          phonemic: 'Ia bermula dengan bunyi "hi"',
          modeling: 'hidung',
        },
      },
      {
        id: 'w_body_easy_4',
        imageUrl: 'body_parts_ear.png',
        correctAnswer: 'telinga',
        cueHierarchy: {
          functional: 'Bahagian badan ini digunakan untuk dengar',
          rhyming: 'Ia berima dengan "melinga"',
          written_initial: 't_ _ _ _ _ _',
          spelling: 't-e-l-i-n-g-a',
          sentence_completion: 'Saya guna _____ untuk dengar muzik',
          phonemic: 'Ia bermula dengan bunyi "te"',
          modeling: 'telinga',
        },
      },
    ],
  },
  
  // Writing exercises - Body Parts - Hard
  {
    id: 'writing_body_hard',
    title: 'Anggota Badan - Sukar',
    description: 'Taip nama bahagian badan yang ditunjukkan',
    type: 'writing',
    category: 'bodyParts',
    exerciseType: 'writing',
    options: [],
    difficulty: 3,
    questions: [
      {
        id: 'w_body_hard_1',
        imageUrl: 'body_parts_knee.png',
        correctAnswer: 'lutut',
        cueHierarchy: {
          functional: 'Bahagian badan ini di tengah kaki, untuk berlutut',
          rhyming: 'Ia berima dengan "butut"',
          written_initial: 'l_ _ _ _',
          spelling: 'l-u-t-u-t',
          sentence_completion: 'Saya sakit _____ bila naik tangga',
          phonemic: 'Ia bermula dengan bunyi "lu"',
          modeling: 'lutut',
        },
      },
      {
        id: 'w_body_hard_2',
        imageUrl: 'body_parts_arm.png',
        correctAnswer: 'lengan',
        cueHierarchy: {
          functional: 'Bahagian badan ini dari bahu hingga tangan',
          rhyming: 'Ia berima dengan "tengah"',
          written_initial: 'l_ _ _ _ _',
          spelling: 'l-e-n-g-a-n',
          sentence_completion: 'Saya patahkan _____ semasa bermain bola',
          phonemic: 'Ia bermula dengan bunyi "le"',
          modeling: 'lengan',
        },
      },
    ],
  },
  
  // Writing exercises - Food - Easy
  {
    id: 'writing_food_easy',
    title: 'Makanan - Mudah',
    description: 'Taip nama makanan yang ditunjukkan',
    type: 'writing',
    category: 'food',
    exerciseType: 'writing',
    options: [],
    difficulty: 1,
    questions: [
      {
        id: 'w_food_easy_1',
        imageUrl: 'food_rice.png',
        correctAnswer: 'nasi',
        cueHierarchy: {
          functional: 'Makanan ini dibuat dari beras',
          rhyming: 'Ia berima dengan "hati"',
          written_initial: 'n_ _ _',
          spelling: 'n-a-s-i',
          sentence_completion: 'Saya makan _____ setiap hari',
          phonemic: 'Ia bermula dengan bunyi "na"',
          modeling: 'nasi',
        },
      },
      {
        id: 'w_food_easy_2',
        imageUrl: 'food_bread.png',
        correctAnswer: 'roti',
        cueHierarchy: {
          functional: 'Makanan ini dibuat dari tepung dan boleh disapu dengan mentega',
          rhyming: 'Ia berima dengan "doti"',
          written_initial: 'r_ _ _',
          spelling: 'r-o-t-i',
          sentence_completion: 'Saya sapu _____ dengan kaya',
          phonemic: 'Ia bermula dengan bunyi "ro"',
          modeling: 'roti',
        },
      },
      {
        id: 'w_food_easy_3',
        imageUrl: 'food_milk.png',
        correctAnswer: 'susu',
        cueHierarchy: {
          functional: 'Minuman putih yang datang dari lembu',
          rhyming: 'Ia berima dengan "musu"',
          written_initial: 's_ _ _',
          spelling: 's-u-s-u',
          sentence_completion: 'Bayi minum _____ dari botol',
          phonemic: 'Ia bermula dengan bunyi "su"',
          modeling: 'susu',
        },
      },
      {
        id: 'w_food_easy_4',
        imageUrl: 'food_egg.png',
        correctAnswer: 'telur',
        cueHierarchy: {
          functional: 'Makanan ini dikeluarkan oleh ayam',
          rhyming: 'Ia berima dengan "selut"',
          written_initial: 't_ _ _ _',
          spelling: 't-e-l-u-r',
          sentence_completion: 'Saya makan _____ goreng untuk sarapan',
          phonemic: 'Ia bermula dengan bunyi "te"',
          modeling: 'telur',
        },
      },
    ],
  },
  
  // Writing exercises - Food - Hard
  {
    id: 'writing_food_hard',
    title: 'Makanan - Sukar',
    description: 'Taip nama makanan yang ditunjukkan',
    type: 'writing',
    category: 'food',
    exerciseType: 'writing',
    options: [],
    difficulty: 3,
    questions: [
      {
        id: 'w_food_hard_1',
        imageUrl: 'food_banana.png',
        correctAnswer: 'pisang',
        cueHierarchy: {
          functional: 'Buah yang panjang dan kuning, monyet suka makan',
          rhyming: 'Ia berima dengan "pisang"',
          written_initial: 'p_ _ _ _ _',
          spelling: 'p-i-s-a-n-g',
          sentence_completion: 'Saya goreng _____ untuk minum petang',
          phonemic: 'Ia bermula dengan bunyi "pi"',
          modeling: 'pisang',
        },
      },
      {
        id: 'w_food_hard_2',
        imageUrl: 'food_carrot.png',
        correctAnswer: 'lobak',
        cueHierarchy: {
          functional: 'Sayur oren yang panjang, arnab suka makan',
          rhyming: 'Ia berima dengan "kobak"',
          written_initial: 'l_ _ _ _',
          spelling: 'l-o-b-a-k',
          sentence_completion: 'Saya masak sup dengan _____ merah',
          phonemic: 'Ia bermula dengan bunyi "lo"',
          modeling: 'lobak',
        },
      },
    ],
  },
  
  // Writing exercises - Clothing - Easy
  {
    id: 'writing_clothing_easy',
    title: 'Pakaian - Mudah',
    description: 'Taip nama pakaian yang ditunjukkan',
    type: 'writing',
    category: 'clothing',
    exerciseType: 'writing',
    options: [],
    difficulty: 1,
    questions: [
      {
        id: 'w_clothing_easy_1',
        imageUrl: 'clothing_shirt.png',
        correctAnswer: 'baju',
        cueHierarchy: {
          functional: 'Pakaian ini dipakai di bahagian badan atas',
          rhyming: 'Ia berima dengan "laju"',
          written_initial: 'b_ _ _',
          spelling: 'b-a-j-u',
          sentence_completion: 'Saya pakai _____ baru hari ini',
          phonemic: 'Ia bermula dengan bunyi "ba"',
          modeling: 'baju',
        },
      },
      {
        id: 'w_clothing_easy_2',
        imageUrl: 'clothing_pants.png',
        correctAnswer: 'seluar',
        cueHierarchy: {
          functional: 'Pakaian ini dipakai di kaki',
          rhyming: 'Ia berima dengan "keluar"',
          written_initial: 's_ _ _ _ _',
          spelling: 's-e-l-u-a-r',
          sentence_completion: 'Saya pakai _____ jeans ke sekolah',
          phonemic: 'Ia bermula dengan bunyi "se"',
          modeling: 'seluar',
        },
      },
      {
        id: 'w_clothing_easy_3',
        imageUrl: 'clothing_shoe.png',
        correctAnswer: 'kasut',
        cueHierarchy: {
          functional: 'Pakaian ini dipakai di kaki untuk melindungi',
          rhyming: 'Ia berima dengan "kasut"',
          written_initial: 'k_ _ _ _',
          spelling: 'k-a-s-u-t',
          sentence_completion: 'Saya ikat tali _____ sebelum berlari',
          phonemic: 'Ia bermula dengan bunyi "ka"',
          modeling: 'kasut',
        },
      },
      {
        id: 'w_clothing_easy_4',
        imageUrl: 'clothing_hat.png',
        correctAnswer: 'topi',
        cueHierarchy: {
          functional: 'Pakaian ini dipakai di kepala',
          rhyming: 'Ia berima dengan "kopi"',
          written_initial: 't_ _ _',
          spelling: 't-o-p-i',
          sentence_completion: 'Saya pakai _____ bila panas',
          phonemic: 'Ia bermula dengan bunyi "to"',
          modeling: 'topi',
        },
      },
    ],
  },
  
  // Writing exercises - Clothing - Hard
  {
    id: 'writing_clothing_hard',
    title: 'Pakaian - Sukar',
    description: 'Taip nama pakaian yang ditunjukkan',
    type: 'writing',
    category: 'clothing',
    exerciseType: 'writing',
    options: [],
    difficulty: 3,
    questions: [
      {
        id: 'w_clothing_hard_1',
        imageUrl: 'clothing_jacket.png',
        correctAnswer: 'jaket',
        cueHierarchy: {
          functional: 'Pakaian ini dipakai apabila sejuk',
          rhyming: 'Ia berima dengan "raket"',
          written_initial: 'j_ _ _ _',
          spelling: 'j-a-k-e-t',
          sentence_completion: 'Saya pakai _____ ke Cameron Highlands',
          phonemic: 'Ia bermula dengan bunyi "ja"',
          modeling: 'jaket',
        },
      },
      {
        id: 'w_clothing_hard_2',
        imageUrl: 'clothing_glove.png',
        correctAnswer: 'sarung tangan',
        cueHierarchy: {
          functional: 'Pakaian ini dipakai di tangan untuk melindungi',
          rhyming: 'Ia berima dengan "sarung tangan"',
          written_initial: 's_ _ _ _ _  t_ _ _ _ _',
          spelling: 's-a-r-u-n-g  t-a-n-g-a-n',
          sentence_completion: 'Doktor pakai _____ semasa beroperasi',
          phonemic: 'Ia bermula dengan bunyi "sa"',
          modeling: 'sarung tangan',
        },
      },
    ],
  },
];

// Sample users data
const users = [
  {
    id: 'therapist_001',
    email: 'therapist@speaksteps.com',
    name: 'Dr. Sarah Chen',
    role: 'therapist',
    createdAt: new Date().toISOString(),
  },
  {
    id: 'g8KEOA79AiR8Gq5BAIvkBbXHjJI2',
    email: 'john.patient@speaksteps.com',
    name: 'John Smith',
    role: 'patient',
    createdAt: new Date().toISOString(),
    diagnosis: "Broca's Aphasia",
    patientPhone: '+1 (555) 123-4567',
    caregiverName: 'Mary Smith',
    caregiverPhone: '+1 (555) 123-4568',
  },
  {
    id: 'patient_002',
    email: 'emma.patient@email.com',
    name: 'Emma Johnson',
    role: 'patient',
    createdAt: new Date().toISOString(),
    diagnosis: "Wernicke's Aphasia",
    patientPhone: '+1 (555) 234-5678',
    caregiverName: 'Robert Johnson',
    caregiverPhone: '+1 (555) 234-5679',
  },
  {
    id: 'patient_003',
    email: 'michael.patient@email.com',
    name: 'Michael Brown',
    role: 'patient',
    createdAt: new Date().toISOString(),
    diagnosis: 'Anomic Aphasia',
    patientPhone: '+1 (555) 345-6789',
    caregiverName: 'Lisa Brown',
    caregiverPhone: '+1 (555) 345-6790',
  },
];

async function seedFirestore() {
  console.log('🌱 Starting Firestore seed...\n');

  // Seed exercises
  console.log('📚 Seeding exercises...');
  for (const exercise of exercises) {
    await db.collection('exercises').doc(exercise.id).set(exercise);
    console.log(`  ✓ Added exercise: ${exercise.title}`);
  }
  console.log(`  Total: ${exercises.length} exercises\n`);

  // Seed users
  console.log('👥 Seeding users...');
  for (const user of users) {
    await db.collection('users').doc(user.id).set(user);
    console.log(`  ✓ Added user: ${user.name} (${user.role})`);
  }
  console.log(`  Total: ${users.length} users\n`);

  console.log('✅ Firestore seeding complete!\n');
  console.log('📝 Note: You still need to create Firebase Auth accounts.');
  console.log('   Go to Firebase Console > Authentication > Users');
  console.log('   Create accounts with the following emails:\n');
  console.log('   Therapist:');
  console.log('     Email: therapist@speaksteps.com');
  console.log('     Password: (your choice, e.g., Therapist123!)');
  console.log('     UID: therapist_001\n');
  console.log('   Patients:');
  console.log('     Email: john.patient@speaksteps.com');
  console.log('     Password: Patient123!');
  console.log('     UID: g8KEOA79AiR8Gq5BAIvkBbXHjJI2 (Already exists in Firebase Auth)\n');
  console.log('     Email: emma.patient@email.com');
  console.log('     Password: (your choice, e.g., Patient123!)');
  console.log('     UID: patient_002\n');
  console.log('     Email: michael.patient@email.com');
  console.log('     Password: (your choice, e.g., Patient123!)');
  console.log('     UID: patient_003\n');
  
  process.exit(0);
}

seedFirestore().catch((error) => {
  console.error('Error seeding Firestore:', error);
  process.exit(1);
});



