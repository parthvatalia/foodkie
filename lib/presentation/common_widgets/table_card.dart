// presentation/common_widgets/table_card.dart
import 'package:flutter/material.dart';
import 'package:foodkie/core/animations/fade_animation.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/data/models/table_model.dart';
import 'package:foodkie/presentation/common_widgets/status_badge.dart';

class TableCard extends StatelessWidget {
  final TableModel table;
  final VoidCallback? onTap;
  final bool isSelected;

  const TableCard({
    Key? key,
    required this.table,
    this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      delay: 0.2,
      child: GestureDetector(
        onTap: table.status != TableStatus.available && !isSelected ? null : onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : (table.status != TableStatus.available
                ? Colors.grey.withOpacity(0.1)
                : Theme.of(context).cardTheme.color),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Table Icon
              Icon(
                Icons.table_restaurant,
                size: 40,
                color: _getTableIconColor(),
              ),

              const SizedBox(height: 8),

              // Table Number
              Text(
                'Table ${table.number}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),

              const SizedBox(height: 4),

              // Capacity
              Text(
                '${table.capacity} ${table.capacity > 1 ? 'Seats' : 'Seat'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 8),

              // Status Badge
              StatusBadge(
                text: _getStatusText(),
                color: _getStatusColor(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText() {
    switch (table.status) {
      case TableStatus.available:
        return 'Available';
      case TableStatus.occupied:
        return 'Occupied';
      case TableStatus.reserved:
        return 'Reserved';
    }
  }

  Color _getStatusColor() {
    switch (table.status) {
      case TableStatus.available:
        return AppTheme.successColor;
      case TableStatus.occupied:
        return AppTheme.errorColor;
      case TableStatus.reserved:
        return AppTheme.warningColor;
    }
  }

  Color _getTableIconColor() {
    if (isSelected) {
      return AppTheme.primaryColor;
    }

    switch (table.status) {
      case TableStatus.available:
        return AppTheme.successColor;
      case TableStatus.occupied:
        return AppTheme.errorColor;
      case TableStatus.reserved:
        return AppTheme.warningColor;
    }
  }
}