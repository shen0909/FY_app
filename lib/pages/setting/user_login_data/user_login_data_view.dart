import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/widgets/custom_app_bar.dart';

import '../../../styles/image_resource.dart';
import '../../../models/login_log_list.dart';
import 'user_login_data_logic.dart';
import 'user_login_data_state.dart';

class UserLoginDataPage extends StatelessWidget {
  UserLoginDataPage({Key? key}) : super(key: key);

  final UserLoginDataLogic logic = Get.put(UserLoginDataLogic());
  final UserLoginDataState state = Get.find<UserLoginDataLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FYColors.color_F5F5F5,
      appBar: FYAppBar(
        title: '用户登录日志',
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      // 首次加载状态（只在数据为空且不是刷新状态时显示）
      if (state.isLoading.value && state.loginLogs.isEmpty && !state.isRefreshing.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      // 获取分组数据
      Map<String, List<ListElement>> groupedLogs = logic.getGroupedLogs();

      return RefreshIndicator(
        onRefresh: logic.onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            // 确保内容区域至少占满屏幕高度，使下拉刷新可用
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(Get.context!).size.height - 
                        MediaQuery.of(Get.context!).padding.top - 
                        kToolbarHeight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 空数据状态
                if (groupedLogs.isEmpty && !state.isLoading.value)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64.w,
                            color: FYColors.color_A6A6A6,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            '暂无登录日志数据',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: FYColors.color_A6A6A6,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            '下拉刷新试试',
                            style: TextStyle(
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // 数据列表
                if (groupedLogs.isNotEmpty) ...[
                  ...groupedLogs.entries.map((entry) {
                    return _buildDateSection(entry.key, entry.value);
                  }).toList(),
                  // 加载更多按钮/状态
                  _buildLoadMoreSection(),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  /// 构建加载更多区域
  Widget _buildLoadMoreSection() {
    return Obx(() {
      if (state.isLoadingMore.value) {
        // 正在加载更多
        return Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16.w,
                height: 16.w,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8.w),
              Text(
                '加载中...',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: FYColors.color_A6A6A6,
                ),
              ),
            ],
          ),
        );
      } else if (!state.hasMore.value) {
        // 没有更多数据
        return Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Text(
            '已加载全部 ${state.totalCount.value} 条记录',
            style: TextStyle(
              fontSize: 14.sp,
              color: FYColors.color_A6A6A6,
            ),
          ),
        );
      } else {
        // 可以加载更多
        return GestureDetector(
          onTap: logic.loadMoreLogs,
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '加载更多记录',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: FYColors.color_3361FE,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_right,
                  size: 16.sp,
                  color: FYColors.color_3361FE,
                ),
              ],
            ),
          ),
        );
      }
    });
  }

  Widget _buildDateSection(String date, List<ListElement> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.w, top: 16.h, bottom: 8.h),
          child: Text(
            date,
            style: TextStyle(
              fontSize: 16.sp,
              color: FYColors.color_1A1A1A,
            ),
          ),
        ),
        Container(
          color: FYColors.whiteColor,
          child: Column(
            children: logs.map((log) => _buildLogItem(log)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLogItem(ListElement log) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          // 登录状态图标
          Image.asset(FYImages.user_avatar,
              width: 32.w, height: 32.w, fit: BoxFit.contain),
          SizedBox(width: 12.w),
          // 登录状态和信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.success ? '登录成功' : '登录失败',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: log.success
                        ? FYColors.color_1A1A1A
                        : FYColors.highRiskBorder,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'UUID: ${log.userUuid}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: FYColors.color_A6A6A6,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // 登录时间
          Text(
            state.formatTime(log.createdAt),
            style: TextStyle(
              fontSize: 12.sp,
              color: FYColors.color_A6A6A6,
            ),
          ),
        ],
      ),
    );
  }
}
