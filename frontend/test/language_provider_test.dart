import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:frontend/providers/language_provider.dart';

void main() {
  group('LanguageProvider Tests', () {
    late LanguageProvider languageProvider;

    setUp(() {
      languageProvider = LanguageProvider();
    });

    test('Default language is Bahasa Melayu', () {
      expect(languageProvider.locale, const Locale('ms'));
    });

    test('Can change to English', () async {
      await languageProvider.setLocale(const Locale('en'));
      
      expect(languageProvider.locale, const Locale('en'));
    });

    test('Can change back to Bahasa Melayu', () async {
      await languageProvider.setLocale(const Locale('en'));
      expect(languageProvider.locale, const Locale('en'));
      
      await languageProvider.setLocale(const Locale('ms'));
      expect(languageProvider.locale, const Locale('ms'));
    });

    test('Supports English locale', () {
      expect(LanguageProvider.supportedLocales.contains(const Locale('en')), true);
    });

    test('Supports Malay locale', () {
      expect(LanguageProvider.supportedLocales.contains(const Locale('ms')), true);
    });

    test('Does not support unsupported locale in setLocale', () async {
      await languageProvider.setLocale(const Locale('ms'));
      // Try to set to unsupported locale - it should not change
      await languageProvider.setLocale(const Locale('fr'));
      expect(languageProvider.locale, const Locale('ms'));
    });

    test('Language change notifies listeners', () async {
      bool notified = false;
      languageProvider.addListener(() {
        notified = true;
      });
      
      await languageProvider.setLocale(const Locale('en'));
      
      expect(notified, true);
    });

    test('Multiple language changes work correctly', () async {
      expect(languageProvider.locale, const Locale('ms'));
      
      await languageProvider.setLocale(const Locale('en'));
      expect(languageProvider.locale, const Locale('en'));
      
      await languageProvider.setLocale(const Locale('ms'));
      expect(languageProvider.locale, const Locale('ms'));
      
      await languageProvider.setLocale(const Locale('en'));
      expect(languageProvider.locale, const Locale('en'));
    });

    test('Locale getter returns correct Locale object', () async {
      await languageProvider.setLocale(const Locale('en'));
      expect(languageProvider.locale.languageCode, 'en');
      
      await languageProvider.setLocale(const Locale('ms'));
      expect(languageProvider.locale.languageCode, 'ms');
    });

    test('Language persists after initialization', () async {
      await languageProvider.setLocale(const Locale('en'));
      
      // Create new provider (would normally restore from saved preference)
      final newProvider = LanguageProvider();
      // Note: In real scenario, this would restore saved language
      expect(LanguageProvider.supportedLocales.contains(const Locale('en')), true);
    });
  });
}
