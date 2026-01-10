import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

/// A simple language toggle widget for patients
class LanguageSelector extends StatelessWidget {
  final bool showLabel;
  
  const LanguageSelector({
    super.key,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final isEnglish = languageProvider.locale.languageCode == 'en';
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showLabel)
              Text(
                isEnglish ? 'Language: ' : 'Bahasa: ',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LanguageButton(
                    label: 'EN',
                    isSelected: isEnglish,
                    onTap: () => languageProvider.setLocale(const Locale('en')),
                    isLeft: true,
                  ),
                  _LanguageButton(
                    label: 'BM',
                    isSelected: !isEnglish,
                    onTap: () => languageProvider.setLocale(const Locale('ms')),
                    isLeft: false,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLeft;
  
  const _LanguageButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary 
              : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: isLeft ? const Radius.circular(24) : Radius.zero,
            right: !isLeft ? const Radius.circular(24) : Radius.zero,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? Theme.of(context).colorScheme.onPrimary 
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Full-screen language selection dialog
class LanguageSelectionDialog extends StatelessWidget {
  const LanguageSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return AlertDialog(
          title: Text(
            languageProvider.locale.languageCode == 'en' 
                ? 'Select Language' 
                : 'Pilih Bahasa',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LanguageTile(
                flag: '🇬🇧',
                name: 'English',
                isSelected: languageProvider.locale.languageCode == 'en',
                onTap: () {
                  languageProvider.setLocale(const Locale('en'));
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 8),
              _LanguageTile(
                flag: '🇲🇾',
                name: 'Bahasa Melayu',
                isSelected: languageProvider.locale.languageCode == 'ms',
                onTap: () {
                  languageProvider.setLocale(const Locale('ms'));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                languageProvider.locale.languageCode == 'en' 
                    ? 'Cancel' 
                    : 'Batal',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String flag;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _LanguageTile({
    required this.flag,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 32)),
      title: Text(name),
      trailing: isSelected 
          ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).colorScheme.outline,
          width: isSelected ? 2 : 1,
        ),
      ),
      tileColor: isSelected 
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
          : null,
    );
  }
}

