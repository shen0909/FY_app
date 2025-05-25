import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../styles/colors.dart';
import '../styles/image_resource.dart';

class FYWidget{
  static Widget buildEmptyContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            FYImages.blank_page,
            width: 120.w,
            height: 120.w,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 16.w),
          Text(
            '暂无数据',
            style: TextStyle(
              fontSize: 14.sp,
              color: FYColors.color_A6A6A6,
            ),
          ),
        ],
      ),
    );
  }
}