import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/language_provider.dart';
import 'router/app_router.dart';
import 'services/app_service.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize language provider
  final languageProvider = LanguageProvider();
  await languageProvider.init();
  
  // Check if we're using Firebase or Mock
  final useFirebase = ServiceFactory.useFirebase;
  
  if (useFirebase) {
    // Initialize Firebase with the generated configuration
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized successfully!');
    } catch (e) {
      print('Firebase initialization error: $e');
      print('Please check your Firebase configuration.');
    }
  } else {
    print('Using Mock Service - No Firebase required!');
    print('To use Firebase, set useFirebase = true in lib/services/app_service.dart');
  }

  runApp(SpeakStepsApp(languageProvider: languageProvider));
}

/// SpeakSteps - Broca's Aphasia Therapy App
class SpeakStepsApp extends StatelessWidget {
  final LanguageProvider languageProvider;
  
  const SpeakStepsApp({super.key, required this.languageProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider.value(value: languageProvider),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, langProvider, child) {
          return MaterialApp.router(
            title: 'SpeakSteps',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.router,
            // Localization support
            locale: langProvider.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          );
        },
      ),
    );
  }
}

