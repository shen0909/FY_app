import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/image_resource.dart';

class HomeState {
  // 观察日期
  final String observationDate = "2025.04.27";

  // 风险预警数据
  final int highRiskCount = 5;
  final int mediumRiskCount = 12;
  final int lowRiskCount = 8;

  // 通知数
  final int notificationCount = 3;

  // 清单更新时间
  final String listUpdateTime = "2025.05.06";
  List<Map<String, dynamic>> riskType = [];
  List<Map<String, dynamic>> homeItemList = [];

  HomeState() {
    riskType = [
      {'title': '高风险','count':5,'bgColor':FYColors.highRiskBg,'borderColor':FYColors.highRiskBorder},
      {'title': '中风险','count':5,'bgColor':FYColors.middleRiskBg,'borderColor':FYColors.middleRiskBorder},
      {'title': '低风险','count':5,'bgColor':FYColors.lowRiskBg,'borderColor':FYColors.lowRiskBorder},
    ];
    homeItemList = [
      {'title': '热点', 'image': FYImages.hotIcon, 'bgColor': FYColors.hotBgGridle},
      {'title': 'AI问答', 'image': FYImages.aiIcon, 'bgColor': FYColors.aiBgGridle},
      {'title': '我的订阅', 'image': FYImages.orderIcon, 'bgColor': FYColors.orderBgGridle},
      {'title': '系统设置', 'image': FYImages.settingIcon, 'bgColor': FYColors.settingBgGridle},
    ];
  }
}
