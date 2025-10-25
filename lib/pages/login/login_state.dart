import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginState {
  final TextEditingController accountController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  // 是否正在登录
  final RxBool isLogging = false.obs;
  
  // 是否正在使用生物识别
  final RxBool isBiometricAuthenticating = false.obs;
  
  // 是否正在进行划线登录验证
  final RxBool isPatternAuthenticating = false.obs;
  
  // 是否显示密码
  final RxBool showPassword = false.obs;
  
  // 是否正在检查登录状态
  final RxBool isChecking = true.obs;

  // 登录方式 (0: 密码登录, 1: 划线登录, 2: 指纹登录)
  final RxInt loginMethod = 0.obs;

  // 划线登录相关状态
  final RxString errorMessage = ''.obs;
  final RxBool isError = false.obs;
  final RxInt remainingAttempts = 5.obs;
  final RxBool isLocked = false.obs;
  final RxInt lockTimeMinutes = 0.obs;
  final RxString userName = ''.obs;
  final RxString userUid = ''.obs;
  final RxString greetingMessage = ''.obs;
  
  // 图案锁是否准备好渲染
  final RxBool isPatternReady = false.obs;

  // 是否记住密码
  final RxBool rememberPassword = false.obs;

}
