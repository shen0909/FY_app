import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserAnalysisState {
  // 统计数据
  final int todayVisits = 126;
  final double visitTrend = 12.5;
  final int browseTimes = 582;
  final double browseTrend = -12.0;
  final int aiChatTimes = 218;
  final double aiChatTrend = 3.1;
  final double activityIndex = 85.3;
  final double activityTrend = 5.7;

  // 图表选项卡索引
  final RxInt selectedTabIndex = 0.obs;
  
  // 时间范围
  final RxString timeRange = ''.obs;

  // 用户活跃度分布日期
  final String distributionDate = '2025/5/18';

  // 城市分布数据
  Map<String, Map<String, dynamic>> cityDistribution = {};

  // 功能使用占比
  Map<String, Map<String, dynamic>> functionUsage = {};

  // 高频访问内容
  List<Map<String, dynamic>> highFrequencyContent = [];

  // 用户行为数据
  List<Map<String, dynamic>> userBehaviors = [];

  // 搜索文本
  final RxString searchText = ''.obs;

  // 选中的部门
  final RxString selectedDepartment = ''.obs;

  UserAnalysisState() {
    ///Initialize variables
  }
} 