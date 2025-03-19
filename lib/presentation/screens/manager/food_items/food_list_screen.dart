// presentation/screens/manager/food_items/food_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/constants/route_constants.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/animations/fade_animation.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/core/utils/number_formatter.dart';
import 'package:foodkie/data/models/food_item_model.dart';
import 'package:foodkie/data/models/category_model.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';
import 'package:foodkie/presentation/common_widgets/custom_drawer.dart';
import 'package:foodkie/presentation/common_widgets/empty_state_widget.dart';
import 'package:foodkie/presentation/common_widgets/error_widget.dart';
import 'package:foodkie/presentation/common_widgets/loading_widget.dart';
import 'package:foodkie/presentation/common_widgets/confirmation_dialog.dart';
import 'package:foodkie/presentation/common_widgets/search_bar.dart';
import 'package:foodkie/presentation/common_widgets/status_badge.dart';
import 'package:foodkie/presentation/providers/auth_provider.dart';
import 'package:foodkie/presentation/providers/food_item_provider.dart';
import 'package:foodkie/presentation/providers/category_provider.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({Key? key}) : super(key: key);

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  late Stream<List<FoodItem>> _foodItemsStream;
  late Stream<List<Category>> _categoriesStream;
  String _searchQuery = '';
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _initStreams();
  }

  void _initStreams() {
    final foodProvider = Provider.of<FoodItemProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    _foodItemsStream = foodProvider.getFoodItemsStream() ?? Stream.value([]);
    _categoriesStream = categoryProvider.getCategoriesStream() ?? Stream.value([]);
  }

  void _searchFoodItems(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _selectCategory(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });

    // Update the food items stream if a category is selected
    if (categoryId != null) {
      final foodProvider = Provider.of<FoodItemProvider>(context, listen: false);
      _foodItemsStream = foodProvider.getFoodItemsByCategoryStream(categoryId)!;
    } else {
      final foodProvider = Provider.of<FoodItemProvider>(context, listen: false);
      _foodItemsStream = foodProvider.getFoodItemsStream() ?? Stream.value([]);
    }
  }

  void _navigateToAddFood() {
    Navigator.pushNamed(context, RouteConstants.managerFoodAdd);
  }

  void _navigateToEditFood(FoodItem foodItem) {
    Navigator.pushNamed(
      context,
      RouteConstants.managerFoodEdit,
      arguments: foodItem,
    );
  }

  Future<void> _toggleAvailability(FoodItem foodItem) async {
    try {
      final provider = Provider.of<FoodItemProvider>(context, listen: false);
      await provider.toggleFoodItemAvailability(foodItem.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              foodItem.available
                  ? '${foodItem.name} marked as unavailable'
                  : '${foodItem.name} marked as available'
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating availability: $e')),
      );
    }
  }

  Future<void> _deleteFood(FoodItem foodItem) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Food Item',
      message: 'Are you sure you want to delete "${foodItem.name}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDestructive: true,
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      onConfirm: () async {
        final provider = Provider.of<FoodItemProvider>(context, listen: false);
        await provider.deleteFoodItem(foodItem.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Food item deleted successfully')),
        );
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
        title: StringConstants.foodItems,
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
              _showFilterOptions();
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              // Show sorting options
              _showSortOptions();
            },
          ),
        ],
      ),
      drawer: CustomDrawer(
        user: user,
        selectedIndex: 2, // Food Items index
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
            hintText: 'Search food items...',
            onSearch: _searchFoodItems,
          ),

          // Category Filter
          _buildCategoryFilter(),

          // Food Items List
          Expanded(
            child: StreamBuilder<List<FoodItem>>(
              stream: _foodItemsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget(message: 'Loading food items...');
                }

                if (snapshot.hasError) {
                  return ErrorDisplayWidget(
                    message: 'Error loading food items: ${snapshot.error}',
                    onRetry: () => _initStreams(),
                  );
                }

                final foodItems = snapshot.data ?? [];

                if (foodItems.isEmpty) {
                  return EmptyStateWidget(
                    message: _selectedCategoryId != null
                        ? 'No food items in this category'
                        : 'No food items found',
                    actionLabel: StringConstants.addFood,
                    onAction: _navigateToAddFood,
                  );
                }

                // Filter food items based on search
                final filteredItems = _searchQuery.isEmpty
                    ? foodItems
                    : foodItems.where((item) =>
                item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    item.description.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

                if (filteredItems.isEmpty) {
                  return EmptyStateWidget(
                    message: 'No food items match your search',
                    actionLabel: 'Clear Search',
                    onAction: () => _searchFoodItems(''),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final foodItem = filteredItems[index];
                    return _buildFoodItemCard(
                      foodItem,
                      index,
                      context,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddFood,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return StreamBuilder<List<Category>>(
      stream: _categoriesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final categories = snapshot.data!;

        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: categories.length + 1, // +1 for "All" option
            itemBuilder: (context, index) {
              if (index == 0) {
                // "All" option
                return _buildCategoryChip(
                  null,
                  'All',
                  _selectedCategoryId == null,
                );
              }

              final category = categories[index - 1];
              return _buildCategoryChip(
                category.id,
                category.name,
                _selectedCategoryId == category.id,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(
      String? categoryId,
      String name,
      bool isSelected,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(name),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            _selectCategory(categoryId);
          }
        },
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildFoodItemCard(FoodItem foodItem, int index, BuildContext context) {
    return FadeAnimation(
      delay: 0.05 * index,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        elevation: 2,
        child: InkWell(
          onTap: () => _navigateToEditFood(foodItem),
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food Image and Status
              Stack(
                children: [
                  _buildFoodImage(foodItem),

                  // Availability Badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: StatusBadge(
                      text: foodItem.available ? 'Available' : 'Unavailable',
                      color: foodItem.available ? Colors.green : Colors.red,
                    ),
                  ),

                  // Category Badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: FutureBuilder<Category?>(
                      future: _getCategoryById(foodItem.categoryId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            snapshot.data!.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              // Food Details
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            foodItem.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          NumberFormatter.formatCurrency(foodItem.price),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Description
                    Text(
                      foodItem.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Preparation Time and Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Preparation Time
                        Row(
                          children: [
                            const Icon(
                              Icons.timer,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${foodItem.preparationTime} min',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        // Action Buttons
                        Row(
                          children: [
                            // Toggle Availability
                            IconButton(
                              icon: Icon(
                                foodItem.available ? Icons.visibility : Icons.visibility_off,
                                color: foodItem.available ? Colors.green : Colors.grey,
                              ),
                              onPressed: () => _toggleAvailability(foodItem),
                              tooltip: foodItem.available ? 'Mark as Unavailable' : 'Mark as Available',
                            ),

                            // Edit
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blue,
                              ),
                              onPressed: () => _navigateToEditFood(foodItem),
                              tooltip: 'Edit Food Item',
                            ),

                            // Delete
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () => _deleteFood(foodItem),
                              tooltip: 'Delete Food Item',
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildFoodImage(FoodItem foodItem) {
    if (foodItem.imageUrl.isEmpty) {
      return Container(
        height: 150,
        width: double.infinity,
        color: Colors.grey[300],
        child: const Icon(
          Icons.restaurant,
          size: 50,
          color: Colors.grey,
        ),
      );
    }

    return SizedBox(
      height: 150,
      width: double.infinity,
      child: Image.network(
        foodItem.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 150,
            width: double.infinity,
            color: Colors.grey[300],
            child: const Icon(
              Icons.restaurant,
              size: 50,
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }

  void _showFilterOptions() {
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
                title: const Text('Show All Items'),
                leading: const Icon(Icons.all_inclusive),
                onTap: () {
                  Navigator.pop(context);
                  _selectCategory(null);
                },
              ),
              ListTile(
                title: const Text('Available Items Only'),
                leading: const Icon(Icons.visibility, color: Colors.green),
                onTap: () {
                  Navigator.pop(context);
                  // Implement filter by availability
                },
              ),
              ListTile(
                title: const Text('Unavailable Items Only'),
                leading: const Icon(Icons.visibility_off, color: Colors.grey),
                onTap: () {
                  Navigator.pop(context);
                  // Implement filter by unavailability
                },
              ),
              const Divider(),
              // Filter by preparation time
              ListTile(
                title: const Text('Quick Preparation (< 10 min)'),
                leading: const Icon(Icons.timer, color: Colors.green),
                onTap: () {
                  Navigator.pop(context);
                  // Implement filter by preparation time
                },
              ),
              ListTile(
                title: const Text('Medium Preparation (10-20 min)'),
                leading: const Icon(Icons.timer, color: Colors.orange),
                onTap: () {
                  Navigator.pop(context);
                  // Implement filter by preparation time
                },
              ),
              ListTile(
                title: const Text('Long Preparation (> 20 min)'),
                leading: const Icon(Icons.timer, color: Colors.red),
                onTap: () {
                  Navigator.pop(context);
                  // Implement filter by preparation time
                },
              ),
            ],
          ),
        );
      },
    );
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
                title: const Text('Sort by Name (A-Z)'),
                leading: const Icon(Icons.sort_by_alpha),
                onTap: () {
                  Navigator.pop(context);
                  // Implement sorting by name
                },
              ),
              ListTile(
                title: const Text('Sort by Name (Z-A)'),
                leading: const Icon(Icons.sort_by_alpha),
                onTap: () {
                  Navigator.pop(context);
                  // Implement sorting by name descending
                },
              ),
              ListTile(
                title: const Text('Sort by Price (Low to High)'),
                leading: const Icon(Icons.attach_money),
                onTap: () {
                  Navigator.pop(context);
                  // Implement sorting by price ascending
                },
              ),
              ListTile(
                title: const Text('Sort by Price (High to Low)'),
                leading: const Icon(Icons.attach_money),
                onTap: () {
                  Navigator.pop(context);
                  // Implement sorting by price descending
                },
              ),
              ListTile(
                title: const Text('Sort by Preparation Time'),
                leading: const Icon(Icons.timer),
                onTap: () {
                  Navigator.pop(context);
                  // Implement sorting by preparation time
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Category?> _getCategoryById(String categoryId) async {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    return categoryProvider.getCategoryById(categoryId);
  }
}