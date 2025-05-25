import 'package:flutter/cupertino.dart';

class PermissionRequestState {
  // 当前选中的标签索引：0-已批准申请，1-待审核，2-已驳回
  int selectedTabIndex = 1;
  
  // 权限申请列表
  List<PermissionRequest> permissionRequests = [];
  
  // 搜索关键词
  String searchKeyword = '';

  TextEditingController  searchController = TextEditingController();

  PermissionRequestState() {
    ///Initialize variables
  }
}

// 权限申请模型
class PermissionRequest {
  final String userId;
  final String permissionType;
  final String applyTime;
  final String? approveTime;
  final int status; // 0-已批准，1-待审核，2-已驳回
  final String? remark; // 备注信息
  
  PermissionRequest({
    required this.userId,
    required this.permissionType,
    required this.applyTime,
    this.approveTime,
    required this.status,
    this.remark,
  });
}
