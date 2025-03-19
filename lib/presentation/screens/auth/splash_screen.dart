// presentation/screens/auth/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/constants/assets_constants.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/presentation/providers/auth_provider.dart';
import 'package:foodkie/presentation/screens/auth/login_screen.dart';
import 'package:foodkie/presentation/screens/auth/onboarding_screen.dart';
import 'package:foodkie/presentation/screens/kitchen/kitchen_home_screen.dart';
import 'package:foodkie/presentation/screens/manager/dashboard/manager_dashboard_screen.dart';
import 'package:foodkie/presentation/screens/waiter/waiter_home_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();

    _checkFirstTime();
    _navigateToNextScreen();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('first_time') ?? true;

    if (isFirstTime) {
      setState(() {
        _showOnboarding = true;
      });

      await prefs.setBool('first_time', false);
    }
  }

  Future<void> _navigateToNextScreen() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Simulating a loading delay
    await Future.delayed(const Duration(seconds: 3));

    await auth.initialize();

    if (!mounted) return;

    if (auth.isAuthenticated) {
      // Navigate based on user role
      if (auth.isManager) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ManagerDashboardScreen()),
        );
      } else if (auth.isWaiter) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WaiterHomeScreen()),
        );
      } else if (auth.isKitchenStaff) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const KitchenHomeScreen()),
        );
      }
    } else {
      // Show onboarding for first time users, otherwise login screen
      if (_showOnboarding) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                AssetsConstants.logoIconPath,
                width: 150,
                height: 150,
              ),
            ],
          ),
        ),
      ),
    );
  }
}