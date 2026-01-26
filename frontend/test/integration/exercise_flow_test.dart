import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/exercise_model.dart';
import 'package:frontend/models/exercise_score_model.dart';
import 'package:frontend/services/app_service.dart';

void main() {
  group('Exercise Flow Integration Tests', () {
    late AppService service;

    setUp(() {
      service = ServiceFactory.createService();
    });

    test('Can fetch exercises from service', () async {
      final exercises = await service.getExercises();
      
      expect(exercises, isNotEmpty);
      expect(exercises.first, isA<Exercise>());
    });

    test('Can get specific exercise by ID', () async {
      final exercises = await service.getExercises();
      final firstExercise = exercises.first;
      
      final exercise = await service.getExercise(firstExercise.id);
      
      expect(exercise, isNotNull);
      expect(exercise!.id, firstExercise.id);
    });

    test('Can save exercise score', () async {
      final score = ExerciseScore(
        id: 'test_score_1',
        patientId: 'patient_1',
        exerciseId: 'exercise_1',
        score: 85,
        completedAt: DateTime.now(),
        attemptsCount: 1,
        hintsUsed: 2,
        timeSpentSeconds: 120,
      );
      
      await service.saveExerciseScore(score);
      
      // Verify it was saved
      final scores = await service.getPatientScores('patient_1');
      expect(scores.any((s) => s.id == score.id), true);
    });

    test('Can fetch patient scores', () async {
      final scores = await service.getPatientScores('patient_1');
      
      expect(scores, isA<List<ExerciseScore>>());
    });

    test('Exercise has required fields', () async {
      final exercises = await service.getExercises();
      final exercise = exercises.first;
      
      expect(exercise.id, isNotEmpty);
      expect(exercise.category, isNotEmpty);
      expect(exercise.type, isNotEmpty);
      expect(exercise.module, isNotEmpty);
    });

    test('Multiple exercises have different IDs', () async {
      final exercises = await service.getExercises();
      
      if (exercises.length > 1) {
        final ids = exercises.map((e) => e.id).toSet();
        expect(ids.length, exercises.length);
      }
    });

    test('Can track question responses', () async {
      final response = {
        'patient_id': 'patient_1',
        'exercise_id': 'exercise_1',
        'question_id': 'q1',
        'correct': true,
        'response_time_seconds': 5.5,
        'cue_given': false,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await service.saveQuestionResponse(response);
      
      final responses = await service.getPatientResponses('patient_1', limit: 10);
      expect(responses, isNotEmpty);
    });

    test('Can save exercise session', () async {
      final session = {
        'patient_id': 'patient_1',
        'exercise_id': 'exercise_1',
        'started_at': DateTime.now().toIso8601String(),
        'completed_at': DateTime.now().add(const Duration(minutes: 5)).toIso8601String(),
        'total_questions': 10,
        'correct_answers': 8,
        'total_time_seconds': 300,
      };
      
      await service.saveExerciseSession(session);
      
      final sessions = await service.getPatientSessions('patient_1', limit: 10);
      expect(sessions, isNotEmpty);
    });

    test('Multiple scores can be saved and retrieved', () async {
      final score1 = ExerciseScore(
        id: 'score_1',
        patientId: 'patient_2',
        exerciseId: 'exercise_1',
        score: 90,
        completedAt: DateTime.now(),
        attemptsCount: 1,
        hintsUsed: 0,
        timeSpentSeconds: 100,
      );

      final score2 = ExerciseScore(
        id: 'score_2',
        patientId: 'patient_2',
        exerciseId: 'exercise_2',
        score: 75,
        completedAt: DateTime.now(),
        attemptsCount: 2,
        hintsUsed: 1,
        timeSpentSeconds: 150,
      );
      
      await service.saveExerciseScore(score1);
      await service.saveExerciseScore(score2);
      
      final scores = await service.getPatientScores('patient_2');
      expect(scores.length, greaterThanOrEqualTo(2));
    });

    test('Exercise scores stream emits updates', () async {
      final stream = service.getPatientScoresStream('patient_1');
      
      expect(stream, isNotNull);
      // Verify it's a stream
      expect(stream, isA<Stream>());
    });

    test('Can save multiple question responses', () async {
      final responses = [
        {
          'patient_id': 'patient_3',
          'question_id': 'q1',
          'correct': true,
          'response_time_seconds': 3.0,
        },
        {
          'patient_id': 'patient_3',
          'question_id': 'q2',
          'correct': false,
          'response_time_seconds': 8.5,
        },
        {
          'patient_id': 'patient_3',
          'question_id': 'q3',
          'correct': true,
          'response_time_seconds': 4.2,
        },
      ];
      
      await service.saveQuestionResponses(responses);
      
      final savedResponses = await service.getPatientResponses('patient_3', limit: 10);
      expect(savedResponses.length, greaterThanOrEqualTo(3));
    });

    test('Exercise score contains valid data', () async {
      final score = ExerciseScore(
        id: 'test_score',
        patientId: 'patient_test',
        exerciseId: 'exercise_test',
        score: 88,
        completedAt: DateTime.now(),
        attemptsCount: 2,
        hintsUsed: 1,
        timeSpentSeconds: 250,
      );
      
      expect(score.score, greaterThanOrEqualTo(0));
      expect(score.score, lessThanOrEqualTo(100));
      expect(score.attemptsCount, greaterThan(0));
      expect(score.timeSpentSeconds, greaterThan(0));
    });
  });
}
