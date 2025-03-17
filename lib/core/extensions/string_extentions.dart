// core/extensions/string_extensions.dart
extension StringExtensions on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }

  String capitalizeEachWord() {
    if (this.isEmpty) return this;
    return this.split(' ').map((word) => word.capitalize()).join(' ');
  }

  bool isValidEmail() {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  bool isValidUrl() {
    return RegExp(r'^(http|https)://[a-zA-Z0-9-\.]+\.[a-zA-Z]{2,}(/\S*)?$').hasMatch(this);
  }

  bool isNumeric() {
    return RegExp(r'^-?[0-9]+$').hasMatch(this);
  }

  bool isDouble() {
    return double.tryParse(this) != null;
  }

  String truncate(int maxLength) {
    if (this.length <= maxLength) return this;
    return '${this.substring(0, maxLength)}...';
  }

  String removeAllWhitespace() {
    return this.replaceAll(RegExp(r'\s+'), '');
  }

  String toSlug() {
    return this
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');
  }
}