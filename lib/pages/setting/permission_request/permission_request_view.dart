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
              _showPermissionDetailDialog(context);
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
              padding: EdgeInsets.only(
                  left: 16.w, right: 16.w, top: 16.h, bottom: 16.h),
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
                          Icon(Icons.search,
                              color: FYColors.color_3A3A3A, size: 20.w),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: TextField(
                              controller: state.searchController,
                              onChanged: logic.searchUser,
                              decoration: InputDecoration(
                                hintText: '搜索用户名称',
                                hintStyle: TextStyle(
                                    color: FYColors.color_A6A6A6,
                                    fontSize: 14.sp),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8.h),
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
                  return _buildScrollableTable(requests);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 申请详情弹窗
  void _showPermissionDetailDialog(BuildContext context) {
    final approvedRequest = state.permissionRequests.firstWhere(
      (request) => request.status == 0,
      orElse: () => state.permissionRequests.first,
    );
    
    // 获取屏幕高度的80%
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogHeight = screenHeight * 0.8;
    
    Get.bottomSheet(
      Container(
        width: 375.w,
        height: dialogHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
          ),
        ),
        child: Column(
          children: [
            // 弹窗标题栏
            Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '申请详情',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: FYColors.color_1A1A1A,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 24.w,
                      height: 24.h,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.close,
                        size: 20.sp,
                        color: FYColors.color_1A1A1A,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 用户信息
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Row(
                children: [
                  // 用户头像
                  Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 30.sp,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  // 用户信息
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '刘晓龙',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: FYColors.color_1A1A1A,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '用户名：ZQP001',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: FYColors.color_1A1A1A,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  // 批准状态
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7FEF8),
                      borderRadius: BorderRadius.circular(12.5.r),
                    ),
                    child: Text(
                      '已批准',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF07CC89),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 申请信息
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    // 申请编号
                    _buildInfoItem('申请编号', 'REO-2024-0301'),

                    // 申请时间
                    _buildInfoItem('申请时间', '2024-05-03 09:15'),

                    // 申请权限
                    _buildInfoItem('申请权限', approvedRequest.permissionType),

                    // 批准时间
                    _buildInfoItem('批准时间', approvedRequest.approveTime ?? ''),

                    // 申请原因
                    _buildReasonItem(
                      '申请原因',
                      '部门新增员工，需要创建新的普通用户账号用于系统访问和日常工作。',
                    ),

                    // 批准备注
                    _buildReasonItem(
                      '批准备注',
                      '用户已完成相关培训，符合权限授予条件。已向用户发送权限使用指南。',
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),

            // 底部按钮
            Container(
              height: 72.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3361FE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                  minimumSize: Size(double.infinity, 48.h),
                ),
                child: Text(
                  '关闭',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true, // 允许弹窗内容滚动
    );
  }

  // 构建信息项
  Widget _buildInfoItem(String label, String value) {
    return Container(
      height: 48.h,
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9).withOpacity(0),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.transparent, width: 0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF666666),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: FYColors.color_1A1A1A,
            ),
          ),
        ],
      ),
    );
  }

  // 构建多行文本项
  Widget _buildReasonItem(String label, String content) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16.w),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF666666),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14.sp,
                color: FYColors.color_1A1A1A,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 可滚动表格
  Widget _buildScrollableTable(List<PermissionRequest> requests) {
    // 使用两个同步滚动控制器，确保左右两侧列表同步滚动
    final ScrollController verticalController = ScrollController();

    return Row(
      children: [
        // 固定的第一列（账户ID）
        Container(
          width: 90.w,
          child: Column(
            children: [
              // 表头
              Container(
                height: 28.h,
                color: const Color(0xFFF0F5FF),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 8.w),
                child: Text(
                  '账户ID',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF3361FE),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              // 数据行
              Expanded(
                child: ListView.builder(
                  controller: verticalController, // 使用同一个滚动控制器
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final item = requests[index];
                    final isEven = index % 2 == 0;
                    return Container(
                      height: 44.h,
                      color: isEven ? Colors.white : const Color(0xFFF9F9F9),
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 8.w),
                      child: Text(
                        item.userId,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: FYColors.color_1A1A1A,
                          overflow: TextOverflow.ellipsis, // 文本溢出时显示省略号
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // 右侧可滚动部分
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: 520.w, // 设置一个适当的宽度，确保内容能够滚动
              child: Column(
                children: [
                  // 表头行
                  Container(
                    height: 28.h,
                    color: const Color(0xFFF0F5FF),
                    child: Row(
                      children: [
                        _buildHeaderCell('申请权限', width: 120.w),
                        _buildHeaderCell('申请时间', width: 120.w),
                        _buildHeaderCell('批准时间', width: 140.w),
                        _buildHeaderCell('备注', width: 140.w),
                      ],
                    ),
                  ),
                  // 数据行
                  Expanded(
                    child: ListView.builder(
                      controller: verticalController, // 使用同一个滚动控制器，保持左右同步
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final item = requests[index];
                        final isEven = index % 2 == 0;
                        return Container(
                          height: 44.h,
                          color:
                              isEven ? Colors.white : const Color(0xFFF9F9F9),
                          child: Row(
                            children: [
                              _buildDataCell(item.permissionType, width: 120.w),
                              _buildDataCell(item.applyTime, width: 120.w),
                              _buildActionOrTimeCell(item, width: 140.w),
                              _buildDataCell(item.remark ?? '',
                                  width: 140.w,
                                  color: _getRemarkColor(item.status)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 表头单元格（右侧滚动部分使用）
  Widget _buildHeaderCell(String title, {required double width}) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.sp,
          color: const Color(0xFF3361FE),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  // 数据单元格（右侧滚动部分使用）
  Widget _buildDataCell(String text, {required double width, Color? color}) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          color: color ?? FYColors.color_1A1A1A,
          overflow: TextOverflow.ellipsis, // 文本溢出时显示省略号
        ),
        maxLines: 1, // 限制为单行
      ),
    );
  }

  // 操作按钮或时间单元格（右侧滚动部分使用）
  Widget _buildActionOrTimeCell(PermissionRequest item,
      {required double width}) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      alignment: Alignment.centerLeft,
      child: item.status == 1
          ? _buildActionButtons(item)
          : Text(
              item.approveTime ?? '',
              style: TextStyle(
                fontSize: 12.sp,
                color: FYColors.color_1A1A1A,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
    );
  }

  // 根据状态获取备注文本颜色
  Color _getRemarkColor(int status) {
    switch (status) {
      case 0: // 已批准
        return const Color(0xFF07CC89);
      case 1: // 待审核
        return FYColors.color_1A1A1A;
      case 2: // 已驳回
        return const Color(0xFFFF3B30);
      default:
        return FYColors.color_1A1A1A;
    }
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
        // SizedBox(width: 8.w),
        // GestureDetector(
        //   onTap: () => logic.rejectRequest(item),
        //   child: Container(
        //     padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        //     decoration: BoxDecoration(
        //       color: const Color(0xFFFFECE9),
        //       borderRadius: BorderRadius.circular(4.r),
        //     ),
        //     child: Row(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         Icon(Icons.close, color: const Color(0xFFFF3B30), size: 12.w),
        //         SizedBox(width: 2.w),
        //         Text(
        //           '驳回',
        //           style: TextStyle(
        //             fontSize: 12.sp,
        //             color: const Color(0xFFFF3B30),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }

  // 标签栏
  Widget _buildTabBar() {
    return Container(
      // height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: GetBuilder<PermissionRequestLogic>(builder: (logic) {
        return Row(
          children: [
            _buildTabItem(
                title: '已批准申请',
                count: logic.getTabCount(0),
                index: 0,
                bgColor: const Color(0xFFE7FEF8),
                countColor: const Color(0xFF07CC89),
                isSelected: state.selectedTabIndex == 0,
                iconPath: FYImages.check_gree),
            SizedBox(width: 12.w),
            _buildTabItem(
                title: '待审核',
                count: logic.getTabCount(1),
                index: 1,
                bgColor: const Color(0xFFF9F9F9),
                countColor: Colors.black,
                isSelected: state.selectedTabIndex == 1,
                iconPath: FYImages.uncheck),
            SizedBox(width: 12.w),
            _buildTabItem(
                title: '已驳回',
                count: logic.getTabCount(2),
                index: 2,
                bgColor: const Color(0xFFFFECE9),
                countColor: const Color(0xFFFF3B30),
                isSelected: state.selectedTabIndex == 2,
                iconPath: FYImages.refuse_red),
          ],
        );
      }),
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
          width: 106.w,
          padding: EdgeInsets.only(left: 6.w, right: 4.w, top: 10.w, bottom: 5),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8.r),
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
              Image.asset(
                iconPath,
                width: 24.w,
                height: 24.w,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
