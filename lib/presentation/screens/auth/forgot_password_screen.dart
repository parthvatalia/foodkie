// presentation/screens/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/core/utils/validators.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';
import 'package:foodkie/presentation/common_widgets/custom_text_field.dart';
import 'package:foodkie/presentation/common_widgets/loading_widget.dart';
import 'package:foodkie/presentation/providers/auth_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:foodkie/core/constants/assets_constants.dart';
import 'package:foodkie/core/utils/toast_utils.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.forgotPassword(_emailController.text.trim());

      if (!mounted) return;

      if (success) {
        setState(() {
          _emailSent = true;
        });
      } else {
        // Show error toast
        ToastUtils.showErrorToast(
          authProvider.errorMessage ?? 'Failed to send reset email',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(StringConstants.forgotPassword),
        elevation: 0,
      ),
      body: authProvider.isLoading
          ? const LoadingWidget(message: 'Sending reset instructions...')
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _emailSent
              ? _buildSuccessView()
              : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),

          // Title and description
          Text(
            'Password Reset',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          Text(
            'Enter your email address and we\'ll send you instructions to reset your password.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Email Field
          CustomTextField(
            label: StringConstants.email,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: Validators.validateEmail,
          ),

          const SizedBox(height: 24),

          // Reset Button
          CustomButton(
            text: StringConstants.resetPassword,
            onPressed: _resetPassword,
            height: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Success Animation
        Lottie.asset(
          AssetsConstants.successAnimationPath,
          width: 200,
          height: 200,
        ),

        const SizedBox(height: 24),

        // Success Message
        Text(
          'Reset Email Sent!',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.successColor,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        Text(
          'We\'ve sent an email to ${_emailController.text} with instructions to reset your password. Please check your inbox.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        // Back to Login Button
        CustomButton(
          text: 'Back to Login',
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}