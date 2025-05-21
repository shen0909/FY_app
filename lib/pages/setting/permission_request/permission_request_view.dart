import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/image_resource.dart';
import 'package:safe_app/widgets/custom_app_bar.dart';

import 'permission_request_logic.dart';
import 'permission_request_state.dart';

class PermissionRequestPage extends StatelessWidget {
  PermissionRequestPage({Key? key}) : super(key: key);

  final PermissionRequestLogic logic = Get.put(PermissionRequestLogic());
  final PermissionRequestState state = Get.find<PermissionRequestLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FYAppBar(
        title: '权限申请审核',
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: FYColors.color_1A1A1A),
            onPressed: () {
              // 帮助说明
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabBar(),
            Padding(
              padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 16.h, bottom: 16.h),
              child: Row(
                children: [
                  Text(
                    '权限申请列表',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Container(
                      height: 36.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: FYColors.color_E6E6E6),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 16.w),
                          Icon(
                              Icons.search,
                              color: FYColors.color_3A3A3A,
                              size: 20.w
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: TextField(
                              controller: state.searchController,
                              onChanged: logic.searchUser,
                              decoration: InputDecoration(
                                hintText: '搜索用户名称',
                                hintStyle: TextStyle(
                                    color: FYColors.color_A6A6A6,
                                    fontSize: 14.sp
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16.w, top: 20.h, bottom: 10.h),
              child: Text(
                '权限申请列表',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            _buildTableHeader(),
            Expanded(
              child: GetBuilder<PermissionRequestLogic>(
                builder: (logic) {
                  final requests = logic.currentRequests;
                  if (requests.isEmpty) {
                    return Center(
                      child: Text(
                        '暂无数据',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: FYColors.color_A6A6A6,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final item = requests[index];
                      final isEven = index % 2 == 0;
                      return _buildTableRow(item, isEven);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 标签栏
  Widget _buildTabBar() {
    return Container(
      // height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: GetBuilder<PermissionRequestLogic>(
        builder: (logic) {
          return Row(
            children: [
              _buildTabItem(
                title: '已批准申请',
                count: logic.getTabCount(0),
                index: 0,
                bgColor: const Color(0xFFE7FEF8),
                countColor: const Color(0xFF07CC89),
                isSelected: state.selectedTabIndex == 0,
                iconPath: FYImages.check_gree
              ),
              SizedBox(width: 12.w),
              _buildTabItem(
                title: '待审核',
                count: logic.getTabCount(1),
                index: 1,
                bgColor: const Color(0xFFF9F9F9),
                countColor: Colors.black,
                isSelected: state.selectedTabIndex == 1,
                iconPath: FYImages.uncheck
              ),
              SizedBox(width: 12.w),
              _buildTabItem(
                title: '已驳回',
                count: logic.getTabCount(2),
                index: 2,
                bgColor: const Color(0xFFFFECE9),
                countColor: const Color(0xFFFF3B30),
                isSelected: state.selectedTabIndex == 2,
                  iconPath: FYImages.refuse_red
              ),
            ],
          );
        }
      ),
    );
  }

  // 标签项
  Widget _buildTabItem({
    required String title,
    required int count,
    required int index,
    required Color bgColor,
    required Color countColor,
    required bool isSelected,
    required String iconPath,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => logic.switchTab(index),
        child: Container(
          // height: 56.h,
          padding: EdgeInsets.only(left: 10.w,right: 4.w,top: 10.w,bottom: 5),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8.r),
            // border: isSelected
            //     ? Border.all(color: const Color(0xFFE6E6E6), width: 2.w)
            //     : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: FYColors.color_1A1A1A,
                    ),
                  ),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: countColor,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Image.asset(iconPath,width: 24.w,height: 24.w,fit: BoxFit.contain,),
            ],
          ),
        ),
      ),
    );
  }

  // 表格头部
  Widget _buildTableHeader() {
    return Container(
      height: 28.h,
      color: const Color(0xFFF0F5FF),
      child: Row(
        children: [
          _buildHeaderCell('账户ID', flex: 2),
          _buildHeaderCell('申请权限', flex: 3),
          _buildHeaderCell('申请时间', flex: 3),
          _buildHeaderCell('批准时间', flex: 3),
        ],
      ),
    );
  }

  // 表头单元格
  Widget _buildHeaderCell(String title, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF3361FE),
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // 表格行
  Widget _buildTableRow(PermissionRequest item, bool isEven) {
    return Container(
      height: 44.h,
      color: isEven ? Colors.white : const Color(0xFFF9F9F9),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                item.userId,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: FYColors.color_1A1A1A,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                item.permissionType,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: FYColors.color_1A1A1A,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                item.applyTime,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: FYColors.color_1A1A1A,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child:
              // item.status == 1
              //     ? _buildActionButtons(item)
              //     :
              Text(
                      item.applyTime ?? '',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: FYColors.color_1A1A1A,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // 操作按钮（批准/驳回）
  Widget _buildActionButtons(PermissionRequest item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => logic.approveRequest(item),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE7FEF8),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, color: const Color(0xFF07CC89), size: 12.w),
                SizedBox(width: 2.w),
                Text(
                  '批准',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF07CC89),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: () => logic.rejectRequest(item),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFECE9),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close, color: const Color(0xFFFF3B30), size: 12.w),
                SizedBox(width: 2.w),
                Text(
                  '驳回',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFFFF3B30),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
