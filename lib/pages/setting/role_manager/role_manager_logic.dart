import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'role_manager_state.dart';
import 'role_manager_view.dart';

class RoleManagerLogic extends GetxController {
  final RoleManagerState state = RoleManagerState();
  final TextEditingController searchController = TextEditingController();
  final RxList<UserRole> filteredUserList = <UserRole>[].obs;
  
  // 添加滚动控制器
  late final ScrollController horizontalScrollController;
  late final ScrollController leftVerticalController;
  late final ScrollController rightVerticalController;

  @override
  void onInit() {
    super.onInit();
    // 初始化滚动控制器
    horizontalScrollController = ScrollController();
    leftVerticalController = ScrollController();
    rightVerticalController = ScrollController();
    
    // 设置滚动同步
    setupScrollControllers();
  }

  @override
  void onReady() {
    filteredUserList.value = state.userList;
    super.onReady();
  }

  @override
  void onClose() {
    searchController.dispose();
    // 释放滚动控制器资源
    horizontalScrollController.dispose();
    leftVerticalController.dispose();
    rightVerticalController.dispose();
    super.onClose();
  }
  
  // 设置滚动控制器
  void setupScrollControllers() {
    leftVerticalController.addListener(syncRightScroll);
    rightVerticalController.addListener(syncLeftScroll);
  }
  
  // 同步右侧滚动到左侧
  void syncRightScroll() {
    if (leftVerticalController.offset != rightVerticalController.offset) {
      rightVerticalController.jumpTo(leftVerticalController.offset);
    }
  }
  
  // 同步左侧滚动到右侧
  void syncLeftScroll() {
    if (rightVerticalController.offset != leftVerticalController.offset) {
      leftVerticalController.jumpTo(rightVerticalController.offset);
    }
  }

  // 搜索用户
  void searchUser(String keyword) {
    if (keyword.isEmpty) {
      filteredUserList.value = state.userList;
    } else {
      filteredUserList.value = state.userList.where((user) {
        final fullName = '${user.name} (${user.id})';
        return fullName.toLowerCase().contains(keyword.toLowerCase());
      }).toList();
    }
  }

  // 添加用户对话框
  void showAddUserDialog() {
    Get.dialog(
      const AddUserDialog(),
      barrierDismissible: false,
    );
  }

  // 添加用户
  void addUser(String name, String role, String password, String remark) {
    final newUser = UserRole(
      id: 'ZQP${state.userList.length + 1}'.padLeft(6, '0'),
      name: name,
      role: role,
      status: role == '管理员' || role == '审核员' ? '申请中' : '离线',
      lastLoginTime: '2024-05-11 09:45',
    );
    
    state.userList.add(newUser);
    filteredUserList.add(newUser);
    Get.back();
  }

  // 编辑用户
  void editUser(UserRole user) {
    // 实现编辑用户逻辑
  }
}
