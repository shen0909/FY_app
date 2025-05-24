import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/image_resource.dart';
import 'package:safe_app/widgets/pattern_lock_widget.dart';

import 'pattern_lock_logic.dart';
import 'pattern_lock_state.dart';

class PatternLockPage extends StatelessWidget {
  PatternLockPage({Key? key}) : super(key: key);

  final PatternLockLogic logic = Get.put(PatternLockLogic());
  final PatternLockState state = Get.find<PatternLockLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 60.h),
              Image.asset(
                FYImages.appIcon_32,
                width: 80.w,
                height: 80.w,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 40.h),
              Text(
                '图案解锁',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: FYColors.color_1A1A1A,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                '请绘制您的解锁图案',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: FYColors.color_666666,
                ),
              ),
              SizedBox(height: 60.h),
              Obx(() => PatternLockWidget(
                size: 300.w,
                dotSize: 70.w,
                lineWidth: 4.w,
                isError: state.isError.value,
                onCompleted: (pattern) {
                  logic.verifyPattern(pattern);
                },
                showInput: false,
              )),
              SizedBox(height: 24.h),
              Obx(() => Visibility(
                visible: state.errorMessage.isNotEmpty,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    state.errorMessage.value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFFFF3B30),
                      fontFamily: 'Alibaba PuHuiTi 3.0',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )),
              SizedBox(height: 16.h),
              Obx(() => Visibility(
                visible: state.remainingAttempts.value > 0 && state.remainingAttempts.value < 5,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    '手势密码错误:您还可以尝试${state.remainingAttempts.value}次',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFFFF3B30),
                      fontFamily: 'Alibaba PuHuiTi 3.0',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )),
              SizedBox(height: 16.h),
              Obx(() => Visibility(
                visible: state.isLocked.value,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    '尝试次数过多，请${state.lockTimeMinutes.value}分钟后再试',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  // 应该跳转到指纹解锁或其他方式
                  Get.snackbar('提示', '请联系管理员重置密码');
                },
                child: Padding(
                  padding: EdgeInsets.only(bottom: 40.h),
                  child: Text(
                    '忘记图案?',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 