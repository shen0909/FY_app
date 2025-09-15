import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/https/api_service.dart';
import 'package:safe_app/models/setting/permission_list.dart';
import 'package:safe_app/utils/dialog_utils.dart';

import '../../../styles/colors.dart';
import 'permission_request_state.dart';

class PermissionRequestLogic extends GetxController {
  final PermissionRequestState state = PermissionRequestState();

  @override
  void onInit() {
    super.onInit();
    // 监听左侧列表的滚动，并同步到右侧
    state.verticalControllerLeft.addListener(() {
      if (state.verticalControllerLeft.position.pixels != state.verticalControllerRight.position.pixels) {
        state.verticalControllerRight.jumpTo(state.verticalControllerLeft.position.pixels);
      }
    });

    // 监听右侧列表的滚动，并同步到左侧
    state.verticalControllerRight.addListener(() {
      if (state.verticalControllerRight.position.pixels != state.verticalControllerLeft.position.pixels) {
        state.verticalControllerLeft.jumpTo(state.verticalControllerRight.position.pixels);
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    // 加载默认数据
    _loadData();
  }

  @override
  void onClose() {
    super.onClose();
  }
  
  // 切换标签
  void switchTab(int index) {
    state.selectedTabIndex.value = index;
  }
  
  // 搜索用户
  void searchUser(String keyword) {
    state.searchKeyword.value = keyword;
  }
  
  // 批准申请
  Future<void> approveRequest(PermissionListElement request) async {
    final result = await showDialog(
      context: Get.context!,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: FYColors.whiteColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '是否批准该申请',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                color: const Color(0xFF1A1A1A),
                fontWeight: FontWeight.w400,
                fontFamily: 'AlibabaPuHuiTi',
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
              // 不批准按钮
              Expanded(
                child: InkWell(
                  onTap: () => Get.back(result: false),
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
                      '驳回',
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
                  onTap: () => Get.back(result: true),
                  child: Container(
                    height: 44.w,
                    alignment: Alignment.center,
                    child: Text(
                      '批准',
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

    final resultPermission = await ApiService().dealPermission(
        applicationUuid: request.applicant.uuid,
        isApproved: result,
        processReason: '');
    if(resultPermission!= null && resultPermission['返回数据'] != null) {
      await _loadData(); //重新加载数据
    }
  }
  
  // 驳回申请
  void rejectRequest(PermissionRequest request) {

  }
  
  // 获取当前标签的申请数量
  int getTabCount(int tabIndex) {
    return state.permissionRequests.where((request) => request.status == tabIndex).length;
  }
  
  // // 获取当前选中标签下的权限申请
  List<PermissionListElement> get currentRequests {
    List<PermissionListElement> filteredByStatus = state.permissionRequests.where(
      (request) => request.status == state.selectedTabIndex.value
    ).toList();
    return filteredByStatus;
  }

  
  // 加载数据
  Future<void> _loadData() async {
    DialogUtils.showLoading();
   final result = await ApiService().getPermissionList(currentPage: 1);
   DialogUtils.hideLoading();
   if(result != null) {
     PermissionList permissionList = PermissionList.fromMap(result);
     state.permissionRequests.value = permissionList.list;
   }
  }
}
