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

  // 风险预警页面-地区标题
  static TextStyle riskLocationTitleStyle({Color color = const Color(0xFF000000)}) {
    return TextStyle(
      color: color,
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
      fontFamily: 'Alibaba PuHuiTi 3.0',
      height: 1.3, // 16sp + 4.8sp 行高约等于 20.8sp/16sp ≈ 1.3
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  // 单位类别未选中
  static TextStyle riskUnitTypeUnselectedStyle({Color color = FYColors.color_3361FE}) {
    return TextStyle(
      color: color,
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      fontFamily: 'Alibaba PuHuiTi 3.0',
      height: 0.8, // 14sp - 2.8sp 行高约等于 11.2sp/14sp ≈ 0.8
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  // 单位类别选中
  static TextStyle riskUnitTypeSelectedStyle({Color color = Colors.white}) {
    return TextStyle(
      color: color,
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      fontFamily: 'Alibaba PuHuiTi 3.0',
      height: 0.8,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  // 风险统计卡片高风险
  static TextStyle riskStatHighRiskStyle({Color color = FYColors.color_1D4293}) {
    return TextStyle(
      color: color,
      fontSize: 16.sp,
      fontWeight: FontWeight.w700,
      fontFamily: 'Alibaba PuHuiTi 3.0',
      height: 1.3,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  // 企业列表标题
  static TextStyle riskCompanyTitleStyle({Color color = const Color(0xFF1A1A1A)}) {
    return TextStyle(
      color: color,
      fontSize: 16.sp,
      fontWeight: FontWeight.w500,
      fontFamily: 'Alibaba PuHuiTi 3.0',
      height: 0.8, // 16sp - 3.2sp 行高约等于 12.8sp/16sp ≈ 0.8
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  // 企业列表副标题/描述
  static TextStyle riskCompanyDescStyle({Color color = const Color(0xFF1A1A1A)}) {
    return TextStyle(
      color: color,
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      fontFamily: 'Alibaba PuHuiTi 3.0',
      leadingDistribution: TextLeadingDistribution.even,
    );
  }
}
