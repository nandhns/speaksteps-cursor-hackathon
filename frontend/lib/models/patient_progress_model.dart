import 'exercise_score_model.dart';

class PatientProgress {
  final String patientId;
  final String patientName;
  final int totalExercisesCompleted;
  final double averageScore; // 0-100
  final DateTime lastActivity;
  final List<ExerciseScore> recentScores; // Last 5-10 scores
  final Map<String, int> scoresByExercise; // Exercise ID -> latest score

  PatientProgress({
    required this.patientId,
    required this.patientName,
    required this.totalExercisesCompleted,
    required this.averageScore,
    required this.lastActivity,
    required this.recentScores,
    required this.scoresByExercise,
  });

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'totalExercisesCompleted': totalExercisesCompleted,
      'averageScore': averageScore,
      'lastActivity': lastActivity.toIso8601String(),
      'recentScores': recentScores.map((s) => s.toMap()).toList(),
      'scoresByExercise': scoresByExercise,
    };
  }

  factory PatientProgress.fromMap(Map<String, dynamic> map) {
    return PatientProgress(
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      totalExercisesCompleted: map['totalExercisesCompleted'] ?? 0,
      averageScore: (map['averageScore'] ?? 0).toDouble(),
      lastActivity: map['lastActivity'] != null
          ? DateTime.parse(map['lastActivity'])
          : DateTime.now(),
      recentScores: (map['recentScores'] as List<dynamic>?)
              ?.map((s) => ExerciseScore.fromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
      scoresByExercise: map['scoresByExercise'] != null
          ? Map<String, int>.from(map['scoresByExercise'])
          : {},
    );
  }
}

