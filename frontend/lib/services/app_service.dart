import '../models/user_model.dart';
import '../models/exercise_model.dart';
import '../models/exercise_score_model.dart';
import '../models/patient_progress_model.dart';
import 'mock_service.dart';
import 'firebase_service.dart';

/// Abstract service interface
abstract class AppService {
  UserModel? get currentUser;
  Future<bool> signInWithEmail(String email, String password);
  Future<bool> signUpWithEmail(String email, String password, String name, UserRole role);
  Future<void> signOut();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser(String userId);
  Future<List<Exercise>> getExercises();
  Future<Exercise?> getExercise(String exerciseId);
  Future<void> saveExerciseScore(ExerciseScore score);
  Future<List<ExerciseScore>> getPatientScores(String patientId);
  Stream<List<ExerciseScore>> getPatientScoresStream(String patientId);
  Future<List<UserModel>> getTherapistPatients(String therapistId);
  Future<PatientProgress?> getPatientProgress(String patientId);
  Stream<PatientProgress?> getPatientProgressStream(String patientId);
}

/// Service factory - Switch between Mock and Firebase
class ServiceFactory {
  // Set to true to use Firebase, false to use Mock (for testing without Firebase)
  static const bool useFirebase = false; // Change to true when Firebase is ready

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
}

/// Adapter for FirebaseService to implement AppService
class FirebaseServiceAdapter implements AppService {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  UserModel? get currentUser {
    final user = _firebaseService.currentUser;
    if (user == null) return null;
    // Convert Firebase User to UserModel - this would need async call in real implementation
    return null; // Will be loaded via getUser
  }

  @override
  Future<bool> signInWithEmail(String email, String password) async {
    final credential = await _firebaseService.signInWithEmail(email, password);
    return credential != null;
  }

  @override
  Future<bool> signUpWithEmail(String email, String password, String name, UserRole role) async {
    final credential = await _firebaseService.signUpWithEmail(email, password, name, role);
    return credential != null;
  }

  @override
  Future<void> signOut() => _firebaseService.signOut();

  @override
  Future<void> saveUser(UserModel user) => _firebaseService.saveUser(user);

  @override
  Future<UserModel?> getUser(String userId) => _firebaseService.getUser(userId);

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
}

