/// Model to track overall exercise session data
/// This captures session-level metrics for therapist review and analytics
class ExerciseSession {
  final String id;
  final String patientId;
  final String therapistId;
  final String exerciseId;
  final String exerciseTitle;
  final String module; // 'writing' or 'comprehension'
  final String category;
  
  // Session timing
  final DateTime startTime;
  final DateTime? endTime;
  final int totalTimeSeconds; // Total time spent in session
  final int activeTimeSeconds; // Time actively working (excluding pauses)
  
  // Performance metrics
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int questionsSkipped;
  final double accuracyPercentage;
  
  // Cue usage
  final int totalCuesGiven;
  final int questionsWithCues;
  final Map<String, int> cueTypeCount; // Count of each cue type used
  
  // Additional metadata
  final String? deviceType; // 'mobile', 'web', 'tablet'
  final Map<String, dynamic>? metadata;
  
  ExerciseSession({
    required this.id,
    required this.patientId,
    required this.therapistId,
    required this.exerciseId,
    required this.exerciseTitle,
    required this.module,
    required this.category,
    required this.startTime,
    this.endTime,
    required this.totalTimeSeconds,
    required this.activeTimeSeconds,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    this.questionsSkipped = 0,
    required this.accuracyPercentage,
    required this.totalCuesGiven,
    required this.questionsWithCues,
    required this.cueTypeCount,
    this.deviceType,
    this.metadata,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'therapistId': therapistId,
      'exerciseId': exerciseId,
      'exerciseTitle': exerciseTitle,
      'module': module,
      'category': category,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'totalTimeSeconds': totalTimeSeconds,
      'activeTimeSeconds': activeTimeSeconds,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'questionsSkipped': questionsSkipped,
      'accuracyPercentage': accuracyPercentage,
      'totalCuesGiven': totalCuesGiven,
      'questionsWithCues': questionsWithCues,
      'cueTypeCount': cueTypeCount,
      'deviceType': deviceType,
      'metadata': metadata ?? {},
    };
  }
  
  factory ExerciseSession.fromMap(Map<String, dynamic> map) {
    return ExerciseSession(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      therapistId: map['therapistId'] ?? '',
      exerciseId: map['exerciseId'] ?? '',
      exerciseTitle: map['exerciseTitle'] ?? '',
      module: map['module'] ?? '',
      category: map['category'] ?? '',
      startTime: map['startTime'] != null
          ? DateTime.parse(map['startTime'])
          : DateTime.now(),
      endTime: map['endTime'] != null
          ? DateTime.parse(map['endTime'])
          : null,
      totalTimeSeconds: map['totalTimeSeconds'] ?? 0,
      activeTimeSeconds: map['activeTimeSeconds'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      incorrectAnswers: map['incorrectAnswers'] ?? 0,
      questionsSkipped: map['questionsSkipped'] ?? 0,
      accuracyPercentage: (map['accuracyPercentage'] ?? 0.0).toDouble(),
      totalCuesGiven: map['totalCuesGiven'] ?? 0,
      questionsWithCues: map['questionsWithCues'] ?? 0,
      cueTypeCount: map['cueTypeCount'] != null
          ? Map<String, int>.from(map['cueTypeCount'])
          : {},
      deviceType: map['deviceType'],
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
    );
  }
}

