import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_app/routers/routers.dart';

import 'setting_state.dart';

class SettingLogic extends GetxController {
  final SettingState state = SettingState();

  @override
  void onReady() {
    super.onReady();
    // 加载数据
    loadSettingData();
  }

  @override
  void onClose() {
    super.onClose();
  }
  
  // 加载设置数据
  void loadSettingData() {
    // 实际项目中应该从API获取数据
    // 这里使用了state中的示例数据
  }
  
  // 切换锁屏开关
  void toggleLockScreen(bool value) {
    state.isLockEnabled.value = value;
  }
  
  // 切换指纹解锁开关
  void toggleFingerprint(bool value) {
    state.isFingerprintEnabled.value = value;
  }
  
  // 切换风险预警推送开关
  void toggleRiskAlert(bool value) {
    state.isRiskAlertEnabled.value = value;
  }
  
  // 切换订阅信息推送开关
  void toggleSubscriptionNotification(bool value) {
    state.isSubscriptionEnabled.value = value;
  }
  
  // 清除缓存
  void clearCache() {
    Get.dialog(
      AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有缓存数据吗？这将删除应用程序的临时文件和数据。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // 执行清除缓存操作
              Get.back();
              Get.snackbar('提示', '缓存已清除');
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  // 前往使用教程页面
  void goToUseTutorial() {
    Get.toNamed(Routers.useTutorial);
  }
  
  // 前往用户反馈页面
  void goToFeedback() {
    Get.toNamed('/feedback');
  }
  
  // 前往用户行为分析页面
  void goToUserAnalysis() {
    Get.toNamed('/user_analysis');
  }
  
  // 前往角色管理页面
  void goToRoleManagement() {
    Get.toNamed('/role_management');
  }
  
  // 前往权限申请列表页面
  void goToPermissionRequests() {
    Get.toNamed('/permission_requests');
  }
  
  // 添加新用户
  void addNewUser() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController idController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Text('添加用户'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '用户名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: '用户ID',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && idController.text.isNotEmpty) {
                state.userList.add({
                  'name': nameController.text,
                  'id': idController.text,
                  'role': '普通用户',
                  'status': '在线',
                  'lastLoginTime': DateTime.now().toString().substring(0, 16)
                });
                Get.back();
                Get.snackbar('提示', '用户已添加');
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }
  
  // 搜索用户
  void searchUser(String keyword) {
    // 实际项目中应该进行用户搜索
    Get.snackbar('提示', '正在搜索: $keyword');
  }
  
  // 前往用户日志页面
  void goToUserLogs() {
    Get.toNamed(Routers.userLoginData);
  }
}
