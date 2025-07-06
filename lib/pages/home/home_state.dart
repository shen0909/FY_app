import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/image_resource.dart';
import 'package:get/get.dart';

// 轮播图数据模型
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
  List<Map<String, dynamic>> riskType = [];
  List<Map<String, dynamic>> homeItemList = [];
  
  // 轮播图数据
  final carouselItems = <CarouselItem>[].obs;
  int currentBannerIndex = 0;

  HomeState() {
    riskType = [
      {'title': '高风险','count':30,'bgColor':FYColors.highRiskBg,'borderColor':FYColors.highRiskBorder},
      {'title': '中风险','count':17,'bgColor':FYColors.middleRiskBg,'borderColor':FYColors.middleRiskBorder},
      {'title': '低风险','count':52,'bgColor':FYColors.lowRiskBg,'borderColor':FYColors.lowRiskBorder},
    ];
    homeItemList = [
      {'title': '舆情热点', 'image': FYImages.hotIcon, 'bgColor': FYColors.hotBgGridle},
      {'title': 'AI问答', 'image': FYImages.aiIcon, 'bgColor': FYColors.aiBgGridle},
      {'title': '我的订阅', 'image': FYImages.orderIcon, 'bgColor': FYColors.orderBgGridle},
      {'title': '安全设置', 'image': FYImages.settingIcon, 'bgColor': FYColors.settingBgGridle},
    ];
    
    _initData();
  }

  void _initData() {
    // 初始化轮播图数据
    carouselItems.addAll([
      CarouselItem(
        imageUrl:  FYImages.lunbo1,
        title: '美国BIS企图全球禁用华为昇腾芯片',
        date: '2025.05.12',
        linkUrl: 'https://www.mofcom.gov.cn/syxwfb/art/2025/art_8232e23dd3cb49bcb70634eb0c65ecea.html',
      ),
      CarouselItem(
        imageUrl:  FYImages.lunbo3,
        title: '有迹象表明特朗普可能准备撤回关税措施',
        date: '2025.04.27',
        linkUrl: 'https://www.bbc.com/zhongwen/articles/c5ylzv95nj3o/simp',
      ),
      CarouselItem(
        imageUrl:  FYImages.lunbo2,
        title: '美国商务部进一步限制中国AI和先进算力',
        date: '2025.03.31',
        linkUrl: 'https://www.state.gov/translations/chinese/20250325-commerce-further-restricts-chinas-artificial-intelligence-and-advanced-computing-capabilities-chinese/',
      ),
    ]);
  }
}
