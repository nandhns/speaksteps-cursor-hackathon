// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get appTitle => 'SpeakSteps';

  @override
  String get loginTitle => 'Selamat Datang ke SpeakSteps';

  @override
  String get loginSubtitle => 'Teman terapi pertuturan anda';

  @override
  String get emailLabel => 'E-mel';

  @override
  String get passwordLabel => 'Kata Laluan';

  @override
  String get signIn => 'Log Masuk';

  @override
  String get signUp => 'Daftar';

  @override
  String get forgotPassword => 'Lupa Kata Laluan?';

  @override
  String get therapistRole => 'Ahli Terapi';

  @override
  String get patientRole => 'Pesakit';

  @override
  String get selectRole => 'Saya adalah...';

  @override
  String get homeTitle => 'Utama';

  @override
  String get exercisesTitle => 'Latihan';

  @override
  String get progressTitle => 'Kemajuan';

  @override
  String get settingsTitle => 'Tetapan';

  @override
  String get writingModule => 'Menulis';

  @override
  String get comprehensionModule => 'Kefahaman';

  @override
  String get selectModule => 'Pilih modul untuk bermula';

  @override
  String get categoryAnimals => 'Haiwan';

  @override
  String get categoryFood => 'Makanan';

  @override
  String get categoryBodyParts => 'Anggota Badan';

  @override
  String get categoryClothing => 'Pakaian';

  @override
  String get categoryHousehold => 'Barangan Rumah';

  @override
  String get categoryTransport => 'Pengangkutan';

  @override
  String get difficultyEasy => 'Mudah';

  @override
  String get difficultyMedium => 'Sederhana';

  @override
  String get difficultyHard => 'Sukar';

  @override
  String get selectDifficulty => 'Pilih tahap kesukaran';

  @override
  String get startExercise => 'Mula Latihan';

  @override
  String get nextQuestion => 'Soalan Seterusnya';

  @override
  String get submitAnswer => 'Hantar';

  @override
  String get skipQuestion => 'Langkau';

  @override
  String get finishExercise => 'Selesai';

  @override
  String get correctAnswer => 'Betul!';

  @override
  String get incorrectAnswer => 'Cuba Lagi';

  @override
  String get showHint => 'Tunjuk Petunjuk';

  @override
  String get hideHint => 'Sembunyi Petunjuk';

  @override
  String questionLabel(int current, int total) {
    return 'Soalan $current daripada $total';
  }

  @override
  String get typeYourAnswer => 'Taip jawapan anda di sini...';

  @override
  String get selectTheCorrectImage => 'Pilih gambar yang betul';

  @override
  String get whatIsThis => 'Apakah ini?';

  @override
  String get listenAndSelect => 'Dengar dan pilih gambar yang sepadan';

  @override
  String get exerciseComplete => 'Latihan Selesai!';

  @override
  String yourScore(int score, int total) {
    return 'Skor Anda: $score/$total';
  }

  @override
  String timeTaken(int minutes, int seconds) {
    return 'Masa: ${minutes}m ${seconds}s';
  }

  @override
  String hintsUsed(int count) {
    return 'Petunjuk Digunakan: $count';
  }

  @override
  String get tryAgain => 'Cuba Lagi';

  @override
  String get backToHome => 'Kembali ke Utama';

  @override
  String get viewProgress => 'Lihat Kemajuan';

  @override
  String get cueFunction => 'Fikirkan kegunaan benda ini...';

  @override
  String cueRhyming(String rhyme) {
    return 'Ia berbunyi seperti: $rhyme';
  }

  @override
  String cueFirstLetter(String letter) {
    return 'Ia bermula dengan: $letter';
  }

  @override
  String cueSpelling(String spelling) {
    return 'Ejaan: $spelling';
  }

  @override
  String get noExercisesAvailable => 'Tiada latihan tersedia';

  @override
  String get loadingExercises => 'Memuatkan latihan...';

  @override
  String get errorLoadingExercises => 'Ralat memuatkan latihan';

  @override
  String get language => 'Bahasa';

  @override
  String get english => 'English';

  @override
  String get bahasaMelayu => 'Bahasa Melayu';

  @override
  String get changeLanguage => 'Tukar Bahasa';

  @override
  String get logout => 'Log Keluar';

  @override
  String get profile => 'Profil';

  @override
  String get help => 'Bantuan';

  @override
  String get createAccount => 'Buat Akaun';

  @override
  String get welcomeBack => 'Selamat kembali';

  @override
  String get createYourAccount => 'Buat akaun anda';

  @override
  String get startTherapyJourney => 'Mulakan perjalanan terapi anda hari ini';

  @override
  String get signInToContinue => 'Log masuk untuk meneruskan kemajuan anda';

  @override
  String get fullName => 'Nama penuh';

  @override
  String get enterFullName => 'Masukkan nama penuh anda';

  @override
  String get emailAddress => 'Alamat e-mel';

  @override
  String get emailPlaceholder => 'anda@contoh.com';

  @override
  String get enterPassword => 'Masukkan kata laluan anda';

  @override
  String get pleaseEnterName => 'Sila masukkan nama anda';

  @override
  String get pleaseEnterEmail => 'Sila masukkan e-mel anda';

  @override
  String get pleaseEnterValidEmail => 'Sila masukkan e-mel yang sah';

  @override
  String get pleaseEnterPassword => 'Sila masukkan kata laluan anda';

  @override
  String get passwordMinLength =>
      'Kata laluan mesti sekurang-kurangnya 6 aksara';

  @override
  String get alreadyHaveAccount => 'Sudah mempunyai akaun?';

  @override
  String get dontHaveAccount => 'Belum mempunyai akaun?';

  @override
  String get signUpFailed => 'Pendaftaran gagal';

  @override
  String get signInFailed => 'Log masuk gagal';

  @override
  String get aphasiaPlatform => 'Platform Rehabilitasi Afasia';

  @override
  String get exitConfirmTitle => 'Keluar dari Latihan?';

  @override
  String get exitConfirmMessage =>
      'Anda belum selesaikan latihan ini. Kemajuan anda akan disimpan.';

  @override
  String get exitConfirmStay => 'Teruskan Latihan';

  @override
  String get exitConfirmLeave => 'Keluar';

  @override
  String get completed => 'Selesai';

  @override
  String get notStarted => 'Belum Dimulakan';

  @override
  String get inProgress => 'Sedang Berjalan';

  @override
  String scoreLabel(int score, int total) {
    return 'Skor: $score/$total';
  }

  @override
  String lastAttempt(String date) {
    return 'Percubaan terakhir: $date';
  }

  @override
  String get sortBy => 'Isih:';

  @override
  String get sortAZ => 'A-Z';

  @override
  String get sortZA => 'Z-A';

  @override
  String get downloadReport => 'Muat Turun Laporan (PDF)';

  @override
  String get import => 'Import';

  @override
  String get addPatient => 'Tambah Pesakit';

  @override
  String get pleaseTypeAnswer => 'Sila taip jawapan anda';

  @override
  String get pleaseSelectAnswer => 'Sila pilih jawapan';

  @override
  String get pleaseSelectImage => 'Sila pilih gambar';

  @override
  String get done => 'Selesai';

  @override
  String get availableExercises => 'Latihan Tersedia';
}
