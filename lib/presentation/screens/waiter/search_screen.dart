// presentation/screens/waiter/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/animations/fade_animation.dart';
import 'package:foodkie/core/constants/route_constants.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/data/models/category_model.dart';
import 'package:foodkie/data/models/food_item_model.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';
import 'package:foodkie/presentation/common_widgets/category_card.dart';
import 'package:foodkie/presentation/common_widgets/empty_state_widget.dart';
import 'package:foodkie/presentation/common_widgets/food_item_card.dart';
import 'package:foodkie/presentation/common_widgets/loading_widget.dart';
import 'package:foodkie/presentation/common_widgets/search_bar.dart';
import 'package:foodkie/presentation/providers/category_provider.dart';
import 'package:foodkie/presentation/providers/food_item_provider.dart';
import 'package:foodkie/presentation/providers/order_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _isLoading = false;
  String _searchQuery = '';
  List<FoodItem> _foodResults = [];
  List<Category> _categoryResults = [];
  bool _hasSearched = false;

  // For initial screen
  List<Category> _popularCategories = [];
  List<FoodItem> _popularItems = [];
  bool _loadingInitialData = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _loadingInitialData = true;
    });

    try {
      // Load popular categories (assuming top 4 categories for now)
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
      final foodItemProvider = Provider.of<FoodItemProvider>(context, listen: false);

      // Get categories asynchronously
      final categoriesFuture = categoryProvider.getAllCategoriesFuture();

      // Get food items asynchronously
      final foodItemsFuture = foodItemProvider.getAllFoodItemsFuture();

      // Wait for both futures to complete
      final results = await Future.wait([categoriesFuture, foodItemsFuture]);

      // Extract results
      final categories = results[0] as List<Category>;
      final foodItems = results[1] as List<FoodItem>;

      setState(() {
        // Take first 4 categories or less if fewer are available
        _popularCategories = categories.take(4).toList();

        // Take available food items (up to 6) and sort them by name
        _popularItems = foodItems
            .where((item) => item.available)
            .take(6)
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        _loadingInitialData = false;
      });
    } catch (e) {
      setState(() {
        _loadingInitialData = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _foodResults = [];
        _categoryResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchQuery = query;
      _hasSearched = true;
    });

    try {
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
      final foodItemProvider = Provider.of<FoodItemProvider>(context, listen: false);

      // Search categories
      final categoryResults = await categoryProvider.searchCategories(query);

      // Search food items
      final foodResults = await foodItemProvider.searchFoodItems(query);

      // Only include available food items
      final availableFoodItems = foodResults.where((item) => item.available).toList();

      setState(() {
        _categoryResults = categoryResults;
        _foodResults = availableFoodItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleAddToCart(FoodItem foodItem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddToCartBottomSheet(foodItem: foodItem),
    );
  }

  void _navigateToCategory(Category category) {
    // Navigate to food selection with the selected category
    final foodItemProvider = Provider.of<FoodItemProvider>(context, listen: false);

    // Set the selected category
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    categoryProvider.selectCategory(category);

    // Navigate to food selection screen
    Navigator.pushNamed(context, RouteConstants.waiterFoodSelection);
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final hasItemsInCart = orderProvider.hasItemsInCart;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Search Menu',
        showBackButton: true,
        actions: [
          if (hasItemsInCart)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.pushNamed(context, RouteConstants.waiterOrderCart);
                  },
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${orderProvider.cart.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSearchBar(
              hintText: 'Search for food items or categories...',
              onSearch: _performSearch,
              autofocus: true,
            ),
          ),

          // Results or Initial Content
          Expanded(
            child: _isLoading
                ? const Center(child: LoadingWidget())
                : _hasSearched
                ? _buildSearchResults()
                : _loadingInitialData
                ? const Center(child: LoadingWidget())
                : _buildInitialContent(),
          ),

          // Bottom Cart Button
          if (hasItemsInCart)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, RouteConstants.waiterOrderCart);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_cart, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'View Cart (${orderProvider.cart.length} items)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_categoryResults.isEmpty && _foodResults.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          message: 'No results found for "$_searchQuery"',
          icon: Icons.search_off,
          actionLabel: 'Clear Search',
          onAction: () {
            setState(() {
              _searchQuery = '';
              _hasSearched = false;
              _foodResults = [];
              _categoryResults = [];
            });
          },
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories Section
          if (_categoryResults.isNotEmpty) ...[
            Text(
              'Categories',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _categoryResults.length,
              itemBuilder: (context, index) {
                final category = _categoryResults[index];
                return FadeAnimation(
                  delay: 0.05 * (index + 1),
                  child: CategoryCard(
                    category: category,
                    onTap: () => _navigateToCategory(category),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],

          // Food Items Section
          if (_foodResults.isNotEmpty) ...[
            Text(
              'Food Items',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _foodResults.length,
              itemBuilder: (context, index) {
                final foodItem = _foodResults[index];
                return FadeAnimation(
                  delay: 0.05 * (index + 1),
                  child: FoodItemCard(
                    foodItem: foodItem,
                    onTap: () => _handleAddToCart(foodItem),
                    onAddToOrder: () => _handleAddToCart(foodItem),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInitialContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Popular Categories Section
          Text(
            'Popular Categories',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _popularCategories.isEmpty
              ? const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No categories available'),
            ),
          )
              : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _popularCategories.length,
            itemBuilder: (context, index) {
              final category = _popularCategories[index];
              return FadeAnimation(
                delay: 0.05 * (index + 1),
                child: CategoryCard(
                  category: category,
                  onTap: () => _navigateToCategory(category),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Popular Items Section
          Text(
            'Popular Items',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _popularItems.isEmpty
              ? const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No items available'),
            ),
          )
              : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _popularItems.length,
            itemBuilder: (context, index) {
              final foodItem = _popularItems[index];
              return FadeAnimation(
                delay: 0.05 * (index + 1),
                child: FoodItemCard(
                  foodItem: foodItem,
                  onTap: () => _handleAddToCart(foodItem),
                  onAddToOrder: () => _handleAddToCart(foodItem),
                ),
              );
            },
          ),

          // Search tips
          const SizedBox(height: 32),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Search Tips',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('• Search by food name (e.g., "Burger", "Pizza")'),
                  const SizedBox(height: 4),
                  const Text('• Search by category (e.g., "Appetizers", "Desserts")'),
                  const SizedBox(height: 4),
                  const Text('• Search by ingredients (e.g., "Chicken", "Cheese")'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddToCartBottomSheet extends StatefulWidget {
  final FoodItem foodItem;

  const _AddToCartBottomSheet({
    Key? key,
    required this.foodItem,
  }) : super(key: key);

  @override
  State<_AddToCartBottomSheet> createState() => _AddToCartBottomSheetState();
}

class _AddToCartBottomSheetState extends State<_AddToCartBottomSheet> {
  int _quantity = 1;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _addToCart() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    orderProvider.addToCart(
      widget.foodItem,
      _quantity,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.foodItem.name} added to cart'),
        action: SnackBarAction(
          label: 'VIEW CART',
          onPressed: () {
            Navigator.pushNamed(context, RouteConstants.waiterOrderCart);
          },
        ),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add to Order',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Food Item Details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Food Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: widget.foodItem.imageUrl.isNotEmpty
                      ? Image.network(
                    widget.foodItem.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.restaurant,
                      size: 32,
                      color: Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Food Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.foodItem.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.foodItem.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${widget.foodItem.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quantity Selector
            Text(
              'Quantity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Decrement Button
                InkWell(
                  onTap: _decrementQuantity,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.remove),
                  ),
                ),

                // Quantity Display
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _quantity.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Increment Button
                InkWell(
                  onTap: _incrementQuantity,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Notes Field
            Text(
              'Special Instructions (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'E.g., No onions, extra spicy, etc.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}