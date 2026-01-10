import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/app_service.dart';

/// Provider to manage the app's locale/language setting
class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  
  Locale _locale = const Locale('en'); // Default to English
  AppService? _appService;
  String? _userId;
  
  Locale get locale => _locale;
  
  /// Set the app service and user ID for syncing with database
  void setAppService(AppService service, String? userId) {
    _appService = service;
    _userId = userId;
  }
  
  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('ms'), // Bahasa Melayu
  ];
  
  /// Initialize locale from stored preferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }
  
  /// Change the app's locale
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    
    _locale = locale;
    
    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
    
    // Sync with database if user is logged in
    if (_appService != null && _userId != null) {
      try {
        await _appService!.updateUserLanguage(_userId!, locale.languageCode);
      } catch (e) {
        print('Error syncing language preference to database: $e');
      }
    }
    
    notifyListeners();
  }
  
  /// Get language display name
  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'ms':
        return 'Bahasa Melayu';
      case 'en':
      default:
        return 'English';
    }
  }
  
  /// Toggle between English and Bahasa Melayu
  Future<void> toggleLanguage() async {
    final newLocale = _locale.languageCode == 'en' 
        ? const Locale('ms') 
        : const Locale('en');
    await setLocale(newLocale);
  }
}

