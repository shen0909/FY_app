import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_app/utils/toast_util.dart';
import 'package:safe_app/https/api_service.dart';
import 'package:safe_app/utils/area_data_manager.dart';

import 'user_analysis_state.dart';

class UserAnalysisLogic extends GetxController {
  final UserAnalysisState state = UserAnalysisState();

  @override
  void onReady() {
    super.onReady();
    _initializeData();
  }

  /// 初始化数据（异步处理路由参数和接口调用）
  Future<void> _initializeData() async {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      final activateArg = args['today_visit'];
      final todayVisitsTrend = args['today_trend'];
      state.todayVisits.value = activateArg;
      state.todayVisitsTrend.value = todayVisitsTrend;

      // active_region_count
      final region = args['active_region_count'];
      if (region is Map) {
        final mapped = <String, double>{};
        // 确保地区字典已加载（异步）
        await AreaDataManager.instance.loadAreaData();
        region.forEach((k, v) {
          final doubleVal = v is num ? v.toDouble() : double.tryParse('$v') ?? 0.0;
          if (doubleVal > 0) {
            final name = AreaDataManager.instance.cityNameByCode(k.toString());
            mapped[name] = doubleVal;
          }
        });
        if (mapped.isNotEmpty) {
          state.cityDistribution.assignAll(mapped);
        }
      }

      // time_range_active_count
      final timeRange = args['time_range_active_count'];
      if (timeRange is List) {
        state.visitTrendData.assignAll(
          timeRange.map((e) => VisitTrendData(
                e['time']?.toString() ?? '',
                ((e['count'] ?? 0) as int).toDouble(),
              )),
        );
      }
    }
  }

  @override
  void onClose() {
    super.onClose();
  }

  // 更新时间范围显示
  void updateTimeRange() {
    final now = DateTime.now();
    
    switch (state.selectedTabIndex.value) {
      case 0: // 日视图
        state.timeRange.value = '今日 0:00~${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
        break;
      case 1: // 周视图
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        state.timeRange.value = '本周 ${startOfWeek.month}/${startOfWeek.day}~${now.month}/${now.day}';
        break;
      case 2: // 月视图
        state.timeRange.value = '${now.year}年${now.month}月';
        break;
    }
  }

  // 切换图表选项卡
  void changeTab(int index) {
    state.selectedTabIndex.value = index;
    updateTimeRange();
    
    // 实际应用中这里应该重新加载对应时间维度的数据
    // loadChartData(state.selectedTabIndex.value);
  }

  // 搜索文本变化
  void onSearchTextChanged(String text) {
    state.searchText.value = text;
    
    // 实际应用中这里应该根据输入筛选用户列表
    // filterUserBehaviors(text);
  }

  // 显示部门选择器
  void showDepartmentSelector() {
    final departments = ['研发部', '产品部', '市场部', '销售部', '人力资源部'];
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '选择部门',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...departments.map((dept) => ListTile(
              title: Text(dept),
              onTap: () {
                state.selectedDepartment.value = dept;
                Get.back();
                
                // 实际应用中这里应该根据选择的部门过滤数据
                // filterUserBehaviorsByDepartment(dept);
              },
            )).toList(),
            ListTile(
              title: const Text('所有部门'),
              onTap: () {
                state.selectedDepartment.value = '';
                Get.back();
                
                // 实际应用中这里应该重置部门过滤
                // resetDepartmentFilter();
              },
            ),
          ],
        ),
      ),
    );
  }

  // 导出Excel
  void exportToExcel() {
    ToastUtil.showShort('正在导出Excel文件...');
    // 实际应用中这里应该调用导出Excel的API
  }

  // 导出PDF
  void exportToPDF() {
    ToastUtil.showShort('正在导出PDF文件...');
    // 实际应用中这里应该调用导出PDF的API
  }

  // 导出CSV
  void exportToCSV() {
    ToastUtil.showShort('正在导出CSV文件...');
    // 实际应用中这里应该调用导出CSV的API
  }

  // 打印报表
  void printReport() {
    ToastUtil.showShort('正在准备打印报表...');
    // 实际应用中这里应该调用打印报表的API
  }
} 