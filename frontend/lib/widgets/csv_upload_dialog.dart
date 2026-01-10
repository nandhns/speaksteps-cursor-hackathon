import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/app_service.dart';

/// Dialog for uploading CSV file to bulk import patients
/// 
/// Expected CSV format:
/// email,name,diagnosis,patient_phone,caregiver_name,caregiver_phone,modules
/// 
/// modules column accepts: "writing", "comprehension", or "writing,comprehension"
class CsvUploadDialog extends StatefulWidget {
  final Function(int count) onPatientsImported;

  const CsvUploadDialog({
    super.key,
    required this.onPatientsImported,
  });

  @override
  State<CsvUploadDialog> createState() => _CsvUploadDialogState();
}

class _CsvUploadDialogState extends State<CsvUploadDialog> {
  final AppService _service = ServiceFactory.createService();
  
  String? _fileName;
  List<Map<String, String>>? _parsedData;
  List<String> _errors = [];
  bool _isLoading = false;
  bool _isImporting = false;
  bool _sendOnboardingEmails = true;
  int _importedCount = 0;
  int _totalToImport = 0;

  // Expected CSV headers
  static const List<String> _requiredHeaders = [
    'email',
    'name',
    'diagnosis',
    'patient_phone',
    'caregiver_name',
    'caregiver_phone',
  ];

  static const String _modulesHeader = 'modules';

  void _downloadTemplate() {
    const templateContent = '''email,name,diagnosis,patient_phone,caregiver_name,caregiver_phone,modules
patient1@example.com,John Smith,Broca's Aphasia,+1234567890,Jane Smith,+1234567891,writing
patient2@example.com,Mary Johnson,Wernicke's Aphasia,+1234567892,Robert Johnson,+1234567893,comprehension
patient3@example.com,David Brown,Anomic Aphasia,+1234567894,Lisa Brown,+1234567895,"writing,comprehension"
''';
    
    // Show a dialog with the template content that user can copy
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.file_download),
            SizedBox(width: 8),
            Text('CSV Template'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Copy this template and paste it into a spreadsheet or text editor:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SelectableText(
                  templateContent,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '📝 Tips:\n'
                '• Save as .csv file from your spreadsheet\n'
                '• Keep the header row exactly as shown\n'
                '• Phone numbers must have at least 10 digits\n'
                '• For multiple modules, use quotes: "writing,comprehension"',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    setState(() {
      _isLoading = true;
      _errors = [];
      _parsedData = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final content = utf8.decode(bytes);
        _parseCSV(content);
        setState(() {
          _fileName = result.files.single.name;
        });
      }
    } catch (e) {
      setState(() {
        _errors = ['Error reading file: $e'];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _parseCSV(String content) {
    final lines = content.split('\n').where((l) => l.trim().isNotEmpty).toList();
    
    if (lines.isEmpty) {
      setState(() => _errors = ['CSV file is empty']);
      return;
    }

    // Parse headers
    final headers = _parseCSVLine(lines[0]).map((h) => h.toLowerCase().trim()).toList();
    
    // Validate required headers
    final missingHeaders = _requiredHeaders.where((h) => !headers.contains(h)).toList();
    if (missingHeaders.isNotEmpty) {
      setState(() => _errors = ['Missing required columns: ${missingHeaders.join(', ')}']);
      return;
    }

    // Parse data rows
    final data = <Map<String, String>>[];
    final errors = <String>[];

    for (var i = 1; i < lines.length; i++) {
      final values = _parseCSVLine(lines[i]);
      
      if (values.length < headers.length) {
        errors.add('Row ${i + 1}: Not enough values');
        continue;
      }

      final row = <String, String>{};
      for (var j = 0; j < headers.length; j++) {
        row[headers[j]] = values[j].trim();
      }

      // Validate email
      if (!row['email']!.contains('@')) {
        errors.add('Row ${i + 1}: Invalid email "${row['email']}"');
        continue;
      }

      // Validate phone numbers (basic check)
      final patientPhone = row['patient_phone'] ?? '';
      final caregiverPhone = row['caregiver_phone'] ?? '';
      if (patientPhone.replaceAll(RegExp(r'[^\d]'), '').length < 10) {
        errors.add('Row ${i + 1}: Invalid patient phone "${patientPhone}"');
        continue;
      }
      if (caregiverPhone.replaceAll(RegExp(r'[^\d]'), '').length < 10) {
        errors.add('Row ${i + 1}: Invalid caregiver phone "${caregiverPhone}"');
        continue;
      }

      data.add(row);
    }

    setState(() {
      _parsedData = data;
      _errors = errors;
    });
  }

  List<String> _parseCSVLine(String line) {
    final values = <String>[];
    var current = '';
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        values.add(current);
        current = '';
      } else {
        current += char;
      }
    }
    values.add(current); // Add last value
    
    return values.map((v) => v.trim().replaceAll('"', '')).toList();
  }

  List<TherapyModule> _parseModules(String? modulesStr) {
    if (modulesStr == null || modulesStr.isEmpty) {
      return [TherapyModule.writing]; // Default to writing
    }

    final modules = <TherapyModule>[];
    final parts = modulesStr.toLowerCase().split(',');
    
    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed == 'writing') {
        modules.add(TherapyModule.writing);
      } else if (trimmed == 'comprehension') {
        modules.add(TherapyModule.comprehension);
      }
    }

    return modules.isEmpty ? [TherapyModule.writing] : modules;
  }

  Future<void> _importPatients() async {
    if (_parsedData == null || _parsedData!.isEmpty) return;

    setState(() {
      _isImporting = true;
      _importedCount = 0;
      _totalToImport = _parsedData!.length;
    });

    final importErrors = <String>[];

    for (var i = 0; i < _parsedData!.length; i++) {
      final row = _parsedData![i];
      
      try {
        await _service.createPatient(
          email: row['email']!,
          name: row['name']!,
          diagnosis: row['diagnosis']!,
          patientPhone: row['patient_phone']!,
          caregiverName: row['caregiver_name']!,
          caregiverPhone: row['caregiver_phone']!,
          assignedModules: _parseModules(row[_modulesHeader]),
          sendOnboardingEmail: _sendOnboardingEmails,
        );
        
        setState(() => _importedCount++);
      } catch (e) {
        importErrors.add('${row['name']} (${row['email']}): $e');
      }
    }

    if (mounted) {
      if (importErrors.isEmpty) {
        widget.onPatientsImported(_importedCount);
        Navigator.of(context).pop();
      } else {
        setState(() {
          _errors = importErrors;
          _isImporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.indigo.shade700,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.upload_file, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Import Patients from CSV',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _isImporting ? null : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // CSV Format Instructions
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Expected CSV Format',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _downloadTemplate,
                                icon: const Icon(Icons.download, size: 16),
                                label: const Text('Download Template'),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Required columns (first row as headers):',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const SelectableText(
                              'email,name,diagnosis,patient_phone,caregiver_name,caregiver_phone,modules\n'
                              'patient@email.com,John Doe,Broca\'s Aphasia,+1234567890,Jane Doe,+1234567891,writing\n'
                              'patient2@email.com,Mary Smith,Anomic Aphasia,+1234567892,Bob Smith,+1234567893,"writing,comprehension"',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Note: modules column is optional. Accepts: writing, comprehension, or both.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // File Picker
                    ElevatedButton.icon(
                      onPressed: _isLoading || _isImporting ? null : _pickFile,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.folder_open),
                      label: Text(_fileName ?? 'Select CSV File'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    // Preview Data
                    if (_parsedData != null && _parsedData!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  '${_parsedData!.length} patients ready to import',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Show preview of first few patients
                            ...(_parsedData!.take(3).map((row) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.person, size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${row['name']} (${row['email']})',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      row[_modulesHeader] ?? 'writing',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ))),
                            if (_parsedData!.length > 3)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '... and ${_parsedData!.length - 3} more',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Send emails option
                      CheckboxListTile(
                        title: const Row(
                          children: [
                            Icon(Icons.email, size: 20),
                            SizedBox(width: 8),
                            Text('Send onboarding emails to all patients'),
                          ],
                        ),
                        subtitle: const Text(
                          'Each patient will receive login instructions and app download link',
                        ),
                        value: _sendOnboardingEmails,
                        onChanged: _isImporting
                            ? null
                            : (value) {
                                setState(() => _sendOnboardingEmails = value ?? true);
                              },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ],
                    // Errors
                    if (_errors.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning, color: Colors.red.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  'Errors (${_errors.length})',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ..._errors.take(5).map((e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                '• $e',
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            )),
                            if (_errors.length > 5)
                              Text(
                                '... and ${_errors.length - 5} more errors',
                                style: TextStyle(
                                  color: Colors.red.shade600,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    // Import Progress
                    if (_isImporting) ...[
                      const SizedBox(height: 24),
                      Column(
                        children: [
                          LinearProgressIndicator(
                            value: _totalToImport > 0 ? _importedCount / _totalToImport : 0,
                          ),
                          const SizedBox(height: 8),
                          Text('Importing $_importedCount of $_totalToImport patients...'),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _isImporting ? null : () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: (_parsedData != null && _parsedData!.isNotEmpty && !_isImporting)
                              ? _importPatients
                              : null,
                          icon: _isImporting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.upload),
                          label: Text(_isImporting ? 'Importing...' : 'Import Patients'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

