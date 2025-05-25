import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_app/utils/toast_util.dart';

import 'user_analysis_state.dart';

class UserAnalysisLogic extends GetxController {
  final UserAnalysisState state = UserAnalysisState();

  @override
  void onReady() {
    super.onReady();
    // 加载数据
    loadUserAnalysisData();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // 加载用户行为分析数据
  void loadUserAnalysisData() {
    // 实际项目中应该从API获取数据
    // 这里使用模拟数据
    _loadMockData();

    // 设置初始时间范围
    updateTimeRange();
  }

  // 加载模拟数据
  void _loadMockData() {
    // 更新城市分布数据
    state.cityDistribution.assignAll({
      '广州市': 19.0,
      '成都市': 27.0,
      '北京市': 22.0,
      '上海市': 12.0,
      '广西市': 10.0,
    });

    // 更新功能使用占比数据
    state.functionUsage.assignAll({
      '内容浏览': 19.0,
      'AI聊天': 27.0,
      '智能分析': 22.0,
      '文档管理': 12.0,
      '其他功能': 15.0,
    });

    // 更新高频访问内容
    state.highFrequencyContent.assignAll([
      {
        'title': '美国芯片出口',
        'visitCount': 89,
        'avgTime': '3:25',
        'conversionRate': 12.5,
        'bounceRate': 34.8,
      },
      {
        'title': '静默GDP增长',
        'visitCount': 72,
        'avgTime': '2:48',
        'conversionRate': 9.7,
        'bounceRate': 28.3,
      },
      {
        'title': '各国安全动态',
        'visitCount': 65,
        'avgTime': '4:12',
        'conversionRate': 15.2,
        'bounceRate': 42.1,
      },
      {
        'title': '黑天鹅事件',
        'visitCount': 58,
        'avgTime': '3:42',
        'conversionRate': 13.9,
        'bounceRate': 35.4,
      },
    ]);

    // 更新用户行为数据
    state.userBehaviors.assignAll([
      {
        'department': '研发部门',
        'user': '张三',
        'action': '浏览报告',
        'time': '2024-05-11 09:45',
        'duration': '5分钟',
        'pages': 28,
        'details': '114页报告',
      },
      {
        'department': '研发部门',
        'user': '李四',
        'action': '导出数据',
        'time': '2024-05-11 09:30',
        'duration': '15分钟',
        'pages': 15,
        'details': '48份数据',
      },
    ]);
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