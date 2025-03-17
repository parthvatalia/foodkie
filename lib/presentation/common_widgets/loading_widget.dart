// presentation/common_widgets/loading_widget.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:foodkie/core/constants/assets_constants.dart';
import 'package:foodkie/core/theme/app_theme.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool useLottie;
  final double size;

  const LoadingWidget({
    Key? key,
    this.message,
    this.useLottie = true,
    this.size = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (useLottie) ...[
            // Lottie Animation
            Lottie.asset(
              AssetsConstants.loadingAnimationPath,
              width: size,
              height: size,
            ),
          ] else ...[
            // Circular Progress Indicator
            SizedBox(
              width: size * 0.5,
              height: size * 0.5,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                strokeWidth: 3,
              ),
            ),
          ],

          // Message
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}