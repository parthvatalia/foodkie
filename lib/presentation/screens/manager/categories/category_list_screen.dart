// presentation/screens/manager/categories/category_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/constants/route_constants.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/animations/slide_animation.dart';
import 'package:foodkie/data/models/category_model.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';
import 'package:foodkie/presentation/common_widgets/custom_drawer.dart';
import 'package:foodkie/presentation/common_widgets/empty_state_widget.dart';
import 'package:foodkie/presentation/common_widgets/error_widget.dart';
import 'package:foodkie/presentation/common_widgets/loading_widget.dart';
import 'package:foodkie/presentation/common_widgets/confirmation_dialog.dart';
import 'package:foodkie/presentation/common_widgets/search_bar.dart';
import 'package:foodkie/presentation/providers/auth_provider.dart';
import 'package:foodkie/presentation/providers/category_provider.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({Key? key}) : super(key: key);

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  late Stream<List<Category>> _categoriesStream;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initCategoriesStream();
  }

  void _initCategoriesStream() {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    _categoriesStream = categoryProvider.getCategoriesStream() ?? Stream.value([]);
  }

  void _searchCategories(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _navigateToAddCategory() {
    Navigator.pushNamed(context, RouteConstants.managerCategoryAdd);
  }

  void _navigateToEditCategory(Category category) {
    Navigator.pushNamed(
      context,
      RouteConstants.managerCategoryEdit,
      arguments: category,
    );
  }

  Future<void> _deleteCategory(Category category) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Category',
      message: 'Are you sure you want to delete "${category.name}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDestructive: true,
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      onConfirm: () async {
        final provider = Provider.of<CategoryProvider>(context, listen: false);
        await provider.deleteCategory(category.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category deleted successfully')),
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
        title: StringConstants.categories,
        showBackButton: true,
        actions: [
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
        selectedIndex: 1, // Categories index
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
            hintText: 'Search categories...',
            onSearch: _searchCategories,
          ),

          // Category List
          Expanded(
            child: StreamBuilder<List<Category>>(
              stream: _categoriesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget(message: 'Loading categories...');
                }

                if (snapshot.hasError) {
                  return ErrorDisplayWidget(
                    message: 'Error loading categories: ${snapshot.error}',
                    onRetry: () => _initCategoriesStream(),
                  );
                }

                final categories = snapshot.data ?? [];

                if (categories.isEmpty) {
                  return EmptyStateWidget(
                    message: 'No categories found',
                    actionLabel: StringConstants.addCategory,
                    onAction: _navigateToAddCategory,
                  );
                }

                // Filter categories based on search
                final filteredCategories = _searchQuery.isEmpty
                    ? categories
                    : categories.where((category) =>
                category.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    category.description.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

                if (filteredCategories.isEmpty) {
                  return EmptyStateWidget(
                    message: 'No categories match your search',
                    actionLabel: 'Clear Search',
                    onAction: () => _searchCategories(''),
                  );
                }

                return ReorderableListView.builder(
                  itemCount: filteredCategories.length,
                  onReorder: (oldIndex, newIndex) {
                    // Implement category reordering
                    _reorderCategories(filteredCategories, oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    return _buildCategoryListItem(
                      category,
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
        onPressed: _navigateToAddCategory,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryListItem(Category category, int index, BuildContext context) {
    return SlideAnimation(
      key: ValueKey(category.id),
      position: index,
      itemCount: index + 1,
      direction: SlideDirection.fromBottom,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        child: ListTile(
          leading: _buildCategoryImage(category),
          title: Text(
            category.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            category.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Order: ${category.order}'),
              const SizedBox(width: 8),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _navigateToEditCategory(category);
                  } else if (value == 'delete') {
                    _deleteCategory(category);
                  }
                },
              ),
            ],
          ),
          onTap: () => _navigateToEditCategory(category),
        ),
      ),
    );
  }

  Widget _buildCategoryImage(Category category) {
    if (category.imageUrl.isEmpty) {
      return const CircleAvatar(
        backgroundColor: Colors.grey,
        child: Icon(Icons.category, color: Colors.white),
      );
    }
   bool _hasImageLoadError = false;
    return CircleAvatar(
      backgroundColor: Colors.grey,
      backgroundImage: NetworkImage(category.imageUrl),
      onBackgroundImageError: (exception, stackTrace) {
        // Use setState or a state management solution to handle the error
        setState(() {
          // Update your state to show a fallback
          _hasImageLoadError = true;
        });
      },
      child: _hasImageLoadError
          ? Icon(Icons.category, color: Colors.white)
          : null,
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
                title: const Text('Sort by Order (Ascending)'),
                leading: const Icon(Icons.sort),
                onTap: () {
                  Navigator.pop(context);
                  // Implement sorting by order ascending
                },
              ),
              ListTile(
                title: const Text('Sort by Order (Descending)'),
                leading: const Icon(Icons.sort),
                onTap: () {
                  Navigator.pop(context);
                  // Implement sorting by order descending
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _reorderCategories(List<Category> categories, int oldIndex, int newIndex) async {
    // Adjust the newIndex if it's after removal
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    // Create a copy of the list
    final List<Category> updatedCategories = List.from(categories);

    // Remove item at oldIndex and insert at newIndex
    final item = updatedCategories.removeAt(oldIndex);
    updatedCategories.insert(newIndex, item);

    // Update order values
    for (int i = 0; i < updatedCategories.length; i++) {
      updatedCategories[i] = updatedCategories[i].copyWith(order: i + 1);
    }

    // Save the updated order
    final provider = Provider.of<CategoryProvider>(context, listen: false);
    try {
      await provider.reorderCategories(updatedCategories);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categories reordered successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reorder categories: $e')),
      );
    }
  }
}