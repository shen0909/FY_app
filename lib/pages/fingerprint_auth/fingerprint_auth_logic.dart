import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_app/routers/routers.dart';
import 'package:safe_app/services/biometric_service.dart';
import 'package:safe_app/utils/toast_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fingerprint_auth_state.dart';

class FingerprintAuthLogic extends GetxController {
  final FingerprintAuthState state = FingerprintAuthState();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    // 页面加载完成后自动开始指纹验证
    authenticateWithBiometrics();
  }

  // 使用指纹验证
  Future<void> authenticateWithBiometrics() async {
    state.isAuthenticating.value = true;
    try {
      bool isAvailable = await BiometricService.isBiometricAvailable();
      if (!isAvailable) {
        ToastUtil.showError('您的设备不支持指纹登录');
        state.isAuthenticating.value = false;
        // 不支持指纹时返回密码登录
        await _usePasswordLogin();
        return;
      }
      
      bool success = await BiometricService.authenticateWithBiometrics(
        reason: '请验证指纹以登录',
      );
      
      if (success) {
        // 指纹验证成功，进入主页
        Get.offAllNamed(Routers.home);
      } else {
        // 用户取消了指纹验证
        state.isAuthenticating.value = false;
      }
    } catch (e) {
      state.isAuthenticating.value = false;
      ToastUtil.showError(e.toString());
    }
  }

  // 使用密码登录
  Future<void> usePasswordLogin() async {
    await _usePasswordLogin();
  }

  Future<void> _usePasswordLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_password_login', true);
    Get.offAllNamed(Routers.login);
  }
} 