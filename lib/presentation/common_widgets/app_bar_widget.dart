// presentation/common_widgets/app_bar_widget.dart
import 'package:flutter/material.dart';
import 'package:foodkie/core/theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? leadingIcon;
  final bool centerTitle;
  final Color? backgroundColor;
  final double elevation;
  final PreferredSizeWidget? bottom;
  final double height;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.leadingIcon,
    this.centerTitle = true,
    this.backgroundColor,
    this.elevation = 0,
    this.bottom,
    this.height = kToolbarHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: _shouldUseDarkForeground(backgroundColor ?? AppTheme.primaryColor)
              ? Colors.white
              : Colors.black,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppTheme.primaryColor,
      elevation: elevation,
      actions: actions,

      leading: showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        color: _shouldUseDarkForeground(backgroundColor ?? AppTheme.primaryColor)
            ? Colors.white
            : Colors.black,
      )
          : leadingIcon,
      automaticallyImplyLeading: showBackButton,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height + (bottom?.preferredSize.height ?? 0.0));

  // Helper function to determine if we should use dark foreground (white text/icons)
  // based on the background color brightness
  bool _shouldUseDarkForeground(Color backgroundColor) {
    return ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark;
  }
}