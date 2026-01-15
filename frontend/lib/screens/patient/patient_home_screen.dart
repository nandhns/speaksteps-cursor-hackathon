import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/language_provider.dart';
import '../../services/app_service.dart';
import '../../models/exercise_model.dart';
import '../../models/exercise_score_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ui/app_card.dart';
import '../../widgets/language_selector.dart';
import '../../l10n/app_strings.dart';
import 'writing_exercise_screen.dart';
import 'comprehension_exercise_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  late final AppService _service;
  List<Exercise> _exercises = [];
  Map<String, ExerciseScore?> _exerciseScores = {}; // Store latest scores by exercise ID
  bool _isLoading = true;
  ExerciseType? _selectedExerciseType;
  ExerciseCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _service = ServiceFactory.createService();
    _loadExercises();
    
    // Initialize language provider with app service after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<app_auth.AuthProvider>();
      final languageProvider = context.read<LanguageProvider>();
      languageProvider.setAppService(_service, authProvider.currentUser?.id);
      
      // Load user's preferred language from database
      _loadUserLanguage(authProvider.currentUser?.id);
    });
  }
  
  Future<void> _loadUserLanguage(String? userId) async {
    if (userId == null) return;
    
    try {
      final user = await _service.getUser(userId);
      if (user?.preferredLanguage != null && mounted) {
        final languageProvider = context.read<LanguageProvider>();
        await languageProvider.setLocale(Locale(user!.preferredLanguage!));
      }
    } catch (e) {
      print('Error loading user language preference: $e');
    }
  }

  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);
    final authProvider = context.read<app_auth.AuthProvider>();
    final patientId = authProvider.currentUser?.id;
    final user = authProvider.currentUser;
    print('DEBUG: currentUser assignedModules = ${user?.assignedModules}');
    
    print('DEBUG: Loading exercises for patientId: $patientId');
    
    // Get all exercises first
    final allExercises = await _service.getExercises();
    
    // Filter by assigned modules if available
    List<Exercise> filteredExercises = allExercises;
    if (user?.assignedModules != null && user!.assignedModules!.isNotEmpty) {
      print('DEBUG: Patient has assigned modules: ${user.assignedModules}');
      final assignedModuleNames = user.assignedModules!
          .map((m) => m.toString().split('.').last)
          .toSet();
      
      filteredExercises = allExercises.where((exercise) {
        final typeEnum = exercise.exerciseType.name; // Use enum name (writing/comprehension)
        return assignedModuleNames.contains(typeEnum);
      }).toList();
      print('DEBUG: Filtered to ${filteredExercises.length} exercises from assigned modules');
    } else {
      print('DEBUG: No assigned modules found, showing all exercises');
    }
    
    // Load latest scores for each exercise
    if (patientId != null) {
      final allScores = await _service.getPatientScores(patientId);
      print('DEBUG: Loaded ${allScores.length} scores for patient');
      
      final scoreMap = <String, ExerciseScore>{};
      for (final score in allScores) {
        print('DEBUG: Score for exercise ${score.exerciseId}: ${score.score}/${score.maxScore}');
        // Keep only the most recent score per exercise
        if (!scoreMap.containsKey(score.exerciseId) ||
            score.completedAt.isAfter(scoreMap[score.exerciseId]!.completedAt)) {
          scoreMap[score.exerciseId] = score;
        }
      }
      setState(() {
        _exercises = filteredExercises;
        _exerciseScores = scoreMap;
        _isLoading = false;
      });
    } else {
      setState(() {
        _exercises = filteredExercises;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleExerciseComplete(ExerciseScore score) async {
    print('DEBUG: Saving exercise score: ${score.score}/${score.maxScore} for exercise ${score.exerciseId}');
    await _service.saveExerciseScore(score);
    print('DEBUG: Score saved successfully');
    
    // Reload exercises to update scores
    await _loadExercises();
    if (mounted) {
      final strings = AppStrings(Localizations.localeOf(context).languageCode);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${strings.exerciseCompletedScore}: ${score.score}/${score.maxScore}'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  void _goBack() {
    setState(() {
      if (_selectedCategory != null) {
        _selectedCategory = null;
      } else if (_selectedExerciseType != null) {
        _selectedExerciseType = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<app_auth.AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // App Bar
          _buildAppBar(context, user, authProvider),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _exercises.isEmpty
                    ? _buildEmptyState()
                    : _buildContent(user),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, user, app_auth.AuthProvider authProvider) {
    final showBackButton = _selectedExerciseType != null;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showBackButton) ...[  
                SizedBox(
                  width: 36,
                  height: 36,
                  child: IconButton(
                    onPressed: _goBack,
                    icon: const Icon(Icons.arrow_back, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.surfaceVariant,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
              ],
              
              // Logo
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurpleLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(
                  Icons.record_voice_over,
                  color: AppTheme.primaryPurple,
                  size: 16,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              
              // Title section
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: (MediaQuery.of(context).size.width - 380).clamp(0.0, double.infinity),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SpeakSteps',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _getSubtitle(context),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: AppTheme.spacingSm),
              
              // Language selector - compact on mobile
              SizedBox(
                height: 36,
                child: const LanguageSelector(showLabel: false),
              ),
              
              const SizedBox(width: 4),
              
              // Refresh button
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  icon: const Icon(Icons.refresh_outlined, size: 18),
                  onPressed: _loadExercises,
                  tooltip: 'Refresh exercises',
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.surfaceVariant,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
              
              const SizedBox(width: 4),
              
              // User menu
              _buildUserMenu(context, user, authProvider),
            ],
          ),
        ),
      ),
    );
  }

  String _getSubtitle(BuildContext context) {
    final lang = context.watch<LanguageProvider>().locale.languageCode;
    final strings = AppStrings(lang);
    
    if (_selectedCategory != null) {
      final categoryName = strings.getCategoryName(_selectedCategory!.name);
      final typeName = _selectedExerciseType == ExerciseType.writing 
          ? strings.writing 
          : strings.comprehension;
      return '$categoryName • $typeName';
    }
    if (_selectedExerciseType != null) {
      return strings.selectCategory;
    }
    return strings.selectExercise;
  }

  Widget _buildUserMenu(BuildContext context, user, app_auth.AuthProvider authProvider) {
    final lang = context.watch<LanguageProvider>().locale.languageCode;
    final strings = AppStrings(lang);
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppTheme.primaryPurpleLight,
              child: Text(
                user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'P',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              user?.name ?? 'Patient',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(width: AppTheme.spacingXs),
            Icon(Icons.expand_more, size: 18, color: AppTheme.textSecondary),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'language',
          child: Row(
            children: [
              Icon(Icons.language, size: 18, color: AppTheme.textSecondary),
              const SizedBox(width: AppTheme.spacingMd),
              Consumer<LanguageProvider>(
                builder: (context, langProvider, child) {
                  final isEnglish = langProvider.locale.languageCode == 'en';
                  return Text(
                    isEnglish ? 'Bahasa: English' : 'Bahasa: BM',
                  );
                },
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 18, color: AppTheme.error),
              const SizedBox(width: AppTheme.spacingMd),
              Text(strings.logout, style: TextStyle(color: AppTheme.error)),
            ],
          ),
        ),
      ],
      onSelected: (value) async {
        if (value == 'language') {
          showDialog(
            context: context,
            builder: (context) => const LanguageSelectionDialog(),
          );
        } else if (value == 'logout') {
          await authProvider.signOut();
          if (mounted) context.go('/login');
        }
      },
    );
  }

  Widget _buildEmptyState() {
    final lang = context.watch<LanguageProvider>().locale.languageCode;
    final strings = AppStrings(lang);
    
    return EmptyState(
      icon: Icons.assignment_outlined,
      title: strings.noExercises,
      subtitle: strings.isMalay 
          ? 'Sila semak semula atau hubungi ahli terapi anda'
          : 'Please check back later or contact your therapist',
    );
  }

  Widget _buildContent(user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome card (only on first screen)
          if (_selectedExerciseType == null) _buildWelcomeCard(user),
          
          const SizedBox(height: AppTheme.spacingXl),
          
          // Main content based on selection state
          if (_selectedExerciseType == null)
            _buildExerciseTypeSelection()
          else if (_selectedCategory == null)
            _buildCategorySelection()
          else
            _buildExerciseList(user),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(user) {
    final lang = context.watch<LanguageProvider>().locale.languageCode;
    final strings = AppStrings(lang);
    
    final welcomeText = strings.isMalay 
        ? 'Selamat kembali, ${user?.name ?? "Pesakit"}!'
        : 'Welcome back, ${user?.name ?? "Patient"}!';
    final readyText = strings.isMalay 
        ? 'Sedia untuk berlatih hari ini?'
        : 'Ready to practice today?';
    
    return AppCard(
      backgroundColor: AppTheme.primaryPurpleLight,
      hasBorder: false,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Center(
              child: Text(
                user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'P',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  welcomeText,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryPurpleDark,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  readyText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryPurple,
                      ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.emoji_events_outlined,
            size: 32,
            color: AppTheme.primaryPurple.withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseTypeSelection() {
    final lang = context.watch<LanguageProvider>().locale.languageCode;
    final strings = AppStrings(lang);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.selectExercise,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacingLg),
        _ExerciseTypeCard(
          icon: Icons.edit_outlined,
          emoji: '✍️',
          title: strings.writing,
          description: strings.writingDescription,
          color: AppTheme.primaryPurple,
          onTap: () => setState(() => _selectedExerciseType = ExerciseType.writing),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        _ExerciseTypeCard(
          icon: Icons.headphones_outlined,
          emoji: '👂',
          title: strings.comprehension,
          description: strings.comprehensionDescription,
          color: const Color(0xFF0891B2),
          onTap: () => setState(() => _selectedExerciseType = ExerciseType.comprehension),
        ),
      ],
    );
  }

  Widget _buildCategorySelection() {
    final lang = context.watch<LanguageProvider>().locale.languageCode;
    final strings = AppStrings(lang);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.selectCategory,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacingLg),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppTheme.spacingMd,
          crossAxisSpacing: AppTheme.spacingMd,
          childAspectRatio: 1.2,
          children: [
            _CategoryCard(
              emoji: '🐾',
              title: strings.animals,
              color: const Color(0xFFF97316),
              onTap: () => setState(() => _selectedCategory = ExerciseCategory.animal),
            ),
            _CategoryCard(
              emoji: '👤',
              title: strings.bodyParts,
              color: const Color(0xFFEC4899),
              onTap: () => setState(() => _selectedCategory = ExerciseCategory.bodyParts),
            ),
            _CategoryCard(
              emoji: '🍎',
              title: strings.food,
              color: const Color(0xFF22C55E),
              onTap: () => setState(() => _selectedCategory = ExerciseCategory.food),
            ),
            _CategoryCard(
              emoji: '🎬',
              title: strings.verbs,
              color: const Color(0xFFA855F7),
              onTap: () => setState(() => _selectedCategory = ExerciseCategory.verbs),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExerciseList(user) {
    final filteredExercises = _exercises
        .where((e) => e.category == _selectedCategory && e.exerciseType == _selectedExerciseType)
        .toList();

    // Remove duplicates by title
    final seenTitles = <String>{};
    final uniqueExercises = <Exercise>[];
    for (var exercise in filteredExercises) {
      if (!seenTitles.contains(exercise.title)) {
        seenTitles.add(exercise.title);
        uniqueExercises.add(exercise);
      }
    }

    if (uniqueExercises.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'No exercises available',
        subtitle: 'No exercises found for this category and type',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Exercises',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacingLg),
        ...uniqueExercises.map((exercise) => Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
          child: _ExerciseCard(
            exercise: exercise,
            score: _exerciseScores[exercise.id],
            onTap: () => _navigateToExercise(exercise, user),
          ),
        )),
      ],
    );
  }

  void _navigateToExercise(Exercise exercise, user) {
    Widget exerciseScreen;
    if (exercise.exerciseType == ExerciseType.writing) {
      exerciseScreen = WritingExerciseScreen(
        exercise: exercise,
        patientId: user?.id ?? '',
        therapistId: user?.therapistId,
        onComplete: _handleExerciseComplete,
      );
    } else {
      exerciseScreen = ComprehensionExerciseScreen(
        exercise: exercise,
        patientId: user?.id ?? '',
        therapistId: user?.therapistId,
        onComplete: _handleExerciseComplete,
      );
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => exerciseScreen),
    );
  }
}

class _ExerciseTypeCard extends StatelessWidget {
  final IconData icon;
  final String emoji;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ExerciseTypeCard({
    required this.icon,
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(width: AppTheme.spacingLg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: color,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String emoji;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.emoji,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final ExerciseScore? score; // Latest score for this exercise
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    this.score,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {    final lang = context.watch<LanguageProvider>().locale.languageCode;
    final strings = AppStrings(lang);    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPurpleLight,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                          child: const Icon(
                            Icons.fitness_center,
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingLg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                exercise.description,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    if (score != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: score!.score >= score!.maxScore * 0.7
                                ? AppTheme.success
                                : AppTheme.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Score: ${score!.score}/${score!.maxScore}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (score != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.done,
                                  size: 14,
                                  color: AppTheme.success,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  strings.isMalay ? 'Selesai' : 'Completed',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.success,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.textTertiary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: Text(
                              strings.notStarted,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        Icon(
                          Icons.chevron_right,
                          color: AppTheme.textTertiary,
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurpleLight,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingLg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            exercise.description,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (score != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: score!.score >= score!.maxScore * 0.7
                                      ? AppTheme.success
                                      : AppTheme.warning,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Score: ${score!.score}/${score!.maxScore}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    if (score != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.done,
                              size: 14,
                              color: AppTheme.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              strings.isMalay ? 'Selesai' : 'Completed',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.success,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.textTertiary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: Text(
                          strings.notStarted,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Icon(
                      Icons.chevron_right,
                      color: AppTheme.textTertiary,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
