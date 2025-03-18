// presentation/screens/manager/categories/edit_category_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/utils/validators.dart';
import 'package:foodkie/data/models/category_model.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';
import 'package:foodkie/presentation/common_widgets/custom_text_field.dart';
import 'package:foodkie/presentation/common_widgets/image_picker_widget.dart';
import 'package:foodkie/presentation/common_widgets/confirmation_dialog.dart';
import 'package:foodkie/presentation/providers/category_provider.dart';

class EditCategoryScreen extends StatefulWidget {
  final Category category;

  const EditCategoryScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _orderController;
  File? _selectedImage;
  bool _isSubmitting = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _descriptionController = TextEditingController(text: widget.category.description);
    _orderController = TextEditingController(text: widget.category.order.toString());

    // Listen for text changes to detect modifications
    _nameController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
    _orderController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final nameChanged = _nameController.text != widget.category.name;
    final descriptionChanged = _descriptionController.text != widget.category.description;
    final orderChanged = _orderController.text != widget.category.order.toString();
    final imageChanged = _selectedImage != null;

    setState(() {
      _hasChanges = nameChanged || descriptionChanged || orderChanged || imageChanged;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      int? order;
      if (_orderController.text.isNotEmpty) {
        order = int.tryParse(_orderController.text);
      }

      final provider = Provider.of<CategoryProvider>(context, listen: false);
      final success = await provider.updateCategory(
        id: widget.category.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        imageFile: _selectedImage,
        order: order,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category updated successfully')),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update category: ${provider.errorMessage}')),
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

  Future<void> _deleteCategory() async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Category',
      message: 'Are you sure you want to delete "${widget.category.name}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDestructive: true,
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      onConfirm: () async {
        setState(() {
          _isSubmitting = true;
        });

        try {
          final provider = Provider.of<CategoryProvider>(context, listen: false);
          final success = await provider.deleteCategory(widget.category.id);

          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Category deleted successfully')),
            );
            Navigator.pop(context);
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to delete category: ${provider.errorMessage}')),
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
      },
    );
  }

  void _onImagePicked(File? imageFile) {
    setState(() {
      _selectedImage = imageFile;
      _hasChanges = true;
    });
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
          title: StringConstants.editCategory,
          showBackButton: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: _deleteCategory,
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
            // Category Image
            Center(
              child: ImagePickerWidget(
                imageUrl: widget.category.imageUrl,
                imageFile: _selectedImage,
                onImagePicked: _onImagePicked,
                height: 150,
                width: 150,
                shape: BoxShape.circle,
                placeholder: 'Update Category Image',
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
              textInputAction: TextInputAction.next,
              maxLines: 3,
              validator: (value) => Validators.validateRequired(value, 'Description'),
            ),
            const SizedBox(height: 16),

            // Category Order
            CustomTextField(
              label: 'Display Order',
              controller: _orderController,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final number = int.tryParse(value);
                  if (number == null) {
                    return 'Please enter a valid number';
                  }
                  if (number < 1) {
                    return 'Order must be greater than 0';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Submit Button
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
}