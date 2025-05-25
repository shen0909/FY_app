import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:safe_app/routers/routers.dart';
import 'package:safe_app/services/biometric_service.dart';
import 'package:safe_app/utils/pattern_lock_util.dart';
import 'package:safe_app/utils/shared_prefer.dart';
import 'package:safe_app/utils/toast_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  void loadSettingData() async {
    // 加载锁屏设置状态
    bool isPatternEnabled = await PatternLockUtil.isPatternEnabled();
    
    // 加载指纹解锁设置状态
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFingerprintEnabled = prefs.getBool('fingerprint_enabled') ?? false;
    
    // 确保两种解锁方式不会同时启用
    if (isPatternEnabled && isFingerprintEnabled) {
      // 如果配置出现冲突，优先使用指纹解锁
      await PatternLockUtil.enablePatternLock(false);
      isPatternEnabled = false;
      ToastUtil.showShort('检测到锁屏方式冲突，已禁用划线解锁');
    }
    
    // 更新UI状态
    state.isLockEnabled.value = isPatternEnabled;
    state.isFingerprintEnabled.value = isFingerprintEnabled;
  }
  
  // 切换锁屏开关
  void toggleLockScreen(bool value) async {
    if (value) {
      // 如果要开启划线解锁，先关闭指纹解锁
      if (state.isFingerprintEnabled.value) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('fingerprint_enabled', false);
        state.isFingerprintEnabled.value = false;
        ToastUtil.showShort('已关闭指纹解锁');
      }
      
      // 检查是否已设置过图案
      List<int>? savedPattern = await PatternLockUtil.getPattern();
      if (savedPattern != null && savedPattern.isNotEmpty) {
        // 已经设置过，直接启用
        await PatternLockUtil.enablePatternLock(true);
        state.isLockEnabled.value = true;
      } else {
        // 没有设置过，引导用户设置
        _showPatternSetupDialog();
      }
    } else {
      // 关闭划线解锁
      await PatternLockUtil.enablePatternLock(false);
      state.isLockEnabled.value = false;
    }
  }
  
  // 切换指纹解锁开关
  void toggleFingerprint(bool value) async {
    if (value) {
      try {
        // 检查设备是否支持指纹识别
        bool isAvailable = await BiometricService.isBiometricAvailable();
        if (!isAvailable) {
          state.isFingerprintEnabled.value = false;
          ToastUtil.showError('您的设备不支持指纹登录');
          return;
        }
        
        // 获取可用的生物识别类型
        List<BiometricType> availableBiometrics = await BiometricService.getAvailableBiometrics();
        if (availableBiometrics.isEmpty) {
          state.isFingerprintEnabled.value = false;
          ToastUtil.showError('未检测到可用的指纹，请先在系统设置中添加指纹');
          return;
        }
        
        // 如果要开启指纹解锁，先关闭划线解锁
        if (state.isLockEnabled.value) {
          await PatternLockUtil.enablePatternLock(false);
          state.isLockEnabled.value = false;
          ToastUtil.showShort('已关闭划线解锁');
        }
        
        // 验证指纹
        bool authenticated = await BiometricService.authenticateWithBiometrics(
          reason: '请验证指纹以启用指纹解锁功能',
        );
        
        if (authenticated) {
          // 验证成功，启用指纹解锁
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('fingerprint_enabled', true);
          state.isFingerprintEnabled.value = true;
        } else {
          // 验证失败，不开启指纹解锁
          state.isFingerprintEnabled.value = false;
        }
      } catch (e) {
        state.isFingerprintEnabled.value = false;
        ToastUtil.showError(e.toString());
      }
    } else {
      // 关闭指纹解锁
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('fingerprint_enabled', false);
      state.isFingerprintEnabled.value = false;
    }
  }
  
  // 显示设置图案解锁的对话框
  void _showPatternSetupDialog() async {
    final result = await Get.toNamed(Routers.patternSetup);
    if (result == true) {
      // 设置成功，更新状态
      state.isLockEnabled.value = true;
      ToastUtil.showShort('划线解锁设置成功');
    } else {
      // 设置取消或失败
      state.isLockEnabled.value = false;
      await PatternLockUtil.enablePatternLock(false);
    }
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
  
  // 前往隐私保护页面
  void goToPrivacySafe() {
    Get.toNamed(Routers.privacySafe);
  }
  
  // 前往用户反馈页面
  void goToFeedback() {
    Get.toNamed(Routers.feedback);
  }
  
  // 前往用户行为分析页面
  void goToUserAnalysis() {
    Get.toNamed('/user_analysis');
  }
  
  // 前往角色管理页面
  void goToRoleManagement() {
    Get.toNamed(Routers.role_manager);
  }
  
  // 前往权限申请列表页面
  void goToPermissionRequests() {
    Get.toNamed(Routers.permissionRequest);
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
