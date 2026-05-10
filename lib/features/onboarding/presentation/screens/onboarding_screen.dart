import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Dobrodošli u\nKixFit',
      subtitle: 'Tvoj personalizirani AI nutricionista koji te prati u stopu.',
      icon: Icons.auto_awesome,
    ),
    OnboardingData(
      title: 'Samo reci\nšta si pojeo',
      subtitle: 'Bez kucanja, bez traženja. Samo glasovno unesi obrok i prepusti AI-u ostalo.',
      icon: Icons.mic,
    ),
    OnboardingData(
      title: 'Ostvari svoje\nciljeve',
      subtitle: 'Prati makronutrijente i kalorije na najmoderniji način do sada.',
      icon: Icons.insights,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Glow
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.15),
              ),
            ),
          ).animate().fadeIn(duration: 1200.ms),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _pages[index].icon,
                              size: 100,
                              color: AppColors.primary,
                            ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack),
                            const SizedBox(height: AppSpacing.xxl),
                            Text(
                              _pages[index].title,
                              textAlign: TextAlign.center,
                              style: AppTypography.displayMd,
                            ).animate().fadeIn(delay: 400.ms).moveY(begin: 20, end: 0),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _pages[index].subtitle,
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyLg,
                            ).animate().fadeIn(delay: 600.ms).moveY(begin: 20, end: 0),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // Bottom UI
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      // Page Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: AppDurations.normal,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index ? AppColors.primary : AppColors.textDisabled,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      
                      AppButton(
                        text: _currentPage == _pages.length - 1 ? 'Kreni sada' : 'Dalje',
                        onPressed: () {
                          if (_currentPage < _pages.length - 1) {
                            _pageController.nextPage(
                              duration: AppDurations.normal,
                              curve: Curves.easeInOut,
                            );
                          } else {
                            context.go('/dashboard');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final IconData icon;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
