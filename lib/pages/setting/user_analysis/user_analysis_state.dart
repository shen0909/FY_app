import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class VisitTrendData {
  final String time;
  final double value;
  VisitTrendData(this.time, this.value);
}

class UserAnalysisState {
  final RxInt todayVisits = 0.obs; // 今日访问数量
  final RxInt todayVisitsTrend = 0.obs; // 今日访问趋势

  // 其余统计（接口未返回，仍保留静态展示）
  final int browseTimes = 582;
  final double browseTrend = -12.0;
  final int aiChatTimes = 218;
  final double aiChatTrend = 3.1;
  final double activityIndex = 85.3;
  final double activityTrend = 5.7;

  // 图表选项卡索引
  final RxInt selectedTabIndex = 0.obs;
  
  // 时间范围
  final RxString timeRange = '今日 0:00-09:00'.obs;

  // 访问趋势数据
  final RxList<VisitTrendData> visitTrendData = <VisitTrendData>[].obs;

  // 用户活跃度分布日期
  final String distributionDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // 城市分布数据
  final RxMap<String, double> cityDistribution = <String, double>{}.obs; // active_region_count

  // 功能使用占比
  final RxMap<String, double> functionUsage = <String, double>{
    '内容浏览': 19,
    'AI聊天': 27,
    '智能分析': 22,
    '文档管理': 12,
    '其他功能': 15,
  }.obs;

  // 高频访问内容
  final RxList<Map<String, dynamic>> highFrequencyContent = <Map<String, dynamic>>[
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
  ].obs;

  // 用户行为数据
  final RxList<Map<String, dynamic>> userBehaviors = <Map<String, dynamic>>[
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
  ].obs;

  // 搜索文本
  final RxString searchText = ''.obs;

  // 选中的部门
  final RxString selectedDepartment = ''.obs;

  ScrollController highScrollController = ScrollController();
  ScrollController listScrollController = ScrollController();
  UserAnalysisState() {
    ///Initialize variables
  }

} 