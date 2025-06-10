import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/routers/routers.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/widgets/custom_app_bar.dart';

import 'lock_method_selection_logic.dart';
import 'lock_method_selection_state.dart';

class LockMethodSelectionPage extends StatelessWidget {
  LockMethodSelectionPage({Key? key}) : super(key: key);

  final LockMethodSelectionLogic logic = Get.put(LockMethodSelectionLogic());
  final LockMethodSelectionState state =
      Get.find<LockMethodSelectionLogic>().state;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: FYAppBar(title: '设置安全锁屏方式'),
        body: Column(
          children: [
            _buildHeader(),
            SizedBox(height: 24.h),
            _buildLockMethodCard(
              title: '划线解锁',
              desc: '绘制图案进行解锁，安全便捷',
              icon: Icons.gesture,
              onTap: () => logic.selectPatternLock(),
            ),
            SizedBox(height: 16.h),
            _buildLockMethodCard(
              title: '指纹解锁',
              desc: '使用指纹进行解锁，快速安全',
              icon: Icons.fingerprint,
              onTap: () => logic.selectFingerprintLock(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '首次登录设置',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: FYColors.color_1A1A1A,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '为了您的账户安全，必须选择一种锁屏方式',
            style: TextStyle(
              fontSize: 14.sp,
              color: FYColors.color_666666,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockMethodCard({
    required String title,
    required String desc,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: FYColors.color_F9F9F9,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: FYColors.color_E6E6E6),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: FYColors.color_3361FE.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Icon(
                icon,
                color: FYColors.color_3361FE,
                size: 24.w,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: FYColors.color_1A1A1A,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: FYColors.color_666666,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: FYColors.color_666666,
              size: 16.w,
            ),
          ],
        ),
      ),
    );
  }
}
