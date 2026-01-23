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
    final exerciseTitles = <String, String>{}; // Track exercise titles
    for (var score in allScores) {
      if (score.metadata?['timeTaken'] != null) {
        final category = score.metadata?['category'] as String? ?? 'unknown';
        final exerciseId = score.exerciseId;
        exerciseTitles[exerciseId] = score.exerciseTitle; // Store title
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
        final title = exerciseTitles[exerciseEntry.key] ?? 'Exercise';
        questionDurationList.add('[$categoryName] $title - ${avg}s');
      }
    }

    // Cue needed per question (group by category)
    final cueNeededByCategory = <String, Map<String, List<int>>>{};
    for (var score in allScores) {
      if (score.metadata?['cueLevel'] != null) {
        final category = score.metadata?['category'] as String? ?? 'unknown';
        final exerciseId = score.exerciseId;
        final cueLevel = score.metadata!['cueLevel'] as int;
        exerciseTitles[exerciseId] = score.exerciseTitle; // Store title
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
        final title = exerciseTitles[exerciseEntry.key] ?? 'Exercise';
        cueNeededList.add('[$categoryName] $title - $cueType');
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
    final exerciseTitles = <String, String>{}; // Track exercise titles
    for (var score in scores) {
      if (score.metadata?['timeTaken'] != null) {
        final category = score.metadata?['category'] as String? ?? 'unknown';
        final exerciseId = score.exerciseId;
        exerciseTitles[exerciseId] = score.exerciseTitle; // Store title
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
        final title = exerciseTitles[exerciseEntry.key] ?? 'Exercise';
        questionDurationList.add('[$categoryName] $title - ${avg}s');
      }
    }

    // Cue needed per question (group by category)
    final cueNeededByCategory = <String, Map<String, List<int>>>{};
    for (var score in scores) {
      if (score.metadata?['cueLevel'] != null) {
        final category = score.metadata?['category'] as String? ?? 'unknown';
        final exerciseId = score.exerciseId;
        final cueLevel = score.metadata!['cueLevel'] as int;
        exerciseTitles[exerciseId] = score.exerciseTitle; // Store title
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
        final title = exerciseTitles[exerciseEntry.key] ?? 'Exercise';
        cueNeededList.add('[$categoryName] $title - $cueType');
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
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(
          base: pw.Font.courier(),
          bold: pw.Font.courierBold(),
        ),
        build: (pw.Context context) {
          return [
            // Header Section
            _buildHeader(isAllPatients, patients, dateStr),
            pw.SizedBox(height: 30),
            
            // Patient Information Section (for single patient report)
            if (!isAllPatients) ...[
              _buildPatientInfoSection(patients.first),
              pw.SizedBox(height: 20),
            ],
            
            // Summary Statistics Section
            _buildSummarySection(reportData, isAllPatients, patients.length),
            pw.SizedBox(height: 20),
            
            // Question Durations Section
            if ((reportData['questionDurations'] as List<String>).isNotEmpty) ...[
              _buildQuestionDurationsSection(reportData['questionDurations'] as List<String>),
              pw.SizedBox(height: 20),
            ],
            
            // Cue Analysis Section
            if ((reportData['cueNeededPerQuestion'] as List<String>).isNotEmpty) ...[
              _buildCueAnalysisSection(reportData['cueNeededPerQuestion'] as List<String>),
              pw.SizedBox(height: 20),
            ],
            
            // Footer
            pw.Spacer(),
            _buildFooter(),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Widget _buildHeader(bool isAllPatients, List<UserModel> patients, String dateStr) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blueGrey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            isAllPatients ? 'All Patients Performance Report' : 'Patient Performance Report',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Generated on: $dateStr',
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
          if (isAllPatients) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Total Patients: ${patients.length}',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blueGrey800,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildPatientInfoSection(UserModel patient) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey400, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Patient Information',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 12),
          _buildInfoRow('Name', patient.name),
          _buildInfoRow('Email', patient.email),
          if (patient.patientPhone != null && patient.patientPhone!.isNotEmpty)
            _buildInfoRow('Phone Number', patient.patientPhone!),
          if (patient.diagnosis != null && patient.diagnosis!.isNotEmpty)
            _buildInfoRow('Diagnosis', patient.diagnosis!),
          if (patient.caregiverName != null && patient.caregiverName!.isNotEmpty)
            _buildInfoRow('Caregiver Name', patient.caregiverName!),
          if (patient.caregiverPhone != null && patient.caregiverPhone!.isNotEmpty)
            _buildInfoRow('Caregiver Phone', patient.caregiverPhone!),
          _buildInfoRow(
            'Member Since',
            '${patient.createdAt.day}/${patient.createdAt.month}/${patient.createdAt.year}',
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(
                fontSize: 12,
                color: PdfColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummarySection(Map<String, dynamic> reportData, bool isAllPatients, int patientCount) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.blue200, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Summary Statistics',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(3),
            },
            children: [
              if (isAllPatients)
                _buildTableRow('Total Patients', '${patientCount}'),
              _buildTableRow('Average Time to Complete', reportData['avgTimeComplete'] ?? 'N/A'),
              _buildTableRow('Total Time on App', reportData['totalTimeOnApp'] ?? 'N/A'),
              _buildTableRow('Average Cue Type', reportData['avgCueType'] ?? 'N/A'),
            ],
          ),
        ],
      ),
    );
  }

  static pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: pw.Text(
            value,
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.black,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildQuestionDurationsSection(List<String> durations) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Question Durations by Category',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 12),
          ...durations.map((item) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 6,
                      height: 6,
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.blue700,
                        shape: pw.BoxShape.circle,
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      child: pw.Text(
                        item,
                        style: const pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  static pw.Widget _buildCueAnalysisSection(List<String> cueData) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Cue Analysis by Question',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 12),
          ...cueData.map((item) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 6,
                      height: 6,
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.green700,
                        shape: pw.BoxShape.circle,
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      child: pw.Text(
                        item,
                        style: const pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 12),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey400, width: 1),
        ),
      ),
      child: pw.Center(
        child: pw.Text(
          'SpeakSteps - Aphasia Therapy App | Confidential Report',
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey600,
            fontStyle: pw.FontStyle.italic,
          ),
        ),
      ),
    );
  }

  static String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'animal':
        return 'Animal';
      case 'bodyParts':
        return 'Body Parts';
      case 'food':
        return 'Food';
      case 'verbs':
        return 'Verbs';
      default:
        return category;
    }
  }
}

