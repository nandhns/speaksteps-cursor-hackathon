import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../theme/app_theme.dart';

/// Shows a confirmation dialog when user tries to exit an incomplete exercise
/// Returns true if user wants to exit, false if they want to stay
Future<bool> showExitConfirmationDialog(BuildContext context) async {
  final locale = Localizations.localeOf(context);
  final strings = AppStrings(locale.languageCode);
  
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                strings.exitConfirmTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          strings.exitConfirmMessage,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryPurple,
            ),
            child: Text(strings.exitConfirmStay),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: Text(strings.exitConfirmLeave),
          ),
        ],
      );
    },
  );
  
  return result ?? false; // Default to staying if dialog is dismissed
}
