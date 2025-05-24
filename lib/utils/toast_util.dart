import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ToastUtil {
  // 显示短时间提示
  static void showShort(String message) {
    Get.snackbar(
      '提示',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
  
  // 显示长时间提示
  static void showLong(String message) {
    Get.snackbar(
      '提示',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }
  
  // 显示成功提示
  static void showSuccess(String message) {
    Get.snackbar(
      '成功',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green,
    );
  }
  
  // 显示错误提示
  static void showError(String message) {
    Get.snackbar(
      '错误',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red.withOpacity(0.1),
      colorText: Colors.red,
    );
  }
} 