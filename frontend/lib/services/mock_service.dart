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
    // Writing exercises
    Exercise(
      id: 'exercise1',
      title: 'Writing - Animal',
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
    Exercise(
      id: 'exercise2',
      title: 'Writing - Food',
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
    Exercise(
      id: 'exercise3',
      title: 'Writing - Body Parts',
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
    Exercise(
      id: 'exercise4',
      title: 'Writing - Clothing',
      description: 'Look at the image and type the word you see.',
      type: 'writing',
      category: ExerciseCategory.clothing,
      exerciseType: ExerciseType.writing,
      options: [],
      correctAnswer: 'Shirt',
      difficulty: 1,
      imageUrl: null,
      cueHierarchy: {
        'function': 'You wear it on your upper body',
        'rhyming': 'Rhymes with "hurt"',
        'written': 'S-H-I-R-T',
      },
      questions: _generateWritingQuestions(
        'exercise4',
        ['Shirt', 'Pants', 'Hat', 'Shoes', 'Socks'],
        [
          {'function': 'You wear it on your upper body', 'rhyming': 'Rhymes with "hurt"', 'written': 'S-H-I-R-T'},
          {'function': 'You wear them on your legs', 'rhyming': 'Rhymes with "ants"', 'written': 'P-A-N-T-S'},
          {'function': 'You wear it on your head', 'rhyming': 'Rhymes with "cat"', 'written': 'H-A-T'},
          {'function': 'You wear them on your feet', 'rhyming': 'Rhymes with "news"', 'written': 'S-H-O-E-S'},
          {'function': 'You wear them under shoes', 'rhyming': 'Rhymes with "locks"', 'written': 'S-O-C-K-S'},
        ],
      ),
    ),
    // Comprehension exercises (Easy level - wrong answers from different categories)
    Exercise(
      id: 'exercise5',
      title: 'Comprehension - Animal',
      description: 'Listen to the audio and match the picture to the word shown.',
      type: 'comprehension',
      category: ExerciseCategory.animal,
      exerciseType: ExerciseType.comprehension,
      options: ['Dog', 'Hand', 'Shirt', 'Apple'],
      correctAnswer: 'Dog',
      difficulty: 1,
      audioUrl: null,
      imageOptions: ['Dog', 'Hand', 'Shirt', 'Apple'],
      cueHierarchy: {
        'function': 'It barks and wags its tail',
        'rhyming': 'Rhymes with "log"',
        'written': 'D-O-G',
      },
      questions: _generateComprehensionQuestions(
        'exercise5',
        ['Dog', 'Cat', 'Bird', 'Fish', 'Lion'],
        [
          ['Dog', 'Hand', 'Shirt', 'Apple'],
          ['Cat', 'Foot', 'Pants', 'Banana'],
          ['Bird', 'Eye', 'Hat', 'Bread'],
          ['Fish', 'Ear', 'Shoes', 'Milk'],
          ['Lion', 'Nose', 'Socks', 'Orange'],
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
      title: 'Comprehension - Food',
      description: 'Listen to the audio and match the picture to the word shown.',
      type: 'comprehension',
      category: ExerciseCategory.food,
      exerciseType: ExerciseType.comprehension,
      options: ['Banana', 'Cat', 'Foot', 'Pants'],
      correctAnswer: 'Banana',
      difficulty: 1,
      audioUrl: null,
      imageOptions: ['Banana', 'Cat', 'Foot', 'Pants'],
      cueHierarchy: {
        'function': 'A yellow fruit',
        'rhyming': 'Rhymes with "bandana"',
        'written': 'B-A-N-A-N-A',
      },
      questions: _generateComprehensionQuestions(
        'exercise6',
        ['Banana', 'Apple', 'Bread', 'Milk', 'Orange'],
        [
          ['Banana', 'Cat', 'Foot', 'Pants'],
          ['Apple', 'Dog', 'Hand', 'Shirt'],
          ['Bread', 'Bird', 'Eye', 'Hat'],
          ['Milk', 'Fish', 'Ear', 'Shoes'],
          ['Orange', 'Lion', 'Nose', 'Socks'],
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
    // More Writing exercises
    Exercise(
      id: 'exercise7',
      title: 'Writing - Animal',
      description: 'Look at the image and type the word you see.',
      type: 'writing',
      category: ExerciseCategory.animal,
      exerciseType: ExerciseType.writing,
      options: [],
      correctAnswer: 'Dog',
      difficulty: 1,
      imageUrl: null,
      cueHierarchy: {
        'function': 'It barks and wags its tail',
        'rhyming': 'Rhymes with "log"',
        'written': 'D-O-G',
      },
      questions: _generateWritingQuestions(
        'exercise7',
        ['Dog', 'Cat', 'Bird', 'Fish', 'Lion'],
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
      id: 'exercise8',
      title: 'Writing - Food',
      description: 'Look at the image and type the word you see.',
      type: 'writing',
      category: ExerciseCategory.food,
      exerciseType: ExerciseType.writing,
      options: [],
      correctAnswer: 'Banana',
      difficulty: 1,
      imageUrl: null,
      cueHierarchy: {
        'function': 'A yellow fruit',
        'rhyming': 'Rhymes with "bandana"',
        'written': 'B-A-N-A-N-A',
      },
      questions: _generateWritingQuestions(
        'exercise8',
        ['Banana', 'Apple', 'Bread', 'Milk', 'Orange'],
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
      id: 'exercise9',
      title: 'Writing - Body Parts',
      description: 'Look at the image and type the word you see.',
      type: 'writing',
      category: ExerciseCategory.bodyParts,
      exerciseType: ExerciseType.writing,
      options: [],
      correctAnswer: 'Foot',
      difficulty: 1,
      imageUrl: null,
      cueHierarchy: {
        'function': 'You walk with it',
        'rhyming': 'Rhymes with "put"',
        'written': 'F-O-O-T',
      },
      questions: _generateWritingQuestions(
        'exercise9',
        ['Foot', 'Hand', 'Eye', 'Ear', 'Nose'],
        [
          {'function': 'You walk with it', 'rhyming': 'Rhymes with "put"', 'written': 'F-O-O-T'},
          {'function': 'You use it to hold things', 'rhyming': 'Rhymes with "band"', 'written': 'H-A-N-D'},
          {'function': 'You see with it', 'rhyming': 'Rhymes with "sky"', 'written': 'E-Y-E'},
          {'function': 'You hear with it', 'rhyming': 'Rhymes with "near"', 'written': 'E-A-R'},
          {'function': 'You smell with it', 'rhyming': 'Rhymes with "rose"', 'written': 'N-O-S-E'},
        ],
      ),
    ),
    Exercise(
      id: 'exercise10',
      title: 'Writing - Clothing',
      description: 'Look at the image and type the word you see.',
      type: 'writing',
      category: ExerciseCategory.clothing,
      exerciseType: ExerciseType.writing,
      options: [],
      correctAnswer: 'Pants',
      difficulty: 1,
      imageUrl: null,
      cueHierarchy: {
        'function': 'You wear them on your legs',
        'rhyming': 'Rhymes with "ants"',
        'written': 'P-A-N-T-S',
      },
      questions: _generateWritingQuestions(
        'exercise10',
        ['Pants', 'Shirt', 'Hat', 'Shoes', 'Socks'],
        [
          {'function': 'You wear them on your legs', 'rhyming': 'Rhymes with "ants"', 'written': 'P-A-N-T-S'},
          {'function': 'You wear it on your upper body', 'rhyming': 'Rhymes with "hurt"', 'written': 'S-H-I-R-T'},
          {'function': 'You wear it on your head', 'rhyming': 'Rhymes with "cat"', 'written': 'H-A-T'},
          {'function': 'You wear them on your feet', 'rhyming': 'Rhymes with "news"', 'written': 'S-H-O-E-S'},
          {'function': 'You wear them under shoes', 'rhyming': 'Rhymes with "locks"', 'written': 'S-O-C-K-S'},
        ],
      ),
    ),
    // More Comprehension exercises
    Exercise(
      id: 'exercise11',
      title: 'Comprehension - Body Parts',
      description: 'Listen to the audio and match the picture to the word shown.',
      type: 'comprehension',
      category: ExerciseCategory.bodyParts,
      exerciseType: ExerciseType.comprehension,
      options: ['Hand', 'Dog', 'Shirt', 'Apple'],
      correctAnswer: 'Hand',
      difficulty: 1,
      audioUrl: null,
      imageOptions: ['Hand', 'Dog', 'Shirt', 'Apple'],
      cueHierarchy: {
        'function': 'You use it to hold things',
        'rhyming': 'Rhymes with "band"',
        'written': 'H-A-N-D',
      },
      questions: _generateComprehensionQuestions(
        'exercise11',
        ['Hand', 'Foot', 'Eye', 'Ear', 'Nose'],
        [
          ['Hand', 'Dog', 'Shirt', 'Apple'],
          ['Foot', 'Cat', 'Pants', 'Banana'],
          ['Eye', 'Bird', 'Hat', 'Bread'],
          ['Ear', 'Fish', 'Shoes', 'Milk'],
          ['Nose', 'Lion', 'Socks', 'Orange'],
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
      id: 'exercise12',
      title: 'Comprehension - Clothing',
      description: 'Listen to the audio and match the picture to the word shown.',
      type: 'comprehension',
      category: ExerciseCategory.clothing,
      exerciseType: ExerciseType.comprehension,
      options: ['Shirt', 'Cat', 'Foot', 'Banana'],
      correctAnswer: 'Shirt',
      difficulty: 1,
      audioUrl: null,
      imageOptions: ['Shirt', 'Cat', 'Foot', 'Banana'],
      cueHierarchy: {
        'function': 'You wear it on your upper body',
        'rhyming': 'Rhymes with "hurt"',
        'written': 'S-H-I-R-T',
      },
      questions: _generateComprehensionQuestions(
        'exercise12',
        ['Shirt', 'Pants', 'Hat', 'Shoes', 'Socks'],
        [
          ['Shirt', 'Cat', 'Foot', 'Banana'],
          ['Pants', 'Dog', 'Hand', 'Apple'],
          ['Hat', 'Bird', 'Eye', 'Bread'],
          ['Shoes', 'Fish', 'Ear', 'Milk'],
          ['Socks', 'Lion', 'Nose', 'Orange'],
        ],
        [
          {'function': 'You wear it on your upper body', 'rhyming': 'Rhymes with "hurt"', 'written': 'S-H-I-R-T'},
          {'function': 'You wear it on your legs', 'rhyming': 'Rhymes with "ants"', 'written': 'P-A-N-T-S'},
          {'function': 'You wear it on your head', 'rhyming': 'Rhymes with "bat"', 'written': 'H-A-T'},
          {'function': 'You wear them on your feet', 'rhyming': 'Rhymes with "news"', 'written': 'S-H-O-E-S'},
          {'function': 'You wear them under shoes', 'rhyming': 'Rhymes with "locks"', 'written': 'S-O-C-K-S'},
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
    return _mockUsers.where((u) => u.role == UserRole.patient).toList();
  }

  /// Create a new patient (called by therapist)
  Future<UserModel?> createPatient({
    required String email,
    required String name,
    required String diagnosis,
    required String patientPhone,
    required String caregiverName,
    required String caregiverPhone,
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
    );

    _mockUsers.add(newPatient);
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
}

