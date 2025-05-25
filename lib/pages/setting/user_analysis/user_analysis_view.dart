import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/widgets/custom_app_bar.dart';
import 'package:fl_chart/fl_chart.dart';

import 'user_analysis_logic.dart';
import 'user_analysis_state.dart';

// 自定义画笔，用于绘制指示线
class LinePainter extends CustomPainter {
  final double startX;
  final double startY;
  final double midX;
  final double midY;
  final double endX;
  final double endY;
  final Color color;

  LinePainter({
    required this.startX,
    required this.startY,
    required this.midX,
    required this.midY,
    required this.endX,
    required this.endY,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(startX, startY)
      ..lineTo(midX, midY)
      ..lineTo(endX, endY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) => false;
}

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

  // 趋势图表
  Widget _buildChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 20,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: FYColors.color_F9F9F9,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: FYColors.color_F9F9F9,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0,
                  child: Text(
                    state.visitTrendData[value.toInt()].time,
                    style: TextStyle(
                      color: FYColors.color_A6A6A6,
                      fontSize: 12.sp,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: TextStyle(
                    color: FYColors.color_A6A6A6,
                    fontSize: 12.sp,
                  ),
                );
              },
              reservedSize: 42,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: FYColors.color_F9F9F9),
        ),
        minX: 0,
        maxX: state.visitTrendData.length - 1.0,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: state.visitTrendData.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.value);
            }).toList(),
            isCurved: true,
            color: FYColors.color_07CC89,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: FYColors.color_07CC89,
                  strokeWidth: 2,
                  strokeColor: FYColors.color_07CC89,
                );
              },
            ),
            /*belowBarData: BarAreaData(
              show: true,
              color: FYColors.color_07CC89.withOpacity(0.1),
            ),*/
          ),
        ],
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '用户活跃度分布',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: FYColors.color_1A1A1A,
                ),
              ),
              Text(
                state.distributionDate,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: FYColors.color_A6A6A6,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildUserDistributionChart(),
        ],
      ),
    );
  }

  // 自定义徽章组件（用于显示指示线和文本）
  Widget _Badge(String title, String value, Color color, int index, int total) {
    // 计算徽章的位置角度
    final double angle = 2 * pi * (index / total) - pi / 2;
    
    // 根据角度确定文本对齐方式和指示线的方向
    final bool isRight = angle >= -pi / 2 && angle <= pi / 2;
    
    // 计算指示线的起始位置（从饼图边缘开始）
    final double radius = 80.0;
    final double lineStartX = cos(angle) * radius;
    final double lineStartY = sin(angle) * radius;
    
    // 计算指示线的弯折点（向外延伸20个单位）
    final double extendLength = 20.0;
    final double lineMidX = cos(angle) * (radius + extendLength);
    final double lineMidY = sin(angle) * (radius + extendLength);
    
    // 计算水平延伸线的长度
    final double horizontalLineLength = 30.0;
    final double endX = isRight ? lineMidX + horizontalLineLength : lineMidX - horizontalLineLength;
    
    return Stack(
      children: [
        // 绘制指示线
        CustomPaint(
          size: Size(200, 200), // 设置合适的绘制区域大小
          painter: LinePainter(
            startX: lineStartX,
            startY: lineStartY,
            midX: lineMidX,
            midY: lineMidY,
            endX: endX,
            endY: lineMidY,
            color: color,
          ),
        ),
        // 绘制文本
        Positioned(
          left: isRight ? endX + 8 : endX - 60,
          top: lineMidY - 10,
          child: Container(
            width: 60,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: isRight ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: FYColors.color_1A1A1A,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: FYColors.color_1A1A1A,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 用户分布饼图
  Widget _buildUserDistributionChart() {
    final List<Color> colors = [
      const Color(0xFF4646DF), // 蓝色
      const Color(0xFF36CBCB), // 青色
      const Color(0xFFFF8F1F), // 橙色
      const Color(0xFF4ECB73), // 绿色
      const Color(0xFFFF6B6B), // 红色
    ];

    return Container(
      height: 280.h,
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 240.w,
              height: 240.w,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: state.cityDistribution.entries.toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    final color = colors[index % colors.length];

                    return PieChartSectionData(
                      color: color,
                      value: data.value,
                      title: '${data.key}\n${data.value.toStringAsFixed(1)}%',
                      radius: 90,
                      titleStyle: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      titlePositionPercentageOffset: 0.6,
                      showTitle: true,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
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
          _buildFunctionUsageChart(),
        ],
      ),
    );
  }

  // 功能使用饼图
  Widget _buildFunctionUsageChart() {
    final List<Color> colors = [
      const Color(0xFF4646DF), // 蓝色
      const Color(0xFF36CBCB), // 青色
      const Color(0xFFFF8F1F), // 橙色
      const Color(0xFF4ECB73), // 绿色
      const Color(0xFFFF6B6B), // 红色
    ];

    return Container(
      height: 280.h,
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 240.w,
              height: 240.w,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: state.functionUsage.entries.toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    final color = colors[index % colors.length];

                    return PieChartSectionData(
                      color: color,
                      value: data.value,
                      title: '${data.key}\n${data.value.toStringAsFixed(1)}%',
                      radius: 90,
                      titleStyle: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      titlePositionPercentageOffset: 0.6,
                      showTitle: true,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
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
          Container(
            height: 280.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                // 固定的第一列（内容标题）
                Container(
                  width: 160.w,
                  child: Column(
                    children: [
                      // 表头
                      Container(
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: FYColors.color_F0F5FF,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8.r),
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 16.w),
                        child: Text(
                          '内容标题',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: FYColors.color_3361FE,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // 数据行
                      Expanded(
                        child: ListView.builder(
                          controller: state.highScrollController,
                          itemCount: state.highFrequencyContent.length,
                          itemBuilder: (context, index) {
                            final item = state.highFrequencyContent[index];
                            return Container(
                              height: 48.h,
                              decoration: BoxDecoration(
                                color: index.isEven ? Colors.white : FYColors.color_F9F9F9,
                                border: Border(
                                  bottom: BorderSide(
                                    color: FYColors.color_F5F5F5,
                                    width: 1,
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                item['title'] ?? '',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: FYColors.color_1A1A1A,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                      width: 400.w,
                      child: Column(
                        children: [
                          // 表头
                          Container(
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: FYColors.color_F0F5FF,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8.r),
                              ),
                            ),
                            child: Row(
                              children: [
                                _buildHeaderCell('访问次数', 100.w),
                                _buildHeaderCell('平均时长', 100.w),
                                _buildHeaderCell('转化率', 100.w),
                                _buildHeaderCell('关注率', 100.w),
                              ],
                            ),
                          ),
                          // 数据行
                          Expanded(
                            child: ListView.builder(
                              controller: state.highScrollController,
                              itemCount: state.highFrequencyContent.length,
                              itemBuilder: (context, index) {
                                final item = state.highFrequencyContent[index];
                                return Container(
                                  height: 48.h,
                                  decoration: BoxDecoration(
                                    color: index.isEven ? Colors.white : FYColors.color_F9F9F9,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: FYColors.color_F5F5F5,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildContentCell(item['visitCount'].toString(), 100.w),
                                      _buildContentCell(item['avgTime'], 100.w),
                                      _buildContentCell('${item['conversionRate']}%', 100.w),
                                      _buildContentCell('${item['bounceRate']}%', 100.w),
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
            ),
          ),
        ],
      ),
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
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          // 固定的第一列（用户信息）
          Container(
            width: 100.w,
            child: Column(
              children: [
                // 表头
                Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: FYColors.color_F0F5FF,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.r),
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 16.w),
                  child: Text(
                    '用户',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: FYColors.color_3361FE,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // 数据行
                Expanded(
                  child: ListView.builder(
                    controller: state.highScrollController,
                    itemCount: state.userBehaviors.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final item = state.userBehaviors[index];
                      return Container(
                        height: 64.h,
                        decoration: BoxDecoration(
                          color: index.isEven ? Colors.white : FYColors.color_F9F9F9,
                          border: Border(
                            bottom: BorderSide(
                              color: FYColors.color_F5F5F5,
                              width: 1,
                            ),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item['user'] ?? '',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: FYColors.color_1A1A1A,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              item['department'] ?? '',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: FYColors.color_A6A6A6,
                              ),
                            ),
                          ],
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
                width: 500.w,
                child: Column(
                  children: [
                    // 表头
                    Container(
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: FYColors.color_F0F5FF,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8.r),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildHeaderCell('最近活动', 200.w),
                          _buildHeaderCell('登录次数', 100.w),
                          _buildHeaderCell('活动次数', 100.w),
                          _buildHeaderCell('总时长', 100.w),
                        ],
                      ),
                    ),
                    // 数据行
                    Expanded(
                      child: ListView.builder(
                        controller: state.listScrollController,
                        itemCount: state.userBehaviors.length,
                        itemBuilder: (context, index) {
                          final item = state.userBehaviors[index];
                          return Container(
                            height: 64.h,
                            decoration: BoxDecoration(
                              color: index.isEven ? Colors.white : FYColors.color_F9F9F9,
                              border: Border(
                                bottom: BorderSide(
                                  color: FYColors.color_F5F5F5,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 200.w,
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item['action'] ?? '',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: FYColors.color_1A1A1A,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        item['time'] ?? '',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: FYColors.color_A6A6A6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildContentCell(item['pages'].toString(), 100.w),
                                _buildContentCell(item['duration'], 100.w),
                                _buildContentCell(item['details'], 100.w),
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
      ),
    );
  }

  // 表头单元格
  Widget _buildHeaderCell(String title, double width) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          color: FYColors.color_3361FE,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // 内容单元格
  Widget _buildContentCell(String text, double width) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          color: FYColors.color_1A1A1A,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
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