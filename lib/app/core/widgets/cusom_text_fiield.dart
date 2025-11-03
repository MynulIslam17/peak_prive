import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';


class CustomTextField extends StatefulWidget {
  final String hintText;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.controller,
    this.isPassword = false,
    this.keyboardType,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      style: TextStyle(fontSize: 14.sp, color: AppColors.black_3),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.black_3),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: AppColors.primary_1, size: 20.r)
            : null,
        suffixIcon: widget.isPassword
            ? GestureDetector(
          onTap: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          child: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: AppColors.primary_1,
            size: 20.r,
          ),
        )
            : null,
        contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 10.w),
        fillColor: Colors.grey.shade100,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: AppColors.primary_1, width: 1.5),
        ),
      ),
    );
  }
}
