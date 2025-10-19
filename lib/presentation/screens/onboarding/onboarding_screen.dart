import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/first_launch_checker.dart';
import '../auth/login_screen.dart';
import '../../widgets/onboarding_page.dart';

/// Onboarding screen with 4 pages
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }
  
  void _skipOnboarding() {
    _completeOnboarding();
  }
  
  void _completeOnboarding() async {
    await FirstLaunchChecker.markOnboardingCompleted();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
  
  void _goToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button (top right)
            if (_currentPage < 3)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'Skip',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  // Page 1: Welcome
                  OnboardingPage(
                    title: 'Welcome to HabitFlow',
                    subtitle: 'Build better habits with the power of gamification',
                    description: 'Transform your daily routines into an engaging journey of growth and achievement.',
                    icon: Icons.rocket_launch,
                    color: AppColors.primary,
                  ),
                  
                  // Page 2: Track Habits
                  OnboardingPage(
                    title: 'Track Your Habits',
                    subtitle: 'Simple, beautiful habit tracking',
                    description: 'Log your daily habits with just a tap. See your progress with beautiful calendars and charts.',
                    icon: Icons.check_circle_outline,
                    color: AppColors.secondary,
                  ),
                  
                  // Page 3: Gamification
                  OnboardingPage(
                    title: 'Level Up Your Life',
                    subtitle: 'Earn XP, unlock achievements, grow your garden',
                    description: 'Turn habit building into a game. Earn experience points, unlock achievements, and watch your virtual garden grow.',
                    icon: Icons.emoji_events,
                    color: AppColors.success,
                  ),
                  
                  // Page 4: Optional Backup
                  OnboardingPage(
                    title: 'Keep Your Progress Safe',
                    subtitle: 'Optional cloud backup for your data',
                    description: 'Backup your habits, progress, and achievements to the cloud. Access your data from any device.',
                    icon: Icons.cloud_upload,
                    color: AppColors.warning,
                    showBackupOptions: true,
                    onSignIn: _goToLogin,
                    onSkip: _completeOnboarding,
                  ),
                ],
              ),
            ),
            
            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index 
                          ? AppColors.primary 
                          : AppColors.primary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  
                  if (_currentPage > 0) const SizedBox(width: 16),
                  
                  Expanded(
                    flex: _currentPage == 0 ? 1 : 1,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentPage == 3 ? 'Get Started' : 'Next',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
