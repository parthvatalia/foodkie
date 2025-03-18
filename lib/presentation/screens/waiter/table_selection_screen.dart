// presentation/screens/waiter/table_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/animations/fade_animation.dart';
import 'package:foodkie/core/constants/route_constants.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/data/models/table_model.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';
import 'package:foodkie/presentation/common_widgets/empty_state_widget.dart';
import 'package:foodkie/presentation/common_widgets/loading_widget.dart';
import 'package:foodkie/presentation/common_widgets/table_card.dart';
import 'package:foodkie/presentation/providers/table_provider.dart';
import 'package:foodkie/presentation/providers/order_provider.dart';

class TableSelectionScreen extends StatefulWidget {
  const TableSelectionScreen({Key? key}) : super(key: key);

  @override
  State<TableSelectionScreen> createState() => _TableSelectionScreenState();
}

class _TableSelectionScreenState extends State<TableSelectionScreen> {
  bool _isLoading = true;
  List<TableModel> _availableTables = [];
  List<TableModel> _occupiedTables = [];
  List<TableModel> _reservedTables = [];
  String? _selectedFilter;
  final List<String> _filters = ['All', 'Available', 'Occupied', 'Reserved'];

  @override
  void initState() {
    super.initState();
    _selectedFilter = _filters[0]; // Default to 'All'
    _loadTables();
  }

  Future<void> _loadTables() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tableProvider = Provider.of<TableProvider>(context, listen: false);

      // Load all tables
      tableProvider.getTablesStream()?.listen(
            (tables) {
          if (mounted) {
            setState(() {
              // Filter tables by status
              _availableTables = tables.where((table) => table.status == TableStatus.available).toList();
              _occupiedTables = tables.where((table) => table.status == TableStatus.occupied).toList();
              _reservedTables = tables.where((table) => table.status == TableStatus.reserved).toList();
              _isLoading = false;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading tables: $error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onTableSelected(TableModel table) async {
    if (table.status != TableStatus.available) {
      // Check if there's an active order for this table
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final activeOrder = await orderProvider.getActiveOrderForTable(table.id);

      if (activeOrder != null) {
        if (mounted) {
          // Navigate to the order details
          Navigator.pushNamed(
            context,
            RouteConstants.waiterOrderDetail,
            arguments: activeOrder.id,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This table is not available for new orders'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
      return;
    }

    // For available tables, proceed to food selection
    if (mounted) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      orderProvider.setSelectedTable(table.id);
      Navigator.pushNamed(context, RouteConstants.waiterFoodSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Select Table',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: LoadingWidget())
          : Column(
        children: [
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildFilterTabs(),
          ),

          // Table Grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadTables,
              child: _buildTableGrid(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FadeAnimation(
              delay: 0.1 * (_filters.indexOf(filter) + 1),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                backgroundColor: Colors.grey[200],
                selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                checkmarkColor: AppTheme.primaryColor,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTableGrid() {
    // Determine which tables to show based on the filter
    List<TableModel> tablesToShow = [];
    switch (_selectedFilter) {
      case 'Available':
        tablesToShow = _availableTables;
        break;
      case 'Occupied':
        tablesToShow = _occupiedTables;
        break;
      case 'Reserved':
        tablesToShow = _reservedTables;
        break;
      default: // 'All'
        tablesToShow = [..._availableTables, ..._occupiedTables, ..._reservedTables];
        break;
    }

    // Sort by table number
    tablesToShow.sort((a, b) => a.number.compareTo(b.number));

    if (tablesToShow.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          message: 'No ${_selectedFilter?.toLowerCase()} tables found',
          icon: Icons.table_restaurant,
          actionLabel: 'Refresh',
          onAction: _loadTables,
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: tablesToShow.length,
      itemBuilder: (context, index) {
        final table = tablesToShow[index];
        return FadeAnimation(
          delay: 0.1 * (index + 1),
          child: TableCard(
            table: table,
            onTap: () => _onTableSelected(table),
          ),
        );
      },
    );
  }
}