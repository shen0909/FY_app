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
    _loadSavedCredentials();
  }

  @override
  void onClose() {
    state.accountController.dispose();
    state.passwordController.dispose();
    super.onClose();
  }

  // 加载已保存的账号密码
  Future<void> _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool rememberCredentials = prefs.getBool('remember_credentials') ?? false;
    state.rememberCredentials.value = rememberCredentials;
    
    if (rememberCredentials) {
      String? username = prefs.getString('saved_username');
      String? password = prefs.getString('saved_password');
      
      if (username != null && username.isNotEmpty) {
        state.accountController.text = username;
      }
      
      if (password != null && password.isNotEmpty) {
        state.passwordController.text = password;
      }
    }
  }
  
  // 切换记住账号密码状态
  void toggleRememberCredentials(bool value) {
    state.rememberCredentials.value = value;
  }
  
  // 保存账号密码
  Future<void> _saveCredentials() async {
    if (state.rememberCredentials.value) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_credentials', true);
      await prefs.setString('saved_username', state.accountController.text);
      await prefs.setString('saved_password', state.passwordController.text);
    } else {
      // 如果不记住，则清除已保存的账号密码
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_credentials', false);
      await prefs.remove('saved_username');
      await prefs.remove('saved_password');
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
        
        // 如果选择记住账号密码，保存凭据
        await _saveCredentials();
        
        state.isLogging.value = false;
        
        // 检查是否已设置过锁屏方式
        bool hasSetupLockMethod = await _hasSetupLockMethod();
        
        if (!hasSetupLockMethod) {
          // 如果是首次登录，强制引导用户设置锁屏方式
          ToastUtil.showShort('首次登录需要设置安全锁屏方式');
          Get.offAllNamed(Routers.lockMethodSelection);
        } else {
          // 判断使用哪种生物认证方式
          bool hasPatternLock = await PatternLockUtil.isPatternEnabled();
          bool hasFingerprintLock = await _isFingerprintEnabled();
          
          if (hasPatternLock) {
            // 使用图案锁
            Get.offAllNamed(Routers.patternLock);
          } else if (hasFingerprintLock) {
            // 使用指纹锁
            Get.offAllNamed(Routers.fingerprintAuth);
          } else {
            // 没有设置生物认证，直接进入主页（理论上不会出现这种情况）
            Get.offAllNamed(Routers.home);
          }
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
