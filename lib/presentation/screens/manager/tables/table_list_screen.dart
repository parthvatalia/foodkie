// presentation/screens/manager/tables/table_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/constants/route_constants.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/animations/fade_animation.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/data/models/table_model.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';
import 'package:foodkie/presentation/common_widgets/custom_drawer.dart';
import 'package:foodkie/presentation/common_widgets/empty_state_widget.dart';
import 'package:foodkie/presentation/common_widgets/error_widget.dart';
import 'package:foodkie/presentation/common_widgets/loading_widget.dart';
import 'package:foodkie/presentation/common_widgets/confirmation_dialog.dart';
import 'package:foodkie/presentation/common_widgets/search_bar.dart';
import 'package:foodkie/presentation/providers/auth_provider.dart';
import 'package:foodkie/presentation/providers/table_provider.dart';

class TableListScreen extends StatefulWidget {
  const TableListScreen({Key? key}) : super(key: key);

  @override
  State<TableListScreen> createState() => _TableListScreenState();
}

class _TableListScreenState extends State<TableListScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  TableStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  void _initStream() {
    final tableProvider = Provider.of<TableProvider>(context, listen: false);
    tableProvider.loadTables();
  }

  void _searchTables(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _filterByStatus(TableStatus? status) {
    setState(() {
      _filterStatus = status;
    });

    final tableProvider = Provider.of<TableProvider>(context, listen: false);
    if (status != null) {
      tableProvider.loadTablesByStatus(status);
    } else {
      tableProvider.loadTables();
    }
  }

  void _navigateToAddTable() {
    Navigator.pushNamed(context, RouteConstants.managerTableAdd)
        .then((_) => _initStream());
  }

  void _navigateToEditTable(TableModel table) {
    Navigator.pushNamed(
      context,
      RouteConstants.managerTableEdit,
      arguments: table,
    ).then((_) => _initStream());
  }

  Future<void> _deleteTable(TableModel table) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Table',
      message: 'Are you sure you want to delete Table ${table.number}? This action cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDestructive: true,
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      onConfirm: () async {
        try {
          final provider = Provider.of<TableProvider>(context, listen: false);
          await provider.deleteTable(table.id);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Table deleted successfully')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to delete table: $e')),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: StringConstants.tables,
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortOptions(),
            tooltip: 'Sort Tables',
          ),
        ],
      ),
      drawer: CustomDrawer(
        user: user,
        selectedIndex: 3, // Tables index
        onItemSelected: (index) {
          // Navigation logic
        },
        items: [
          DrawerItem(
            icon: Icons.dashboard,
            title: StringConstants.dashboard,
          ),
          DrawerItem(
            icon: Icons.category,
            title: StringConstants.categories,
          ),
          DrawerItem(
            icon: Icons.restaurant_menu,
            title: StringConstants.foodItems,
          ),
          DrawerItem(
            icon: Icons.table_bar,
            title: StringConstants.tables,
          ),
          DrawerItem(
            icon: Icons.people,
            title: StringConstants.staff,
          ),
          DrawerItem(
            icon: Icons.receipt_long,
            title: StringConstants.reports,
          ),
          DrawerItem(
            icon: Icons.analytics,
            title: StringConstants.analytics,
          ),
          DrawerItem(
            icon: Icons.settings,
            title: StringConstants.settings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          CustomSearchBar(
            hintText: 'Search tables by number or capacity...',
            onSearch: _searchTables,
          ),

          // Status Filter Chips
          _buildStatusFilterChips(),

          // Tables List/Grid
          Expanded(
            child: Consumer<TableProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const LoadingWidget(message: 'Loading tables...');
                }

                if (provider.errorMessage != null) {
                  return ErrorDisplayWidget(
                    message: 'Error loading tables: ${provider.errorMessage}',
                    onRetry: _initStream,
                  );
                }

                final tables = provider.tables;
                if (tables.isEmpty) {
                  return EmptyStateWidget(
                    message: 'No tables found',
                    actionLabel: 'Add Table',
                    onAction: _navigateToAddTable,
                  );
                }

                // Filter tables based on search query
                final filteredTables = _searchQuery.isEmpty
                    ? tables
                    : tables.where((table) {
                  return table.number.toString().contains(_searchQuery) ||
                      table.capacity.toString().contains(_searchQuery);
                }).toList();

                if (filteredTables.isEmpty) {
                  return EmptyStateWidget(
                    message: 'No tables match your search',
                    actionLabel: 'Clear Search',
                    onAction: () => _searchTables(''),
                  );
                }

                return _buildTablesGrid(filteredTables);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTable,
        child: const Icon(Icons.add),
        tooltip: 'Add Table',
      ),
    );
  }

  Widget _buildStatusFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // All filter option
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: const Text('All Tables'),
              selected: _filterStatus == null,
              onSelected: (selected) {
                if (selected) {
                  _filterByStatus(null);
                }
              },
              backgroundColor: Colors.grey.shade200,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            ),
          ),

          // Available filter option
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: const Text('Available'),
              selected: _filterStatus == TableStatus.available,
              onSelected: (selected) {
                _filterByStatus(selected ? TableStatus.available : null);
              },
              backgroundColor: Colors.grey.shade200,
              selectedColor: Colors.green.withOpacity(0.2),
              checkmarkColor: Colors.green,
            ),
          ),

          // Occupied filter option
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: const Text('Occupied'),
              selected: _filterStatus == TableStatus.occupied,
              onSelected: (selected) {
                _filterByStatus(selected ? TableStatus.occupied : null);
              },
              backgroundColor: Colors.grey.shade200,
              selectedColor: Colors.red.withOpacity(0.2),
              checkmarkColor: Colors.red,
            ),
          ),

          // Reserved filter option
          FilterChip(
            label: const Text('Reserved'),
            selected: _filterStatus == TableStatus.reserved,
            onSelected: (selected) {
              _filterByStatus(selected ? TableStatus.reserved : null);
            },
            backgroundColor: Colors.grey.shade200,
            selectedColor: Colors.orange.withOpacity(0.2),
            checkmarkColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildTablesGrid(List<TableModel> tables) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: tables.length,
      itemBuilder: (context, index) {
        final table = tables[index];
        return _buildTableCard(table, index);
      },
    );
  }

  Widget _buildTableCard(TableModel table, int index) {
    return FadeAnimation(
      delay: 0.05 * index,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: table.status == TableStatus.available
              ? BorderSide(color: Colors.green.shade300, width: 2)
              : table.status == TableStatus.occupied
              ? BorderSide(color: Colors.red.shade300, width: 2)
              : BorderSide(color: Colors.orange.shade300, width: 2),
        ),
        child: InkWell(
          onTap: () => _navigateToEditTable(table),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Table Number and Status
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _getStatusColor(table.status).withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                width: double.infinity,
                child: Column(
                  children: [
                    Text(
                      'Table ${table.number}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(table.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(table.status),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(table.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Table Icon
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.table_restaurant,
                        size: 80,
                        color: _getStatusColor(table.status).withOpacity(0.7),
                      ),
                      Positioned(
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${table.capacity} seats',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Edit Button
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _navigateToEditTable(table),
                      tooltip: 'Edit Table',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),

                    // Status Toggle Button
                    IconButton(
                      icon: Icon(
                        table.status == TableStatus.available
                            ? Icons.event_seat
                            : Icons.event_available,
                        color: table.status == TableStatus.available
                            ? Colors.orange
                            : Colors.green,
                      ),
                      onPressed: () => _toggleTableStatus(table),
                      tooltip: table.status == TableStatus.available
                          ? 'Mark as Occupied'
                          : 'Mark as Available',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),

                    // Delete Button
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTable(table),
                      tooltip: 'Delete Table',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return 'Available';
      case TableStatus.occupied:
        return 'Occupied';
      case TableStatus.reserved:
        return 'Reserved';
    }
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

  Future<void> _toggleTableStatus(TableModel table) async {
    try {
      final provider = Provider.of<TableProvider>(context, listen: false);
      final newStatus = table.status == TableStatus.available
          ? TableStatus.occupied
          : TableStatus.available;

      await provider.updateTableStatus(id: table.id, status: newStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Table ${table.number} marked as ${_getStatusText(newStatus)}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update table status: $e')),
        );
      }
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Sort by Table Number (Ascending)'),
                leading: const Icon(Icons.sort),
                onTap: () {
                  Navigator.pop(context);
                  // Sort by table number ascending
                  _sortTables('number', true);
                },
              ),
              ListTile(
                title: const Text('Sort by Table Number (Descending)'),
                leading: const Icon(Icons.sort),
                onTap: () {
                  Navigator.pop(context);
                  // Sort by table number descending
                  _sortTables('number', false);
                },
              ),
              ListTile(
                title: const Text('Sort by Capacity (Ascending)'),
                leading: const Icon(Icons.people),
                onTap: () {
                  Navigator.pop(context);
                  // Sort by capacity ascending
                  _sortTables('capacity', true);
                },
              ),
              ListTile(
                title: const Text('Sort by Capacity (Descending)'),
                leading: const Icon(Icons.people),
                onTap: () {
                  Navigator.pop(context);
                  // Sort by capacity descending
                  _sortTables('capacity', false);
                },
              ),
              ListTile(
                title: const Text('Sort by Status'),
                leading: const Icon(Icons.info),
                onTap: () {
                  Navigator.pop(context);
                  // Sort by status
                  _sortTables('status', true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _sortTables(String criteria, bool ascending) {
    final tableProvider = Provider.of<TableProvider>(context, listen: false);
    final tables = List<TableModel>.from(tableProvider.tables);

    switch (criteria) {
      case 'number':
        tables.sort((a, b) => ascending
            ? a.number.compareTo(b.number)
            : b.number.compareTo(a.number));
        break;
      case 'capacity':
        tables.sort((a, b) => ascending
            ? a.capacity.compareTo(b.capacity)
            : b.capacity.compareTo(a.capacity));
        break;
      case 'status':
        tables.sort((a, b) => a.status.name.compareTo(b.status.name));
        break;
    }

    // Update the table list with sorted tables
    // In a real app, you'd update the provider state
  }
}