// presentation/common_widgets/category_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:foodkie/core/animations/fade_animation.dart';
import 'package:foodkie/data/models/category_model.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool showImage;

  const CategoryCard({
    Key? key,
    required this.category,
    this.onTap,
    this.isSelected = false,
    this.showImage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      delay: 0.2,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showImage) ...[
                // Category Image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: _buildCategoryImage(),
                ),
              ],

              // Category Name
              Padding(
                padding: EdgeInsets.all(showImage ? 8 : 16),
                child: Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryImage() {
    if (category.imageUrl.isEmpty) {
      return Container(
        height: 100,
        width: double.infinity,
        color: Colors.grey[300],
        child: const Icon(
          Icons.category,
          color: Colors.grey,
          size: 40,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: category.imageUrl,
      height: 100,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: 100,
        width: double.infinity,
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: 100,
        width: double.infinity,
        color: Colors.grey[300],
        child: const Icon(
          Icons.category,
          color: Colors.grey,
          size: 40,
        ),
      ),
    );
  }
}