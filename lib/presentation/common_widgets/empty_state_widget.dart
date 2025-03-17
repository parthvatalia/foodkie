// presentation/common_widgets/empty_state_widget.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:foodkie/core/constants/assets_constants.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool useLottie;
  final double size;
  final IconData? icon;

  const EmptyStateWidget({
    Key? key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.useLottie = true,
    this.size = 150,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (useLottie) ...[
              // Lottie Animation
              Lottie.asset(
                AssetsConstants.emptyAnimationPath,
                width: size,
                height: size,
              ),
            ] else if (icon != null) ...[
              // Custom Icon
              Icon(
                icon,
                size: size * 0.5,
                color: Colors.grey,
              ),
            ] else ...[
              // Default Empty Icon
              Icon(
                Icons.inbox_outlined,
                size: size * 0.5,
                color: Colors.grey,
              ),
            ],

            const SizedBox(height: 16),

            // Empty Message
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightSubtextColor,
              ),
              textAlign: TextAlign.center,
            ),

            // Action Button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: actionLabel!,
                onPressed: onAction!,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}