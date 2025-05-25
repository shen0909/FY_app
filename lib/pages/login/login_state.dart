import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginState {
  final TextEditingController accountController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  // 是否正在登录
  final RxBool isLogging = false.obs;
  
  // 是否正在使用生物识别
  final RxBool isBiometricAuthenticating = false.obs;
  
  // 是否显示密码
  final RxBool showPassword = false.obs;
  
  // 是否正在检查登录状态 (从splash页面迁移)
  final RxBool isChecking = true.obs;
}
