/// Model to track individual question responses within an exercise
/// This captures detailed per-question data for ML training and therapist review
class QuestionResponse {
  final String id;
  final String sessionId; // Links to the overall exercise session
  final String patientId;
  final String therapistId; // Links response to the patient's therapist
  final String exerciseId;
  final int questionIndex;
  final String questionText;
  final String? questionImageUrl;
  
  // Response data
  final String? userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  
  // Timing data
  final DateTime presentedAt; // When the question was shown
  final DateTime? respondedAt; // When the user submitted their answer
  final int responseTimeSeconds; // Time taken to respond
  
  // Cue/hint data
  final bool cueGiven;
  final String? cueType; // 'functional', 'rhyming', 'written_initial', 'phonemic', etc.
  final int cueStage; // 0 = no cue, 1-7 = progressive cue levels
  final int? cueWaitSeconds; // Seconds before cue was shown
  final int? timeAfterCueDisplayed; // Seconds from cue display to answer submission
  final int hintCount; // Number of hints/cues shown for this question
  
  // Additional metadata
  final String? difficulty; // 'easy', 'medium', 'hard'
  final String? category;
  final String? module; // 'writing', 'comprehension'
  final int attemptNumber; // Which attempt this is (for retries)
  final Map<String, dynamic>? metadata;

  QuestionResponse({
    required this.id,
    required this.sessionId,
    required this.patientId,
    required this.therapistId,
    required this.exerciseId,
    required this.questionIndex,
    required this.questionText,
    this.questionImageUrl,
    this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.presentedAt,
    this.respondedAt,
    required this.responseTimeSeconds,
    required this.cueGiven,
    this.cueType,
    required this.cueStage,
    this.cueWaitSeconds,
    this.timeAfterCueDisplayed,
    required this.hintCount,
    this.difficulty,
    this.category,
    this.module,
    this.attemptNumber = 1,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'patientId': patientId,
      'therapistId': therapistId,
      'exerciseId': exerciseId,
      'questionIndex': questionIndex,
      'questionText': questionText,
      'questionImageUrl': questionImageUrl,
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
      'presentedAt': presentedAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
      'responseTimeSeconds': responseTimeSeconds,
      'cueGiven': cueGiven,
      'cueType': cueType,
      'cueStage': cueStage,
      'cueWaitSeconds': cueWaitSeconds,
      'timeAfterCueDisplayed': timeAfterCueDisplayed,
      'hintCount': hintCount,
      'difficulty': difficulty,
      'category': category,
      'module': module,
      'attemptNumber': attemptNumber,
      'metadata': metadata ?? {},
    };
  }

  factory QuestionResponse.fromMap(Map<String, dynamic> map) {
    return QuestionResponse(
      id: map['id'] ?? '',
      sessionId: map['sessionId'] ?? '',
      patientId: map['patientId'] ?? '',
      therapistId: map['therapistId'] ?? '',
      exerciseId: map['exerciseId'] ?? '',
      questionIndex: map['questionIndex'] ?? 0,
      questionText: map['questionText'] ?? '',
      questionImageUrl: map['questionImageUrl'],
      userAnswer: map['userAnswer'],
      correctAnswer: map['correctAnswer'] ?? '',
      isCorrect: map['isCorrect'] ?? false,
      presentedAt: map['presentedAt'] != null
          ? DateTime.parse(map['presentedAt'])
          : DateTime.now(),
      respondedAt: map['respondedAt'] != null
          ? DateTime.parse(map['respondedAt'])
          : null,
      responseTimeSeconds: map['responseTimeSeconds'] ?? 0,
      cueGiven: map['cueGiven'] ?? false,
      cueType: map['cueType'],
      cueStage: map['cueStage'] ?? 0,
      cueWaitSeconds: map['cueWaitSeconds'],
      timeAfterCueDisplayed: map['timeAfterCueDisplayed'],
      hintCount: map['hintCount'] ?? 0,
      difficulty: map['difficulty'],
      category: map['category'],
      module: map['module'],
      attemptNumber: map['attemptNumber'] ?? 1,
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
    );
  }
}

