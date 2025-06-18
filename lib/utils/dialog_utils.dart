import 'package:flutter/material.dart';
import 'package:safe_app/utils/toast_util.dart';

class DialogUtils {
  /// 显示"正在建设完善中"的提示弹窗
  static void showUnderConstructionDialog() {
    ToastUtil.showShort('当前功能正在建设完善中');
  }
} 