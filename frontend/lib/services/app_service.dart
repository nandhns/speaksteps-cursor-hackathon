import '../models/user_model.dart';
import '../models/exercise_model.dart';
import '../models/exercise_score_model.dart';
import '../models/patient_progress_model.dart';
import 'mock_service.dart';
import 'firebase_service.dart';

// Re-export TherapyModule for convenience
export '../models/user_model.dart' show TherapyModule;

/// Abstract service interface
abstract class AppService {
  UserModel? get currentUser;
  Future<bool> signInWithEmail(String email, String password);
  Future<bool> signUpWithEmail(String email, String password, String name, UserRole role);
  Future<void> signOut();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser(String userId);
  Future<void> updateUserLanguage(String userId, String languageCode);
  Future<List<Exercise>> getExercises();
  Future<Exercise?> getExercise(String exerciseId);
  Future<void> saveExerciseScore(ExerciseScore score);
  Future<List<ExerciseScore>> getPatientScores(String patientId);
  Stream<List<ExerciseScore>> getPatientScoresStream(String patientId);
  Future<List<UserModel>> getTherapistPatients(String therapistId);
  Future<PatientProgress?> getPatientProgress(String patientId);
  Stream<PatientProgress?> getPatientProgressStream(String patientId);
  Future<UserModel?> createPatient({
    required String email,
    required String name,
    required String diagnosis,
    required String patientPhone,
    required String caregiverName,
    required String caregiverPhone,
    List<TherapyModule>? assignedModules,
    bool sendOnboardingEmail = true,
    String preferredLanguage = 'en',
  });
  
  // Question response tracking
  Future<void> saveQuestionResponse(Map<String, dynamic> response);
  Future<void> saveQuestionResponses(List<Map<String, dynamic>> responses);
  Future<List<Map<String, dynamic>>> getPatientResponses(String patientId, {int? limit});
  
  // Exercise session tracking
  Future<void> saveExerciseSession(Map<String, dynamic> session);
  Future<List<Map<String, dynamic>>> getPatientSessions(String patientId, {int? limit});
}

/// Service factory - Switch between Mock and Firebase
class ServiceFactory {
  // Set to true to use Firebase, false to use Mock (for testing without Firebase)
  static const bool useFirebase = true; // Firebase is now configured!

  static AppService createService() {
    if (useFirebase) {
      return FirebaseServiceAdapter();
    } else {
      return MockServiceAdapter();
    }
  }
}

/// Adapter for MockService to implement AppService
class MockServiceAdapter implements AppService {
  final MockService _mockService = MockService();

  MockServiceAdapter() {
    // Add sample scores for demo
    _mockService.addSampleScores();
  }

  @override
  UserModel? get currentUser => _mockService.currentUser;

  @override
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      return await _mockService.signInWithEmail(email, password);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> signUpWithEmail(String email, String password, String name, UserRole role) async {
    try {
      return await _mockService.signUpWithEmail(email, password, name, role);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> signOut() => _mockService.signOut();

  @override
  Future<void> saveUser(UserModel user) => _mockService.saveUser(user);

  @override
  Future<UserModel?> getUser(String userId) => _mockService.getUser(userId);

  @override
  Future<void> updateUserLanguage(String userId, String languageCode) async {
    // Mock implementation - could update in-memory user
    final user = await _mockService.getUser(userId);
    if (user != null) {
      final updatedUser = user.copyWith(preferredLanguage: languageCode);
      await _mockService.saveUser(updatedUser);
    }
  }

  @override
  Future<List<Exercise>> getExercises() => _mockService.getExercises();

  @override
  Future<Exercise?> getExercise(String exerciseId) => _mockService.getExercise(exerciseId);

  @override
  Future<void> saveExerciseScore(ExerciseScore score) => _mockService.saveExerciseScore(score);

  @override
  Future<List<ExerciseScore>> getPatientScores(String patientId) => _mockService.getPatientScores(patientId);

  @override
  Stream<List<ExerciseScore>> getPatientScoresStream(String patientId) => _mockService.getPatientScoresStream(patientId);

  @override
  Future<List<UserModel>> getTherapistPatients(String therapistId) => _mockService.getTherapistPatients(therapistId);

  @override
  Future<PatientProgress?> getPatientProgress(String patientId) => _mockService.getPatientProgress(patientId);

  @override
  Stream<PatientProgress?> getPatientProgressStream(String patientId) => _mockService.getPatientProgressStream(patientId);

  @override
  Future<UserModel?> createPatient({
    required String email,
    required String name,
    required String diagnosis,
    required String patientPhone,
    required String caregiverName,
    required String caregiverPhone,
    List<TherapyModule>? assignedModules,
    bool sendOnboardingEmail = true,
    String preferredLanguage = 'en',
  }) => _mockService.createPatient(
        email: email,
        name: name,
        diagnosis: diagnosis,
        patientPhone: patientPhone,
        caregiverName: caregiverName,
        caregiverPhone: caregiverPhone,
        assignedModules: assignedModules,
        sendOnboardingEmail: sendOnboardingEmail,
        preferredLanguage: preferredLanguage,
      );
  
  // Mock implementations for question response tracking
  final List<Map<String, dynamic>> _questionResponses = [];
  
  @override
  Future<void> saveQuestionResponse(Map<String, dynamic> response) async {
    _questionResponses.add(response);
  }
  
  @override
  Future<void> saveQuestionResponses(List<Map<String, dynamic>> responses) async {
    _questionResponses.addAll(responses);
  }
  
  @override
  Future<List<Map<String, dynamic>>> getPatientResponses(String patientId, {int? limit}) async {
    final filtered = _questionResponses
        .where((r) => r['patientId'] == patientId)
        .toList();
    if (limit != null && filtered.length > limit) {
      return filtered.take(limit).toList();
    }
    return filtered;
  }
  
  // Mock implementations for exercise session tracking
  final List<Map<String, dynamic>> _exerciseSessions = [];
  
  @override
  Future<void> saveExerciseSession(Map<String, dynamic> session) async {
    _exerciseSessions.add(session);
  }
  
  @override
  Future<List<Map<String, dynamic>>> getPatientSessions(String patientId, {int? limit}) async {
    final filtered = _exerciseSessions
        .where((s) => s['patientId'] == patientId)
        .toList();
    if (limit != null && filtered.length > limit) {
      return filtered.take(limit).toList();
    }
    return filtered;
  }
}

/// Adapter for FirebaseService to implement AppService
class FirebaseServiceAdapter implements AppService {
  final FirebaseService _firebaseService = FirebaseService();
  UserModel? _cachedUser;

  @override
  UserModel? get currentUser {
    final user = _firebaseService.currentUser;
    if (user == null) return null;
    // Return cached user if available, otherwise return a minimal user model
    // The full user data will be loaded via getUser() after sign-in
    if (_cachedUser != null && _cachedUser!.id == user.uid) {
      return _cachedUser;
    }
    // Return minimal user model with Firebase UID for lookup
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? '',
      role: UserRole.patient, // Will be overwritten when full user is loaded
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      print('🔐 Starting sign-in process for: $email');
      final credential = await _firebaseService.signInWithEmail(email, password);
      if (credential != null) {
        print('✅ Firebase Auth successful, loading user data...');
        // Load and cache the full user data
        _cachedUser = await _firebaseService.getUser(credential.user!.uid);
        if (_cachedUser != null) {
          print('✅ User data loaded successfully: ${_cachedUser!.name}');
          return true;
        }
        // Fallback: create a minimal user document if missing
        print('⚠️ No user doc found. Creating default user profile...');
        final newUser = UserModel(
          id: credential.user!.uid,
          email: credential.user!.email ?? email,
          name: credential.user!.displayName ?? '',
          role: UserRole.patient,
          createdAt: DateTime.now(),
        );
        await _firebaseService.saveUser(newUser);
        _cachedUser = newUser;
        print('✅ Default user profile created. Proceeding to app.');
        return true;
      }
      print('❌ Firebase Auth failed');
      return false;
    } catch (e, stackTrace) {
      print('❌ Sign-in error: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  @override
  Future<bool> signUpWithEmail(String email, String password, String name, UserRole role) async {
    final credential = await _firebaseService.signUpWithEmail(email, password, name, role);
    if (credential != null) {
      // Load and cache the full user data
      _cachedUser = await _firebaseService.getUser(credential.user!.uid);
      return true;
    }
    return false;
  }

  @override
  Future<void> signOut() async {
    _cachedUser = null;
    await _firebaseService.signOut();
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _firebaseService.saveUser(user);
    _cachedUser = user;
  }

  @override
  Future<UserModel?> getUser(String userId) async {
    final user = await _firebaseService.getUser(userId);
    if (user != null) {
      _cachedUser = user;
    }
    return user;
  }

  @override
  Future<void> updateUserLanguage(String userId, String languageCode) =>
      _firebaseService.updateUserLanguage(userId, languageCode);

  @override
  Future<List<Exercise>> getExercises() => _firebaseService.getExercises();

  @override
  Future<Exercise?> getExercise(String exerciseId) => _firebaseService.getExercise(exerciseId);

  @override
  Future<void> saveExerciseScore(ExerciseScore score) => _firebaseService.saveExerciseScore(score);

  @override
  Future<List<ExerciseScore>> getPatientScores(String patientId) => _firebaseService.getPatientScores(patientId);

  @override
  Stream<List<ExerciseScore>> getPatientScoresStream(String patientId) => _firebaseService.getPatientScoresStream(patientId);

  @override
  Future<List<UserModel>> getTherapistPatients(String therapistId) => _firebaseService.getTherapistPatients(therapistId);

  @override
  Future<PatientProgress?> getPatientProgress(String patientId) => _firebaseService.getPatientProgress(patientId);

  @override
  Stream<PatientProgress?> getPatientProgressStream(String patientId) => _firebaseService.getPatientProgressStream(patientId);

  @override
  Future<UserModel?> createPatient({
    required String email,
    required String name,
    required String diagnosis,
    required String patientPhone,
    required String caregiverName,
    required String caregiverPhone,
    List<TherapyModule>? assignedModules,
    bool sendOnboardingEmail = true,
    String preferredLanguage = 'en',
  }) => _firebaseService.createPatient(
        email: email,
        name: name,
        diagnosis: diagnosis,
        patientPhone: patientPhone,
        caregiverName: caregiverName,
        caregiverPhone: caregiverPhone,
        assignedModules: assignedModules,
        sendOnboardingEmail: sendOnboardingEmail,
        preferredLanguage: preferredLanguage,
      );
  
  @override
  Future<void> saveQuestionResponse(Map<String, dynamic> response) => 
      _firebaseService.saveQuestionResponse(response);
  
  @override
  Future<void> saveQuestionResponses(List<Map<String, dynamic>> responses) => 
      _firebaseService.saveQuestionResponses(responses);
  
  @override
  Future<List<Map<String, dynamic>>> getPatientResponses(String patientId, {int? limit}) => 
      _firebaseService.getPatientResponses(patientId, limit: limit);
  
  @override
  Future<void> saveExerciseSession(Map<String, dynamic> session) => 
      _firebaseService.saveExerciseSession(session);
  
  @override
  Future<List<Map<String, dynamic>>> getPatientSessions(String patientId, {int? limit}) => 
      _firebaseService.getPatientSessions(patientId, limit: limit);
}

