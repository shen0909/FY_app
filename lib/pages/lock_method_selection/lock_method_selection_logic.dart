import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:safe_app/routers/routers.dart';
import 'package:safe_app/utils/pattern_lock_util.dart';
import 'package:safe_app/utils/toast_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lock_method_selection_state.dart';

class LockMethodSelectionLogic extends GetxController {
  final LockMethodSelectionState state = LockMethodSelectionState();
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
  
  // 选择划线解锁
  void selectPatternLock() async {
    final result = await Get.toNamed(Routers.patternSetup);
    if (result == true) {
      // 设置成功，跳转到主页
      ToastUtil.showSuccess('划线解锁设置成功');
      Get.offAllNamed(Routers.home);
    }
  }
  
  // 选择指纹解锁
  void selectFingerprintLock() async {
    // 检查设备是否支持指纹识别
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
    
    if (canCheckBiometrics && availableBiometrics.isNotEmpty) {
      try {
        bool authenticated = await _localAuth.authenticate(
          localizedReason: '请验证指纹以启用指纹解锁功能',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );
        
        if (authenticated) {
          // 验证成功，启用指纹解锁
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('fingerprint_enabled', true);
          
          // 确保划线解锁已关闭
          await PatternLockUtil.enablePatternLock(false);
          
          ToastUtil.showSuccess('指纹解锁设置成功');
          Get.offAllNamed(Routers.home);
        } else {
          ToastUtil.showError('指纹验证失败，请重试');
        }
      } on PlatformException catch (e) {
        ToastUtil.showError('指纹验证出错: ${e.message}');
      }
    } else {
      ToastUtil.showError('您的设备不支持指纹识别，请选择划线解锁');
    }
  }
} 