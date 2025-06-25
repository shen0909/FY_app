import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_app/routers/routers.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:async';
import 'package:safe_app/utils/dialog_utils.dart';

import 'home_state.dart';

class HomeLogic extends GetxController {
  final HomeState state = HomeState();
  late PageController pageController;
  Timer? _autoPlayTimer;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    // 启动自动轮播
    _startAutoPlay();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    pageController.dispose();
    _stopAutoPlay();
    // TODO: implement onClose
    super.onClose();
  }

  // 启动自动轮播
  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (state.currentBannerIndex < state.carouselItems.length - 1) {
        pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      } else {
        pageController.animateToPage(
          0,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
  }

  // 停止自动轮播
  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  // 更新轮播图当前索引
  void updateBannerIndex(int index) {
    state.currentBannerIndex = index;
    update();
  }

  // 处理轮播图点击
  void onBannerTap(int index) async {
    // 根据索引确定要打开的HTML文件
    String fileName;
    switch (index) {
      case 0:
        fileName = 'commerce_chip_ban.html'; // 美国BIS企图全球禁用华为昇腾芯片
        break;
      case 1:
        fileName = 'trump_tariff_policy.html'; // 有迹象表明特朗普可能准备撤回关税措施
        break;
      case 2:
        fileName = 'us_ai_restrictions.html'; // 美国商务部进一步限制中国AI和先进算力
        break;
      default:
        fileName = 'us_ai_restrictions.html';
        break;
    }
    
    // 跳转到WebView页面显示HTML文件
    Get.toNamed(Routers.webView, arguments: {'file': fileName});
  }

  // 去风险预警页
  void goRisk() {
    Get.toNamed(Routers.risk);
  }

  // 去热点页
  void goHotPot() {
    Get.toNamed(Routers.hotPot);
  }

  // 导航到AI问答页面
  void goAiQus() {
    Get.toNamed(Routers.aiQus);
  }

  // 导航到订阅管理页面
  void goOrder() {
    // DialogUtils.showUnderConstructionDialog();
    Get.toNamed(Routers.order);
  }

  // 导航到系统设置页面
  Future<void> goSetting() async {
    Get.toNamed(Routers.setting);
  }

  goDetailList() {
    Get.toNamed(Routers.detailList);
  }
}
