// presentation/screens/auth/verify_email_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';
import 'package:foodkie/presentation/providers/auth_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:foodkie/core/constants/assets_constants.dart';
import 'package:foodkie/core/utils/toast_utils.dart';
import 'package:foodkie/presentation/screens/auth/login_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _timer;
  bool _isVerified = false;
  bool _isLoading = false;
  int _remainingTime = 60;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _checkEmailVerification();

      // Decrement remaining time for resend
      if (_remainingTime > 0 && mounted) {
        setState(() {
          _remainingTime--;
        });
      }
    });

    // Start a timer for updating UI countdown
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0 && mounted) {
        setState(() {
          _remainingTime--;
        });
      }

      // Stop this timer when counter reaches 0
      if (_remainingTime <= 0) {
        timer.cancel();
      }
    });
  }

  Future<void> _checkEmailVerification() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isVerified = await authProvider.isEmailVerified();

      if (mounted) {
        setState(() {
          _isVerified = isVerified;
          _isLoading = false;
        });
      }

      if (isVerified) {
        _timer?.cancel();
        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ToastUtils.showErrorToast(e.toString());
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.resendVerificationEmail();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _remainingTime = 60;
        });

        ToastUtils.showSuccessToast('Verification email resent successfully.');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ToastUtils.showErrorToast(e.toString());
      }
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(StringConstants.verifyEmail),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Email verification animation
              Lottie.asset(
                _isVerified
                    ? AssetsConstants.successAnimationPath
                    : AssetsConstants.loadingAnimationPath,
                width: 200,
                height: 200,
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                _isVerified
                    ? 'Email Verified!'
                    : StringConstants.verificationEmailSent,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _isVerified ? AppTheme.successColor : null,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                _isVerified
                    ? 'Your email has been verified successfully. You can now login to your account.'
                    : 'We\'ve sent a verification email to ${widget.email}. Please check your inbox and verify your email address.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              if (!_isVerified) ...[
                // Resend button
                CustomButton(
                  text: _remainingTime > 0
                      ? 'Resend Email (${_remainingTime}s)'
                      : 'Resend Verification Email',
                  onPressed: _remainingTime > 0
                      ? (){}
                      : () { _resendVerificationEmail(); },           disabled: _remainingTime > 0,
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 16),

                // Back to login button
                CustomButton(
                  text: 'Back to Login',
                  onPressed: _navigateToLogin,
                  isOutlined: true,
                ),
              ] else ...[
                // Continue to login button
                CustomButton(
                  text: 'Continue to Login',
                  onPressed: _navigateToLogin,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}