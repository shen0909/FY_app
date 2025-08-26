import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

class ToastUtil {
  // 防抖计时器
  static Timer? _debounceTimer;
  static String? _lastMessage;
  static Duration _debounceDelay = const Duration(milliseconds: 500);
  
  // 防抖检查
  static bool _shouldShowToast(String message) {
    // 如果消息相同且在防抖时间内，不显示
    if (_lastMessage == message && _debounceTimer?.isActive == true) {
      return false;
    }
    
    // 取消之前的计时器
    _debounceTimer?.cancel();
    
    // 设置新的计时器
    _debounceTimer = Timer(_debounceDelay, () {
      _lastMessage = null;
    });
    
    _lastMessage = message;
    return true;
  }

  // 显示短时间提示（带防抖）
  static void showShort(String message) {
    if (!_shouldShowToast(message)) return;
    Get.snackbar(
      '提示',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
  
  // 显示长时间提示（带防抖）
  static void showLong(String message) {
    if (!_shouldShowToast(message)) return;
    
    Get.snackbar(
      '提示',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }
  
  // 显示成功提示（带防抖）
  static void showSuccess(String message) {
    if (!_shouldShowToast(message)) return;
    
    Get.snackbar(
      '成功',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green,
    );
  }
  
  // 显示错误提示（带防抖）
  static void showError(String message) {
    if (!_shouldShowToast(message)) return;
    
    Get.snackbar(
      '错误',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red.withOpacity(0.1),
      colorText: Colors.red,
    );
  }
  
  // 强制显示Toast（忽略防抖）
  static void showForce(String message, {String title = '提示'}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
  
  // 清除防抖状态
  static void clearDebounce() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _lastMessage = null;
  }
  
  // 设置防抖延迟时间
  static void setDebounceDelay(Duration delay) {
    _debounceDelay = delay;
  }
} 