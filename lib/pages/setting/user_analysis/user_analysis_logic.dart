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
    // 初始化城市分布数据
    state.cityDistribution = {
      '广州市': {
        'percentage': 15,
        'color': const Color(0xFFFF6850),
        'position': const Offset(50, 70),
      },
      '北京市': {
        'percentage': 22,
        'color': const Color(0xFFFF6850),
        'position': const Offset(50, 130),
      },
      '上海市': {
        'percentage': 12,
        'color': const Color(0xFFFF6850),
        'position': const Offset(50, 190),
      },
      '广西市': {
        'percentage': 19,
        'color': const Color(0xFF4646DF),
        'position': const Offset(280, 70),
      },
      '成都市': {
        'percentage': 27,
        'color': const Color(0xFF4646DF),
        'position': const Offset(280, 130),
      },
    };

    // 初始化功能使用占比数据
    state.functionUsage = {
      '风险预警': {
        'percentage': 15,
        'color': const Color(0xFFFF6850),
        'position': const Offset(50, 70),
      },
      '我的订阅': {
        'percentage': 22,
        'color': const Color(0xFFFF6850),
        'position': const Offset(50, 130),
      },
      'XX清单': {
        'percentage': 12,
        'color': const Color(0xFFFF6850),
        'position': const Offset(50, 190),
      },
      'AI智能问答': {
        'percentage': 19,
        'color': const Color(0xFF4646DF),
        'position': const Offset(280, 70),
      },
      '热点': {
        'percentage': 27,
        'color': const Color(0xFF4646DF),
        'position': const Offset(280, 130),
      },
    };

    // 初始化高频访问内容
    state.highFrequencyContent = [
      {
        'title': '美国芯片出口管制新政(事件)',
        'visitCount': 89,
        'avgTime': '3:25',
        'shareRate': 12.5,
        'followRate': 34.8,
      },
      {
        'title': '欧盟GDPR合规调查(事件)',
        'visitCount': 72,
        'avgTime': '2:48',
        'shareRate': 9.7,
        'followRate': 28.3,
      },
      {
        'title': '数据安全合规(专题|最近更新)',
        'visitCount': 65,
        'avgTime': '4:12',
        'shareRate': 15.2,
        'followRate': 42.1,
      },
      {
        'title': '某企业数据泄露事件(事件)',
        'visitCount': 58,
        'avgTime': '2:35',
        'shareRate': 11.3,
        'followRate': 25.9,
      },
      {
        'title': '国际贸易摩擦(专题|最近更新)',
        'visitCount': 54,
        'avgTime': '3:42',
        'shareRate': 13.8,
        'followRate': 36.4,
      },
    ];

    // 初始化用户行为数据
    state.userBehaviors = [
      {
        'name': '张三',
        'department': '研发部',
        'activity': '浏览事件信息',
        'time': '2024-05-11 09:45',
        'loginCount': 5,
        'activityCount': 28,
        'duration': '1小时25分',
      },
      {
        'name': '张三',
        'department': '研发部',
        'activity': '使用AI助手',
        'time': '2024-05-11 09:30',
        'loginCount': 3,
        'activityCount': 15,
        'duration': '48分钟',
      },
      {
        'name': '张三',
        'department': '研发部',
        'activity': '查看统计数据',
        'time': '2024-05-11 08:55',
        'loginCount': 4,
        'activityCount': 22,
        'duration': '1小时5分',
      },
    ];
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