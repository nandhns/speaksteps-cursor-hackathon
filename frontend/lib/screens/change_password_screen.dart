import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    final locale = context.read<LanguageProvider>().locale;
    final strings = AppStrings(locale.languageCode);

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.signInFailed), backgroundColor: AppTheme.error),
        );
      }
      context.go('/login');
      return;
    }

    setState(() => _loading = true);

    try {
      await user.updatePassword(_passwordController.text.trim());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'mustChangePassword': false});

      // Refresh provider state
      final authProvider = context.read<app_auth.AuthProvider>();
      await authProvider.loadUser(user.uid);

      if (!mounted) return;
      final updatedUser = authProvider.currentUser;
      if (updatedUser?.role == UserRole.patient) {
        context.go('/patient');
      } else if (updatedUser?.role == UserRole.therapist) {
        context.go('/therapist');
      } else {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.signInFailed), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.read<LanguageProvider>().locale;
    final strings = AppStrings(locale.languageCode);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingXl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeader(strings),
                const SizedBox(height: AppTheme.spacingXxl),
                Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingXxl),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Set a new password',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: AppTheme.spacingSm),
                          Text(
                            'Please change your temporary password before using SpeakSteps.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppTheme.spacingXl),
                          _buildField(
                            label: strings.passwordLabel,
                            controller: _passwordController,
                            obscure: _obscure,
                            onToggle: () => setState(() => _obscure = !_obscure),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return strings.pleaseEnterPassword;
                              }
                              if (value.length < 6) {
                                return strings.passwordMinLength;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.spacingLg),
                          _buildField(
                            label: 'Confirm password',
                            controller: _confirmController,
                            obscure: _obscure,
                            onToggle: () => setState(() => _obscure = !_obscure),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.spacingXl),
                          FilledButton(
                            onPressed: _loading ? null : _submit,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              disabledBackgroundColor: AppTheme.primaryPurple.withOpacity(0.6),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text('Save and continue'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppStrings strings) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          decoration: BoxDecoration(
            color: AppTheme.primaryPurpleLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: Image.asset(
            'images/SpeakSteps_Logo_Only.png',
            height: 72,
            width: 72,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.record_voice_over,
                size: 56,
                color: AppTheme.primaryPurple,
              );
            },
          ),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        Text(
          'Change Password',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.primaryPurple,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppTheme.spacingXs),
        Text(
          'For security, update your temporary password now.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppTheme.spacingSm),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}
