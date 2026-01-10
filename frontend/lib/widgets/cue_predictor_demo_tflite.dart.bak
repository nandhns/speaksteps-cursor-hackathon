/// SpeakSteps Cue Predictor Demo Widget
/// 
/// Demonstrates TFLite model inference for cue prediction.

import 'package:flutter/material.dart';
import '../services/cue_predictor.dart';

/// Demo widget showing cue prediction inference
class CuePredictorDemo extends StatefulWidget {
  const CuePredictorDemo({super.key});

  @override
  State<CuePredictorDemo> createState() => _CuePredictorDemoState();
}

class _CuePredictorDemoState extends State<CuePredictorDemo> {
  // Predictor instance
  final CuePredictor _predictor = CuePredictor();
  
  // UI state
  bool _isLoading = true;
  String _statusMessage = 'Loading model...';
  CuePredictionResult? _result;
  String? _errorMessage;

  // Sample input values (adjustable via sliders)
  double _responseTime = 15.0;
  String _difficulty = 'easy';
  int _attempts = 0;
  String _category = 'animals';

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

  /// Load the TFLite model
  Future<void> _loadModel() async {
    try {
      await _predictor.loadModel();
      setState(() {
        _isLoading = false;
        _statusMessage = 'Model loaded successfully!';
      });
      // Run initial prediction
      _runPrediction();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load model: $e';
        _statusMessage = 'Error loading model';
      });
    }
  }

  /// Run inference with current input values
  void _runPrediction() {
    if (!_predictor.isLoaded) return;

    try {
      // Create input from current slider values
      final input = CuePredictorInput.fromSimple(
        responseTimeSeconds: _responseTime,
        cueGiven: 0,
        cueStage: 0,
        hintCount: 0,
        difficulty: _difficulty,
        isMobile: true,
        therapistLevel: 3,
        questionType: 'pic_to_word',
        cueType: null,
        timeOfDay: _getTimeOfDay(),
        module: 'writing',
        category: _category,
      );

      // Run inference
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

  /// Get current time of day bucket
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
        title: const Text('SpeakSteps Cue Predictor'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? _buildLoadingView()
          : _errorMessage != null && _result == null
              ? _buildErrorView()
              : _buildMainView(),
    );
  }

  /// Loading indicator
  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.teal),
          SizedBox(height: 16),
          Text('Loading TFLite model...'),
        ],
      ),
    );
  }

  /// Error display
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
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

  /// Main content with sliders and results
  Widget _buildMainView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status card
          _buildStatusCard(),
          const SizedBox(height: 16),
          
          // Input controls
          _buildInputCard(),
          const SizedBox(height: 16),
          
          // Results display
          if (_result != null) _buildResultCard(),
          
          // Run button
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _runPrediction,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Run Prediction'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  /// Status indicator card
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
                  Text(
                    _statusMessage,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Input features: ${CuePredictor.inputFeatureCount}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Input controls card
  Widget _buildInputCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Input Features',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Response time slider
            Text('Response Time: ${_responseTime.toStringAsFixed(1)}s'),
            Slider(
              value: _responseTime,
              min: 1,
              max: 60,
              divisions: 59,
              activeColor: Colors.teal,
              onChanged: (value) {
                setState(() => _responseTime = value);
              },
              onChangeEnd: (_) => _runPrediction(),
            ),
            
            // Difficulty dropdown
            Row(
              children: [
                const Text('Difficulty: '),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _difficulty,
                  items: const [
                    DropdownMenuItem(value: 'easy', child: Text('Easy')),
                    DropdownMenuItem(value: 'hard', child: Text('Hard')),
                  ],
                  onChanged: (value) {
                    setState(() => _difficulty = value!);
                    _runPrediction();
                  },
                ),
              ],
            ),
            
            // Category dropdown
            Row(
              children: [
                const Text('Category: '),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _category,
                  items: const [
                    DropdownMenuItem(value: 'animals', child: Text('Animals')),
                    DropdownMenuItem(value: 'body_parts', child: Text('Body Parts')),
                    DropdownMenuItem(value: 'clothing', child: Text('Clothing')),
                    DropdownMenuItem(value: 'food', child: Text('Food')),
                  ],
                  onChanged: (value) {
                    setState(() => _category = value!);
                    _runPrediction();
                  },
                ),
              ],
            ),
            
            // Attempts counter
            Row(
              children: [
                const Text('Attempts: '),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _attempts > 0
                      ? () {
                          setState(() => _attempts--);
                          _runPrediction();
                        }
                      : null,
                ),
                Text('$_attempts', style: const TextStyle(fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.add),
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

  /// Results display card
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
                  needCue ? Icons.lightbulb : Icons.check,
                  color: needCue ? Colors.orange : Colors.green,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  needCue ? 'Cue Recommended' : 'No Cue Needed',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: needCue ? Colors.orange[800] : Colors.green[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Probability bar
            const Text('Prediction Probability:'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: result.probability,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(
                needCue ? Colors.orange : Colors.green,
              ),
              minHeight: 12,
            ),
            const SizedBox(height: 4),
            Text(
              '${(result.probability * 100).toStringAsFixed(2)}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            
            const Divider(height: 24),
            
            // Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailItem('Raw Value', result.probability.toStringAsFixed(6)),
                _buildDetailItem('Threshold', '0.50'),
                _buildDetailItem('Latency', '${result.inferenceTimeMs}ms'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

