// presentation/screens/manager/tables/add_table_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/core/utils/validators.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';
import 'package:foodkie/presentation/common_widgets/custom_text_field.dart';
import 'package:foodkie/presentation/providers/table_provider.dart';

class AddTableScreen extends StatefulWidget {
  const AddTableScreen({Key? key}) : super(key: key);

  @override
  State<AddTableScreen> createState() => _AddTableScreenState();
}

class _AddTableScreenState extends State<AddTableScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tableNumberController = TextEditingController();
  final _capacityController = TextEditingController();

  TableStatus _tableStatus = TableStatus.available;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _capacityController.text = '4'; // Default capacity
  }

  @override
  void dispose() {
    _tableNumberController.dispose();
    _capacityController.dispose();
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
      final tableNumber = int.parse(_tableNumberController.text);
      final capacity = int.parse(_capacityController.text);

      final provider = Provider.of<TableProvider>(context, listen: false);
      final success = await provider.addTable(
        number: tableNumber,
        capacity: capacity,
        status: _tableStatus,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Table added successfully')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add table: ${provider.errorMessage}')),
          );
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: StringConstants.addTable,
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
            // Table Icon
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _getStatusColor(_tableStatus).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.table_restaurant,
                  size: 60,
                  color: _getStatusColor(_tableStatus),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Table Number
            CustomTextField(
              label: 'Table Number',
              controller: _tableNumberController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Table number is required';
                }

                final number = int.tryParse(value);
                if (number == null || number <= 0) {
                  return 'Please enter a valid table number';
                }

                return null;
              },
              prefixIcon: const Icon(Icons.tag),
            ),
            const SizedBox(height: 16),

            // Capacity
            CustomTextField(
              label: 'Seating Capacity',
              controller: _capacityController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Capacity is required';
                }

                final capacity = int.tryParse(value);
                if (capacity == null || capacity <= 0) {
                  return 'Please enter a valid capacity';
                }

                return null;
              },
              prefixIcon: const Icon(Icons.people),
            ),
            const SizedBox(height: 16),

            // Table Status
            _buildStatusSelection(),
            const SizedBox(height: 24),

            // Submit Button
            CustomButton(
              text: 'Add Table',
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

  Widget _buildStatusSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Table Status',
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
              // Available Status
              RadioListTile<TableStatus>(
                title: const Text('Available'),
                subtitle: const Text('Ready to be assigned'),
                value: TableStatus.available,
                groupValue: _tableStatus,
                onChanged: (value) {
                  setState(() {
                    _tableStatus = value!;
                  });
                },
                activeColor: Colors.green,
              ),

              Divider(height: 1, color: Colors.grey.shade300),

              // Occupied Status
              RadioListTile<TableStatus>(
                title: const Text('Occupied'),
                subtitle: const Text('Currently in use'),
                value: TableStatus.occupied,
                groupValue: _tableStatus,
                onChanged: (value) {
                  setState(() {
                    _tableStatus = value!;
                  });
                },
                activeColor: Colors.red,
              ),

              Divider(height: 1, color: Colors.grey.shade300),

              // Reserved Status
              RadioListTile<TableStatus>(
                title: const Text('Reserved'),
                subtitle: const Text('Booked for future use'),
                value: TableStatus.reserved,
                groupValue: _tableStatus,
                onChanged: (value) {
                  setState(() {
                    _tableStatus = value!;
                  });
                },
                activeColor: Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return Colors.green;
      case TableStatus.occupied:
        return Colors.red;
      case TableStatus.reserved:
        return Colors.orange;
    }
  }
}