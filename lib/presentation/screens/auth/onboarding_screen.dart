// presentation/screens/auth/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:foodkie/core/constants/assets_constants.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';
import 'package:foodkie/presentation/screens/auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      title: 'Streamlined Restaurant Management',
      description: 'Manage your restaurant seamlessly with our easy-to-use interface',
      image: AssetsConstants.onboarding1Path,
    ),
    OnboardingItem(
      title: 'Multi-role Support',
      description: 'Specific interfaces for managers, waiters, and kitchen staff',
      image: AssetsConstants.onboarding2Path,
    ),
    OnboardingItem(
      title: 'Real-time Order Processing',
      description: 'Track orders in real-time from placing to serving',
      image: AssetsConstants.onboarding3Path,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _navigateToLogin,
                child: Text(
                  StringConstants.skip,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingItems.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return _buildPage(_onboardingItems[index]);
                },
              ),
            ),

            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingItems.length,
                    (index) => _buildDot(index),
              ),
            ),

            const SizedBox(height: 24),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  if (_currentPage > 0)
                    CustomButton(
                      text: StringConstants.back,
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      isOutlined: true,
                      width: 120,
                    )
                  else
                    const SizedBox(width: 120),

                  // Next/Get Started button
                  CustomButton(
                    text: _currentPage == _onboardingItems.length - 1
                        ? StringConstants.getStarted
                        : StringConstants.next,
                    onPressed: _currentPage == _onboardingItems.length - 1
                        ? _navigateToLogin
                        : () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    width: 120,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Image.asset(
            item.image,
            height: 300,
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            item.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index
            ? AppTheme.primaryColor
            : Colors.grey.shade300,
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String image;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.image,
  });
}