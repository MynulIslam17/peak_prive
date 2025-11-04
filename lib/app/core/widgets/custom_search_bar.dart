import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onClear;
  final ValueChanged<String>? onChanged;
  final Color ? filledColor;

  const CustomSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search...',
    this.onClear,
    this.onChanged,
     this.filledColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor:filledColor ?? Colors.white,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),

        // Prefix Icon
        prefixIcon: const Padding(
          padding: EdgeInsets.all(10.0),
          child: Icon(Icons.search, size: 30, color: Colors.grey),
        ),

        // Suffix Icon (clear)
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear, size: 20, color: Colors.grey),
          onPressed: onClear,
        )
            : null,

        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
