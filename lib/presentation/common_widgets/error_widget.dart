// presentation/common_widgets/error_widget.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:foodkie/core/constants/assets_constants.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool useLottie;
  final double size;

  const ErrorDisplayWidget({
    Key? key,
    required this.message,
    this.onRetry,
    this.useLottie = true,
    this.size = 150,
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
                AssetsConstants.errorAnimationPath,
                width: size,
                height: size,
              ),
            ] else ...[
              // Error Icon
              Icon(
                Icons.error_outline,
                size: size * 0.5,
                color: AppTheme.errorColor,
              ),
            ],

            const SizedBox(height: 16),

            // Error Message
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),

            // Retry Button
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: 'Retry',
                onPressed: onRetry!,
                icon: Icons.refresh,
                width: 120,
              ),
            ],
          ],
        ),
      ),
    );
  }
}