// core/extensions/context_extensions.dart
import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  // Screen size utilities
  double get screenHeight => MediaQuery.of(this).size.height;
  double get screenWidth => MediaQuery.of(this).size.width;

  // Responsive sizing
  double get height => screenHeight;
  double get width => screenWidth;
  double heightPercentage(double percentage) => screenHeight * percentage / 100;
  double widthPercentage(double percentage) => screenWidth * percentage / 100;

  // Check screen size
  bool get isSmallScreen => screenWidth < 600;
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 900;
  bool get isLargeScreen => screenWidth >= 900;

  // Theme extensions
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // Common theme colors
  Color get primaryColor => Theme.of(this).primaryColor;
  Color get scaffoldBackgroundColor => Theme.of(this).scaffoldBackgroundColor;
  Color get cardColor => Theme.of(this).cardColor;
  Color get errorColor => Theme.of(this).colorScheme.error;

  // Text Styles
  TextStyle? get headlineStyle => textTheme.displayLarge;
  TextStyle? get titleStyle => textTheme.displayMedium;
  TextStyle? get bodyStyle => textTheme.bodyLarge;
  TextStyle? get subtitleStyle => textTheme.bodyMedium;

  // Navigation helpers
  void push(Widget page) {
    Navigator.push(this, MaterialPageRoute(builder: (_) => page));
  }

  void pushReplacement(Widget page) {
    Navigator.pushReplacement(this, MaterialPageRoute(builder: (_) => page));
  }

  void pushAndRemoveUntil(Widget page) {
    Navigator.pushAndRemoveUntil(
      this,
      MaterialPageRoute(builder: (_) => page),
          (route) => false,
    );
  }

  void pop<T>([T? result]) {
    Navigator.pop(this, result);
  }

  // Dialog helpers
  Future<T?> showCustomDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: child,
      ),
    );
  }

  // Bottom Sheet helpers
  Future<T?> showCustomBottomSheet<T>({
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
  }) {
    return showModalBottomSheet<T>(
      context: this,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape ?? const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => child,
    );
  }

  // Snackbar helpers
  void showSnackBar({
    required String message,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }

  void showErrorSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    showSnackBar(
      message: message,
      backgroundColor: errorColor,
      duration: duration,
    );
  }

  void showSuccessSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.green,
      duration: duration,
    );
  }
}