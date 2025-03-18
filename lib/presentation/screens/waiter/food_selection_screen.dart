// presentation/screens/waiter/food_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/animations/fade_animation.dart';
import 'package:foodkie/core/constants/route_constants.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/data/models/category_model.dart';
import 'package:foodkie/data/models/food_item_model.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';
import 'package:foodkie/presentation/common_widgets/category_card.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';
import 'package:foodkie/presentation/common_widgets/empty_state_widget.dart';
import 'package:foodkie/presentation/common_widgets/food_item_card.dart';
import 'package:foodkie/presentation/common_widgets/loading_widget.dart';
import 'package:foodkie/presentation/common_widgets/search_bar.dart';
import 'package:foodkie/presentation/providers/category_provider.dart';
import 'package:foodkie/presentation/providers/food_item_provider.dart';
import 'package:foodkie/presentation/providers/order_provider.dart';

class FoodSelectionScreen extends StatefulWidget {
  const FoodSelectionScreen({Key? key}) : super(key: key);

  @override
  State<FoodSelectionScreen> createState() => _FoodSelectionScreenState();
}

class _FoodSelectionScreenState extends State<FoodSelectionScreen> {
  bool _isLoading = true;
  bool _isCategoriesLoading = true;
  bool _isFoodItemsLoading = true;
  List<Category> _categories = [];
  List<FoodItem> _foodItems = [];
  Category? _selectedCategory;
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _loadCategories();
    _loadFoodItems();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isCategoriesLoading = true;
    });

    try {
      final categoryProvider = Provider.of<CategoryProvider>(
        context,
        listen: false,
      );

      categoryProvider.getCategoriesStream()?.listen(
        (categories) {
          if (mounted) {
            setState(() {
              _categories = categories;
              _selectedCategory = categories.isNotEmpty ? categories[0] : null;
              _isCategoriesLoading = false;
              _checkLoading();
            });

            if (_selectedCategory != null) {
              _loadFoodItemsByCategory(_selectedCategory!.id);
            }
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _isCategoriesLoading = false;
              _checkLoading();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading categories: $error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCategoriesLoading = false;
          _checkLoading();
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

  Future<void> _loadFoodItems() async {
    setState(() {
      _isFoodItemsLoading = true;
    });

    try {
      final foodItemProvider = Provider.of<FoodItemProvider>(
        context,
        listen: false,
      );

      foodItemProvider.getAvailableFoodItemsStream()?.listen(
        (foodItems) {
          if (mounted) {
            setState(() {
              _foodItems = foodItems;
              _isFoodItemsLoading = false;
              _checkLoading();
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _isFoodItemsLoading = false;
              _checkLoading();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading food items: $error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFoodItemsLoading = false;
          _checkLoading();
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

  Future<void> _loadFoodItemsByCategory(String categoryId) async {
    setState(() {
      _isFoodItemsLoading = true;
    });

    try {
      final foodItemProvider = Provider.of<FoodItemProvider>(
        context,
        listen: false,
      );

      foodItemProvider
          .getFoodItemsByCategoryStream(categoryId)
          ?.listen(
            (foodItems) {
              if (mounted) {
                setState(() {
                  _foodItems =
                      foodItems.where((item) => item.available).toList();
                  _isFoodItemsLoading = false;
                  _checkLoading();
                });
              }
            },
            onError: (error) {
              if (mounted) {
                setState(() {
                  _isFoodItemsLoading = false;
                  _checkLoading();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error loading food items: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFoodItemsLoading = false;
          _checkLoading();
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

  void _checkLoading() {
    setState(() {
      _isLoading = _isCategoriesLoading || _isFoodItemsLoading;
    });
  }

  void _selectCategory(Category category) {
    if (_selectedCategory?.id != category.id) {
      setState(() {
        _selectedCategory = category;
      });
      _loadFoodItemsByCategory(category.id);
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });
  }

  void _addToCart(FoodItem foodItem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddToCartBottomSheet(foodItem: foodItem),
    );
  }

  List<FoodItem> get _filteredFoodItems {
    if (_isSearching) {
      return _foodItems
          .where(
            (item) =>
                item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                item.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    return _foodItems;
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final hasItemsInCart = orderProvider.hasItemsInCart;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Select Food Items',
        showBackButton: true,
        actions: [
          if (hasItemsInCart)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      RouteConstants.waiterOrderCart,
                    );
                  },
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
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
              hintText: 'Search food items...',
              onSearch: _handleSearch,
              onClear: () {
                setState(() {
                  _searchQuery = '';
                  _isSearching = false;
                });
              },
            ),
          ),

          // Categories Horizontal List
          if (!_isSearching) ...[
            Container(
              height: 120,
              margin: const EdgeInsets.only(bottom: 16),
              child:
                  _isCategoriesLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _categories.isEmpty
                      ? const Center(child: Text('No categories available'))
                      : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          return FadeAnimation(
                            delay: 0.05 * (index + 1),
                            child: SizedBox(
                              width: 120,
                              child: CategoryCard(
                                category: category,
                                isSelected:
                                    _selectedCategory?.id == category.id,
                                onTap: () => _selectCategory(category),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],

          // Food Items Grid
          Expanded(
            child:
                _isFoodItemsLoading && !_isSearching
                    ? const Center(child: LoadingWidget())
                    : _filteredFoodItems.isEmpty
                    ? Center(
                      child: EmptyStateWidget(
                        message:
                            _isSearching
                                ? 'No food items match your search'
                                : 'No food items available in this category',
                        icon: Icons.no_food,
                        actionLabel: _isSearching ? 'Clear Search' : 'Refresh',
                        onAction:
                            _isSearching
                                ? () {
                                  setState(() {
                                    _searchQuery = '';
                                    _isSearching = false;
                                  });
                                }
                                : _loadData,
                      ),
                    )
                    : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemCount: _filteredFoodItems.length,
                      itemBuilder: (context, index) {
                        final foodItem = _filteredFoodItems[index];
                        return FadeAnimation(
                          delay: 0.05 * (index + 1),
                          child: FoodItemCard(
                            foodItem: foodItem,
                            onTap: () => _addToCart(foodItem),
                            onAddToOrder: () => _addToCart(foodItem),
                          ),
                        );
                      },
                    ),
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
              child: CustomButton(
                text: 'View Cart (${orderProvider.cart.length} items)',
                onPressed: () {
                  Navigator.pushNamed(context, RouteConstants.waiterOrderCart);
                },
                width: double.infinity,
                icon: Icons.shopping_cart,
              ),
            ),
        ],
      ),
    );
  }
}

class AddToCartBottomSheet extends StatefulWidget {
  final FoodItem foodItem;

  const AddToCartBottomSheet({Key? key, required this.foodItem})
    : super(key: key);

  @override
  State<AddToCartBottomSheet> createState() => _AddToCartBottomSheetState();
}

class _AddToCartBottomSheetState extends State<AddToCartBottomSheet> {
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                  child:
                      widget.foodItem.imageUrl.isNotEmpty
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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
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
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
            CustomButton(
              text: 'Add to Cart',
              onPressed: _addToCart,
              width: double.infinity,
              color: AppTheme.primaryColor,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
