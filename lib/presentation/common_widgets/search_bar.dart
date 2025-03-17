// presentation/common_widgets/search_bar.dart
import 'package:flutter/material.dart';
import 'package:foodkie/core/theme/app_theme.dart';

class CustomSearchBar extends StatefulWidget {
  final String hintText;
  final Function(String) onSearch;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final bool autofocus;
  final bool showBorder;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? margin;
  final Widget? prefix;
  final double height;

  const CustomSearchBar({
    Key? key,
    this.hintText = 'Search...',
    required this.onSearch,
    this.onClear,
    this.controller,
    this.autofocus = false,
    this.showBorder = true,
    this.backgroundColor,
    this.margin,
    this.prefix,
    this.height = 48.0,
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _showClearButton = _controller.text.isNotEmpty;
    });
    widget.onSearch(_controller.text);
  }

  void _clearSearch() {
    _controller.clear();
    if (widget.onClear != null) {
      widget.onClear!();
    } else {
      widget.onSearch('');
    }
    setState(() {
      _showClearButton = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: widget.showBorder
            ? Border.all(color: Colors.grey.shade300)
            : null,
        boxShadow: widget.showBorder
            ? null
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          prefixIcon: widget.prefix ?? const Icon(Icons.search, color: AppTheme.lightSubtextColor),
          suffixIcon: _showClearButton
              ? IconButton(
            icon: const Icon(Icons.clear, color: AppTheme.lightSubtextColor),
            onPressed: _clearSearch,
          )
              : null,
        ),
        onSubmitted: widget.onSearch,
      ),
    );
  }
}