import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:safe_app/models/setting/permission_list.dart';

class PermissionRequestState {
  RxList<PermissionListElement> permissionRequests = <PermissionListElement>[].obs;

  // 当前选中的标签索引：0-待审核，1-已批准申请，2-已驳回
  RxInt selectedTabIndex = 0.obs;
  
  // // 权限申请列表
  // List<PermissionRequest> permissionRequests = [];
  
  // 搜索关键词
  RxString searchKeyword = ''.obs;

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
