import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'user_login_data_state.dart';

class UserLoginDataLogic extends GetxController {
  final UserLoginDataState state = UserLoginDataState();

  @override
  void onReady() {
    super.onReady();
    // 加载登录日志数据
    loadLoginLogs();
  }

  @override
  void onClose() {
    super.onClose();
  }
  
  // 加载登录日志数据
  void loadLoginLogs() {
    // 实际项目中应该从API获取数据
    // 这里使用了state中的示例数据
  }
  
  // 加载更多日志
  void loadMoreLogs() {
    // 实际项目中应该分页加载更多数据
    Get.snackbar(
      '提示',
      '正在加载更多数据...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // 获取按日期分组的登录日志
  Map<String, List<Map<String, dynamic>>> getGroupedLogs() {
    Map<String, List<Map<String, dynamic>>> result = {};
    
    for (var log in state.loginLogs) {
      String date = log['date'];
      if (!result.containsKey(date)) {
        result[date] = [];
      }
      result[date]!.add(log);
    }
    
    return result;
  }
}
