import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../../models/setting/user_list.dart';

class RoleManagerState {
  List<UserRole> userList = [];
  RxList<UserListElement> filteredUserList = <UserListElement>[].obs;
  RxInt currentPage = 1.obs;
  RxString searchUserName = ''.obs;
  final RxBool hasMoreData = true.obs; // 是否还有更多数据
  final RxBool isLoadingMore = false.obs; // 是否正在加载更多（用于显示底部加载指示器）
  RoleManagerState() {}
}

class UserRole {
  final String id;
  final String name;
  final String role;
  final String status;
  final String lastLoginTime;

  UserRole({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
    required this.lastLoginTime,
  });
}
