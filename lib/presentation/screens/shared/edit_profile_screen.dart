// presentation/screens/shared/edit_profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/utils/validators.dart';
import 'package:foodkie/data/models/user_model.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';
import 'package:foodkie/presentation/common_widgets/custom_text_field.dart';
import 'package:foodkie/presentation/common_widgets/image_picker_widget.dart';
import 'package:foodkie/presentation/providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name;
      if (user.phone != null) {
        _phoneController.text = user.phone!;
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user == null) {
        throw Exception('User not found');
      }

      // Upload image and get URL (missing implementation for simplicity)
      String? profileImageUrl;
      // If we had image upload implementation, it would be here

      final success = await authProvider.updateProfile(
        userId: user.id,
        name: _nameController.text,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        profileImage: profileImageUrl,
      );

      if (success) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authProvider.errorMessage ?? 'Failed to update profile',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not found'),
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Edit Profile',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image
              Center(
                child: ImagePickerWidget(
                  imageUrl: user.profileImage,
                  imageFile: _selectedImage,
                  onImagePicked: (file) {
                    setState(() {
                      _selectedImage = file;
                    });
                  },
                  width: 120,
                  height: 120,
                  shape: BoxShape.circle,
                  placeholder: 'Select Profile Photo',
                ),
              ),

              const SizedBox(height: 32),

              // Name Field
              CustomTextField(
                label: StringConstants.name,
                controller: _nameController,
                validator: (value) => Validators.validateRequired(
                  value,
                  StringConstants.name,
                ),
                prefixIcon: const Icon(Icons.person),
              ),

              const SizedBox(height: 16),

              // Phone Field
              CustomTextField(
                label: StringConstants.phoneNumber,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone),
              ),

              const SizedBox(height: 16),

              // Email Field (Read-only)
              CustomTextField(
                label: StringConstants.email,
                initialValue: user.email,
                enabled: false,
                prefixIcon: const Icon(Icons.email),
              ),

              const SizedBox(height: 16),

              // Role Field (Read-only)
              CustomTextField(
                label: StringConstants.role,
                initialValue: user.role.name,
                enabled: false,
                prefixIcon: const Icon(Icons.badge),
              ),

              const SizedBox(height: 32),

              // Save Button
              CustomButton(
                text: StringConstants.save,
                onPressed: _saveProfile,
                isLoading: _isLoading,
                width: double.infinity,
              ),

              const SizedBox(height: 16),

              // Cancel Button
              CustomButton(
                text: StringConstants.cancel,
                onPressed: () => Navigator.pop(context),
                isOutlined: true,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}