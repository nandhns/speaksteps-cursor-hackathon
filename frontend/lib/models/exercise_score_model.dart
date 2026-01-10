import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseScore {
  final String id;
  final String patientId;
  final String exerciseId;
  final String exerciseTitle;
  final int score; // 0-100
  final int maxScore;
  final String? answer;
  final String? correctAnswer;
  final DateTime completedAt;
  final Map<String, dynamic>? metadata; // Additional data like time taken, attempts, etc.

  ExerciseScore({
    required this.id,
    required this.patientId,
    required this.exerciseId,
    required this.exerciseTitle,
    required this.score,
    required this.maxScore,
    this.answer,
    this.correctAnswer,
    required this.completedAt,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'exerciseId': exerciseId,
      'exerciseTitle': exerciseTitle,
      'score': score,
      'maxScore': maxScore,
      'answer': answer,
      'correctAnswer': correctAnswer,
      'completedAt': completedAt.toIso8601String(),
      'metadata': metadata ?? {},
    };
  }

  factory ExerciseScore.fromMap(Map<String, dynamic> map) {
    // Handle completedAt as either Timestamp or String
    DateTime parsedDate = DateTime.now();
    final completedAtValue = map['completedAt'];

    if (completedAtValue is Timestamp) {
      // Firestore Timestamp
      parsedDate = completedAtValue.toDate();
    } else if (completedAtValue is String) {
      // ISO 8601 string
      parsedDate = DateTime.parse(completedAtValue);
    } else if (completedAtValue != null) {
      try {
        // Try to parse as DateTime
        parsedDate = completedAtValue as DateTime;
      } catch (_) {
        // Fallback to now()
      }
    }

    return ExerciseScore(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      exerciseId: map['exerciseId'] ?? '',
      exerciseTitle: map['exerciseTitle'] ?? '',
      score: map['score'] ?? 0,
      maxScore: map['maxScore'] ?? 100,
      answer: map['answer'],
      correctAnswer: map['correctAnswer'],
      completedAt: parsedDate,
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
    );
  }
}

