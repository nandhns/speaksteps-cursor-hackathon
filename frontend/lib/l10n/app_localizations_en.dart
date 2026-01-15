// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SpeakSteps';

  @override
  String get loginTitle => 'Welcome to SpeakSteps';

  @override
  String get loginSubtitle => 'Your speech therapy companion';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get therapistRole => 'Therapist';

  @override
  String get patientRole => 'Patient';

  @override
  String get selectRole => 'I am a...';

  @override
  String get homeTitle => 'Home';

  @override
  String get exercisesTitle => 'Exercises';

  @override
  String get progressTitle => 'Progress';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get writingModule => 'Writing';

  @override
  String get comprehensionModule => 'Comprehension';

  @override
  String get selectModule => 'Select a module to start';

  @override
  String get categoryAnimals => 'Animals';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryBodyParts => 'Body Parts';

  @override
  String get categoryClothing => 'Clothing';

  @override
  String get categoryHousehold => 'Household';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get selectDifficulty => 'Select difficulty';

  @override
  String get startExercise => 'Start Exercise';

  @override
  String get nextQuestion => 'Next Question';

  @override
  String get submitAnswer => 'Submit';

  @override
  String get skipQuestion => 'Skip';

  @override
  String get finishExercise => 'Finish';

  @override
  String get correctAnswer => 'Correct!';

  @override
  String get incorrectAnswer => 'Try Again';

  @override
  String get showHint => 'Show Hint';

  @override
  String get hideHint => 'Hide Hint';

  @override
  String questionLabel(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get typeYourAnswer => 'Type your answer here...';

  @override
  String get selectTheCorrectImage => 'Select the correct image';

  @override
  String get whatIsThis => 'What is this?';

  @override
  String get listenAndSelect => 'Listen and select the matching picture';

  @override
  String get exerciseComplete => 'Exercise Complete!';

  @override
  String yourScore(int score, int total) {
    return 'Your Score: $score/$total';
  }

  @override
  String timeTaken(int minutes, int seconds) {
    return 'Time: ${minutes}m ${seconds}s';
  }

  @override
  String hintsUsed(int count) {
    return 'Hints Used: $count';
  }

  @override
  String get tryAgain => 'Try Again';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get viewProgress => 'View Progress';

  @override
  String get cueFunction => 'Think about what this is used for...';

  @override
  String cueRhyming(String rhyme) {
    return 'It rhymes with: $rhyme';
  }

  @override
  String cueFirstLetter(String letter) {
    return 'It starts with: $letter';
  }

  @override
  String cueSpelling(String spelling) {
    return 'Spelling: $spelling';
  }

  @override
  String get noExercisesAvailable => 'No exercises available';

  @override
  String get loadingExercises => 'Loading exercises...';

  @override
  String get errorLoadingExercises => 'Error loading exercises';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get bahasaMelayu => 'Bahasa Melayu';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get logout => 'Logout';

  @override
  String get profile => 'Profile';

  @override
  String get help => 'Help';

  @override
  String get createAccount => 'Create Account';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get createYourAccount => 'Create your account';

  @override
  String get startTherapyJourney => 'Start your therapy journey today';

  @override
  String get signInToContinue => 'Sign in to continue your progress';

  @override
  String get fullName => 'Full name';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get emailAddress => 'Email address';

  @override
  String get emailPlaceholder => 'you@example.com';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get pleaseEnterName => 'Please enter your name';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signUpFailed => 'Sign up failed';

  @override
  String get signInFailed => 'Sign in failed';

  @override
  String get aphasiaPlatform => 'Aphasia Rehabilitation Platform';

  @override
  String get exitConfirmTitle => 'Exit Exercise?';

  @override
  String get exitConfirmMessage =>
      'You haven\'t finished this exercise yet. Your progress will be saved.';

  @override
  String get exitConfirmStay => 'Continue Exercise';

  @override
  String get exitConfirmLeave => 'Exit';

  @override
  String get completed => 'Completed';

  @override
  String get notStarted => 'Not Started';

  @override
  String get inProgress => 'In Progress';

  @override
  String scoreLabel(int score, int total) {
    return 'Score: $score/$total';
  }

  @override
  String lastAttempt(String date) {
    return 'Last attempt: $date';
  }

  @override
  String get sortBy => 'Sort:';

  @override
  String get sortAZ => 'A-Z';

  @override
  String get sortZA => 'Z-A';

  @override
  String get downloadReport => 'Download Report (PDF)';

  @override
  String get import => 'Import';

  @override
  String get addPatient => 'Add Patient';

  @override
  String get pleaseTypeAnswer => 'Please type your answer';

  @override
  String get pleaseSelectAnswer => 'Please select an answer';

  @override
  String get pleaseSelectImage => 'Please select an image';

  @override
  String get done => 'Done';

  @override
  String get availableExercises => 'Available Exercises';
}
