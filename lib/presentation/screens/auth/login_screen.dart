// presentation/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/constants/assets_constants.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/core/utils/validators.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';
import 'package:foodkie/presentation/common_widgets/custom_text_field.dart';
import 'package:foodkie/presentation/common_widgets/loading_widget.dart';
import 'package:foodkie/presentation/providers/auth_provider.dart';
import 'package:foodkie/presentation/screens/auth/forgot_password_screen.dart';
import 'package:foodkie/presentation/screens/auth/register_screen.dart';
import 'package:foodkie/presentation/screens/kitchen/kitchen_home_screen.dart';
import 'package:foodkie/presentation/screens/manager/dashboard/manager_dashboard_screen.dart';
import 'package:foodkie/presentation/screens/waiter/waiter_home_screen.dart';
import 'package:foodkie/core/utils/toast_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );

      if (!mounted) return;

      if (success) {
        // Navigate based on user role
        if (authProvider.isManager) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ManagerDashboardScreen()),
          );
        } else if (authProvider.isWaiter) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const WaiterHomeScreen()),
          );
        } else if (authProvider.isKitchenStaff) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const KitchenHomeScreen()),
          );
        }
      } else {
        // Show error toast
        ToastUtils.showErrorToast(
          authProvider.errorMessage ?? StringConstants.invalidCredentials,
        );
      }
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  void _navigateToForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: authProvider.isLoading
          ? const LoadingWidget(message: 'Logging in...')
          : SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Image.asset(
                    AssetsConstants.logoFullPath,
                    height: 100,
                  ),

                  const SizedBox(height: 40),

                  // Title
                  Text(
                    StringConstants.login,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Welcome back to ${StringConstants.appName}',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Email Field
                  CustomTextField(
                    label: StringConstants.email,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: Validators.validateEmail,
                  ),

                  const SizedBox(height: 16),

                  // Password Field
                  CustomTextField(
                    label: StringConstants.password,
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: Validators.validatePassword,
                  ),

                  const SizedBox(height: 16),

                  // Remember Me & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Remember Me
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            activeColor: AppTheme.primaryColor,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                          Text(
                            StringConstants.rememberMe,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),

                      // Forgot Password
                      TextButton(
                        onPressed: _navigateToForgotPassword,
                        child: Text(
                          StringConstants.forgotPassword,
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Login Button
                  CustomButton(
                    text: StringConstants.login,
                    onPressed: _login,
                    height: 50,
                  ),

                  const SizedBox(height: 24),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        StringConstants.dontHaveAccount,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: _navigateToRegister,
                        child: Text(
                          StringConstants.signUp,
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}