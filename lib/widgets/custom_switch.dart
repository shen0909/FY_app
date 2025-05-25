import 'package:flutter/material.dart';
import 'package:safe_app/styles/image_resource.dart';

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double width;
  final double height;

  const CustomSwitch({
    Key? key,
    required this.value,
    this.onChanged,
    this.width = 51,
    this.height = 31,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: Image.asset(
        value ? FYImages.open_icon : FYImages.unopen_icon,
        width: width,
        height: height,
      ),
    );
  }
} 