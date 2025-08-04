import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/image_resource.dart';
import 'package:get/get.dart';
import '../../models/banner_models.dart';

class HomeState {
  // 观察日期
  final String observationDate = "2025.04.27";

  // 风险预警数据
  final int highRiskCount = 5;
  final int mediumRiskCount = 12;
  final int lowRiskCount = 8;

  // 通知数
  final int notificationCount = 3;

  // 清单更新时间和总数（从接口获取）
  final RxString listUpdateTime = "".obs;
  final RxInt listTotalCount = 0.obs;

  final riskType = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> homeItemList = [];
  
  // 轮播图当前索引
  int currentBannerIndex = 0;

  // 从接口获取的banner数据
  final bannerList = <BannerModels>[].obs;
  
  final RxBool isBannerTouching = false.obs; //是否触摸轮播图

  HomeState() {
    // 初始化默认风险类型数据
    riskType.assignAll([
      {'title': '高风险','count':10,'bgColor':FYColors.highRiskBg,'borderColor':FYColors.highRiskBorder},
      {'title': '中风险','count':10,'bgColor':FYColors.middleRiskBg,'borderColor':FYColors.middleRiskBorder},
      {'title': '低风险','count':10,'bgColor':FYColors.lowRiskBg,'borderColor':FYColors.lowRiskBorder},
    ]);
    
    homeItemList = [
      {'title': '舆情热点', 'image': FYImages.hotIcon, 'bgColor': FYColors.hotBgGridle},
      {'title': 'AI问答', 'image': FYImages.aiIcon, 'bgColor': FYColors.aiBgGridle},
      {'title': '我的订阅', 'image': FYImages.orderIcon, 'bgColor': FYColors.orderBgGridle},
      {'title': '安全设置', 'image': FYImages.settingIcon, 'bgColor': FYColors.settingBgGridle},
    ];
  }
  
  /// 更新风险评分数量
  void updateRiskScoreCount({
    required int highRisk,
    required int mediumRisk, 
    required int lowRisk,
  }) {
    riskType.assignAll([
      {'title': '高风险','count':highRisk,'bgColor':FYColors.highRiskBg,'borderColor':FYColors.highRiskBorder},
      {'title': '中风险','count':mediumRisk,'bgColor':FYColors.middleRiskBg,'borderColor':FYColors.middleRiskBorder},
      {'title': '低风险','count':lowRisk,'bgColor':FYColors.lowRiskBg,'borderColor':FYColors.lowRiskBorder},
    ]);
  }

  /// 更新实体清单数据
  void updateSanctionData({
    required int totalCount,
    required String updateDate,
  }) {
    listTotalCount.value = totalCount;
    listUpdateTime.value = updateDate;
  }

}
