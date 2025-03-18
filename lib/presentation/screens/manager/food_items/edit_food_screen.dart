// presentation/screens/manager/food_items/edit_food_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/utils/validators.dart';
import 'package:foodkie/data/models/category_model.dart';
import 'package:foodkie/data/models/food_item_model.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';
import 'package:foodkie/presentation/common_widgets/custom_text_field.dart';
import 'package:foodkie/presentation/common_widgets/image_picker_widget.dart';
import 'package:foodkie/presentation/common_widgets/loading_widget.dart';
import 'package:foodkie/presentation/common_widgets/error_widget.dart';
import 'package:foodkie/presentation/common_widgets/confirmation_dialog.dart';
import 'package:foodkie/presentation/providers/category_provider.dart';
import 'package:foodkie/presentation/providers/food_item_provider.dart';

class EditFoodScreen extends StatefulWidget {
  final FoodItem foodItem;

  const EditFoodScreen({
    Key? key,
    required this.foodItem,
  }) : super(key: key);

  @override
  State<EditFoodScreen> createState() => _EditFoodScreenState();
}

class _EditFoodScreenState extends State<EditFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _preparationTimeController;

  String? _selectedCategoryId;
  late bool _isAvailable;
  File? _selectedImage;
  bool _isSubmitting = false;
  bool _categoriesLoading = true;
  List<Category> _categories = [];
  String? _errorMessage;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing values
    _nameController = TextEditingController(text: widget.foodItem.name);
    _descriptionController = TextEditingController(text: widget.foodItem.description);
    _priceController = TextEditingController(text: widget.foodItem.price.toString());
    _preparationTimeController = TextEditingController(text: widget.foodItem.preparationTime.toString());
    _selectedCategoryId = widget.foodItem.categoryId;
    _isAvailable = widget.foodItem.available;

    // Add listeners to detect changes
    _nameController.addListener(_checkForChanges);
    _descriptionController.addListener(_checkForChanges);
    _priceController.addListener(_checkForChanges);
    _preparationTimeController.addListener(_checkForChanges);

    _loadCategories();
  }

  void _checkForChanges() {
    final nameChanged = _nameController.text != widget.foodItem.name;
    final descriptionChanged = _descriptionController.text != widget.foodItem.description;
    final priceChanged = _priceController.text != widget.foodItem.price.toString();
    final prepTimeChanged = _preparationTimeController.text != widget.foodItem.preparationTime.toString();
    final categoryChanged = _selectedCategoryId != widget.foodItem.categoryId;
    final availabilityChanged = _isAvailable != widget.foodItem.available;
    final hasImageChange = _selectedImage != null;

    setState(() {
      _hasChanges = nameChanged || descriptionChanged || priceChanged ||
          prepTimeChanged || categoryChanged || availabilityChanged ||
          hasImageChange;
    });
  }

  Future<void> _loadCategories() async {
    setState(() {
      _categoriesLoading = true;
      _errorMessage = null;
    });

    try {
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
      final categoriesFuture = categoryProvider.getAllCategoriesFuture();

      final categories = await categoriesFuture;

      setState(() {
        _categories = categories;
        _categoriesLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading categories: $e';
        _categoriesLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _preparationTimeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final provider = Provider.of<FoodItemProvider>(context, listen: false);
      final success = await provider.updateFoodItem(
        id: widget.foodItem.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        categoryId: _selectedCategoryId!,
        available: _isAvailable,
        preparationTime: int.parse(_preparationTimeController.text),
        imageFile: _selectedImage,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Food item updated successfully')),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update food item: ${provider.errorMessage}')),
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

  Future<void> _deleteFoodItem() async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Food Item',
      message: 'Are you sure you want to delete "${widget.foodItem.name}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDestructive: true,
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      onConfirm: () async {
        setState(() {
          _isSubmitting = true;
        });

        try {
          final provider = Provider.of<FoodItemProvider>(context, listen: false);
          final success = await provider.deleteFoodItem(widget.foodItem.id);

          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Food item deleted successfully')),
            );
            Navigator.pop(context);
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to delete food item: ${provider.errorMessage}')),
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
    });
    _checkForChanges();
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) {
      return true;
    }

    final shouldDiscard = await ConfirmationDialog.show(
      context: context,
      title: StringConstants.discardChangesConfirmation,
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
          title: StringConstants.editFood,
          showBackButton: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: _deleteFoodItem,
              tooltip: 'Delete Food Item',
            ),
          ],
        ),
        body: _categoriesLoading
            ? const LoadingWidget(message: 'Loading categories...')
            : _errorMessage != null
            ? ErrorDisplayWidget(
          message: _errorMessage!,
          onRetry: _loadCategories,
        )
            : _buildForm(),
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
            // Food Image
            Center(
              child: ImagePickerWidget(
                imageUrl: widget.foodItem.imageUrl,
                imageFile: _selectedImage,
                onImagePicked: _onImagePicked,
                height: 200,
                width: double.infinity,
                placeholder: 'Update Food Image',
              ),
            ),
            const SizedBox(height: 24),

            // Food Name
            CustomTextField(
              label: StringConstants.foodName,
              controller: _nameController,
              textInputAction: TextInputAction.next,
              validator: (value) => Validators.validateRequired(value, 'Food name'),
            ),
            const SizedBox(height: 16),

            // Food Description
            CustomTextField(
              label: StringConstants.description,
              controller: _descriptionController,
              textInputAction: TextInputAction.next,
              maxLines: 3,
              validator: (value) => Validators.validateRequired(value, 'Description'),
            ),
            const SizedBox(height: 16),

            // Food Price
            CustomTextField(
              label: StringConstants.price,
              controller: _priceController,
              textInputAction: TextInputAction.next,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) => Validators.validatePrice(value),
              prefixIcon: const Icon(Icons.attach_money),
            ),
            const SizedBox(height: 16),

            // Food Category
            _buildCategoryDropdown(),
            const SizedBox(height: 16),

            // Preparation Time
            CustomTextField(
              label: StringConstants.preparationTime,
              controller: _preparationTimeController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) => Validators.validateQuantity(value),
              prefixIcon: const Icon(Icons.timer),
              suffixIcon: const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: Text('minutes'),
              ),
            ),
            const SizedBox(height: 16),

            // Availability Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  StringConstants.availability,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Switch(
                  value: _isAvailable,
                  onChanged: (value) {
                    setState(() {
                      _isAvailable = value;
                    });
                    _checkForChanges();
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              _isAvailable ? StringConstants.available : StringConstants.unavailable,
              style: TextStyle(
                color: _isAvailable ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // Row with Save and Reset buttons
            Row(
              children: [
                // Save Button
                Expanded(
                  child: CustomButton(
                    text: 'Save Changes',
                    onPressed: _hasChanges ? _submitForm : (){},
                    isLoading: _isSubmitting,
                    icon: Icons.save,
                    disabled: !_hasChanges,
                  ),
                ),

                const SizedBox(width: 16),

                // Toggle Availability Button
                Expanded(
                  child: CustomButton(
                    text: _isAvailable ? 'Mark Unavailable' : 'Mark Available',
                    onPressed: () {
                      setState(() {
                        _isAvailable = !_isAvailable;
                      });
                      _checkForChanges();
                    },
                    color: _isAvailable ? Colors.red : Colors.green,
                    icon: _isAvailable ? Icons.visibility_off : Icons.visibility,
                    isOutlined: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StringConstants.category,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategoryId,
              isExpanded: true,
              hint: const Text(StringConstants.selectCategory),
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedCategoryId = value;
                });
                _checkForChanges();
              },
            ),
          ),
        ),
        if (_categories.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'No categories available. Please create a category first.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}