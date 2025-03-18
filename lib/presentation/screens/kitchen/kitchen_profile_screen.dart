// presentation/screens/kitchen/kitchen_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';
import 'package:foodkie/presentation/common_widgets/custom_text_field.dart';
import 'package:foodkie/presentation/common_widgets/image_picker_widget.dart';
import 'package:foodkie/presentation/common_widgets/loading_widget.dart';
import 'package:foodkie/presentation/providers/auth_provider.dart';
import 'package:foodkie/core/utils/image_utils.dart';
import 'package:foodkie/core/utils/toast_utils.dart';
import 'dart:io';

import '../shared/change_password_screen.dart';

class KitchenProfileScreen extends StatefulWidget {
  const KitchenProfileScreen({Key? key}) : super(key: key);

  @override
  State<KitchenProfileScreen> createState() => _KitchenProfileScreenState();
}

class _KitchenProfileScreenState extends State<KitchenProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  File? _profileImage;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        ToastUtils.showErrorToast('User information not available');
        return;
      }

      try {
        String? profileImageUrl;
        // Handle image upload logic here if needed

        final success = await authProvider.updateProfile(
          userId: user.id,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          profileImage: profileImageUrl,
        );

        if (success && mounted) {
          ToastUtils.showSuccessToast('Profile updated successfully');
          setState(() {
            _isEditing = false;
          });
        } else if (mounted) {
          ToastUtils.showErrorToast('Failed to update profile');
        }
      } catch (e) {
        ToastUtils.showErrorToast('Error: ${e.toString()}');
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImageUtils.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = pickedFile;
        });
      }
    } catch (e) {
      ToastUtils.showErrorToast('Failed to pick image: ${e.toString()}');
    }
  }

  void _navigateToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  const ChangePasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User information not available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditMode,
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body: authProvider.isLoading
          ? const LoadingWidget(message: 'Loading profile...')
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image
              if (_isEditing)
                ImagePickerWidget(
                  imageUrl: user.profileImage,
                  imageFile: _profileImage,
                  onImagePicked: (file) {
                    setState(() {
                      _profileImage = file;
                    });
                  },
                  height: 150,
                  width: 150,
                  shape: BoxShape.circle,
                  placeholder: 'Tap to select image',
                )
              else
                CircleAvatar(
                  radius: 75,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  backgroundImage: user.profileImage != null
                      ? NetworkImage(user.profileImage!)
                      : null,
                  child: user.profileImage == null
                      ? Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  )
                      : null,
                ),

              const SizedBox(height: 24),

              // User Role Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  'Kitchen Staff',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Name Field
              CustomTextField(
                label: StringConstants.name,
                controller: _nameController,
                enabled: _isEditing,
                prefixIcon: const Icon(Icons.person),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Email Field (Disabled)
              CustomTextField(
                label: StringConstants.email,
                controller: _emailController,
                enabled: false,
                prefixIcon: const Icon(Icons.email),
              ),

              const SizedBox(height: 16),

              // Phone Field
              CustomTextField(
                label: StringConstants.phoneNumber,
                controller: _phoneController,
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              if (_isEditing)
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Cancel',
                        onPressed: _toggleEditMode,
                        isOutlined: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Save',
                        onPressed: _saveProfile,
                      ),
                    ),
                  ],
                )
              else
                CustomButton(
                  text: 'Change Password',
                  onPressed: _navigateToChangePassword,
                  icon: Icons.lock_outline,
                  isOutlined: true,
                ),
            ],
          ),
        ),
      ),
    );
  }
}