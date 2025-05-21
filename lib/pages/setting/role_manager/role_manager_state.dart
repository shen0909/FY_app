class RoleManagerState {
  List<UserRole> userList = [];
  String? selectedRole;

  RoleManagerState() {
    ///初始化数据
    userList = [
      UserRole(
        id: 'ZQP001',
        name: '张三',
        role: '管理员',
        status: '在线',
        lastLoginTime: '2024-05-11 09:45',
      ),
      UserRole(
        id: 'ZQP002',
        name: '李四',
        role: '审核员',
        status: '离线',
        lastLoginTime: '2024-05-11 09:45',
      ),
      UserRole(
        id: 'ZQP003',
        name: '王五',
        role: '普通用户',
        status: '申请中',
        lastLoginTime: '2024-05-11 09:45',
      ),
    ];
  }
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
