import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';

import 'fingerprint_auth_logic.dart';
import 'fingerprint_auth_state.dart';

class FingerprintAuthPage extends StatelessWidget {
  FingerprintAuthPage({Key? key}) : super(key: key);

  final FingerprintAuthLogic logic = Get.put(FingerprintAuthLogic());
  final FingerprintAuthState state = Get.find<FingerprintAuthLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 指纹图标
            Icon(
              Icons.fingerprint,
              size: 80.w,
              color: FYColors.color_3361FE,
            ),
            SizedBox(height: 24.h),
            Text(
              '指纹验证',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: FYColors.color_1A1A1A,
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 48.w),
              child: Text(
                '请使用已注册的指纹进行验证',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: FYColors.color_666666,
                ),
              ),
            ),
            SizedBox(height: 40.h),
            Obx(() => state.isAuthenticating.value
                ? CircularProgressIndicator(
                    color: FYColors.color_3361FE,
                  )
                : Column(
                    children: [
                      // 重试按钮
                      GestureDetector(
                        onTap: () => logic.authenticateWithBiometrics(),
                        child: Container(
                          width: 200.w,
                          height: 48.h,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: FYColors.loginBtn),
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '重新验证',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      // 使用密码登录按钮
                      GestureDetector(
                        onTap: () => logic.usePasswordLogin(),
                        child: Text(
                          '使用密码登录',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: FYColors.color_3361FE,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  )),
          ],
        ),
      ),
    );
  }
} 