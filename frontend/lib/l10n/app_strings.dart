/// Localized strings for SpeakSteps
/// Supports English (en) and Bahasa Melayu (ms)

class AppStrings {
  final String languageCode;
  
  AppStrings(this.languageCode);
  
  // Factory constructor based on locale
  factory AppStrings.of(String languageCode) {
    return AppStrings(languageCode);
  }
  
  bool get isMalay => languageCode == 'ms';
  
  // ==================== GENERAL ====================
  String get appName => isMalay ? 'SpeakSteps' : 'SpeakSteps';
  String get loading => isMalay ? 'Memuatkan...' : 'Loading...';
  String get error => isMalay ? 'Ralat' : 'Error';
  String get success => isMalay ? 'Berjaya' : 'Success';
  String get cancel => isMalay ? 'Batal' : 'Cancel';
  String get confirm => isMalay ? 'Sahkan' : 'Confirm';
  String get submit => isMalay ? 'Hantar' : 'Submit';
  String get next => isMalay ? 'Seterusnya' : 'Next';
  String get back => isMalay ? 'Kembali' : 'Back';
  String get done => isMalay ? 'Selesai' : 'Done';
  String get close => isMalay ? 'Tutup' : 'Close';
  String get yes => isMalay ? 'Ya' : 'Yes';
  String get no => isMalay ? 'Tidak' : 'No';
  String get ok => isMalay ? 'OK' : 'OK';
  String get save => isMalay ? 'Simpan' : 'Save';
  String get logout => isMalay ? 'Log Keluar' : 'Logout';
  
  // ==================== LOGIN & AUTHENTICATION ====================
  String get signIn => isMalay ? 'Daftar Masuk' : 'Sign In';
  String get signUp => isMalay ? 'Daftar Akaun' : 'Sign Up';
  String get createAccount => isMalay ? 'Buat Akaun' : 'Create Account';
  String get signInFailed => isMalay ? 'Gagal daftar masuk. Sila semak e-mel dan kata laluan anda.' : 'Sign in failed. Please check your email and password.';
  String get signUpFailed => isMalay ? 'Gagal buat akaun. Sila cuba lagi.' : 'Sign up failed. Please try again.';
  String get createYourAccount => isMalay ? 'Buat Akaun Anda' : 'Create Your Account';
  String get welcomeBack => isMalay ? 'Selamat Kembali' : 'Welcome Back';
  String get startTherapyJourney => isMalay ? 'Mulakan perjalanan terapi anda hari ini' : 'Start your therapy journey today';
  String get signInToContinue => isMalay ? 'Daftar masuk untuk meneruskan' : 'Sign in to continue';
  String get fullName => isMalay ? 'Nama Penuh' : 'Full Name';
  String get enterFullName => isMalay ? 'Masukkan nama penuh anda...' : 'Enter your full name...';
  String get pleaseEnterName => isMalay ? 'Sila masukkan nama anda' : 'Please enter your name';
  String get emailAddress => isMalay ? 'Alamat E-mel' : 'Email Address';
  String get emailPlaceholder => isMalay ? 'nama@contoh.com' : 'name@example.com';
  String get pleaseEnterEmail => isMalay ? 'Sila masukkan e-mel anda' : 'Please enter your email';
  String get pleaseEnterValidEmail => isMalay ? 'Sila masukkan e-mel yang sah' : 'Please enter a valid email';
  String get passwordLabel => isMalay ? 'Kata Laluan' : 'Password';
  String get enterPassword => isMalay ? 'Masukkan kata laluan...' : 'Enter password...';
  String get pleaseEnterPassword => isMalay ? 'Sila masukkan kata laluan' : 'Please enter password';
  String get passwordMinLength => isMalay ? 'Kata laluan mesti sekurang-kurangnya 6 aksara' : 'Password must be at least 6 characters';
  String get confirmPassword => isMalay ? 'Sahkan Kata Laluan' : 'Confirm Password';
  String get passwordsDontMatch => isMalay ? 'Kata laluan tidak sepadan' : 'Passwords do not match';
  String get alreadyHaveAccount => isMalay ? 'Sudah ada akaun?' : 'Already have an account?';
  String get dontHaveAccount => isMalay ? 'Belum ada akaun?' : 'Don\'t have an account?';
  String get selectRole => isMalay ? 'Pilih Peranan' : 'Select Role';
  String get patientRole => isMalay ? 'Pesakit' : 'Patient';
  String get therapistRole => isMalay ? 'Ahli Terapi' : 'Therapist';
  String get aphasiaPlatform => isMalay ? 'Platform Rehabilitasi Afasia' : 'Aphasia Rehabilitation Platform';
  
  // ==================== EXIT CONFIRMATION ====================
  String get exitConfirmTitle => isMalay ? 'Anda tidak mahu teruskan?' : 'Exit Exercise?';
  String get exitConfirmMessage => isMalay ? 'Jawapan anda akan disimpan sebagai tidak lengkap.' : 'Your answers will be saved as incomplete.';
  String get exitConfirmStay => isMalay ? 'Teruskan Latihan' : 'Continue Exercise';
  String get exitConfirmLeave => isMalay ? 'Keluar' : 'Exit';
  
  // ==================== EXERCISE STATUS ====================
  String get notStarted => isMalay ? 'Belum Dimulai' : 'Not Started';
  String get scoreLabel => isMalay ? 'Markah' : 'Score';
  String get lastAttempt => isMalay ? 'Percubaan Terakhir' : 'Last Attempt';
  
  // ==================== PATIENT HOME ====================
  String get welcome => isMalay ? 'Selamat Datang' : 'Welcome';
  String get selectExercise => isMalay ? 'Pilih Latihan' : 'Select Exercise';
  String get selectCategory => isMalay ? 'Pilih Kategori' : 'Select Category';
  String get startExercise => isMalay ? 'Mula Latihan' : 'Start Exercise';
  String get noExercises => isMalay ? 'Tiada latihan tersedia' : 'No exercises available';
  String get continueExercise => isMalay ? 'Teruskan' : 'Continue';
  
  // ==================== EXERCISE TYPES ====================
  String get writing => isMalay ? 'Menulis' : 'Writing';
  String get comprehension => isMalay ? 'Pemahaman' : 'Comprehension';
  String get writingDescription => isMalay 
      ? 'Latihan menaip dan mengeja perkataan' 
      : 'Typing and spelling exercises';
  String get comprehensionDescription => isMalay 
      ? 'Latihan memadankan gambar dengan perkataan' 
      : 'Picture and word matching exercises';
  
  // ==================== CATEGORIES ====================
  String get animals => isMalay ? 'Haiwan' : 'Animals';
  String get food => isMalay ? 'Makanan' : 'Food';
  String get bodyParts => isMalay ? 'Anggota Badan' : 'Body Parts';
  String get clothing => isMalay ? 'Pakaian' : 'Clothing';
  String get verbs => isMalay ? 'Kata Kerja' : 'Verbs';
  String get household => isMalay ? 'Barangan Rumah' : 'Household';
  String get nature => isMalay ? 'Alam Semulajadi' : 'Nature';
  String get transportation => isMalay ? 'Pengangkutan' : 'Transportation';
  String get colors => isMalay ? 'Warna' : 'Colors';
  String get numbers => isMalay ? 'Nombor' : 'Numbers';
  String get family => isMalay ? 'Keluarga' : 'Family';
  
  /// Get category name by enum name
  String getCategoryName(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'animals': return animals;
      case 'food': return food;
      case 'bodyparts': 
      case 'body_parts': return bodyParts;
      case 'clothing': return clothing;
      case 'household': return household;
      case 'nature': return nature;
      case 'transportation': return transportation;
      case 'colors': return colors;
      case 'numbers': return numbers;
      case 'family': return family;
      default: return categoryName;
    }
  }
  
  // ==================== EXERCISE SCREEN ====================
  String get typeYourAnswer => isMalay ? 'Taipkan jawapan anda' : 'Type your answer';
  String get enterAnswer => isMalay ? 'Masukkan jawapan...' : 'Enter your answer...';
  String get checkAnswer => isMalay ? 'Semak Jawapan' : 'Check Answer';
  String get correct => isMalay ? 'Betul!' : 'Correct!';
  String get incorrect => isMalay ? 'Tidak betul' : 'Incorrect';
  String get tryAgain => isMalay ? 'Cuba lagi' : 'Try Again';
  String get showHint => isMalay ? 'Tunjuk Petunjuk' : 'Show Hint';
  String get needHelp => isMalay ? 'Perlukan Bantuan?' : 'Need Help?';
  String get getHint => isMalay ? 'Dapatkan Petunjuk' : 'Get Hint';
  String get hint => isMalay ? 'Petunjuk' : 'Hint';
  String get skip => isMalay ? 'Langkau' : 'Skip';
  
  // ==================== CUES ====================
  String get cue => isMalay ? 'Petunjuk' : 'Cue';
  String get noCue => isMalay ? 'Tiada petunjuk' : 'No cue';
  String get functionalCue => isMalay ? 'Petunjuk fungsi' : 'Functional cue';
  String get rhymingCue => isMalay ? 'Petunjuk rima' : 'Rhyming cue';
  String get writtenInitialCue => isMalay ? 'Petunjuk huruf awal' : 'Written initial cue';
  String get spellingCue => isMalay ? 'Petunjuk ejaan' : 'Spelling cue';
  String get sentenceCompletionCue => isMalay ? 'Lengkapkan ayat' : 'Sentence completion';
  String get phonemicCue => isMalay ? 'Petunjuk bunyi' : 'Phonemic cue';
  String get writtenCue => isMalay ? 'Petunjuk bertulis' : 'Written cue';
  String get modelingCue => isMalay ? 'Contoh' : 'Modeling';
  
  // ==================== RESULTS ====================
  String get exerciseComplete => isMalay ? 'Latihan Selesai!' : 'Exercise Complete!';
  String get yourScore => isMalay ? 'Markah Anda' : 'Your Score';
  String get timeTaken => isMalay ? 'Masa Diambil' : 'Time Taken';
  String get seconds => isMalay ? 'saat' : 'seconds';
  String get minutes => isMalay ? 'minit' : 'minutes';
  String get questionsCorrect => isMalay ? 'Soalan Betul' : 'Questions Correct';
  String get greatJob => isMalay ? 'Bagus!' : 'Great job!';
  String get keepPracticing => isMalay ? 'Teruskan berlatih!' : 'Keep practicing!';
  String get excellentWork => isMalay ? 'Kerja cemerlang!' : 'Excellent work!';
  String get goodEffort => isMalay ? 'Usaha yang baik!' : 'Good effort!';
  String get practiceMore => isMalay ? 'Cuba lagi untuk lebih baik!' : 'Try again to improve!';
  
  // ==================== QUESTIONS ====================
  String get question => isMalay ? 'Soalan' : 'Question';
  String get of => isMalay ? 'daripada' : 'of';
  String get whatIsThis => isMalay ? 'Apakah ini?' : 'What is this?';
  String get selectTheCorrectImage => isMalay 
      ? 'Pilih gambar yang betul' 
      : 'Select the correct image';
  String get matchTheWord => isMalay 
      ? 'Padankan perkataan dengan gambar' 
      : 'Match the word with the picture';
  String get listenAndSelect => isMalay 
      ? 'Dengar dan pilih jawapan yang betul' 
      : 'Listen and select the correct answer';
  
  // ==================== PROGRESS ====================
  String get progress => isMalay ? 'Kemajuan' : 'Progress';
  String get score => isMalay ? 'Markah' : 'Score';
  String get totalExercises => isMalay ? 'Jumlah Latihan' : 'Total Exercises';
  String get completed => isMalay ? 'Selesai' : 'Completed';
  String get inProgress => isMalay ? 'Sedang Dijalankan' : 'In Progress';
  
  // ==================== DIFFICULTY ====================
  String get easy => isMalay ? 'Mudah' : 'Easy';
  String get medium => isMalay ? 'Sederhana' : 'Medium';
  String get hard => isMalay ? 'Sukar' : 'Hard';
  
  // ==================== AUDIO INSTRUCTIONS ====================
  String get tapToListen => isMalay ? 'Tekan untuk dengar' : 'Tap to listen';
  String get playAudio => isMalay ? 'Main audio' : 'Play audio';
  String get listenAgain => isMalay ? 'Dengar lagi' : 'Listen again';
  
  // ==================== ERRORS ====================
  String get somethingWentWrong => isMalay 
      ? 'Sesuatu tidak kena. Sila cuba lagi.' 
      : 'Something went wrong. Please try again.';
  String get noConnection => isMalay 
      ? 'Tiada sambungan internet' 
      : 'No internet connection';
  String get pleaseSelectAnswer => isMalay 
      ? 'Sila pilih jawapan' 
      : 'Please select an answer';
  
  // ==================== ENCOURAGEMENT ====================
  String get youCanDoIt => isMalay ? 'Anda boleh!' : 'You can do it!';
  String get takeYourTime => isMalay ? 'Ambil masa anda' : 'Take your time';
  String get almostThere => isMalay ? 'Hampir sampai!' : 'Almost there!';
  String get wellDone => isMalay ? 'Syabas!' : 'Well done!';
  String get fantastic => isMalay ? 'Hebat!' : 'Fantastic!';
  String get keepGoing => isMalay ? 'Teruskan!' : 'Keep going!';
  
  // ==================== COMPLETION DIALOG ====================
  String get excellent => isMalay ? 'Cemerlang! 🎉' : 'Excellent! 🎉';
  String get goodJob => isMalay ? 'Bagus! 💪' : 'Good Job! 💪';
  String get youGotCorrect => isMalay ? 'Anda betul' : 'You got';
  String get outOf => isMalay ? 'daripada' : 'out of';
  String get questionsCorrectSuffix => isMalay ? 'soalan!' : 'questions correct!';
  String get youGotItRight => isMalay ? 'Anda betul!' : 'You got it right!';
  String get theCorrectAnswerWas => isMalay ? 'Jawapan yang betul ialah' : 'The correct answer was';
  String get keepPracticingExclaim => isMalay ? 'Teruskan berlatih! 💪' : 'Keep Practicing! 💪';
  String get greatJobExclaim => isMalay ? 'Kerja Hebat! 🎉' : 'Great Job! 🎉';
  String get exerciseCompletedScore => isMalay ? 'Latihan selesai! Markah' : 'Exercise completed! Score';
  String get pleaseSelectImage => isMalay ? 'Sila pilih gambar' : 'Please select an image';
  
  // ==================== CHANGE PASSWORD ====================
  String get changePassword => isMalay ? 'Tukar Kata Laluan' : 'Change Password';
  String get setNewPassword => isMalay ? 'Tetapkan kata laluan baharu' : 'Set a new password';
  String get changePasswordMessage => isMalay ? 'Sila tukar kata laluan sementara anda sebelum menggunakan SpeakSteps.' : 'Please change your temporary password before using SpeakSteps.';
  String get confirmPasswordLabel => isMalay ? 'Sahkan Kata Laluan' : 'Confirm password';
  String get pleaseConfirmPassword => isMalay ? 'Sila sahkan kata laluan anda' : 'Please confirm your password';
  String get passwordsDoNotMatch => isMalay ? 'Kata laluan tidak sepadan' : 'Passwords do not match';
  String get saveAndContinue => isMalay ? 'Simpan dan Teruskan' : 'Save and continue';
  String get forSecurityUpdateTemporary => isMalay ? 'Untuk keselamatan, kemaskini kata laluan sementara anda sekarang.' : 'For security, update your temporary password now.';
}

/// Extension to easily get strings from BuildContext
extension AppStringsExtension on String {
  AppStrings get strings => AppStrings(this);
}

