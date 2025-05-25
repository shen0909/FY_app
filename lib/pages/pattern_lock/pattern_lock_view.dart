import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/image_resource.dart';
import 'package:safe_app/styles/text_styles.dart';
import 'package:safe_app/widgets/pattern_lock_widget.dart';

import 'pattern_lock_logic.dart';
import 'pattern_lock_state.dart';

class PatternLockPage extends StatelessWidget {
  PatternLockPage({super.key});

  final PatternLockLogic logic = Get.put(PatternLockLogic());
  final PatternLockState state = Get.find<PatternLockLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部状态栏区域
            Container(
              width: 375.w,
              height: 88.h,
              color: Colors.white,
            ),
            
            // 主体内容区域
            Expanded(
              child: Column(
                children: [
                  SizedBox(height: 13.h),
                  // 用户头像
                  ClipOval(
                    child: Image.asset(
                      FYImages.user_avatar,
                      width: 88.w,
                      height: 88.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 42.h),
                  Obx(() {
                    String displayName = state.userName.value.isNotEmpty 
                        ? state.userName.value 
                        : '用户';
                    String greeting = state.greetingMessage.value.isNotEmpty 
                        ? state.greetingMessage.value 
                        : '你好';
                    return Text(
                      '$displayName,$greeting',
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: FYColors.color_1A1A1A,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'AlibabaPuHuiTi',
                      ),
                    );
                  }),
                  SizedBox(height: 32.h),
                  // 错误信息显示
                  Obx(() => state.errorMessage.isNotEmpty ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      state.errorMessage.value,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: FYColors.color_FF3B30,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ) : Container()),
                  // 图案锁控件
                  Obx(() => PatternLockWidget(
                    size: 300.w,
                    dotSize: 59.w,
                    lineWidth: 4.w,
                    selectedColor: FYColors.color_1A1A1A, // 选中点的颜色
                    notSelectedColor: FYColors.color_D8D8D8, // 未选中点的颜色
                    errorColor: FYColors.color_FF3B30, // 错误状态颜色
                    isError: state.isError.value,
                    onCompleted: (pattern) {
                      logic.verifyPattern(pattern);
                    },
                    showInput: false,
                  )),
                  
                  // 锁定信息显示
                  Obx(() => Visibility(
                    visible: state.isLocked.value,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      child: Text(
                        '尝试次数过多，请${state.lockTimeMinutes.value}分钟后再试',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: FYColors.color_FF3B30,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )),
                  
                  // 使用密码登录选项
                  Padding(
                    padding: EdgeInsets.only(top: 24.h),
                    child: GestureDetector(
                      onTap: () => logic.navigateToPasswordLogin(),
                      child: Text(
                        '使用密码登录',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: FYColors.text1Color,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 底部Home Indicator区域
            Container(
              width: 375.w,
              height: 34.h,
              color: Colors.transparent,
              alignment: Alignment.center,
              child: Container(
                width: 134.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(100.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 