import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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

  // ==================== AUTHENTICATION ====================
  
  /// Get current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Sign in error: $e');
      return null;
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
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // ==================== EXERCISE OPERATIONS ====================

  /// Get all exercises
  /// Path: exercises/{exerciseId}
  Future<List<Exercise>> getExercises() async {
    try {
      final snapshot = await _firestore.collection('exercises').get();
      return snapshot.docs
          .map((doc) => Exercise.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting exercises: $e');
      return [];
    }
  }

  /// Get exercise by ID
  Future<Exercise?> getExercise(String exerciseId) async {
    try {
      final doc = await _firestore.collection('exercises').doc(exerciseId).get();
      if (doc.exists) {
        return Exercise.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting exercise: $e');
      return null;
    }
  }

  // ==================== EXERCISE SCORE OPERATIONS ====================

  /// Save exercise score
  /// Path: exercise_scores/{scoreId}
  /// This is called when a patient completes an exercise
  Future<void> saveExerciseScore(ExerciseScore score) async {
    try {
      await _firestore
          .collection('exercise_scores')
          .doc(score.id)
          .set(score.toMap());
    } catch (e) {
      print('Error saving exercise score: $e');
    }
  }

  /// Get exercise scores for a patient
  /// Path: exercise_scores (filtered by patientId)
  Future<List<ExerciseScore>> getPatientScores(String patientId) async {
    try {
      final snapshot = await _firestore
          .collection('exercise_scores')
          .where('patientId', isEqualTo: patientId)
          .orderBy('completedAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => ExerciseScore.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting patient scores: $e');
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

  // ==================== PATIENT PROGRESS OPERATIONS ====================

  /// Get all patients for a therapist
  /// Path: users (filtered by role = patient)
  Future<List<UserModel>> getTherapistPatients(String therapistId) async {
    try {
      // In a real app, you might have a therapist_patients collection
      // For now, we'll get all patients
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'patient')
          .get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting therapist patients: $e');
      return [];
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

