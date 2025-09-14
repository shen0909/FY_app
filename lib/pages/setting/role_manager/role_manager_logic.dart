import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/https/api_service.dart';
import 'package:safe_app/models/setting/user_list.dart';
import 'package:safe_app/utils/dialog_utils.dart';

import '../../../styles/colors.dart';
import 'role_manager_state.dart';
import 'role_manager_view.dart';

class RoleManagerLogic extends GetxController {
  final RoleManagerState state = RoleManagerState();
  final TextEditingController searchController = TextEditingController();

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
    leftVerticalController.addListener(() {
      if (leftVerticalController.position.pixels >=
          leftVerticalController.position.maxScrollExtent - 200) {
        loadMoreData();
      }
    });
    
    // 设置滚动同步
    setupScrollControllers();
  }

  // 加载更多数据
  Future<void> loadMoreData() async {
    // 防止重复加载
    if (state.isLoadingMore.value || !state.hasMoreData.value) {
      return;
    }

    state.isLoadingMore.value = true;
    state.currentPage.value++;
    try {
      await getUserList(isLoadMore: true);
    } catch (e) {
      print("加载更多数据失败: $e");
      // 加载失败时回退页数
      state.currentPage.value--;
    } finally {
      state.isLoadingMore.value = false;
    }
  }

  @override
  Future<void> onReady() async {
    await getUserList();
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
  Future<void> searchUser(String keyword) async {
    final result = await ApiService().getUserList(currentPage: state.currentPage.value,userName: keyword);

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
    Get.back();
  }

  // 编辑用户
  void editUser(UserListElement user) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        backgroundColor: FYColors.whiteColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '确认要删除该用户？',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.w)),
        contentPadding: EdgeInsets.symmetric(vertical: 24.w, horizontal: 16.w),
        actionsPadding: EdgeInsets.zero,
        buttonPadding: EdgeInsets.zero,
        actions: [
          // 分割线
          Container(
            height: 1.w,
            color: const Color(0xFFEFEFEF),
          ),
          // 按钮区域
          Row(
            children: [
              // 取消按钮
              Expanded(
                child: InkWell(
                  onTap: () => Get.back(),
                  child: Container(
                    height: 44.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: const Color(0xFFEFEFEF),
                          width: 1.w,
                        ),
                      ),
                    ),
                    child: Text(
                      '取消',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ),
              ),
              // 确定按钮
              Expanded(
                child: InkWell(
                  onTap: () => deleteUser(user.uuid!),
                  child: Container(
                    height: 44.w,
                    alignment: Alignment.center,
                    child: Text(
                      '确定',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF3361FE),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Future<void> getUserList({bool isLoadMore = false}) async {
    DialogUtils.showLoading();
    final result = await ApiService().getUserList(currentPage: state.currentPage.value);
    DialogUtils.hideLoading();
    if(result != null) {
      UserList userList = UserList.fromJson(result);
      if(isLoadMore) {
        state.filteredUserList.addAll(userList.list);
      } else{
        state.filteredUserList.clear();
        state.filteredUserList.value = userList.list;
      }
      if(userList.list.length < 20) {
        state.hasMoreData.value = false;
      } else {
        state.hasMoreData.value = true;
      }
    }
  }

  /// 删除用户
  Future<void> deleteUser(String uuid) async {
    Get.back();
    DialogUtils.showLoading("正在删除用户");
    final result = await ApiService().deleteUserListItem(uuid: uuid);
    DialogUtils.hideLoading();

  }
}
