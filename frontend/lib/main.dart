import 'package:flutter/material.dart';
import 'widgets/cue_predictor_demo.dart';

void main() {
  runApp(const SpeakStepsApp());
}

/// SpeakSteps - Broca's Aphasia Therapy App
class SpeakStepsApp extends StatelessWidget {
  const SpeakStepsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpeakSteps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // Show the Cue Predictor Demo as the home screen
      home: const CuePredictorDemo(),
    );
  }
}

