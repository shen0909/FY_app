import 'dart:async';

import 'package:get/get.dart';
import 'package:safe_app/routers/routers.dart';
import 'package:safe_app/utils/pattern_lock_util.dart';
import 'package:safe_app/utils/toast_util.dart';
import 'package:safe_app/utils/shared_prefer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pattern_lock_state.dart';

class PatternLockLogic extends GetxController {
  final PatternLockState state = PatternLockState();
  Timer? _lockTimer;

  @override
  void onReady() {
    super.onReady();
    // 初始化操作
    _loadUserInfo();
    _checkLockStatus();
  }

  @override
  void onClose() {
    _lockTimer?.cancel();
    super.onClose();
  }
  
  // 加载用户信息
  Future<void> _loadUserInfo() async {
    try {
      // 从SharedPreferences获取用户信息
      final loginData = await FYSharedPreferenceUtils.getLoginData();
      if (loginData != null) {
        state.userName.value = loginData.username ?? '';
        _setGreetingMessage();
      }
    } catch (e) {
      print('加载用户信息错误: $e');
    }
  }
  
  // 设置问候语
  void _setGreetingMessage() {
    final hour = DateTime.now().hour;
    String greeting;
    
    if (hour < 6) {
      greeting = '凌晨好';
    } else if (hour < 9) {
      greeting = '早上好';
    } else if (hour < 12) {
      greeting = '上午好';
    } else if (hour < 14) {
      greeting = '中午好';
    } else if (hour < 18) {
      greeting = '下午好';
    } else if (hour < 22) {
      greeting = '晚上好';
    } else {
      greeting = '夜深了';
    }
    
    state.greetingMessage.value = greeting;
  }
  
  // 检查锁定状态
  Future<void> _checkLockStatus() async {
    // 检查是否被锁定
    final isLocked = await PatternLockUtil.isLocked();
    state.isLocked.value = isLocked;
    
    if (isLocked) {
      // 获取剩余锁定时间
      final remainingTime = await PatternLockUtil.getRemainingLockTime();
      state.lockTimeMinutes.value = remainingTime;
      
      // 启动倒计时
      _startLockTimer();
    } else {
      // 获取剩余尝试次数
      final remainingAttempts = await PatternLockUtil.getRemainingAttempts();
      state.remainingAttempts.value = remainingAttempts;
    }
  }
  
  // 启动锁定倒计时
  void _startLockTimer() {
    _lockTimer?.cancel();
    _lockTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      final remainingTime = await PatternLockUtil.getRemainingLockTime();
      state.lockTimeMinutes.value = remainingTime;
      
      if (remainingTime <= 0) {
        timer.cancel();
        state.isLocked.value = false;
        state.remainingAttempts.value = 5;
      }
    });
  }
  
  // 验证图案
  Future<void> verifyPattern(List<int> pattern) async {
    // 如果已被锁定，不进行验证
    if (state.isLocked.value) {
      return;
    }
    
    final isValid = await PatternLockUtil.verifyPattern(pattern);
    if (isValid) {
      // 验证成功，重置失败次数
      await PatternLockUtil.resetFailedAttempts();
      
      // 验证成功，直接进入主页
      Get.offAllNamed(Routers.home);
    } else {
      // 验证失败，记录失败次数
      final remainingAttempts = 5 - await PatternLockUtil.recordFailedAttempt();
      state.remainingAttempts.value = remainingAttempts > 0 ? remainingAttempts : 0;
      
      // 显示错误
      _showError('手势密码错误:您还可以尝试${state.remainingAttempts.value}次');
      
      // 检查是否达到最大尝试次数
      if (remainingAttempts <= 0) {
        await _checkLockStatus();
      }
    }
  }
  
  // 显示错误信息
  void _showError(String message) {
    state.isError.value = true;
    state.errorMessage.value = message;
    
    // 如果仍有剩余尝试次数，延迟重置错误状态
    if (state.remainingAttempts.value > 0) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        // 仅重置错误消息，保持isError状态，让用户可以看到红色的错误图案
        state.errorMessage.value = '';
        
        // 在用户开始下一次划线操作时，PatternLockWidget会自动重置错误状态
      });
    }
  }
  
  // 跳转到密码登录
  void navigateToPasswordLogin() async {
    // 重置图案锁的状态，这样下次进入不会处于错误状态
    await PatternLockUtil.resetFailedAttempts();
    
    // 设置标记，表示用户选择使用密码登录
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_password_login', true);
    
    // 导航到登录页面
    Get.offAllNamed(Routers.login);
    
    // 显示提示
    ToastUtil.showShort('请使用账号密码登录');
  }
} 