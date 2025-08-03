import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/image_resource.dart';
import 'package:get/get.dart';
import '../../models/banner_models.dart';

// 轮播图数据模型（保留原有的以防向后兼容）
class CarouselItem {
  final String imageUrl;
  final String title;
  final String date;
  final String linkUrl;

  CarouselItem({
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.linkUrl,
  });
}

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
  final String listUpdateTime = "2025.07.07";

  final riskType = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> homeItemList = [];
  
  // 轮播图数据（保留原有的）
  final carouselItems = <CarouselItem>[].obs;
  int currentBannerIndex = 0;

  // 新增：从接口获取的banner数据
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
    
    _initData();
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

  void _initData() {
    // 初始化轮播图数据（保留作为fallback）
    carouselItems.addAll([
      CarouselItem(
        imageUrl:  FYImages.lunbo1,
        title: '特朗普"贸易信函"拉响新一轮全球关税警报',
        date: '2025.05.12',
        linkUrl: 'https://www.mofcom.gov.cn/syxwfb/art/2025/art_8232e23dd3cb49bcb70634eb0c65ecea.html',
      ),
      CarouselItem(
        imageUrl:  FYImages.lunbo2,
        title: '特朗普称TikTok有买家了',
        date: '2025.04.27',
        linkUrl: 'https://www.bbc.com/zhongwen/articles/c5ylzv95nj3o/simp',
      ),
      CarouselItem(
        imageUrl:  FYImages.lunbo3,
        title: '美国禁止包括中国在内的所有国家使用华为人工智能芯片组',
        date: '2025.03.31',
        linkUrl: 'https://www.state.gov/translations/chinese/20250325-commerce-further-restricts-chinas-artificial-intelligence-and-advanced-computing-capabilities-chinese/',
      ),
    ]);
  }
}
