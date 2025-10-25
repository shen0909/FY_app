import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../styles/colors.dart';
import '../styles/text_styles.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String prefixIconPath;
  final Widget? suffixIcon;
  final bool obscureText;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIconPath,
    this.suffixIcon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.w),
        border: Border.all(color: const Color(0xFFE6E6E6), width: 1),
      ),
      child: Row(
        children: [
          SizedBox(width: 16.w),
          Image.asset(prefixIconPath, width: 24.w, height: 24.w,fit: BoxFit.contain,),
          SizedBox(width: 16.w),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              style: FYTextStyles.inputStyle(color: FYColors.color_1A1A1A),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: FYTextStyles.hintStyle(color: FYColors.color_A6A6A6),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (suffixIcon != null) suffixIcon!
        ],
      ),
    );
  }
}