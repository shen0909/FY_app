import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_app/utils/toast_util.dart';

class DialogUtils {
  static bool _isLoading = false;

  /// 显示"正在建设完善中"的提示弹窗
  static void showUnderConstructionDialog() {
    ToastUtil.showShort('当前功能正在建设完善中');
  }

  /// 显示加载对话框
  static void showLoading([String? message]) {
    if (_isLoading) return; // 防止重复显示
    _isLoading = true;
    
    Get.dialog(
      PopScope(
        canPop: false, // 防止用户点击返回键关闭
        child: Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false, // 防止点击背景关闭
    );
  }

  /// 隐藏加载对话框
  static void hideLoading() {
    if (!_isLoading) return;
    
    _isLoading = false;
    try {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    } catch (e) {
      print('关闭加载对话框时出现异常: $e');
      // 忽略异常，确保不会影响主流程
    }
  }

  /// 显示底部弹窗
  static void showBottomSheet(Widget content) {
    Get.bottomSheet(
      content,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// 显示确认对话框
  static Future<bool?> showConfirmDialog({
    required String title,
    required String content,
    String confirmText = '确定',
    String cancelText = '取消',
    Color? confirmColor,
  }) {
    return Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: confirmColor != null 
                ? TextButton.styleFrom(foregroundColor: confirmColor)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// 显示信息对话框
  static Future<void> showInfoDialog({
    required String title,
    required String content,
    String buttonText = '确定',
  }) {
    return Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// 显示自定义对话框
  static Future<T?> showCustomDialog<T>(Widget dialog) {
    return Get.dialog<T>(dialog);
  }
} 