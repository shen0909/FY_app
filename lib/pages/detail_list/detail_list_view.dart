import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/image_resource.dart';
import 'package:safe_app/widgets/custom_app_bar.dart';
import 'package:fl_chart/fl_chart.dart';

import 'detail_list_logic.dart';
import 'detail_list_state.dart';

/// 清单信息
class DetailListPage extends StatelessWidget {
  DetailListPage({Key? key}) : super(key: key);

  final DetailListLogic logic = Get.put(DetailListLogic());
  final DetailListState state = Get
      .find<DetailListLogic>()
      .state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FYColors.whiteColor,
      appBar: FYAppBar(title: '实体清单'),
      body: SingleChildScrollView(
        controller: logic.yearlyStatsController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildYearlyStatsTable(),
            _buildDivider(),
            _buildInfoSection(),
            _buildFilterSection(),
            _buildFilterChips(context),
            _buildResultCount(),
            _buildTable(),
          ],
        ),
      ),
    );
  }

  // 信息区域
  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "当前总数：",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: FYColors.color_A6A6A6,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Obx(() {
                return Text(
                  "${state.totalCount}",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: FYColors.color_3361FE,
                    fontWeight: FontWeight.normal,
                  ),
                );
              }),
            ],
          ),
          Text(
            "更新时间：2025-05-15",
            style: TextStyle(
              fontSize: 12.sp,
              color: FYColors.color_A6A6A6,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // 筛选条件区域
  Widget _buildFilterSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
      child: Row(
        children: [
          Text(
            "筛选条件",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: FYColors.color_1A1A1A,
            ),
          ),
          const Spacer(),
          Container(
            width: 197.w,
            decoration: BoxDecoration(
              color: FYColors.whiteColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: FYColors.color_E6E6E6),
            ),
            child: Row(
              children: [
                SizedBox(width: 8.w),
                Image.asset(FYImages.search_icon, width: 20.w,
                  height: 20.w,
                  fit: BoxFit.contain,),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextField(
                    style: TextStyle(
                      fontSize: 14.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: '请输入企业名称',
                      hintStyle: TextStyle(
                        color: FYColors.color_A6A6A6,
                        fontSize: 14.sp,
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                    ),
                    onChanged: (value) => logic.search(value),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 筛选标签区域
  Widget _buildFilterChips(BuildContext context) {
    return Container(
      height: 56,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: _buildFilterChip(
              context, "类型", state.typeFilter, logic.typeKey)),
          const SizedBox(width: 12),
          Expanded(child: _buildFilterChip(
              context, "省份", state.provinceFilter, logic.provinceKey)),
          const SizedBox(width: 12),
          Expanded(child: _buildFilterChip(
              context, "城市", state.cityFilter, logic.cityKey)),
        ],
      ),
    );
  }

  // 筛选按钮
  Widget _buildFilterChip(BuildContext context, String title, Rx<String> filter,
      GlobalKey key) {
    return Obx(() {
      final bool hasValue = filter.value.isNotEmpty;

      return InkWell(
        key: key,
        onTap: () {
          logic.showFilterOverlay(context, title, key);
        },
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: hasValue ? Color(0xFFF0F5FF) : Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(8),
            border: hasValue
                ? Border.all(color: Color(0xFF3361FE), width: 1)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hasValue ? filter.value : title,
                style: TextStyle(
                  fontSize: 14,
                  color: hasValue ? Color(0xFF3361FE) : Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              Icon(
                hasValue ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                size: 16,
                color: hasValue ? Color(0xFF3361FE) : Color(0xFF1A1A1A),
              ),
            ],
          ),
        ),
      );
    });
  }

  // 结果数量
  Widget _buildResultCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(() =>
          Text(
            "${state.companyList.length} 条结果",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF3361FE),
              fontWeight: FontWeight.normal,
            ),
          )),
    );
  }

  // 表格实现
  Widget _buildTable() {
    return Container(
      height: 400.h, // 设置一个固定高度
      child: Obx(() {
        if (state.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return Row(
          children: [
            // 固定的首列（序号列）
            Container(
              width: 50.w,
              child: Column(
                children: [
                  // 首列表头
                  Container(
                    height: 28.h,
                    color: Color(0xFFF0F5FF),
                    alignment: Alignment.center,
                    child: Text(
                      "序号",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Color(0xFF3361FE),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),

                  // 首列数据
                  Expanded(
                    child: ListView.builder(
                      controller: logic.leftVerticalController,
                      itemCount: state.companyList.length,
                      itemBuilder: (context, index) {
                        final isOdd = index % 2 == 1;
                        return Container(
                          height: 44.h,
                          color: isOdd ? Colors.white : Color(0xFFF9F9F9),
                          alignment: Alignment.center,
                          child: Text(
                            "${state.companyList[index].id}",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Color(0xFF1A1A1A),
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
              child: Stack(
                children: [
                  // 滚动内容
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: logic.horizontalScrollController,
                    child: SizedBox(
                      // 设置足够的宽度让内容可以滚动
                      width: 510.w,
                      child: Column(
                        children: [
                          // 表头行
                          Container(
                            height: 28.h,
                            color: Color(0xFFF0F5FF),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 150.w,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 8.w),
                                    child: Text(
                                      "名称",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Color(0xFF3361FE),
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  // width: 229.w,
                                  child: Text(
                                    "制裁类型",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Color(0xFF3361FE),
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 100.w,
                                  child: Text(
                                    "地区",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Color(0xFF3361FE),
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80.w,
                                  child: Text(
                                    "时间",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Color(0xFF3361FE),
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 80.w,
                                  child: Text(
                                    "移除时间",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Color(0xFF3361FE),
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 表格数据行
                          Expanded(
                            child: ListView.builder(
                              controller: logic.rightVerticalController,
                              itemCount: state.companyList.length,
                              itemBuilder: (context, index) {
                                final item = state.companyList[index];
                                final isOdd = index % 2 == 1;

                                return Container(
                                  height: 44.h,
                                  color: isOdd ? Colors.white : Color(0xFFF9F9F9),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 150.w,
                                        child: Padding(
                                          padding: EdgeInsets.only(left: 8.w),
                                          child: Text(
                                            item.name,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Color(0xFF1A1A1A),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        // width: 229.w,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                                          child: _buildSanctionTypeTag(item.sanctionType),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 100.w,
                                        child: Text(
                                          item.region,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Color(0xFF1A1A1A),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 80.w,
                                        child: Text(
                                          item.time,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Color(0xFF1A1A1A),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 80.w,
                                        child: Text(
                                          item.removalTime,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Color(0xFF1A1A1A),
                                          ),
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
                  ),
                  // 右侧滑动指示阴影
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Obx(() {
                      // 当没有数据时不显示指示器
                      if (state.companyList.isEmpty) {
                        return SizedBox();
                      }
                      return Container(
                        width: 16.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.1),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // 构建制裁类型标签
  Widget _buildSanctionTypeTag(String type) {
    Color bgColor;
    Color textColor;

    if (type.contains('EL')) {
      bgColor = Color(0xFFFFECE9);
      textColor = Color(0xFFFF2A08);
    } else if (type.contains('Non-SDN CMIC') || type.contains('NS-CMIC')) {
      bgColor = Color(0xFFFFF7E9);
      textColor = Color(0xFFFFA408);
    } else if (type.contains('CMC') || type.contains('SSI')) {
      bgColor = Color(0xFFE7FEF8);
      textColor = Color(0xFF07CC89);
    } else {
      // 默认情况（UVL/DPL/其他）
      bgColor = Color(0xFFEDEDED);
      textColor = Color(0xFF1A1A1A);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text(
            type,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(width: 4.w),
          Icon(Icons.remove_red_eye_outlined,size: 14.w,color: textColor)
        ],
      ),
    );
  }

  // 分割线
  Widget _buildDivider() {
    return Container(
      height: 8.h,
      color: Color(0xFFF5F5F5),
    );
  }

  // 年度统计表格改为折线图
  Widget _buildYearlyStatsTable() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和位置选择器
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "实体清单趋势",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // 添加位置选择功能
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16.sp,
                        color: Color(0xFF1A1A1A),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "广东省",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12.sp,
                        color: Color(0xFF1A1A1A),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          Text(
            "新增实体数量",
            style: TextStyle(
              fontSize: 14.sp,
              color: Color(0xFF808080),
            ),
          ),
          SizedBox(height: 5.h),
          // 折线图
          Container(
            height: 200.h,
            child: Obx(() {
              // 如果没有数据，显示空视图
              if (state.yearlyStats.isEmpty) {
                return Center(child: Text("暂无数据"));
              }
              return LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 30.w,
                    // horizontalInterval: 38,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Color(0xFFEEEEEE),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          // 年份标签
                          if (value.toInt() >= 0 && value.toInt() < state.yearlyStats.length) {
                            final year = state.yearlyStats[value.toInt()].year;
                            return Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Transform.rotate(
                                angle: -0.785398, // 45度角
                                child: Text(
                                  year,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Color(0xFF808080),
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 40,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox();
                          return Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: Color(0xFF808080),
                                fontSize: 10.sp,
                              ),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: state.yearlyStats.length - 1.0,
                  minY: 0,
                  maxY: _getMaxYValue(),
                  lineBarsData: [
                    // 累计总数曲线
                    LineChartBarData(
                      spots: List.generate(state.yearlyStats.length, (index) {
                        return FlSpot(index.toDouble(), state.yearlyStats[index].totalCount.toDouble());
                      }),
                      isCurved: true,
                      color: Color(0xFF3361FE),
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Color(0xFF3361FE),
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: false,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          
          SizedBox(height: 16.h),
          
          // 图例说明
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 16.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: Color(0xFFD3DCFF),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    "新增实体数量",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: FYColors.color_1A1A1A,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 24.w),
              Row(
                children: [
                  Container(
                    width: 16.w,
                    height: 3.h,
                    decoration: BoxDecoration(
                      color: Color(0xFF3361FE),
                      borderRadius: BorderRadius.circular(1.5.r),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    "累计总数",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: FYColors.color_1A1A1A,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 获取图表Y轴最大值
  double _getMaxYValue() {
    if (state.yearlyStats.isEmpty) return 240;
    
    double maxTotal = 0;
    double maxNew = 0;
    
    for (var stat in state.yearlyStats) {
      if (stat.totalCount > maxTotal) {
        maxTotal = stat.totalCount.toDouble();
      }
      if (stat.newCount > maxNew) {
        maxNew = stat.newCount.toDouble();
      }
    }
    
    // 向上取整到最接近的40的倍数
    return (((maxTotal > maxNew ? maxTotal : maxNew) ~/ 40) + 1) * 40.0;
  }
}
