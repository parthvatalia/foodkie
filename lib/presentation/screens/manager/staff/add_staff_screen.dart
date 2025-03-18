// presentation/screens/manager/staff/add_staff_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/core/utils/validators.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';
import 'package:foodkie/presentation/common_widgets/custom_text_field.dart';
import 'package:foodkie/presentation/common_widgets/image_picker_widget.dart';
import 'package:foodkie/presentation/providers/auth_provider.dart';

class AddStaffScreen extends StatefulWidget {
  const AddStaffScreen({Key? key}) : super(key: key);

  @override
  State<AddStaffScreen> createState() => _AddStaffScreenState();
}

class _AddStaffScreenState extends State<AddStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserRole _selectedRole = UserRole.waiter;
  File? _selectedImage;
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // In a real app, you would register the user with the auth repository
      // and create the user profile in the database
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Staff member added successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _onImagePicked(File? imageFile) {
    setState(() {
      _selectedImage = imageFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: StringConstants.addStaff,
        showBackButton: true,
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            Center(
              child: ImagePickerWidget(
                imageFile: _selectedImage,
                onImagePicked: _onImagePicked,
                height: 120,
                width: 120,
                shape: BoxShape.circle,
                placeholder: 'Add Profile Picture',
              ),
            ),
            const SizedBox(height: 24),

            // Name
            CustomTextField(
              label: StringConstants.name,
              controller: _nameController,
              textInputAction: TextInputAction.next,
              validator: (value) => Validators.validateRequired(value, 'Name'),
              prefixIcon: const Icon(Icons.person),
            ),
            const SizedBox(height: 16),

            // Email
            CustomTextField(
              label: StringConstants.email,
              controller: _emailController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
              prefixIcon: const Icon(Icons.email),
            ),
            const SizedBox(height: 16),

            // Phone
            CustomTextField(
              label: StringConstants.phoneNumber,
              controller: _phoneController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone),
            ),
            const SizedBox(height: 16),

            // Role Selection
            _buildRoleSelection(),
            const SizedBox(height: 16),

            // Password
            CustomTextField(
              label: StringConstants.password,
              controller: _passwordController,
              textInputAction: TextInputAction.next,
              obscureText: _obscurePassword,
              validator: Validators.validatePassword,
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Confirm Password
            CustomTextField(
              label: StringConstants.confirmPassword,
              controller: _confirmPasswordController,
              textInputAction: TextInputAction.done,
              obscureText: _obscureConfirmPassword,
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            CustomButton(
              text: 'Add Staff Member',
              onPressed: _submitForm,
              isLoading: _isSubmitting,
              width: double.infinity,
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConstants.role,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Manager Role
              RadioListTile<UserRole>(
                title: const Text('Manager'),
                subtitle: const Text('Full access to all features'),
                value: UserRole.manager,
                groupValue: _selectedRole,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
                activeColor: Theme.of(context).primaryColor,
              ),

              Divider(height: 1, color: Colors.grey.shade300),

              // Waiter Role
              RadioListTile<UserRole>(
                title: const Text('Waiter'),
                subtitle: const Text('Can take and manage orders'),
                value: UserRole.waiter,
                groupValue: _selectedRole,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
                activeColor: Theme.of(context).primaryColor,
              ),

              Divider(height: 1, color: Colors.grey.shade300),

              // Kitchen Role
              RadioListTile<UserRole>(
                title: const Text('Kitchen Staff'),
                subtitle: const Text('Can view and process orders'),
                value: UserRole.kitchen,
                groupValue: _selectedRole,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}