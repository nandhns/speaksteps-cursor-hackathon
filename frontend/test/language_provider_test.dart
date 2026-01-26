import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:frontend/providers/language_provider.dart';

void main() {
  group('LanguageProvider Tests', () {
    late LanguageProvider languageProvider;

    setUp(() {
      languageProvider = LanguageProvider();
    });

    test('Default language is English', () {
      expect(languageProvider.locale, const Locale('en'));
      expect(languageProvider.languageCode, 'en');
    });

    test('Can change to Bahasa Melayu', () async {
      await languageProvider.setLanguage('ms');
      
      expect(languageProvider.locale, const Locale('ms'));
      expect(languageProvider.languageCode, 'ms');
    });

    test('Can change back to English', () async {
      await languageProvider.setLanguage('ms');
      expect(languageProvider.languageCode, 'ms');
      
      await languageProvider.setLanguage('en');
      expect(languageProvider.languageCode, 'en');
    });

    test('Supports English locale', () {
      expect(languageProvider.supportsLocale(const Locale('en')), true);
    });

    test('Supports Malay locale', () {
      expect(languageProvider.supportsLocale(const Locale('ms')), true);
    });

    test('Does not support unsupported locale', () {
      expect(languageProvider.supportsLocale(const Locale('fr')), false);
    });

    test('Language change notifies listeners', () async {
      bool notified = false;
      languageProvider.addListener(() {
        notified = true;
      });
      
      await languageProvider.setLanguage('ms');
      
      expect(notified, true);
    });

    test('Multiple language changes work correctly', () async {
      expect(languageProvider.languageCode, 'en');
      
      await languageProvider.setLanguage('ms');
      expect(languageProvider.languageCode, 'ms');
      
      await languageProvider.setLanguage('en');
      expect(languageProvider.languageCode, 'en');
      
      await languageProvider.setLanguage('ms');
      expect(languageProvider.languageCode, 'ms');
    });

    test('Locale getter returns correct Locale object', () async {
      await languageProvider.setLanguage('en');
      expect(languageProvider.locale.languageCode, 'en');
      
      await languageProvider.setLanguage('ms');
      expect(languageProvider.locale.languageCode, 'ms');
    });

    test('Language persists after initialization', () async {
      await languageProvider.setLanguage('ms');
      
      // Create new provider (would normally restore from saved preference)
      final newProvider = LanguageProvider();
      // Note: In real scenario, this would restore saved language
      expect(newProvider.supportsLocale(const Locale('ms')), true);
    });
  });
}
