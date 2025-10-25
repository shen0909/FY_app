import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';

class FYAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final Color backgroundColor;
  final Color titleColor;
  final double fontSize;
  final FontWeight fontWeight;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final double? titleSpacing;
  final double elevation;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  const FYAppBar({
    Key? key,
    required this.title,
    this.centerTitle = true,
    this.backgroundColor = Colors.white,
    this.titleColor = const Color(0xFF101148),
    this.fontSize = 16,
    this.fontWeight = FontWeight.w500,
    this.onBackPressed,
    this.actions,
    this.titleSpacing,
    this.elevation = 0,
    this.leading,
    this.automaticallyImplyLeading = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: elevation,
      titleSpacing: titleSpacing,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontSize: fontSize.sp,
          fontWeight: fontWeight,
        ),
      ),
      leading: leading ?? (automaticallyImplyLeading
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios, color: FYColors.color_1A1A1A, size: 20.w),
              onPressed: onBackPressed ?? () => Get.back(),
            )
          : null),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h);
} 