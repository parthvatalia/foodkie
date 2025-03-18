// presentation/screens/manager/tables/edit_table_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/core/utils/validators.dart';
import 'package:foodkie/data/models/table_model.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';
import 'package:foodkie/presentation/common_widgets/custom_text_field.dart';
import 'package:foodkie/presentation/common_widgets/loading_widget.dart';
import 'package:foodkie/presentation/providers/table_provider.dart';

class EditTableScreen extends StatefulWidget {
  final String tableId;

  const EditTableScreen({
    Key? key,
    required this.tableId,
  }) : super(key: key);

  @override
  State<EditTableScreen> createState() => _EditTableScreenState();
}

class _EditTableScreenState extends State<EditTableScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _capacityController = TextEditingController();

  TableStatus _selectedStatus = TableStatus.available;
  bool _isLoading = true;
  TableModel? _table;

  @override
  void initState() {
    super.initState();
    _loadTableData();
  }

  @override
  void dispose() {
    _numberController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _loadTableData() async {
    final tableProvider = Provider.of<TableProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    try {
      final table = await tableProvider.getTableById(widget.tableId);

      if (table != null) {
        setState(() {
          _table = table;
          _numberController.text = table.number.toString();
          _capacityController.text = table.capacity.toString();
          _selectedStatus = table.status;
          _isLoading = false;
        });
      } else {
        // Handle table not found
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Table not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading table: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveTable() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final tableProvider = Provider.of<TableProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    try {
      final number = int.parse(_numberController.text);
      final capacity = int.parse(_capacityController.text);

      // Check if number is unique when changed
      if (number != _table!.number) {
        final existingTable = await tableProvider.getTableByNumber(number);

        if (existingTable != null) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A table with this number already exists'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      final success = await tableProvider.updateTable(
        id: widget.tableId,
        number: number,
        capacity: capacity,
        status: _selectedStatus,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update table'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating table: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: StringConstants.editTable,
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: LoadingWidget())
          : _buildForm(),
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
            // Table Number Field
            CustomTextField(
              label: StringConstants.tableNumber,
              controller: _numberController,
              keyboardType: TextInputType.number,
              validator: (value) => Validators.validateRequired(value, 'Table number'),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),

            const SizedBox(height: 16),

            // Capacity Field
            CustomTextField(
              label: StringConstants.tableCapacity,
              controller: _capacityController,
              keyboardType: TextInputType.number,
              validator: (value) => Validators.validateRequired(value, 'Capacity'),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),

            const SizedBox(height: 24),

            // Status Selection
            Text(
              StringConstants.tableStatus,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            _buildStatusSelector(),

            const SizedBox(height: 32),

            // Submit Button
            CustomButton(
              text: StringConstants.update,
              onPressed: _saveTable,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildStatusOption(
            status: TableStatus.available,
            title: 'Available',
            description: 'Table is free for new orders',
            icon: Icons.check_circle,
            color: AppTheme.successColor,
          ),

          Divider(height: 1, color: Colors.grey.shade300),

          _buildStatusOption(
            status: TableStatus.occupied,
            title: 'Occupied',
            description: 'Table is currently in use',
            icon: Icons.people,
            color: AppTheme.errorColor,
          ),

          Divider(height: 1, color: Colors.grey.shade300),

          _buildStatusOption(
            status: TableStatus.reserved,
            title: 'Reserved',
            description: 'Table is booked for future use',
            icon: Icons.event_available,
            color: AppTheme.warningColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption({
    required TableStatus status,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedStatus == status;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            // Status Icon
            Icon(
              icon,
              color: color,
              size: 24,
            ),

            const SizedBox(width: 16),

            // Status Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.primaryColor : null,
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // Selection Indicator
            Radio<TableStatus>(
              value: status,
              groupValue: _selectedStatus,
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}