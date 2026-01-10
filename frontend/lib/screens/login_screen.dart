import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../providers/language_provider.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../l10n/app_strings.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<app_auth.AuthProvider>();
    final locale = context.read<LanguageProvider>().locale;
    final strings = AppStrings(locale.languageCode);
    bool success = false;
    success = await authProvider.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      final user = authProvider.currentUser;
      if (authProvider.mustChangePassword) {
        context.go('/change-password');
        return;
      }
      if (user?.role == UserRole.patient) {
        context.go('/patient');
      } else if (user?.role == UserRole.therapist) {
        context.go('/therapist');
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.signInFailed),
          backgroundColor: AppTheme.error,
        ),
      );
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
                // Logo and branding
                _buildHeader(strings),
                const SizedBox(height: AppTheme.spacingXxl),
                
                // Login form card
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
                            strings.welcomeBack,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: AppTheme.spacingSm),
                          Text(
                            strings.signInToContinue,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppTheme.spacingXl),

                          // Email field
                          _buildTextField(
                            controller: _emailController,
                            label: strings.emailAddress,
                            hint: strings.emailPlaceholder,
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return strings.pleaseEnterEmail;
                              }
                              if (!value.contains('@')) {
                                return strings.pleaseEnterValidEmail;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.spacingLg),

                          // Password field
                          _buildTextField(
                            controller: _passwordController,
                            label: strings.passwordLabel,
                            hint: strings.enterPassword,
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppTheme.textTertiary,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return strings.pleaseEnterPassword;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppTheme.spacingXl),

                          // Submit button
                          Consumer<app_auth.AuthProvider>(
                            builder: (context, authProvider, child) {
                              return FilledButton(
                                onPressed: authProvider.isLoading ? null : _handleSubmit,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  disabledBackgroundColor: AppTheme.primaryPurple.withOpacity(0.6),
                                ),
                                child: authProvider.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(strings.signIn),
                              );
                            },
                          ),
                          const SizedBox(height: AppTheme.spacingLg),
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
        // Logo with subtle purple background
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          decoration: BoxDecoration(
            color: AppTheme.primaryPurpleLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: Image.asset(
            'images/SpeakSteps_Logo_Only.png',
            height: 80,
            width: 80,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.record_voice_over,
                size: 64,
                color: AppTheme.primaryPurple,
              );
            },
          ),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        Text(
          'SpeakSteps',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppTheme.primaryPurple,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppTheme.spacingXs),
        Text(
          strings.aphasiaPlatform,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppTheme.spacingSm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(prefixIcon, size: 20),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
