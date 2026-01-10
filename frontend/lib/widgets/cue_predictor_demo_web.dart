/// SpeakSteps Cue Predictor Demo Widget (Web-Compatible)
/// 
/// Works on all platforms including web.

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/cue_predictor_factory.dart';

/// Demo widget showing cue prediction - works on web!
class CuePredictorDemoWeb extends StatefulWidget {
  const CuePredictorDemoWeb({super.key});

  @override
  State<CuePredictorDemoWeb> createState() => _CuePredictorDemoWebState();
}

class _CuePredictorDemoWebState extends State<CuePredictorDemoWeb> {
  final CuePredictor _predictor = CuePredictor();
  
  bool _isLoading = true;
  String _statusMessage = 'Loading...';
  CuePredictionResult? _result;
  String? _errorMessage;

  // Input values
  double _responseTime = 15.0;
  String _difficulty = 'easy';
  int _attempts = 0;
  String _category = 'animals';
  String _module = 'writing';
  int _therapistLevel = 3;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  @override
  void dispose() {
    _predictor.dispose();
    super.dispose();
  }

  Future<void> _loadModel() async {
    try {
      await _predictor.loadModel();
      setState(() {
        _isLoading = false;
        _statusMessage = 'Ready (${_predictor.platformName})';
      });
      _runPrediction();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load: $e';
        _statusMessage = 'Error';
      });
    }
  }

  void _runPrediction() {
    if (!_predictor.isLoaded) return;

    try {
      final input = CuePredictorInput.fromSimple(
        responseTimeSeconds: _responseTime,
        cueGiven: _attempts > 0 ? 1 : 0,
        cueStage: _attempts,
        hintCount: _attempts,
        difficulty: _difficulty,
        isMobile: !kIsWeb,
        therapistLevel: _therapistLevel,
        questionType: 'pic_to_word',
        cueType: _attempts > 0 ? 'functional' : null,
        timeOfDay: _getTimeOfDay(),
        module: _module,
        category: _category,
      );

      final result = _predictor.predict(input);

      setState(() {
        _result = result;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Prediction error: $e';
        _result = null;
      });
    }
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpeakSteps Therapist Dashboard'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          if (kIsWeb)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.teal.shade700,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.web, size: 16),
                  SizedBox(width: 4),
                  Text('Web', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingView()
          : _errorMessage != null && _result == null
              ? _buildErrorView()
              : _buildMainView(),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.teal),
          SizedBox(height: 16),
          Text('Loading predictor...'),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _loadModel();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStatusCard(),
              const SizedBox(height: 16),
              _buildInputCard(),
              const SizedBox(height: 16),
              if (_result != null) _buildResultCard(),
              const SizedBox(height: 24),
              _buildPredictButton(),
              const SizedBox(height: 16),
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              _predictor.isLoaded ? Icons.check_circle : Icons.error,
              color: _predictor.isLoaded ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_statusMessage,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    kIsWeb 
                        ? 'Running in browser (rule-based prediction)'
                        : 'Running on device',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            if (kIsWeb)
              Chip(
                label: const Text('Web Mode'),
                backgroundColor: Colors.blue.shade100,
                labelStyle: TextStyle(color: Colors.blue.shade800, fontSize: 11),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Patient Session Parameters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Response time slider
            Text('Response Time: ${_responseTime.toStringAsFixed(1)}s'),
            Slider(
              value: _responseTime,
              min: 1,
              max: 60,
              divisions: 59,
              activeColor: Colors.teal,
              onChanged: (value) => setState(() => _responseTime = value),
              onChangeEnd: (_) => _runPrediction(),
            ),
            
            const SizedBox(height: 8),
            
            // Row of dropdowns
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // Module dropdown
                _buildDropdown(
                  label: 'Module',
                  value: _module,
                  items: const ['writing', 'comprehension'],
                  onChanged: (v) {
                    setState(() => _module = v!);
                    _runPrediction();
                  },
                ),
                
                // Difficulty dropdown
                _buildDropdown(
                  label: 'Difficulty',
                  value: _difficulty,
                  items: const ['easy', 'hard'],
                  onChanged: (v) {
                    setState(() => _difficulty = v!);
                    _runPrediction();
                  },
                ),
                
                // Category dropdown
                _buildDropdown(
                  label: 'Category',
                  value: _category,
                  items: const ['animals', 'body_parts', 'clothing', 'food'],
                  onChanged: (v) {
                    setState(() => _category = v!);
                    _runPrediction();
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Therapist level slider
            Text('Therapist Assigned Level: $_therapistLevel'),
            Slider(
              value: _therapistLevel.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              activeColor: Colors.teal,
              onChanged: (value) => setState(() => _therapistLevel = value.toInt()),
              onChangeEnd: (_) => _runPrediction(),
            ),
            
            // Attempts counter
            Row(
              children: [
                const Text('Previous Attempts: '),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _attempts > 0
                      ? () {
                          setState(() => _attempts--);
                          _runPrediction();
                        }
                      : null,
                ),
                Text('$_attempts', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    setState(() => _attempts++);
                    _runPrediction();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        DropdownButton<String>(
          value: value,
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item.replaceAll('_', ' ').toUpperCase()),
          )).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    final result = _result!;
    final needCue = result.needCue;
    
    return Card(
      color: needCue ? Colors.orange[50] : Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  needCue ? Icons.lightbulb : Icons.check_circle,
                  color: needCue ? Colors.orange : Colors.green,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        needCue ? 'Cue Recommended' : 'No Cue Needed',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: needCue ? Colors.orange[800] : Colors.green[800],
                        ),
                      ),
                      if (needCue)
                        Text(
                          'Suggest: ${_getSuggestedCueType()}',
                          style: TextStyle(color: Colors.orange[700]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            const Text('Cue Probability:'),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: result.probability,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation(
                  needCue ? Colors.orange : Colors.green,
                ),
                minHeight: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(result.probability * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            
            const Divider(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem('Threshold', '50%'),
                _buildDetailItem('Inference', '${result.inferenceTimeMs}ms'),
                _buildDetailItem('Platform', kIsWeb ? 'Web' : 'Native'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getSuggestedCueType() {
    if (_result == null) return 'functional';
    final prob = _result!.probability;
    if (prob > 0.8) return 'phonemic or modeling';
    if (prob > 0.6) return 'written_initial';
    if (prob > 0.5) return 'functional';
    return 'functional';
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPredictButton() {
    return ElevatedButton.icon(
      onPressed: _runPrediction,
      icon: const Icon(Icons.psychology),
      label: const Text('Run Prediction'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'About This Demo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              kIsWeb
                  ? 'This web version uses rule-based prediction that mirrors '
                    'the TFLite ML model behavior. For production use with '
                    'actual ML inference, run on Android/iOS/Desktop.'
                  : 'This demo shows cue prediction for Broca\'s aphasia '
                    'therapy exercises. Adjust parameters to see how the '
                    'model recommends cues.',
              style: TextStyle(color: Colors.blue[800], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

