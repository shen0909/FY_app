import 'package:get/get.dart';

import 'permission_request_state.dart';

class PermissionRequestLogic extends GetxController {
  final PermissionRequestState state = PermissionRequestState();

  @override
  void onReady() {
    super.onReady();
    // 加载默认数据
    _loadMockData();
  }

  @override
  void onClose() {
    super.onClose();
  }
  
  // 切换标签
  void switchTab(int index) {
    state.selectedTabIndex = index;
    update();
  }
  
  // 搜索用户
  void searchUser(String keyword) {
    state.searchKeyword = keyword;
    update();
  }
  
  // 批准申请
  void approveRequest(PermissionRequest request) {
    final index = state.permissionRequests.indexOf(request);
    if (index != -1) {
      final updatedRequest = PermissionRequest(
        userId: request.userId,
        permissionType: request.permissionType,
        applyTime: request.applyTime,
        approveTime: DateTime.now().toString().substring(0, 16),
        status: 0,
      );
      state.permissionRequests[index] = updatedRequest;
      update();
    }
  }
  
  // 驳回申请
  void rejectRequest(PermissionRequest request) {
    final index = state.permissionRequests.indexOf(request);
    if (index != -1) {
      final updatedRequest = PermissionRequest(
        userId: request.userId,
        permissionType: request.permissionType,
        applyTime: request.applyTime,
        approveTime: DateTime.now().toString().substring(0, 16),
        status: 2,
      );
      state.permissionRequests[index] = updatedRequest;
      update();
    }
  }
  
  // 获取当前标签的申请数量
  int getTabCount(int tabIndex) {
    return state.permissionRequests.where((request) => request.status == tabIndex).length;
  }
  
  // 获取当前选中标签下的权限申请
  List<PermissionRequest> get currentRequests {
    final filteredByStatus = state.permissionRequests.where(
      (request) => request.status == state.selectedTabIndex
    ).toList();
    
    if (state.searchKeyword.isEmpty) {
      return filteredByStatus;
    }
    
    return filteredByStatus.where(
      (request) => request.userId.toLowerCase().contains(state.searchKeyword.toLowerCase())
    ).toList();
  }

  
  // 加载模拟数据
  void _loadMockData() {
    state.permissionRequests = [
      // 已批准的申请
      PermissionRequest(
        userId: 'USER_10086',
        permissionType: '创建普通用户',
        applyTime: '2024-05-11 09:45',
        approveTime: '2024-05-11 10:15',
        status: 0,
      ),
      PermissionRequest(
        userId: 'USER_10087',
        permissionType: '创建管理员用户',
        applyTime: '2024-05-10 14:30',
        approveTime: '2024-05-10 15:20',
        status: 0,
      ),
      // 待审核的申请
      PermissionRequest(
        userId: 'USER_10088',
        permissionType: '创建普通用户',
        applyTime: '2024-05-11 09:45',
        status: 1,
      ),
      PermissionRequest(
        userId: 'USER_10089',
        permissionType: '创建管理员用户',
        applyTime: '2024-05-11 09:45',
        status: 1,
      ),
      PermissionRequest(
        userId: 'USER_10090',
        permissionType: '创建管理员用户',
        applyTime: '2024-05-11 09:45',
        status: 1,
      ),
      // 已驳回的申请
      PermissionRequest(
        userId: 'USER_10091',
        permissionType: '创建普通用户',
        applyTime: '2024-05-09 11:20',
        approveTime: '2024-05-09 14:30',
        status: 2,
      ),
    ];
    update();
  }
}
