// presentation/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/constants/assets_constants.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/core/utils/validators.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';
import 'package:foodkie/presentation/common_widgets/custom_text_field.dart';
import 'package:foodkie/presentation/common_widgets/loading_widget.dart';
import 'package:foodkie/presentation/providers/auth_provider.dart';
import 'package:foodkie/presentation/screens/auth/login_screen.dart';
import 'package:foodkie/presentation/screens/auth/role_selection_screen.dart';
import 'package:foodkie/core/utils/toast_utils.dart';

class RegisterScreen extends StatefulWidget {
  final UserRole? selectedRole;

  const RegisterScreen({Key? key, this.selectedRole}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = true;
  bool _obscureConfirmPassword = true;
  UserRole? _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.selectedRole;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      // Check if the role is selected
      if (_selectedRole == null) {
        // Show a toast message instead of navigating away
        ToastUtils.showWarningToast('Please select a role');
        return;
      }

      // Check if passwords match
      if (_passwordController.text != _confirmPasswordController.text) {
        ToastUtils.showErrorToast('Passwords do not match');
        return;
      }

      setState(() {
        _isLoading = true; // Add a loading state if you don't have one
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        final success = await authProvider.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          role: _selectedRole!,
          phone: _phoneController.text.trim(),
        );

        if (!mounted) return;

        if (success) {
          ToastUtils.showSuccessToast('Registration successful! Please verify your email.');

          // Navigate to verification screen or login
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        } else {
          final errorMsg = authProvider.errorMessage ?? 'Registration failed';
          print("Registration failed: $errorMsg");
          ToastUtils.showErrorToast(errorMsg);

        }
      } catch (e) {
        if (mounted) {
          ToastUtils.showErrorToast('Registration error: ${e.toString()}');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false; // Reset loading state
          });
        }
      }
    }
  }

  void _navigateToRoleSelection() async {
    final selectedRole = await Navigator.of(context).push<UserRole>(
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
    );

    if (selectedRole != null) {
      setState(() {
        _selectedRole = selectedRole;
      });
    }
  }

  String _getRoleText() {
    if (_selectedRole == null) {
      return StringConstants.selectRole;
    }

    switch (_selectedRole) {
      case UserRole.manager:
        return StringConstants.managerTitle;
      case UserRole.waiter:
        return StringConstants.waiterTitle;
      case UserRole.kitchen:
        return StringConstants.kitchenTitle;
      default:
        return StringConstants.selectRole;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(StringConstants.register),
        elevation: 0,
      ),
      body: authProvider.isLoading
          ? const LoadingWidget(message: 'Creating your account...')
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Image.asset(
                  AssetsConstants.logoIconPath,
                  height: 80,
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  StringConstants.createAccount,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Name Field
                CustomTextField(
                  label: StringConstants.name,
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (value) => Validators.validateRequired(
                    value,
                    StringConstants.name,
                  ),
                ),

                const SizedBox(height: 16),

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

                // Phone Field
                CustomTextField(
                  label: StringConstants.phoneNumber,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: (value) => null, // Optional field
                ),

                const SizedBox(height: 16),

                // Password Field
                CustomTextField(
                  label: StringConstants.password,
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
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

                // Confirm Password Field
                CustomTextField(
                  label: StringConstants.confirmPassword,
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
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

                const SizedBox(height: 16),

                // Role Selection
                InkWell(
                  onTap: _navigateToRoleSelection,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.work_outline,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _getRoleText(),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: _selectedRole == null
                                    ? Colors.black
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Register Button
                CustomButton(
                  text: StringConstants.register,
                  onPressed: (){
                    _register();
                  },
                  height: 50,
                ),

                const SizedBox(height: 24),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      StringConstants.alreadyHaveAccount,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        StringConstants.signIn,
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
    );
  }
}