import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_app/https/api_service.dart';
import 'package:safe_app/routers/routers.dart';
import 'package:safe_app/utils/pattern_lock_util.dart';
import 'package:safe_app/utils/shared_prefer.dart';
import 'package:safe_app/utils/toast_util.dart';
import 'package:safe_app/models/login_data.dart';
import 'package:safe_app/pages/login/api/login_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_state.dart';

class LoginLogic extends GetxController {
  final LoginState state = LoginState();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    _checkAuthAndNavigate();
  }

  @override
  void onClose() {
    state.accountController.dispose();
    state.passwordController.dispose();
    super.onClose();
  }

  Future<void> _checkAuthAndNavigate() async {
    state.isChecking.value = true;

    try {
      // 检查是否有使用密码登录的标记
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool usePasswordLogin = prefs.getBool('use_password_login') ?? false;
      
      // 如果设置了使用密码登录的标记，清除标记并留在登录页面
      if (usePasswordLogin) {
        await prefs.remove('use_password_login');
        state.isChecking.value = false;
        return;
      }
      
      bool hasPatternLock = await PatternLockUtil.isPatternEnabled();
      bool hasFingerprintLock = await _isFingerprintEnabled();
      // 只有启用了生物认证才进行跳转，否则保持在登录页面
      if (hasPatternLock) {
        // 有图案锁，进入图案锁验证页面
        Get.offAllNamed(Routers.patternLock);
      } else if (hasFingerprintLock) {
        // 有指纹锁，进入指纹验证页面
        Get.offAllNamed(Routers.fingerprintAuth);
      }
    } catch (e) {
      print('检查认证状态错误: $e');
      // 发生错误时已经在登录页面，无需处理
    } finally {
      state.isChecking.value = false;
    }
  }

  // 执行登录
  void doLogin() async {
    String account = state.accountController.text;
    String password = state.passwordController.text;
    if (account.isEmpty) {
      ToastUtil.showError('请输入账号');
      return;
    }
    if (password.isEmpty) {
      ToastUtil.showError('请输入密码');
      return;
    }

    state.isLogging.value = true;

    try {
      // 调用登录API
      LoginData? loginData = await LoginApi.login(account, password);

      if (loginData != null) {
        // 登录成功，保存登录数据
        await SharedPreference.saveLoginData(loginData);
        state.isLogging.value = false;
        // 检查是否已设置过锁屏方式
        bool hasSetupLockMethod = await _hasSetupLockMethod();
        if (!hasSetupLockMethod) {
          // 如果是首次登录，强制引导用户设置锁屏方式
          ToastUtil.showShort('首次登录需要设置安全锁屏方式');
          Get.offAllNamed(Routers.lockMethodSelection);
        } else {
          // 直接进入主页
          Get.offAllNamed(Routers.home);
        }
      } else {
        state.isLogging.value = false;
        ToastUtil.showError('登录失败，请检查账号密码');
      }
    } catch (e) {
      state.isLogging.value = false;
      ToastUtil.showError('登录失败: ${e.toString()}');
    }
  }

  // 检查是否已设置过锁屏方式
  Future<bool> _hasSetupLockMethod() async {
    bool hasPatternLock = await PatternLockUtil.isPatternEnabled();
    bool hasFingerprintLock = await _isFingerprintEnabled();
    return hasPatternLock || hasFingerprintLock;
  }

  // 检查是否启用了指纹锁
  Future<bool> _isFingerprintEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('fingerprint_enabled') ?? false;
  }
}
