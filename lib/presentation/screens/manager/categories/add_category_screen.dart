
// presentation/screens/manager/categories/add_category_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/utils/validators.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';
import 'package:foodkie/presentation/common_widgets/custom_text_field.dart';
import 'package:foodkie/presentation/common_widgets/image_picker_widget.dart';
import 'package:foodkie/presentation/providers/category_provider.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({Key? key}) : super(key: key);

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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
      final provider = Provider.of<CategoryProvider>(context, listen: false);
      final success = await provider.addCategory(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        imageFile: _selectedImage,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category added successfully')),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add category: ${provider.errorMessage}')),
        );
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
        title: StringConstants.addCategory,
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
            // Category Image
            Center(
              child: ImagePickerWidget(
                imageFile: _selectedImage,
                onImagePicked: _onImagePicked,
                height: 150,
                width: 150,
                shape: BoxShape.circle,
                placeholder: 'Add Category Image',
              ),
            ),
            const SizedBox(height: 24),

            // Category Name
            CustomTextField(
              label: 'Category Name',
              controller: _nameController,
              textInputAction: TextInputAction.next,
              validator: (value) => Validators.validateRequired(value, 'Category name'),
            ),
            const SizedBox(height: 16),

            // Category Description
            CustomTextField(
              label: 'Description',
              controller: _descriptionController,
              textInputAction: TextInputAction.done,
              maxLines: 3,
              validator: (value) => Validators.validateRequired(value, 'Description'),
            ),
            const SizedBox(height: 24),

            // Submit Button
            CustomButton(
              text: 'Add Category',
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
}