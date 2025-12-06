import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/user_model.dart';
import '../../models/exercise_score_model.dart';
import '../../models/exercise_model.dart';

class ReportUtils {
  static Map<String, dynamic> calculateAllPatientsReport(
    List<UserModel> patients,
    List<ExerciseScore> allScores,
  ) {
    if (allScores.isEmpty) {
      return {
        'avgTimeComplete': 'N/A',
        'totalTimeOnApp': '0 min',
        'questionDurations': [],
        'cueNeededPerQuestion': [],
        'avgCueType': 'N/A',
      };
    }

    // Calculate average time to complete (per exercise)
    final times = allScores
        .where((s) => s.metadata?['timeTaken'] != null)
        .map((s) => s.metadata!['timeTaken'] as int)
        .toList();
    final avgTime = times.isEmpty
        ? 0
        : (times.reduce((a, b) => a + b) / times.length).round();
    final avgTimeStr = '${avgTime}s';

    // Calculate total time on app
    final totalTime = times.isEmpty ? 0 : times.reduce((a, b) => a + b);
    final totalTimeMin = (totalTime / 60).toStringAsFixed(1);
    final totalTimeStr = '$totalTimeMin min';

    // Question durations (group by category and exercise)
    final questionDurationsByCategory = <String, Map<String, List<int>>>{};
    for (var score in allScores) {
      if (score.metadata?['timeTaken'] != null) {
        final category = score.metadata?['category'] as String? ?? 'unknown';
        final exerciseId = score.exerciseId;
        questionDurationsByCategory.putIfAbsent(category, () => {});
        questionDurationsByCategory[category]!.putIfAbsent(exerciseId, () => []).add(
              score.metadata!['timeTaken'] as int,
            );
      }
    }
    final questionDurationList = <String>[];
    for (var categoryEntry in questionDurationsByCategory.entries) {
      final categoryName = _getCategoryDisplayName(categoryEntry.key);
      for (var exerciseEntry in categoryEntry.value.entries) {
        final avg = (exerciseEntry.value.reduce((a, b) => a + b) / exerciseEntry.value.length).round();
        questionDurationList.add('[$categoryName] Q${exerciseEntry.key.substring(exerciseEntry.key.length - 1)} - ${avg}s');
      }
    }

    // Cue needed per question (group by category)
    final cueNeededByCategory = <String, Map<String, List<int>>>{};
    for (var score in allScores) {
      if (score.metadata?['cueLevel'] != null) {
        final category = score.metadata?['category'] as String? ?? 'unknown';
        final exerciseId = score.exerciseId;
        final cueLevel = score.metadata!['cueLevel'] as int;
        cueNeededByCategory.putIfAbsent(category, () => {});
        cueNeededByCategory[category]!.putIfAbsent(exerciseId, () => []).add(cueLevel);
      }
    }
    final cueNeededList = <String>[];
    for (var categoryEntry in cueNeededByCategory.entries) {
      final categoryName = _getCategoryDisplayName(categoryEntry.key);
      for (var exerciseEntry in categoryEntry.value.entries) {
        final avgCue = (exerciseEntry.value.reduce((a, b) => a + b) / exerciseEntry.value.length).round();
        final cueType = avgCue == 1
            ? 'Function'
            : avgCue == 2
                ? 'Rhyming'
                : avgCue == 3
                    ? 'Written'
                    : 'None';
        cueNeededList.add('[$categoryName] Q${exerciseEntry.key.substring(exerciseEntry.key.length - 1)} - $cueType');
      }
    }

    // Average cue type
    final allCueLevels = allScores
        .where((s) => s.metadata?['cueLevel'] != null)
        .map((s) => s.metadata!['cueLevel'] as int)
        .toList();
    final avgCueLevel = allCueLevels.isEmpty
        ? 0
        : (allCueLevels.reduce((a, b) => a + b) / allCueLevels.length).round();
    final avgCueType = avgCueLevel == 0
        ? 'None'
        : avgCueLevel == 1
            ? 'Function'
            : avgCueLevel == 2
                ? 'Rhyming'
                : 'Written';

    return {
      'avgTimeComplete': avgTimeStr,
      'totalTimeOnApp': totalTimeStr,
      'questionDurations': questionDurationList,
      'cueNeededPerQuestion': cueNeededList,
      'avgCueType': avgCueType,
    };
  }

  static Map<String, dynamic> calculatePatientReport(
    UserModel patient,
    List<ExerciseScore> scores,
  ) {
    if (scores.isEmpty) {
      return {
        'avgTimeComplete': 'N/A',
        'totalTimeOnApp': '0 min',
        'questionDurations': [],
        'cueNeededPerQuestion': [],
        'avgCueType': 'N/A',
      };
    }

    // Calculate average time to complete
    final times = scores
        .where((s) => s.metadata?['timeTaken'] != null)
        .map((s) => s.metadata!['timeTaken'] as int)
        .toList();
    final avgTime = times.isEmpty
        ? 0
        : (times.reduce((a, b) => a + b) / times.length).round();
    final avgTimeStr = '${avgTime}s';

    // Calculate total time on app
    final totalTime = times.isEmpty ? 0 : times.reduce((a, b) => a + b);
    final totalTimeMin = (totalTime / 60).toStringAsFixed(1);
    final totalTimeStr = '$totalTimeMin min';

    // Question durations (group by category)
    final questionDurationsByCategory = <String, Map<String, List<int>>>{};
    for (var score in scores) {
      if (score.metadata?['timeTaken'] != null) {
        final category = score.metadata?['category'] as String? ?? 'unknown';
        final exerciseId = score.exerciseId;
        questionDurationsByCategory.putIfAbsent(category, () => {});
        questionDurationsByCategory[category]!.putIfAbsent(exerciseId, () => []).add(
              score.metadata!['timeTaken'] as int,
            );
      }
    }
    final questionDurationList = <String>[];
    for (var categoryEntry in questionDurationsByCategory.entries) {
      final categoryName = _getCategoryDisplayName(categoryEntry.key);
      for (var exerciseEntry in categoryEntry.value.entries) {
        final avg = (exerciseEntry.value.reduce((a, b) => a + b) / exerciseEntry.value.length).round();
        questionDurationList.add('[$categoryName] Q${exerciseEntry.key.substring(exerciseEntry.key.length - 1)} - ${avg}s');
      }
    }

    // Cue needed per question (group by category)
    final cueNeededByCategory = <String, Map<String, List<int>>>{};
    for (var score in scores) {
      if (score.metadata?['cueLevel'] != null) {
        final category = score.metadata?['category'] as String? ?? 'unknown';
        final exerciseId = score.exerciseId;
        final cueLevel = score.metadata!['cueLevel'] as int;
        cueNeededByCategory.putIfAbsent(category, () => {});
        cueNeededByCategory[category]!.putIfAbsent(exerciseId, () => []).add(cueLevel);
      }
    }
    final cueNeededList = <String>[];
    for (var categoryEntry in cueNeededByCategory.entries) {
      final categoryName = _getCategoryDisplayName(categoryEntry.key);
      for (var exerciseEntry in categoryEntry.value.entries) {
        final avgCue = (exerciseEntry.value.reduce((a, b) => a + b) / exerciseEntry.value.length).round();
        final cueType = avgCue == 1
            ? 'Function'
            : avgCue == 2
                ? 'Rhyming'
                : avgCue == 3
                    ? 'Written'
                    : 'None';
        cueNeededList.add('[$categoryName] Q${exerciseEntry.key.substring(exerciseEntry.key.length - 1)} - $cueType');
      }
    }

    // Average cue type
    final allCueLevels = scores
        .where((s) => s.metadata?['cueLevel'] != null)
        .map((s) => s.metadata!['cueLevel'] as int)
        .toList();
    final avgCueLevel = allCueLevels.isEmpty
        ? 0
        : (allCueLevels.reduce((a, b) => a + b) / allCueLevels.length).round();
    final avgCueType = avgCueLevel == 0
        ? 'None'
        : avgCueLevel == 1
            ? 'Function'
            : avgCueLevel == 2
                ? 'Rhyming'
                : 'Written';

    return {
      'avgTimeComplete': avgTimeStr,
      'totalTimeOnApp': totalTimeStr,
      'questionDurations': questionDurationList,
      'cueNeededPerQuestion': cueNeededList,
      'avgCueType': avgCueType,
    };
  }

  static Future<void> generatePDFReport(
    BuildContext context,
    Map<String, dynamic> reportData,
    List<UserModel> patients, {
    required bool isAllPatients,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                isAllPatients
                    ? 'All Patients Report'
                    : 'Patient Report: ${patients.first.name}',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            if (isAllPatients)
              pw.Text(
                'Total Patients: ${patients.length}',
                style: const pw.TextStyle(fontSize: 16),
              ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Average Time to Complete: ${reportData['avgTimeComplete']}',
              style: const pw.TextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              'Total Time on App: ${reportData['totalTimeOnApp']}',
              style: const pw.TextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Question Durations:',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            ...(reportData['questionDurations'] as List<String>)
                .map((item) => pw.Text('  • $item')),
            pw.SizedBox(height: 10),
            pw.Text(
              'Cue Needed per Question:',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            ...(reportData['cueNeededPerQuestion'] as List<String>)
                .map((item) => pw.Text('  • $item')),
            pw.SizedBox(height: 10),
            pw.Text(
              'Average Cue Type: ${reportData['avgCueType']}',
              style: const pw.TextStyle(fontSize: 14),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'animal':
        return 'Animal';
      case 'bodyParts':
        return 'Body Parts';
      case 'clothing':
        return 'Clothing';
      case 'food':
        return 'Food';
      default:
        return category;
    }
  }
}

