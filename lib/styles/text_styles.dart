import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safe_app/styles/colors.dart';

class FYTextStyles {
  static TextStyle getAppTitle({Color color = FYColors.color_1A1A1A}) {
    return TextStyle(
      color: color,
      fontSize: 18.sp,
      fontWeight: FontWeight.bold,
    );
  }

  // 普通文字1
  static TextStyle getText1({Color color = FYColors.color_1A1A1A}) {
    return TextStyle(color: color, fontSize: 18.sp);
  }

  static TextStyle loginTitleStyle({Color color = FYColors.color_1A1A1A}) {
    return TextStyle(color: color, fontSize: 32.sp,fontWeight: FontWeight.w700);
  }

  static TextStyle loginTipStyle({Color color = FYColors.color_1A1A1A}) {
    return TextStyle(
      color: color, 
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      // fontFamily: 'Alibaba PuHuiTi 3.0',
      height: 0.66,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }
  static TextStyle loginBtnStyle({Color color = FYColors.color_1A1A1A}) {
    return TextStyle(
      color: color,
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
      // fontFamily: 'Alibaba PuHuiTi 3.0',
      height: 0.8, // 通过降低height来模拟lineSpacingExtra="-3.2sp"
      leadingDistribution: TextLeadingDistribution.even,
    );
  }
  static TextStyle inputStyle({Color color = FYColors.color_1A1A1A}) {
    return TextStyle(
      color: color, 
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      height: 0.8,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  static TextStyle hintStyle({Color color = FYColors.color_1A1A1A}) {
    return TextStyle(
      color: color,
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      // height: 0.8,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }
}
