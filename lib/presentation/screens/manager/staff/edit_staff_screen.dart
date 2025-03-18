// presentation/screens/manager/staff/edit_staff_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/core/utils/validators.dart';
import 'package:foodkie/data/models/user_model.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';
import 'package:foodkie/presentation/common_widgets/custom_text_field.dart';
import 'package:foodkie/presentation/common_widgets/image_picker_widget.dart';
import 'package:foodkie/presentation/common_widgets/confirmation_dialog.dart';
import 'package:foodkie/presentation/providers/auth_provider.dart';

class EditStaffScreen extends StatefulWidget {
  final UserModel staff;

  const EditStaffScreen({
    Key? key,
    required this.staff,
  }) : super(key: key);

  @override
  State<EditStaffScreen> createState() => _EditStaffScreenState();
}

class _EditStaffScreenState extends State<EditStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  late UserRole _selectedRole;
  File? _selectedImage;
  bool _isSubmitting = false;
  bool _hasChanges = false;
  bool _resetPassword = false;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.staff.name);
    _emailController = TextEditingController(text: widget.staff.email);
    _phoneController = TextEditingController(text: widget.staff.phone ?? '');
    _selectedRole = widget.staff.role;

    // Add listeners to detect changes
    _nameController.addListener(_checkForChanges);
    _emailController.addListener(_checkForChanges);
    _phoneController.addListener(_checkForChanges);
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

  void _checkForChanges() {
    setState(() {
      _hasChanges = _nameController.text != widget.staff.name ||
          _emailController.text != widget.staff.email ||
          _phoneController.text != (widget.staff.phone ?? '') ||
          _selectedRole != widget.staff.role ||
          _selectedImage != null ||
          _resetPassword;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_resetPassword && _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // In a real app, update the user profile in the database
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Staff member updated successfully')),
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

  Future<void> _deleteStaff() async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Staff Member',
      message: 'Are you sure you want to delete "${widget.staff.name}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDestructive: true,
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      onConfirm: () async {
        setState(() {
          _isSubmitting = true;
        });

        try {
          // In a real app, delete the user from the database
          await Future.delayed(const Duration(seconds: 1));

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Staff member deleted successfully')),
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
      },
    );
  }

  void _onImagePicked(File? imageFile) {
    setState(() {
      _selectedImage = imageFile;
    });
    _checkForChanges();
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) {
      return true;
    }

    final shouldDiscard = await ConfirmationDialog.show(
      context: context,
      title: 'Discard Changes',
      message: 'You have unsaved changes. Are you sure you want to discard them?',
      confirmLabel: 'Discard',
      cancelLabel: 'Keep Editing',
      isDestructive: true, onConfirm: () {  },
    );

    return shouldDiscard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: CustomAppBar(
          title: StringConstants.editStaff,
          showBackButton: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: _deleteStaff,
              tooltip: 'Delete Staff Member',
            ),
          ],
        ),
        body: _buildForm(),
      ),
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
                imageUrl: widget.staff.profileImage,
                imageFile: _selectedImage,
                onImagePicked: _onImagePicked,
                height: 120,
                width: 120,
                shape: BoxShape.circle,
                placeholder: 'Update Profile Picture',
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
            const SizedBox(height: 24),

            // Reset Password Checkbox
            CheckboxListTile(
              title: const Text('Reset Password'),
              value: _resetPassword,
              onChanged: (value) {
                setState(() {
                  _resetPassword = value ?? false;
                });
                _checkForChanges();
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),

            // Password Fields (only shown if reset password is checked)
            if (_resetPassword) ...[
              const SizedBox(height: 16),

              // New Password
              CustomTextField(
                label: 'New Password',
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

              // Confirm New Password
              CustomTextField(
                label: 'Confirm New Password',
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
            ],

            const SizedBox(height: 24),

            // Save Button
            CustomButton(
              text: 'Save Changes',
              onPressed: _hasChanges ? _submitForm : (){},
              isLoading: _isSubmitting,
              width: double.infinity,
              icon: Icons.save,
              disabled: !_hasChanges,
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
                  _checkForChanges();
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
                  _checkForChanges();
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
                  _checkForChanges();
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