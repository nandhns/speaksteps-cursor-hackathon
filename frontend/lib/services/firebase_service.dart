import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../firebase_options.dart';
import '../models/user_model.dart';
import '../models/exercise_model.dart';
import '../models/exercise_score_model.dart';
import '../models/patient_progress_model.dart';

/// Firebase Service Layer
/// 
/// This service provides methods to interact with Firebase.
/// Your backend developer can implement these methods using either:
/// - Cloud Firestore (recommended for web)
/// - Realtime Database (if already configured)
/// 
/// For Firestore: Use Firestore.instance
/// For Realtime Database: Use FirebaseDatabase.instance.ref()
class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  FirebaseApp? _adminApp;
  FirebaseAuth? _adminAuth;

  Future<FirebaseAuth> _getAdminAuth() async {
    if (_adminAuth != null) return _adminAuth!;

    try {
      _adminApp = Firebase.app('admin-helper');
    } on FirebaseException {
      _adminApp = await Firebase.initializeApp(
        name: 'admin-helper',
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    _adminAuth = FirebaseAuth.instanceFor(app: _adminApp!);
    return _adminAuth!;
  }

  // ==================== AUTHENTICATION ====================
  
  /// Get current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Firebase Auth successful: ${result.user?.email}');
      return result;
    } catch (e) {
      print('❌ Firebase Auth error: $e');
      rethrow; // Re-throw to let the adapter handle it
    }
  }

  /// Sign up with email and password
  Future<UserCredential?> signUpWithEmail(
    String email,
    String password,
    String name,
    UserRole role,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      if (credential.user != null) {
        final userModel = UserModel(
          id: credential.user!.uid,
          email: email,
          name: name,
          role: role,
          createdAt: DateTime.now(),
        );
        await saveUser(userModel);
      }

      return credential;
    } catch (e) {
      print('Sign up error: $e');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ==================== USER OPERATIONS ====================

  /// Save user data to Firestore
  /// Path: users/{userId}
  Future<void> saveUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      print('Error saving user: $e');
    }
  }

  /// Get user data from Firestore
  Future<UserModel?> getUser(String userId) async {
    try {
      print('📥 Fetching user from Firestore: $userId');
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        print('✅ User document found for: $userId');
        final userData = doc.data()!;
        print('   User data keys: ${userData.keys.toList()}');
        return UserModel.fromMap(userData);
      }
      print('❌ User document NOT found for: $userId');
      return null;
    } catch (e) {
      print('❌ Error getting user from Firestore: $e');
      rethrow; // Re-throw to let the adapter handle it
    }
  }

  /// Update user's language preference
  Future<void> updateUserLanguage(String userId, String languageCode) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'preferredLanguage': languageCode,
      });
    } catch (e) {
      print('Error updating user language: $e');
    }
  }

  // ==================== EXERCISE OPERATIONS ====================

  /// Get all exercises
  /// Path: exercises/{exerciseId}
  Future<List<Exercise>> getExercises() async {
    try {
      final snapshot = await _firestore.collection('exercises').get();
      
      // Fetch exercises with their questions from subcollection
      final exercises = <Exercise>[];
      
      for (final doc in snapshot.docs) {
        final exerciseData = doc.data();
        
        // Fetch questions subcollection
        final questionsSnapshot = await doc.reference.collection('questions').get();
        final questions = questionsSnapshot.docs.map((qDoc) {
          final qData = qDoc.data();
          
          // Map question data properly
          return {
            'id': qDoc.id,
            'imageUrl': qData['stimulusType'] == 'image' ? qData['stimulusValue'] : null,
            'audioUrl': qData['audioUrl'],
            'correctAnswer': qData['correctAnswer'] ?? '',
            'options': qData['options'] ?? [],
            'imageOptions': qData['imageOptions'] ?? [],
            'cueHierarchy': qData['cueHierarchy'] ?? {},
          };
        }).toList();
        
        print('DEBUG: Exercise ${doc.id} has ${questions.length} questions');
        if (questions.isNotEmpty) {
          print('  First question: ${questions[0]['correctAnswer']}');
        }
        
        // Add questions to exercise data
        exerciseData['id'] = doc.id;
        exerciseData['questions'] = questions;
        
        // Map category and exerciseType
        final category = exerciseData['category'] ?? '';
        exerciseData['category'] = _mapCategory(category);
        
        final type = exerciseData['module'] ?? exerciseData['type'] ?? '';
        exerciseData['exerciseType'] = _mapExerciseType(type);
        exerciseData['type'] = type;
        
        // Add default values for deprecated fields
        exerciseData['options'] = [];
        
        exercises.add(Exercise.fromMap(exerciseData));
      }
      
      print('DEBUG: Loaded ${exercises.length} total exercises');
      return exercises;
    } catch (e, st) {
      print('Error getting exercises: $e');
      print(st);
      return [];
    }
  }
  
  String _mapCategory(String category) {
    final categoryMap = {
      'haiwan': 'animal',
      'makanan': 'food',
      'anggota_badan': 'bodyParts',
      'badan': 'bodyParts',
      'kata_kerja': 'verbs',
    };
    return categoryMap[category.toLowerCase()] ?? 'animal';
  }
  
  String _mapExerciseType(String type) {
    final typeMap = {
      'penulisan': 'writing',
      'kefahaman': 'comprehension',
      'writing': 'writing',
      'comprehension': 'comprehension',
    };
    return typeMap[type.toLowerCase()] ?? 'writing';
  }

  /// Get exercise by ID
  Future<Exercise?> getExercise(String exerciseId) async {
    try {
      final doc = await _firestore.collection('exercises').doc(exerciseId).get();
      if (doc.exists) {
        final exerciseData = doc.data()!;
        
        // Fetch questions subcollection
        final questionsSnapshot = await doc.reference.collection('questions').get();
        final questions = questionsSnapshot.docs.map((qDoc) {
          final qData = qDoc.data();
          return {
            'id': qDoc.id,
            'imageUrl': qData['stimulusType'] == 'image' ? qData['stimulusValue'] : null,
            'audioUrl': qData['audioUrl'],
            'correctAnswer': qData['correctAnswer'] ?? '',
            'options': qData['options'] ?? [],
            'imageOptions': qData['imageOptions'] ?? [],
            'cueHierarchy': qData['cueHierarchy'] ?? {},
          };
        }).toList();
        
        print('DEBUG getExercise: Exercise $exerciseId has ${questions.length} questions');
        
        // Add questions to exercise data
        exerciseData['id'] = doc.id;
        exerciseData['questions'] = questions;
        
        // Map category and exerciseType
        final category = exerciseData['category'] ?? '';
        exerciseData['category'] = _mapCategory(category);
        
        final type = exerciseData['module'] ?? exerciseData['type'] ?? '';
        exerciseData['exerciseType'] = _mapExerciseType(type);
        exerciseData['type'] = type;
        
        // Add default values for deprecated fields
        exerciseData['options'] = [];
        
        return Exercise.fromMap(exerciseData);
      }
      return null;
    } catch (e, st) {
      print('Error getting exercise: $e');
      print(st);
      return null;
    }
  }

  // ==================== EXERCISE SCORE OPERATIONS ====================

  /// Save exercise score
  /// Path: exercise_scores/{scoreId}
  /// This is called when a patient completes an exercise
  Future<void> saveExerciseScore(ExerciseScore score) async {
    try {
      print('DEBUG Firebase: Saving score to exercise_scores/${score.id}');
      print('DEBUG Firebase: PatientId: ${score.patientId}, ExerciseId: ${score.exerciseId}, Score: ${score.score}/${score.maxScore}');
      
      await _firestore
          .collection('exercise_scores')
          .doc(score.id)
          .set(score.toMap());
      
      print('DEBUG Firebase: Score saved successfully');
    } catch (e) {
      print('Error saving exercise score: $e');
      rethrow;
    }
  }

  /// Get exercise scores for a patient
  /// Path: exercise_scores (filtered by patientId)
  Future<List<ExerciseScore>> getPatientScores(String patientId) async {
    try {
      print('DEBUG Firebase: Fetching scores for patientId: $patientId');

      try {
        final snapshot = await _firestore
            .collection('exercise_scores')
            .where('patientId', isEqualTo: patientId)
            .orderBy('completedAt', descending: true)
            .get();

        print('DEBUG Firebase: Found ${snapshot.docs.length} score documents');

        return snapshot.docs
            .map((doc) {
              print('DEBUG Firebase: Score doc ${doc.id}: ${doc.data()}');
              return ExerciseScore.fromMap(doc.data());
            })
            .toList();
      } on FirebaseException catch (fe) {
        // Handle missing composite index: retry without orderBy
        if (fe.code == 'failed-precondition') {
          print('DEBUG Firebase: Missing index for patient scores. Falling back without orderBy.');
          final snapshot = await _firestore
              .collection('exercise_scores')
              .where('patientId', isEqualTo: patientId)
              .get();
          print('DEBUG Firebase: Fallback found ${snapshot.docs.length} score docs');
          return snapshot.docs
              .map((doc) {
                print('DEBUG Firebase: Score doc ${doc.id}: ${doc.data()}');
                return ExerciseScore.fromMap(doc.data());
              })
              .toList();
        }
        rethrow;
      }
    } catch (e, st) {
      print('Error getting patient scores: $e');
      print(st);
      return [];
    }
  }

  /// Stream of exercise scores for a patient (real-time updates)
  Stream<List<ExerciseScore>> getPatientScoresStream(String patientId) {
    return _firestore
        .collection('exercise_scores')
        .where('patientId', isEqualTo: patientId)
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExerciseScore.fromMap(doc.data()))
            .toList());
  }

  // ==================== QUESTION RESPONSE OPERATIONS ====================
  
  /// Save individual question response
  /// Path: question_responses/{responseId}
  /// This stores detailed per-question data for ML training and therapist review
  Future<void> saveQuestionResponse(Map<String, dynamic> response) async {
    try {
      await _firestore
          .collection('question_responses')
          .doc(response['id'])
          .set(response);
    } catch (e) {
      print('Error saving question response: $e');
    }
  }
  
  /// Save multiple question responses in a batch (more efficient)
  Future<void> saveQuestionResponses(List<Map<String, dynamic>> responses) async {
    try {
      final batch = _firestore.batch();
      for (final response in responses) {
        final docRef = _firestore.collection('question_responses').doc(response['id']);
        batch.set(docRef, response);
      }
      await batch.commit();
    } catch (e) {
      print('Error saving question responses batch: $e');
    }
  }
  
  /// Get question responses for a patient's session
  Future<List<Map<String, dynamic>>> getSessionResponses(String sessionId) async {
    try {
      final snapshot = await _firestore
          .collection('question_responses')
          .where('sessionId', isEqualTo: sessionId)
          .orderBy('questionIndex')
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting session responses: $e');
      return [];
    }
  }
  
  /// Get all question responses for a patient (for therapist review)
  Future<List<Map<String, dynamic>>> getPatientResponses(String patientId, {int? limit}) async {
    try {
      var query = _firestore
          .collection('question_responses')
          .where('patientId', isEqualTo: patientId)
          .orderBy('presentedAt', descending: true);
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting patient responses: $e');
      return [];
    }
  }

  // ==================== EXERCISE SESSION OPERATIONS ====================
  
  /// Save exercise session data
  /// Path: exercise_sessions/{sessionId}
  Future<void> saveExerciseSession(Map<String, dynamic> session) async {
    try {
      await _firestore
          .collection('exercise_sessions')
          .doc(session['id'])
          .set(session);
    } catch (e) {
      print('Error saving exercise session: $e');
    }
  }
  
  /// Get exercise sessions for a patient
  Future<List<Map<String, dynamic>>> getPatientSessions(String patientId, {int? limit}) async {
    try {
      var query = _firestore
          .collection('exercise_sessions')
          .where('patientId', isEqualTo: patientId)
          .orderBy('startTime', descending: true);
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting patient sessions: $e');
      return [];
    }
  }

  // ==================== PATIENT PROGRESS OPERATIONS ====================

  /// Get all patients for a therapist
  /// Path: users (filtered by role = patient AND therapistId)
  Future<List<UserModel>> getTherapistPatients(String therapistId) async {
    try {
      print('DEBUG Firebase: Fetching patients for therapistId: $therapistId');

      // Primary query (requires composite index on role+therapistId)
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
      try {
        final snapshot = await _firestore
            .collection('users')
            .where('role', isEqualTo: 'patient')
            .where('therapistId', isEqualTo: therapistId)
            .get();
        docs = snapshot.docs;
        print('DEBUG Firebase: Filtered query returned ${docs.length} docs');
      } on FirebaseException catch (fe) {
        // Missing index or permission error: fallback to broader query then filter client-side
        print('DEBUG Firebase: Filtered query failed (${fe.code}). Falling back to client filter.');
        final all = await _firestore
            .collection('users')
            .where('role', isEqualTo: 'patient')
            .get();
        docs = all.docs.where((d) => d.data()['therapistId'] == therapistId).toList();
        print('DEBUG Firebase: Fallback docs total=${all.docs.length}, matched=${docs.length}');
      }

      if (docs.isEmpty) {
        print('DEBUG Firebase: No patients matched therapistId=$therapistId');
      }

      final patients = docs
          .map((doc) {
            final data = doc.data();
            print('DEBUG Firebase: Patient ${doc.id} name=${data['name']} therapistId=${data['therapistId']}');
            return UserModel.fromMap(data);
          })
          .toList();

      return patients;
    } catch (e, st) {
      print('Error getting therapist patients: $e');
      print(st);
      return [];
    }
  }

  /// Create a new patient (called by therapist)
  /// Creates a user account with a temporary password
  /// 
  /// NOTE: In production, this should be done via a backend API using Firebase Admin SDK
  /// to avoid signing out the therapist. For now, this implementation creates the patient
  /// but the therapist will need to sign back in after creating a patient.
  Future<UserModel?> createPatient({
    required String email,
    required String name,
    required String diagnosis,
    required String patientPhone,
    required String caregiverName,
    required String caregiverEmail,
    required String caregiverPhone,
    List<TherapyModule>? assignedModules,
    bool sendOnboardingEmail = true,
    String preferredLanguage = 'en',
  }) async {
    try {
      final currentTherapist = _auth.currentUser;
      if (currentTherapist == null) {
        throw Exception('Therapist must be signed in to add a patient');
      }

      final adminAuth = await _getAdminAuth();
      final therapistId = currentTherapist.uid;
      final tempPassword = 'TempPass${DateTime.now().millisecondsSinceEpoch}';

      UserCredential credential;

      try {
        // Create patient in a secondary Firebase app so the therapist session stays intact
        credential = await adminAuth.createUserWithEmailAndPassword(
          email: email,
          password: tempPassword,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          throw Exception('Email already in use. Use a different email or ask the patient to sign in with their existing account.');
        }
        rethrow;
      }

      if (credential.user == null) {
        throw Exception('Failed to create patient account');
      }

      final patientUid = credential.user!.uid;

      // Create user document in Firestore with patient-specific fields
      final patientModel = UserModel(
        id: patientUid,
        email: email,
        name: name,
        role: UserRole.patient,
        createdAt: DateTime.now(),
        diagnosis: diagnosis,
        patientPhone: patientPhone,
        caregiverName: caregiverName,
        caregiverPhone: caregiverPhone,
        therapistId: therapistId,
        assignedModules: assignedModules ?? [TherapyModule.writing],
        onboardingEmailSent: false,
        preferredLanguage: preferredLanguage,
        mustChangePassword: true,
      );

      await saveUser(patientModel);

      if (sendOnboardingEmail) {
        await _queueOnboardingEmail(
          patientEmail: email,
          patientName: name,
          tempPassword: tempPassword,
          assignedModules: assignedModules ?? [TherapyModule.writing],
          caregiverEmail: caregiverEmail,
        );
      }

      // Clean up the secondary auth session
      await adminAuth.signOut();

      return patientModel;
    } catch (e) {
      print('Error creating patient: $e');
      rethrow;
    }
  }

  /// Queue onboarding emails to be sent to patient and caregiver
  /// This creates two documents in the 'mail' collection which trigger Cloud Function sendOnboardingEmail
  /// - One for the patient with login credentials, modules, and web/mobile instructions
  /// - One for the caregiver with supervision steps and guidance
  /// Both emails are bilingual (English + Bahasa Melayu)
  Future<void> _queueOnboardingEmail({
    required String patientEmail,
    required String patientName,
    required String tempPassword,
    required List<TherapyModule> assignedModules,
    required String caregiverEmail,
  }) async {
    try {
      final moduleNames = assignedModules.map((m) => m.toString().split('.').last).toList();
      print('📧 Queueing emails - Modules: $moduleNames');

      // Queue patient email with login credentials and modules
      print('📧 Creating patient email document for: $patientEmail');
      await _firestore.collection('mail').add({
        'to': patientEmail,
        'emailType': 'patient',
        'patientName': patientName,
        'patientEmail': patientEmail,
        'tempPassword': tempPassword,
        'assignedModules': moduleNames,
        'message': {
          'subject': 'Welcome to SpeakSteps | Selamat Datang ke SpeakSteps',
        },
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ Patient onboarding email queued for $patientEmail');

      // Add a small delay to avoid Mailtrap rate limiting (max 1 email/second)
      await Future.delayed(const Duration(milliseconds: 1500));

      // Queue caregiver email with supervision steps
      print('📧 Creating caregiver email document for: $caregiverEmail');
      await _firestore.collection('mail').add({
        'to': caregiverEmail,
        'emailType': 'caregiver',
        'message': {
          'subject': 'Welcome to SpeakSteps Caregiver Portal | Selamat Datang ke Portal Penjaga SpeakSteps',
        },
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('✅ Caregiver onboarding email queued for $caregiverEmail');
    } catch (e) {
      print('❌ Error queuing onboarding emails: $e');
      // Don't throw - email failure shouldn't block patient creation
    }
  }

  /// Get patient progress summary
  /// This aggregates scores to create a progress summary
  Future<PatientProgress?> getPatientProgress(String patientId) async {
    try {
      final user = await getUser(patientId);
      if (user == null) return null;

      final scores = await getPatientScores(patientId);
      if (scores.isEmpty) {
        return PatientProgress(
          patientId: patientId,
          patientName: user.name,
          totalExercisesCompleted: 0,
          averageScore: 0,
          lastActivity: DateTime.now(),
          recentScores: [],
          scoresByExercise: {},
        );
      }

      final averageScore = scores.map((s) => s.score).reduce((a, b) => a + b) /
          scores.length;
      final recentScores = scores.take(10).toList();
      final scoresByExercise = <String, int>{};
      for (var score in scores) {
        scoresByExercise[score.exerciseId] = score.score;
      }

      return PatientProgress(
        patientId: patientId,
        patientName: user.name,
        totalExercisesCompleted: scores.length,
        averageScore: averageScore,
        lastActivity: scores.first.completedAt,
        recentScores: recentScores,
        scoresByExercise: scoresByExercise,
      );
    } catch (e) {
      print('Error getting patient progress: $e');
      return null;
    }
  }

  /// Stream of patient progress (real-time updates)
  Stream<PatientProgress?> getPatientProgressStream(String patientId) {
    return getPatientScoresStream(patientId).asyncMap((scores) async {
      final user = await getUser(patientId);
      if (user == null) return null;

      if (scores.isEmpty) {
        return PatientProgress(
          patientId: patientId,
          patientName: user.name,
          totalExercisesCompleted: 0,
          averageScore: 0,
          lastActivity: DateTime.now(),
          recentScores: [],
          scoresByExercise: {},
        );
      }

      final averageScore = scores.map((s) => s.score).reduce((a, b) => a + b) /
          scores.length;
      final recentScores = scores.take(10).toList();
      final scoresByExercise = <String, int>{};
      for (var score in scores) {
        scoresByExercise[score.exerciseId] = score.score;
      }

      return PatientProgress(
        patientId: patientId,
        patientName: user.name,
        totalExercisesCompleted: scores.length,
        averageScore: averageScore,
        lastActivity: scores.first.completedAt,
        recentScores: recentScores,
        scoresByExercise: scoresByExercise,
      );
    });
  }
}

