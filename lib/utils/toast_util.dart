import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ToastUtil {

  // 显示短时间提示（带防抖）
  static void showShort(String message, {String title = '提示'}) {
    if (Get.isSnackbarOpen) return;
    
    try {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('显示Toast时出现异常: $e');
      // 忽略异常，确保不会影响主流程
    }
  }
  
  // 显示长时间提示（带防抖）
  static void showLong(String message) {
    if (Get.isSnackbarOpen) return;
    
    try {
      Get.snackbar(
        '提示',
        message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      print('显示Toast时出现异常: $e');
      // 忽略异常，确保不会影响主流程
    }
  }
  
  // 显示成功提示（带防抖）
  static void showSuccess(String message) {
    if (Get.isSnackbarOpen) return;
    
    try {
      Get.snackbar(
        '成功',
        message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      print('显示Toast时出现异常: $e');
      // 忽略异常，确保不会影响主流程
    }
  }
  
  // 显示错误提示（带防抖）
  static void showError(String message) {
    if (Get.isSnackbarOpen) return;
    
    try {
      Get.snackbar(
        '错误',
        message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } catch (e) {
      print('显示Toast时出现异常: $e');
      // 忽略异常，确保不会影响主流程
    }
  }
  
  // 强制显示Toast（忽略防抖）
  static void showForce(String message, {String title = '提示'}) {
    try {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('显示Toast时出现异常: $e');
      // 忽略异常，确保不会影响主流程
    }
  }
} 