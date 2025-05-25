import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/widgets/custom_app_bar.dart';

import 'user_analysis_logic.dart';
import 'user_analysis_state.dart';

class UserAnalysisPage extends StatelessWidget {
  UserAnalysisPage({Key? key}) : super(key: key);

  final UserAnalysisLogic logic = Get.put(UserAnalysisLogic());
  final UserAnalysisState state = Get.find<UserAnalysisLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FYColors.whiteColor,
      appBar: FYAppBar(title: '用户行为分析'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatisticsOverview(),
            _buildDivider(),
            _buildTrendSection(),
            _buildDivider(),
            _buildUserDistributionSection(),
            _buildDivider(),
            _buildFunctionUsageSection(),
            _buildDivider(),
            _buildHighFrequencyContentSection(),
            _buildDivider(),
            _buildUserDetailSection(),
            _buildDivider(),
            _buildExportSection(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  // 统计概览
  Widget _buildStatisticsOverview() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatCard(
                '今日访问用户',
                state.todayVisits.toString(),
                state.visitTrend,
                true,
                FYColors.color_07CC89,
              ),
              SizedBox(width: 12.w),
              _buildStatCard(
                '时间浏览次数',
                state.browseTimes.toString(),
                state.browseTrend,
                false,
                FYColors.color_FF3B30,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildStatCard(
                'AI对话次数',
                state.aiChatTimes.toString(),
                state.aiChatTrend,
                true,
                FYColors.color_07CC89,
              ),
              SizedBox(width: 12.w),
              _buildStatCard(
                '活跃度指数',
                state.activityIndex.toString(),
                state.activityTrend,
                true,
                FYColors.color_07CC89,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 统计卡片
  Widget _buildStatCard(String title, String value, double trend, bool isPositive, Color trendColor) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: FYColors.color_F9F9F9,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: FYColors.color_A6A6A6,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: FYColors.color_1A1A1A,
                  ),
                ),
                SizedBox(width: 8.w),
                Row(
                  children: [
                    Text(
                      '${trend.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: trendColor,
                      ),
                    ),
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 12.sp,
                      color: trendColor,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 趋势区域
  Widget _buildTrendSection() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '访问趋势',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: FYColors.color_1A1A1A,
            ),
          ),
          SizedBox(height: 16.h),
          _buildTabSelector(),
          SizedBox(height: 16.h),
          Container(
            height: 240.h,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: FYColors.whiteColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Obx(() => _buildChart()),
          ),
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.timeRange.value,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: FYColors.color_A6A6A6,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.access_time,
                  size: 14.sp,
                  color: FYColors.color_A6A6A6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 图表区域
  Widget _buildChart() {
    // 实际应用中这里应该使用图表库绘制曲线图
    // 如FL_Chart、SyncFusion_Flutter_Charts等
    return Container(
      decoration: BoxDecoration(
        color: FYColors.color_F9F9F9,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: Text(
          '访问趋势图表',
          style: TextStyle(
            fontSize: 14.sp,
            color: FYColors.color_A6A6A6,
          ),
        ),
      ),
    );
  }

  // 选项卡选择器
  Widget _buildTabSelector() {
    return Container(
      height: 36.h,
      decoration: BoxDecoration(
        color: FYColors.color_F5F5F5,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem('日视图', 0),
          ),
          Expanded(
            child: _buildTabItem('周视图', 1),
          ),
          Expanded(
            child: _buildTabItem('月视图', 2),
          ),
        ],
      ),
    );
  }

  // 选项卡项目
  Widget _buildTabItem(String title, int index) {
    return Obx(() {
      bool isSelected = state.selectedTabIndex.value == index;
      return GestureDetector(
        onTap: () => logic.changeTab(index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? FYColors.color_3361FE : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                color: isSelected ? FYColors.whiteColor : FYColors.color_3361FE,
              ),
            ),
          ),
        ),
      );
    });
  }

  // 用户活跃度分布
  Widget _buildUserDistributionSection() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '用户活跃度分布',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: FYColors.color_1A1A1A,
                ),
              ),
              Spacer(),
              Text(
                state.distributionDate,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: FYColors.color_A6A6A6,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.access_time,
                size: 14.sp,
                color: FYColors.color_A6A6A6,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildPieChart(200.h, state.cityDistribution),
        ],
      ),
    );
  }

  // 功能使用占比
  Widget _buildFunctionUsageSection() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '功能使用占比',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: FYColors.color_1A1A1A,
            ),
          ),
          SizedBox(height: 16.h),
          _buildPieChart(200.h, state.functionUsage),
        ],
      ),
    );
  }

  // 饼图
  Widget _buildPieChart(double height, Map<String, dynamic> data) {
    // 实际应用中这里应该使用图表库绘制饼图
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: FYColors.color_F9F9F9,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: FYColors.whiteColor,
              ),
            ),
          ),
          ...data.entries.map((entry) {
            return Positioned(
              left: entry.value['position'].dx,
              top: entry.value['position'].dy,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: entry.value['color'],
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${entry.value['percentage']}%',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: FYColors.color_1A1A1A,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: FYColors.color_666666,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // 高频访问内容
  Widget _buildHighFrequencyContentSection() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '高频访问内容',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: FYColors.color_1A1A1A,
            ),
          ),
          SizedBox(height: 16.h),
          _buildContentTable(),
        ],
      ),
    );
  }

  // 内容表格
  Widget _buildContentTable() {
    return Column(
      children: [
        // 表头
        Container(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: FYColors.color_F0F5FF,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.r),
              topRight: Radius.circular(8.r),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  '内容标题',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: FYColors.color_3361FE,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '访问次数',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: FYColors.color_3361FE,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '平均停留时间',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: FYColors.color_3361FE,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '转发率',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: FYColors.color_3361FE,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '关注率',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: FYColors.color_3361FE,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        // 表格内容
        ...state.highFrequencyContent.map((item) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: FYColors.whiteColor,
              border: Border(
                bottom: BorderSide(
                  color: FYColors.color_F5F5F5,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    item['title'],
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: FYColors.color_1A1A1A,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    item['visitCount'].toString(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: FYColors.color_1A1A1A,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    item['avgTime'],
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: FYColors.color_1A1A1A,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '${item['shareRate']}%',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: FYColors.color_1A1A1A,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '${item['followRate']}%',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: FYColors.color_1A1A1A,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // 用户行为明细
  Widget _buildUserDetailSection() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '用户行为明细',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: FYColors.color_1A1A1A,
            ),
          ),
          SizedBox(height: 16.h),
          _buildSearchBar(),
          SizedBox(height: 16.h),
          _buildDepartmentSelector(),
          SizedBox(height: 16.h),
          _buildUserBehaviorTable(),
        ],
      ),
    );
  }

  // 搜索栏
  Widget _buildSearchBar() {
    return Container(
      height: 36.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: FYColors.whiteColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: FYColors.color_E6E6E6,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 20.sp,
            color: FYColors.color_A6A6A6,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              style: TextStyle(
                fontSize: 14.sp,
                color: FYColors.color_1A1A1A,
              ),
              decoration: InputDecoration(
                hintText: '搜索用户名称',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: FYColors.color_A6A6A6,
                ),
                border: InputBorder.none,
              ),
              onChanged: logic.onSearchTextChanged,
            ),
          ),
        ],
      ),
    );
  }

  // 部门选择器
  Widget _buildDepartmentSelector() {
    return GestureDetector(
      onTap: logic.showDepartmentSelector,
      child: Container(
        height: 32.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: FYColors.color_F5F5F5,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          children: [
            Icon(
              Icons.apps,
              size: 16.sp,
              color: FYColors.color_1A1A1A,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Obx(() => Text(
                state.selectedDepartment.value.isEmpty
                    ? '所有部门'
                    : state.selectedDepartment.value,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: FYColors.color_666666,
                ),
              )),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 12.sp,
              color: FYColors.color_1A1A1A,
            ),
          ],
        ),
      ),
    );
  }

  // 用户行为表格
  Widget _buildUserBehaviorTable() {
    return Column(
      children: [
        // 表头
        Container(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: FYColors.color_F0F5FF,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.r),
              topRight: Radius.circular(8.r),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  '用户',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: FYColors.color_3361FE,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '最近活动',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: FYColors.color_3361FE,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '登录次数',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: FYColors.color_3361FE,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '活动次数',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: FYColors.color_3361FE,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '总时长',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: FYColors.color_3361FE,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        // 表格内容
        ...state.userBehaviors.map((item) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: FYColors.whiteColor,
              border: Border(
                bottom: BorderSide(
                  color: FYColors.color_F5F5F5,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: FYColors.color_1A1A1A,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        item['department'],
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: FYColors.color_A6A6A6,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['activity'],
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: FYColors.color_1A1A1A,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        item['time'],
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: FYColors.color_A6A6A6,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    item['loginCount'].toString(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: FYColors.color_1A1A1A,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    item['activityCount'].toString(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: FYColors.color_1A1A1A,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    item['duration'],
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: FYColors.color_1A1A1A,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // 数据导出
  Widget _buildExportSection() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '数据导出',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: FYColors.color_1A1A1A,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildExportButton('导出Excel', logic.exportToExcel, false),
              SizedBox(width: 12.w),
              _buildExportButton('导出PDF', logic.exportToPDF, false),
              SizedBox(width: 12.w),
              _buildExportButton('导出CSV', logic.exportToCSV, false),
              SizedBox(width: 12.w),
              _buildExportButton('打印报表', logic.printReport, true),
            ],
          ),
        ],
      ),
    );
  }

  // 导出按钮
  Widget _buildExportButton(String text, VoidCallback onTap, bool isPrimary) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36.h,
          decoration: BoxDecoration(
            color: isPrimary ? FYColors.color_3361FE : FYColors.color_F5F5F5,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: isPrimary ? FYColors.whiteColor : FYColors.color_1A1A1A,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 分隔线
  Widget _buildDivider() {
    return Container(
      height: 8.h,
      color: FYColors.color_F5F5F5,
    );
  }
} 