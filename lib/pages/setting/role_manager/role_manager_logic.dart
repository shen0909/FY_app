import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'role_manager_state.dart';
import 'role_manager_view.dart';

class RoleManagerLogic extends GetxController {
  final RoleManagerState state = RoleManagerState();
  final TextEditingController searchController = TextEditingController();
  final RxList<UserRole> filteredUserList = <UserRole>[].obs;

  @override
  void onReady() {
    filteredUserList.value = state.userList;
    super.onReady();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
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
