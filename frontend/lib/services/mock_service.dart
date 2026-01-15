import '../models/user_model.dart';
import '../models/exercise_model.dart';
import '../models/exercise_score_model.dart';
import '../models/patient_progress_model.dart';

/// Mock Service - Simulates Firebase operations with local data
/// Use this to test the frontend without Firebase setup
class MockService {
  // Mock users
  static final List<UserModel> _mockUsers = [
    UserModel(
      id: 'patient1',
      email: 'patient@test.com',
      name: 'John Patient',
      role: UserRole.patient,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      diagnosis: 'Broca\'s Aphasia',
      patientPhone: '+1 (555) 123-4567',
      caregiverName: 'Jane Patient',
      caregiverPhone: '+1 (555) 123-4568',
    ),
    UserModel(
      id: 'patient2',
      email: 'mary@test.com',
      name: 'Mary Smith',
      role: UserRole.patient,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      diagnosis: 'Wernicke\'s Aphasia',
      patientPhone: '+1 (555) 234-5678',
      caregiverName: 'Robert Smith',
      caregiverPhone: '+1 (555) 234-5679',
    ),
    UserModel(
      id: 'patient3',
      email: 'david@test.com',
      name: 'David Johnson',
      role: UserRole.patient,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      diagnosis: 'Anomic Aphasia',
      patientPhone: '+1 (555) 345-6789',
      caregiverName: 'Lisa Johnson',
      caregiverPhone: '+1 (555) 345-6790',
    ),
    UserModel(
      id: 'patient4',
      email: 'emily@test.com',
      name: 'Emily Brown',
      role: UserRole.patient,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      diagnosis: 'Global Aphasia',
      patientPhone: '+1 (555) 456-7890',
      caregiverName: 'Michael Brown',
      caregiverPhone: '+1 (555) 456-7891',
    ),
    UserModel(
      id: 'patient5',
      email: 'james@test.com',
      name: 'James Wilson',
      role: UserRole.patient,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      diagnosis: 'Conduction Aphasia',
      patientPhone: '+1 (555) 567-8901',
      caregiverName: 'Patricia Wilson',
      caregiverPhone: '+1 (555) 567-8902',
    ),
    UserModel(
      id: 'patient6',
      email: 'susan@test.com',
      name: 'Susan Davis',
      role: UserRole.patient,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      diagnosis: 'Transcortical Motor Aphasia',
      patientPhone: '+1 (555) 678-9012',
      caregiverName: 'Thomas Davis',
      caregiverPhone: '+1 (555) 678-9013',
    ),
    UserModel(
      id: 'patient7',
      email: 'robert@test.com',
      name: 'Robert Martinez',
      role: UserRole.patient,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      diagnosis: 'Primary Progressive Aphasia',
      patientPhone: '+1 (555) 789-0123',
      caregiverName: 'Jennifer Martinez',
      caregiverPhone: '+1 (555) 789-0124',
    ),
    UserModel(
      id: 'therapist1',
      email: 'therapist@test.com',
      name: 'Dr. Sarah Therapist',
      role: UserRole.therapist,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
  ];

  // Helper function to generate questions for an exercise
  static List<ExerciseQuestion> _generateWritingQuestions(
    String baseId,
    List<String> answers,
    List<Map<String, String>> cueHierarchies,
  ) {
    return List.generate(answers.length, (index) {
      return ExerciseQuestion(
        id: '${baseId}_q${index + 1}',
        correctAnswer: answers[index],
        cueHierarchy: cueHierarchies[index],
      );
    });
  }

  static List<ExerciseQuestion> _generateComprehensionQuestions(
    String baseId,
    List<String> correctAnswers,
    List<List<String>> wrongOptionsList,
    List<Map<String, String>> cueHierarchies,
  ) {
    return List.generate(correctAnswers.length, (index) {
      return ExerciseQuestion(
        id: '${baseId}_q${index + 1}',
        correctAnswer: correctAnswers[index],
        imageOptions: wrongOptionsList[index],
        cueHierarchy: cueHierarchies[index],
      );
    });
  }

  // Mock exercises
  static final List<Exercise> _mockExercises = [
    // Writing - Animal
    Exercise(
      id: 'exercise1',
      title: 'Writing - Animals (Easy)',
      description: 'Look at the image and type the word you see.',
      type: 'writing',
      category: ExerciseCategory.animal,
      exerciseType: ExerciseType.writing,
      options: [],
      correctAnswer: 'Cat',
      difficulty: 1,
      imageUrl: null,
      cueHierarchy: {
        'function': 'It meows and purrs',
        'rhyming': 'Rhymes with "hat"',
        'written': 'C-A-T',
      },
      questions: _generateWritingQuestions(
        'exercise1',
        ['Cat', 'Dog', 'Bird', 'Fish', 'Lion'],
        [
          {'function': 'It meows and purrs', 'rhyming': 'Rhymes with "hat"', 'written': 'C-A-T'},
          {'function': 'It barks and wags its tail', 'rhyming': 'Rhymes with "log"', 'written': 'D-O-G'},
          {'function': 'It flies and chirps', 'rhyming': 'Rhymes with "word"', 'written': 'B-I-R-D'},
          {'function': 'It swims in water', 'rhyming': 'Rhymes with "dish"', 'written': 'F-I-S-H'},
          {'function': 'It roars and has a mane', 'rhyming': 'Rhymes with "iron"', 'written': 'L-I-O-N'},
        ],
      ),
    ),
    // Writing - Food
    Exercise(
      id: 'exercise2',
      title: 'Writing - Food (Easy)',
      description: 'Look at the image and type the word you see.',
      type: 'writing',
      category: ExerciseCategory.food,
      exerciseType: ExerciseType.writing,
      options: [],
      correctAnswer: 'Apple',
      difficulty: 1,
      imageUrl: null,
      cueHierarchy: {
        'function': 'A red fruit',
        'rhyming': 'Rhymes with "grapple"',
        'written': 'A-P-P-L-E',
      },
      questions: _generateWritingQuestions(
        'exercise2',
        ['Apple', 'Banana', 'Bread', 'Milk', 'Orange'],
        [
          {'function': 'A red fruit', 'rhyming': 'Rhymes with "grapple"', 'written': 'A-P-P-L-E'},
          {'function': 'A yellow fruit', 'rhyming': 'Rhymes with "bandana"', 'written': 'B-A-N-A-N-A'},
          {'function': 'Made from flour', 'rhyming': 'Rhymes with "red"', 'written': 'B-R-E-A-D'},
          {'function': 'White drink', 'rhyming': 'Rhymes with "silk"', 'written': 'M-I-L-K'},
          {'function': 'A citrus fruit', 'rhyming': 'Rhymes with "range"', 'written': 'O-R-A-N-G-E'},
        ],
      ),
    ),
    // Writing - Body Parts
    Exercise(
      id: 'exercise3',
      title: 'Writing - Body Parts (Easy)',
      description: 'Look at the image and type the word you see.',
      type: 'writing',
      category: ExerciseCategory.bodyParts,
      exerciseType: ExerciseType.writing,
      options: [],
      correctAnswer: 'Hand',
      difficulty: 1,
      imageUrl: null,
      cueHierarchy: {
        'function': 'You use it to hold things',
        'rhyming': 'Rhymes with "band"',
        'written': 'H-A-N-D',
      },
      questions: _generateWritingQuestions(
        'exercise3',
        ['Hand', 'Foot', 'Eye', 'Ear', 'Nose'],
        [
          {'function': 'You use it to hold things', 'rhyming': 'Rhymes with "band"', 'written': 'H-A-N-D'},
          {'function': 'You walk with it', 'rhyming': 'Rhymes with "put"', 'written': 'F-O-O-T'},
          {'function': 'You see with it', 'rhyming': 'Rhymes with "sky"', 'written': 'E-Y-E'},
          {'function': 'You hear with it', 'rhyming': 'Rhymes with "near"', 'written': 'E-A-R'},
          {'function': 'You smell with it', 'rhyming': 'Rhymes with "rose"', 'written': 'N-O-S-E'},
        ],
      ),
    ),
    // Writing - Verbs
    Exercise(
      id: 'exercise4',
      title: 'Writing - Actions (Easy)',
      description: 'Look at the image and type the action you see.',
      type: 'writing',
      category: ExerciseCategory.verbs,
      exerciseType: ExerciseType.writing,
      options: [],
      correctAnswer: 'Run',
      difficulty: 1,
      imageUrl: null,
      cueHierarchy: {
        'function': 'Moving fast with your legs',
        'rhyming': 'Rhymes with "fun"',
        'written': 'R-U-N',
      },
      questions: _generateWritingQuestions(
        'exercise4',
        ['Run', 'Jump', 'Walk', 'Sit', 'Sleep'],
        [
          {'function': 'Moving fast with your legs', 'rhyming': 'Rhymes with "fun"', 'written': 'R-U-N'},
          {'function': 'Going up in the air', 'rhyming': 'Rhymes with "pump"', 'written': 'J-U-M-P'},
          {'function': 'Moving slowly on foot', 'rhyming': 'Rhymes with "talk"', 'written': 'W-A-L-K'},
          {'function': 'Resting on a chair', 'rhyming': 'Rhymes with "fit"', 'written': 'S-I-T'},
          {'function': 'Resting at night', 'rhyming': 'Rhymes with "deep"', 'written': 'S-L-E-E-P'},
        ],
      ),
    ),
    // Comprehension exercises
    Exercise(
      id: 'exercise5',
      title: 'Comprehension - Animals (Easy)',
      description: 'Listen to the audio and match the picture to the word shown.',
      type: 'comprehension',
      category: ExerciseCategory.animal,
      exerciseType: ExerciseType.comprehension,
      options: ['Dog', 'Hand', 'Apple', 'Run'],
      correctAnswer: 'Dog',
      difficulty: 1,
      audioUrl: null,
      imageOptions: ['Dog', 'Hand', 'Apple', 'Run'],
      cueHierarchy: {
        'function': 'It barks and wags its tail',
        'rhyming': 'Rhymes with "log"',
        'written': 'D-O-G',
      },
      questions: _generateComprehensionQuestions(
        'exercise5',
        ['Dog', 'Cat', 'Bird', 'Fish', 'Lion'],
        [
          ['Dog', 'Hand', 'Apple', 'Run'],
          ['Cat', 'Foot', 'Banana', 'Jump'],
          ['Bird', 'Eye', 'Bread', 'Walk'],
          ['Fish', 'Ear', 'Milk', 'Sit'],
          ['Lion', 'Nose', 'Orange', 'Sleep'],
        ],
        [
          {'function': 'It barks and wags its tail', 'rhyming': 'Rhymes with "log"', 'written': 'D-O-G'},
          {'function': 'It meows and purrs', 'rhyming': 'Rhymes with "hat"', 'written': 'C-A-T'},
          {'function': 'It flies and chirps', 'rhyming': 'Rhymes with "word"', 'written': 'B-I-R-D'},
          {'function': 'It swims in water', 'rhyming': 'Rhymes with "dish"', 'written': 'F-I-S-H'},
          {'function': 'It roars and has a mane', 'rhyming': 'Rhymes with "iron"', 'written': 'L-I-O-N'},
        ],
      ),
    ),
    Exercise(
      id: 'exercise6',
      title: 'Comprehension - Food (Easy)',
      description: 'Listen to the audio and match the picture to the word shown.',
      type: 'comprehension',
      category: ExerciseCategory.food,
      exerciseType: ExerciseType.comprehension,
      options: ['Banana', 'Cat', 'Foot', 'Walk'],
      correctAnswer: 'Banana',
      difficulty: 1,
      audioUrl: null,
      imageOptions: ['Banana', 'Cat', 'Foot', 'Walk'],
      cueHierarchy: {
        'function': 'A yellow fruit',
        'rhyming': 'Rhymes with "bandana"',
        'written': 'B-A-N-A-N-A',
      },
      questions: _generateComprehensionQuestions(
        'exercise6',
        ['Banana', 'Apple', 'Bread', 'Milk', 'Orange'],
        [
          ['Banana', 'Cat', 'Foot', 'Walk'],
          ['Apple', 'Dog', 'Hand', 'Run'],
          ['Bread', 'Bird', 'Eye', 'Jump'],
          ['Milk', 'Fish', 'Ear', 'Sit'],
          ['Orange', 'Lion', 'Nose', 'Sleep'],
        ],
        [
          {'function': 'A yellow fruit', 'rhyming': 'Rhymes with "bandana"', 'written': 'B-A-N-A-N-A'},
          {'function': 'A red fruit', 'rhyming': 'Rhymes with "grapple"', 'written': 'A-P-P-L-E'},
          {'function': 'Made from flour', 'rhyming': 'Rhymes with "red"', 'written': 'B-R-E-A-D'},
          {'function': 'White drink', 'rhyming': 'Rhymes with "silk"', 'written': 'M-I-L-K'},
          {'function': 'A citrus fruit', 'rhyming': 'Rhymes with "range"', 'written': 'O-R-A-N-G-E'},
        ],
      ),
    ),
    Exercise(
      id: 'exercise7',
      title: 'Comprehension - Body Parts (Easy)',
      description: 'Listen to the audio and match the picture to the word shown.',
      type: 'comprehension',
      category: ExerciseCategory.bodyParts,
      exerciseType: ExerciseType.comprehension,
      options: ['Hand', 'Dog', 'Apple', 'Run'],
      correctAnswer: 'Hand',
      difficulty: 1,
      audioUrl: null,
      imageOptions: ['Hand', 'Dog', 'Apple', 'Run'],
      cueHierarchy: {
        'function': 'You use it to hold things',
        'rhyming': 'Rhymes with "band"',
        'written': 'H-A-N-D',
      },
      questions: _generateComprehensionQuestions(
        'exercise7',
        ['Hand', 'Foot', 'Eye', 'Ear', 'Nose'],
        [
          ['Hand', 'Dog', 'Apple', 'Run'],
          ['Foot', 'Cat', 'Banana', 'Jump'],
          ['Eye', 'Bird', 'Bread', 'Walk'],
          ['Ear', 'Fish', 'Milk', 'Sit'],
          ['Nose', 'Lion', 'Orange', 'Sleep'],
        ],
        [
          {'function': 'You use it to hold things', 'rhyming': 'Rhymes with "band"', 'written': 'H-A-N-D'},
          {'function': 'You walk with it', 'rhyming': 'Rhymes with "put"', 'written': 'F-O-O-T'},
          {'function': 'You see with it', 'rhyming': 'Rhymes with "pie"', 'written': 'E-Y-E'},
          {'function': 'You hear with it', 'rhyming': 'Rhymes with "near"', 'written': 'E-A-R'},
          {'function': 'You smell with it', 'rhyming': 'Rhymes with "rose"', 'written': 'N-O-S-E'},
        ],
      ),
    ),
    Exercise(
      id: 'exercise8',
      title: 'Comprehension - Actions (Easy)',
      description: 'Listen to the audio and match the picture to the action shown.',
      type: 'comprehension',
      category: ExerciseCategory.verbs,
      exerciseType: ExerciseType.comprehension,
      options: ['Run', 'Cat', 'Foot', 'Banana'],
      correctAnswer: 'Run',
      difficulty: 1,
      audioUrl: null,
      imageOptions: ['Run', 'Cat', 'Foot', 'Banana'],
      cueHierarchy: {
        'function': 'Moving fast with your legs',
        'rhyming': 'Rhymes with "fun"',
        'written': 'R-U-N',
      },
      questions: _generateComprehensionQuestions(
        'exercise8',
        ['Run', 'Jump', 'Walk', 'Sit', 'Sleep'],
        [
          ['Run', 'Cat', 'Foot', 'Banana'],
          ['Jump', 'Dog', 'Hand', 'Apple'],
          ['Walk', 'Bird', 'Eye', 'Bread'],
          ['Sit', 'Fish', 'Ear', 'Milk'],
          ['Sleep', 'Lion', 'Nose', 'Orange'],
        ],
        [
          {'function': 'Moving fast with your legs', 'rhyming': 'Rhymes with "fun"', 'written': 'R-U-N'},
          {'function': 'Going up in the air', 'rhyming': 'Rhymes with "pump"', 'written': 'J-U-M-P'},
          {'function': 'Moving slowly on foot', 'rhyming': 'Rhymes with "talk"', 'written': 'W-A-L-K'},
          {'function': 'Resting on a chair', 'rhyming': 'Rhymes with "fit"', 'written': 'S-I-T'},
          {'function': 'Resting at night', 'rhyming': 'Rhymes with "deep"', 'written': 'S-L-E-E-P'},
        ],
      ),
    ),
  ];

  // Mock scores storage (in-memory)
  static final List<ExerciseScore> _mockScores = [];

  // Current authenticated user
  UserModel? _currentUser;

  // ==================== AUTHENTICATION ====================

  UserModel? get currentUser => _currentUser;

  Future<bool> signInWithEmail(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Check mock users
    final user = _mockUsers.firstWhere(
      (u) => u.email == email,
      orElse: () => throw Exception('User not found'),
    );

    // For demo, any password works
    _currentUser = user;
    return true;
  }

  Future<bool> signUpWithEmail(
    String email,
    String password,
    String name,
    UserRole role,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Create new user
    final newUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      role: role,
      createdAt: DateTime.now(),
    );

    _mockUsers.add(newUser);
    _currentUser = newUser;
    return true;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }

  // ==================== USER OPERATIONS ====================

  Future<void> saveUser(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _mockUsers.indexWhere((u) => u.id == user.id);
    if (index >= 0) {
      _mockUsers[index] = user;
    } else {
      _mockUsers.add(user);
    }
  }

  Future<UserModel?> getUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _mockUsers.firstWhere((u) => u.id == userId);
    } catch (e) {
      return null;
    }
  }

  /// Update user's language preference
  Future<void> updateUserLanguage(String userId, String languageCode) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final userIndex = _mockUsers.indexWhere((u) => u.id == userId);
    if (userIndex != -1) {
      _mockUsers[userIndex] = _mockUsers[userIndex].copyWith(
        preferredLanguage: languageCode,
      );
    }
  }

  // ==================== EXERCISE OPERATIONS ====================

  Future<List<Exercise>> getExercises() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockExercises);
  }

  Future<Exercise?> getExercise(String exerciseId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _mockExercises.firstWhere((e) => e.id == exerciseId);
    } catch (e) {
      return null;
    }
  }

  // ==================== EXERCISE SCORE OPERATIONS ====================

  Future<void> saveExerciseScore(ExerciseScore score) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockScores.add(score);
    print('Mock: Saved score - ${score.exerciseTitle}: ${score.score}/${score.maxScore}');
  }

  Future<List<ExerciseScore>> getPatientScores(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockScores
        .where((s) => s.patientId == patientId)
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  Stream<List<ExerciseScore>> getPatientScoresStream(String patientId) {
    // For mock, return a stream that emits current scores
    return Stream.value(
      _mockScores
          .where((s) => s.patientId == patientId)
          .toList()
        ..sort((a, b) => b.completedAt.compareTo(a.completedAt)),
    );
  }

  // ==================== PATIENT PROGRESS OPERATIONS ====================

  Future<List<UserModel>> getTherapistPatients(String therapistId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Filter patients by their assigned therapist
    return _mockUsers.where((u) => 
        u.role == UserRole.patient && 
        u.therapistId == therapistId
    ).toList();
  }

  /// Create a new patient (called by therapist)
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
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if email already exists
    final existingUserIndex = _mockUsers.indexWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );
    if (existingUserIndex >= 0) {
      throw Exception('A user with this email already exists');
    }

    // Get current therapist ID (if available)
    final therapistId = _currentUser?.role == UserRole.therapist ? _currentUser?.id : null;

    // Create new patient user
    final newPatient = UserModel(
      id: 'patient_${DateTime.now().millisecondsSinceEpoch}',
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
      onboardingEmailSent: sendOnboardingEmail,
      preferredLanguage: preferredLanguage,
    );

    _mockUsers.add(newPatient);
    
    // Mock email sending
    if (sendOnboardingEmail) {
      print('Mock: Sending onboarding email to $email for modules: ${assignedModules?.map((m) => m.name).join(", ") ?? "writing"}');
    }
    
    return newPatient;
  }

  Future<PatientProgress?> getPatientProgress(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 300));
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
  }

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

  // Helper method to add some sample scores for demo
  void addSampleScores() {
    if (_mockScores.isEmpty) {
      final now = DateTime.now();
      _mockScores.addAll([
        // Patient 1 scores (5 exercises)
        ExerciseScore(
          id: 'score1',
          patientId: 'patient1',
          exerciseId: 'exercise1',
          exerciseTitle: 'Writing - Animal',
          score: 100,
          maxScore: 100,
          answer: 'Cat',
          correctAnswer: 'Cat',
          completedAt: now.subtract(const Duration(days: 5)),
          metadata: {'timeTaken': 25, 'difficulty': 1, 'category': 'animal', 'cueLevel': 0},
        ),
        ExerciseScore(
          id: 'score2',
          patientId: 'patient1',
          exerciseId: 'exercise2',
          exerciseTitle: 'Writing - Food',
          score: 100,
          maxScore: 100,
          answer: 'Apple',
          correctAnswer: 'Apple',
          completedAt: now.subtract(const Duration(days: 4)),
          metadata: {'timeTaken': 30, 'difficulty': 1, 'category': 'food', 'cueLevel': 0},
        ),
        ExerciseScore(
          id: 'score3',
          patientId: 'patient1',
          exerciseId: 'exercise5',
          exerciseTitle: 'Comprehension - Animal',
          score: 100,
          maxScore: 100,
          answer: 'Dog',
          correctAnswer: 'Dog',
          completedAt: now.subtract(const Duration(days: 3)),
          metadata: {'timeTaken': 35, 'difficulty': 1, 'category': 'animal', 'cueLevel': 1},
        ),
        ExerciseScore(
          id: 'score4',
          patientId: 'patient1',
          exerciseId: 'exercise3',
          exerciseTitle: 'Writing - Body Parts',
          score: 0,
          maxScore: 100,
          answer: 'Arm',
          correctAnswer: 'Hand',
          completedAt: now.subtract(const Duration(days: 2)),
          metadata: {'timeTaken': 50, 'difficulty': 1, 'category': 'bodyParts', 'cueLevel': 2},
        ),
        ExerciseScore(
          id: 'score5',
          patientId: 'patient1',
          exerciseId: 'exercise6',
          exerciseTitle: 'Comprehension - Food',
          score: 100,
          maxScore: 100,
          answer: 'Banana',
          correctAnswer: 'Banana',
          completedAt: now.subtract(const Duration(days: 1)),
          metadata: {'timeTaken': 28, 'difficulty': 1, 'category': 'food', 'cueLevel': 0},
        ),
        // Patient 2 scores (6 exercises)
        ExerciseScore(
          id: 'score6',
          patientId: 'patient2',
          exerciseId: 'exercise1',
          exerciseTitle: 'Writing - Animal',
          score: 100,
          maxScore: 100,
          answer: 'Cat',
          correctAnswer: 'Cat',
          completedAt: now.subtract(const Duration(days: 6)),
          metadata: {'timeTaken': 20, 'difficulty': 1, 'category': 'animal', 'cueLevel': 0},
        ),
        ExerciseScore(
          id: 'score7',
          patientId: 'patient2',
          exerciseId: 'exercise4',
          exerciseTitle: 'Writing - Clothing',
          score: 100,
          maxScore: 100,
          answer: 'Shirt',
          correctAnswer: 'Shirt',
          completedAt: now.subtract(const Duration(days: 5)),
          metadata: {'timeTaken': 32, 'difficulty': 1, 'category': 'clothing', 'cueLevel': 0},
        ),
        ExerciseScore(
          id: 'score8',
          patientId: 'patient2',
          exerciseId: 'exercise5',
          exerciseTitle: 'Comprehension - Animal',
          score: 0,
          maxScore: 100,
          answer: 'Cat',
          correctAnswer: 'Dog',
          completedAt: now.subtract(const Duration(days: 4)),
          metadata: {'timeTaken': 55, 'difficulty': 1, 'category': 'animal', 'cueLevel': 3},
        ),
        ExerciseScore(
          id: 'score9',
          patientId: 'patient2',
          exerciseId: 'exercise2',
          exerciseTitle: 'Writing - Food',
          score: 100,
          maxScore: 100,
          answer: 'Apple',
          correctAnswer: 'Apple',
          completedAt: now.subtract(const Duration(days: 3)),
          metadata: {'timeTaken': 27, 'difficulty': 1, 'category': 'food', 'cueLevel': 0},
        ),
        ExerciseScore(
          id: 'score10',
          patientId: 'patient2',
          exerciseId: 'exercise11',
          exerciseTitle: 'Comprehension - Body Parts',
          score: 100,
          maxScore: 100,
          answer: 'Hand',
          correctAnswer: 'Hand',
          completedAt: now.subtract(const Duration(days: 2)),
          metadata: {'timeTaken': 40, 'difficulty': 1, 'category': 'bodyParts', 'cueLevel': 1},
        ),
        ExerciseScore(
          id: 'score11',
          patientId: 'patient2',
          exerciseId: 'exercise12',
          exerciseTitle: 'Comprehension - Clothing',
          score: 100,
          maxScore: 100,
          answer: 'Shirt',
          correctAnswer: 'Shirt',
          completedAt: now.subtract(const Duration(days: 1)),
          metadata: {'timeTaken': 33, 'difficulty': 1, 'category': 'clothing', 'cueLevel': 0},
        ),
        // Patient 3 scores (6 exercises)
        ExerciseScore(
          id: 'score12',
          patientId: 'patient3',
          exerciseId: 'exercise1',
          exerciseTitle: 'Writing - Animal',
          score: 0,
          maxScore: 100,
          answer: 'Dog',
          correctAnswer: 'Cat',
          completedAt: now.subtract(const Duration(days: 7)),
          metadata: {'timeTaken': 60, 'difficulty': 1, 'category': 'animal', 'cueLevel': 3},
        ),
        ExerciseScore(
          id: 'score13',
          patientId: 'patient3',
          exerciseId: 'exercise7',
          exerciseTitle: 'Writing - Animal',
          score: 100,
          maxScore: 100,
          answer: 'Dog',
          correctAnswer: 'Dog',
          completedAt: now.subtract(const Duration(days: 6)),
          metadata: {'timeTaken': 45, 'difficulty': 1, 'category': 'animal', 'cueLevel': 2},
        ),
        ExerciseScore(
          id: 'score14',
          patientId: 'patient3',
          exerciseId: 'exercise3',
          exerciseTitle: 'Writing - Body Parts',
          score: 100,
          maxScore: 100,
          answer: 'Hand',
          correctAnswer: 'Hand',
          completedAt: now.subtract(const Duration(days: 5)),
          metadata: {'timeTaken': 38, 'difficulty': 1, 'category': 'bodyParts', 'cueLevel': 1},
        ),
        ExerciseScore(
          id: 'score15',
          patientId: 'patient3',
          exerciseId: 'exercise6',
          exerciseTitle: 'Comprehension - Food',
          score: 100,
          maxScore: 100,
          answer: 'Banana',
          correctAnswer: 'Banana',
          completedAt: now.subtract(const Duration(days: 4)),
          metadata: {'timeTaken': 42, 'difficulty': 1, 'category': 'food', 'cueLevel': 1},
        ),
        ExerciseScore(
          id: 'score16',
          patientId: 'patient3',
          exerciseId: 'exercise4',
          exerciseTitle: 'Writing - Clothing',
          score: 0,
          maxScore: 100,
          answer: 'Pants',
          correctAnswer: 'Shirt',
          completedAt: now.subtract(const Duration(days: 3)),
          metadata: {'timeTaken': 65, 'difficulty': 1, 'category': 'clothing', 'cueLevel': 3},
        ),
        ExerciseScore(
          id: 'score17',
          patientId: 'patient3',
          exerciseId: 'exercise10',
          exerciseTitle: 'Writing - Clothing',
          score: 100,
          maxScore: 100,
          answer: 'Pants',
          correctAnswer: 'Pants',
          completedAt: now.subtract(const Duration(days: 2)),
          metadata: {'timeTaken': 35, 'difficulty': 1, 'category': 'clothing', 'cueLevel': 0},
        ),
        // Patient 4 scores (8 exercises - most active)
        ExerciseScore(
          id: 'score18',
          patientId: 'patient4',
          exerciseId: 'exercise2',
          exerciseTitle: 'Writing - Food',
          score: 100,
          maxScore: 100,
          answer: 'Apple',
          correctAnswer: 'Apple',
          completedAt: now.subtract(const Duration(days: 8)),
          metadata: {'timeTaken': 22, 'difficulty': 1, 'category': 'food', 'cueLevel': 0},
        ),
        ExerciseScore(
          id: 'score19',
          patientId: 'patient4',
          exerciseId: 'exercise8',
          exerciseTitle: 'Writing - Food',
          score: 100,
          maxScore: 100,
          answer: 'Banana',
          correctAnswer: 'Banana',
          completedAt: now.subtract(const Duration(days: 7)),
          metadata: {'timeTaken': 24, 'difficulty': 1, 'category': 'food', 'cueLevel': 0},
        ),
        ExerciseScore(
          id: 'score20',
          patientId: 'patient4',
          exerciseId: 'exercise5',
          exerciseTitle: 'Comprehension - Animal',
          score: 100,
          maxScore: 100,
          answer: 'Dog',
          correctAnswer: 'Dog',
          completedAt: now.subtract(const Duration(days: 6)),
          metadata: {'timeTaken': 30, 'difficulty': 1, 'category': 'animal', 'cueLevel': 0},
        ),
        ExerciseScore(
          id: 'score21',
          patientId: 'patient4',
          exerciseId: 'exercise9',
          exerciseTitle: 'Writing - Body Parts',
          score: 100,
          maxScore: 100,
          answer: 'Foot',
          correctAnswer: 'Foot',
          completedAt: now.subtract(const Duration(days: 5)),
          metadata: {'timeTaken': 29, 'difficulty': 1, 'category': 'bodyParts', 'cueLevel': 0},
        ),
        ExerciseScore(
          id: 'score22',
          patientId: 'patient4',
          exerciseId: 'exercise11',
          exerciseTitle: 'Comprehension - Body Parts',
          score: 100,
          maxScore: 100,
          answer: 'Hand',
          correctAnswer: 'Hand',
          completedAt: now.subtract(const Duration(days: 4)),
          metadata: {'timeTaken': 31, 'difficulty': 1, 'category': 'bodyParts', 'cueLevel': 0},
        ),
        ExerciseScore(
          id: 'score23',
          patientId: 'patient4',
          exerciseId: 'exercise12',
          exerciseTitle: 'Comprehension - Clothing',
          score: 100,
          maxScore: 100,
          answer: 'Shirt',
          correctAnswer: 'Shirt',
          completedAt: now.subtract(const Duration(days: 3)),
          metadata: {'timeTaken': 26, 'difficulty': 1, 'category': 'clothing', 'cueLevel': 0},
        ),
        ExerciseScore(
          id: 'score24',
          patientId: 'patient4',
          exerciseId: 'exercise4',
          exerciseTitle: 'Writing - Clothing',
          score: 100,
          maxScore: 100,
          answer: 'Shirt',
          correctAnswer: 'Shirt',
          completedAt: now.subtract(const Duration(days: 2)),
          metadata: {'timeTaken': 28, 'difficulty': 1, 'category': 'clothing', 'cueLevel': 0},
        ),
        ExerciseScore(
          id: 'score25',
          patientId: 'patient4',
          exerciseId: 'exercise1',
          exerciseTitle: 'Writing - Animal',
          score: 100,
          maxScore: 100,
          answer: 'Cat',
          correctAnswer: 'Cat',
          completedAt: now.subtract(const Duration(days: 1)),
          metadata: {'timeTaken': 23, 'difficulty': 1, 'category': 'animal', 'cueLevel': 0},
        ),
      ]);
    }
  }
  
  // ==================== QUESTION RESPONSE OPERATIONS ====================
  
  /// Save individual question response (mock implementation)
  Future<void> saveQuestionResponse(Map<String, dynamic> response) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // In mock mode, we just log it
    print('Mock: Saved question response ${response['id']}');
  }
  
  /// Save multiple question responses (mock implementation)
  Future<void> saveQuestionResponses(List<Map<String, dynamic>> responses) async {
    await Future.delayed(const Duration(milliseconds: 200));
    print('Mock: Saved ${responses.length} question responses');
  }
  
  /// Get question responses for a patient (mock implementation)
  Future<List<Map<String, dynamic>>> getPatientResponses(String patientId, {int? limit}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return []; // Return empty list in mock mode
  }
  
  // ==================== EXERCISE SESSION OPERATIONS ====================
  
  /// Save exercise session (mock implementation)
  Future<void> saveExerciseSession(Map<String, dynamic> session) async {
    await Future.delayed(const Duration(milliseconds: 100));
    print('Mock: Saved exercise session ${session['id']}');
  }
  
  /// Get exercise sessions for a patient (mock implementation)
  Future<List<Map<String, dynamic>>> getPatientSessions(String patientId, {int? limit}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return []; // Return empty list in mock mode
  }
}

