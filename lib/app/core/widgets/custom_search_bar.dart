import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onClear;
  final ValueChanged<String>? onChanged;

  /// Optional styling
  final Color? filledColor;          // Background of the search bar
  final Color? borderColor;          // Normal border color
  final Color? focusColor;           // Focus border & cursor color
  final double borderRadius;         // Rounded corner radius
  final double elevation;            // Shadow strength

  const CustomSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search...',
    this.onClear,
    this.onChanged,
    this.filledColor,
    this.borderColor,
    this.focusColor,
    this.borderRadius = 16,
    this.elevation = 4,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? Colors.grey.shade300;
    final effectiveFocusColor = focusColor ?? Colors.transparent;

    return Material(
      elevation: elevation,
      shadowColor: Colors.black.withOpacity(0.1),
      borderRadius: BorderRadius.circular(borderRadius),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        cursorColor: effectiveFocusColor, // Optional cursor color
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: filledColor ?? Colors.white,

          // Prefix search icon
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.search_rounded,
              color: Colors.grey.shade600,
              size: 26,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 35),

          // Suffix clear button
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear_rounded,
                color: Colors.grey.shade500, size: 20),
            onPressed: onClear,
          )
              : null,

          contentPadding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 12),

          // Border when enabled (not focused)
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: effectiveBorderColor, width: 1),
          ),

          // Border when focused
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: effectiveFocusColor, width: 1.5),
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: effectiveFocusColor, width: 1.5),
          ),
        ),
      ),
    );
  }
}
