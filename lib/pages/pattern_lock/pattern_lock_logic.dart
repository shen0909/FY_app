import 'dart:async';

import 'package:get/get.dart';
import 'package:safe_app/routers/routers.dart';
import 'package:safe_app/utils/pattern_lock_util.dart';
import 'package:safe_app/utils/toast_util.dart';
import 'package:safe_app/utils/token_util.dart';

import 'pattern_lock_state.dart';

class PatternLockLogic extends GetxController {
  final PatternLockState state = PatternLockState();
  Timer? _lockTimer;

  @override
  void onReady() {
    super.onReady();
    // 初始化操作
    _checkLockStatus();
  }

  @override
  void onClose() {
    _lockTimer?.cancel();
    super.onClose();
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
      state.isError.value = false;
      state.errorMessage.value = '';
      
      // 验证token并进入主页
      await onAuthenticationSuccess();
    } else {
      // 验证失败，记录失败次数
      final remainingAttempts = 5 - await PatternLockUtil.recordFailedAttempt();
      state.remainingAttempts.value = remainingAttempts > 0 ? remainingAttempts : 0;
      
      // 显示错误
      state.isError.value = true;
      state.errorMessage.value = '手势密码错误:您还可以尝试${remainingAttempts}次';
      
      // 检查是否达到最大尝试次数
      if (remainingAttempts <= 0) {
        await _checkLockStatus();
      }
    }
  }
  
  // 认证成功后的处理
  Future<void> onAuthenticationSuccess() async {
    // 检查token是否有效
    bool isTokenValid = await TokenUtil.isTokenValid();
    
    if (isTokenValid) {
      // 如果token即将过期，尝试刷新
      await TokenUtil.refreshTokenIfNeeded();
      // 进入主页
      Get.offAllNamed(Routers.home);
    } else {
      // 尝试刷新token
      bool refreshed = await TokenUtil.refreshTokenIfNeeded();
      
      if (refreshed) {
        // 刷新成功，进入主页
        Get.offAllNamed(Routers.home);
      } else {
        // token已过期且无法刷新，需要重新登录
        ToastUtil.showError('登录已过期，请重新登录');
        Get.offAllNamed(Routers.login);
      }
    }
  }
  
  // 显示错误信息
  void _showError(String message) {
    state.isError.value = true;
    state.errorMessage.value = message;
    
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (!state.isLocked.value) {
        state.isError.value = false;
        state.errorMessage.value = '';
      }
    });
  }
  
  // 跳转到密码登录
  void navigateToPasswordLogin() {
    Get.offAllNamed(Routers.login);
  }
} 