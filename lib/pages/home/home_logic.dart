import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_app/https/api_service.dart';
import 'package:safe_app/routers/routers.dart';
import 'dart:async';
import 'package:safe_app/services/token_keep_alive_service.dart';
import 'package:safe_app/utils/shared_prefer.dart';
import 'package:flutter/foundation.dart';
import '../../models/banner_models.dart';
import '../../utils/dialog_utils.dart';
import 'home_state.dart';

class HomeLogic extends GetxController {
  final HomeState state = HomeState();
  late PageController pageController;
  Timer? _autoPlayTimer;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    // 启动Token保活服务
    _startTokenKeepAlive();
  }

  Future<void> onReady() async {
    super.onReady();
    await getBannerList();
    // 启动自动轮播
    _startAutoPlay();
  }

  @override
  void onClose() {
    pageController.dispose();
    _stopAutoPlay();
    // 停止Token保活服务
    _stopTokenKeepAlive();
    // TODO: implement onClose
    super.onClose();
  }

  /// 启动Token保活服务
  Future<void> _startTokenKeepAlive() async {
    try {
      // 检查是否有内层token
      String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
      if (token != null && token.isNotEmpty) {
        if (kDebugMode) {
          print('HomeLogic: 检测到有效token，启动保活服务');
        }
        TokenKeepAliveService().startKeepAlive();
      } else {
        if (kDebugMode) {
          print('HomeLogic: 未检测到有效token，跳过保活服务启动');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('HomeLogic: 启动Token保活服务时出错: $e');
      }
    }
  }

  /// 停止Token保活服务
  void _stopTokenKeepAlive() {
    try {
      TokenKeepAliveService().stopKeepAlive();
      if (kDebugMode) {
        print('HomeLogic: Token保活服务已停止');
      }
    } catch (e) {
      if (kDebugMode) {
        print('HomeLogic: 停止Token保活服务时出错: $e');
      }
    }
  }

  // 启动自动轮播
  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      // 优先使用接口数据，如果没有则使用默认数据
      final bannerCount = state.bannerList.isNotEmpty 
          ? state.bannerList.length 
          : state.carouselItems.length;
      
      if (bannerCount > 0) {
        if (state.currentBannerIndex < bannerCount - 1) {
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

  // 处理轮播图点击 - 修改为跳转到markdown页面
  void onBannerTap(int index) async {
    // 优先使用接口数据
    if (state.bannerList.isNotEmpty && index < state.bannerList.length) {
      final banner = state.bannerList[index];
      // 跳转到markdown内容页面
      Get.toNamed(Routers.bannerContent, arguments: {
        'title': banner.title,
        'content': banner.content,
      });
    } else if (state.carouselItems.isNotEmpty && index < state.carouselItems.length) {
      // 如果没有接口数据，使用默认数据（保持原有逻辑作为兜底）
      String fileName;
      switch (index) {
        case 0:
          fileName = 'html1.html';
          break;
        case 1:
          fileName = 'html2.html';
          break;
        case 2:
          fileName = 'html3.html';
          break;
        default:
          fileName = 'html1.html';
          break;
      }
      
      // 跳转到WebView页面显示HTML文件
      Get.toNamed(Routers.webView, arguments: {'file': fileName});
    }
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

  // 获取Banner列表
  Future<void> getBannerList() async {
    // 方案1：全局Dialog loading（当前方案）
    DialogUtils.showLoading();
    try {
      final result = await ApiService().getBannerLists();
      if (kDebugMode) {
        print("获取Banner列表结果: $result");
      }
      
      if (result != null && result['执行结果'] == true) {
        final bannerData = result['返回数据'];
        if (bannerData is List) {
          // 解析banner数据
          final banners = bannerData
              .map((item) => BannerModels.fromJson(item))
              .where((banner) => banner.enable) // 只显示启用的banner
              .toList();
          // 按sort字段排序
          banners.sort((a, b) => a.sort.compareTo(b.sort));
          // 更新状态
          state.bannerList.assignAll(banners);
          if (kDebugMode) {
            print("成功加载${banners.length}个Banner");
          }
        }
      } else {
        if (kDebugMode) {
          print("Banner接口返回数据异常，使用默认轮播图数据");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("获取Banner列表出错: $e，使用默认轮播图数据");
      }
    } finally {
      // 确保无论成功还是失败都隐藏loading
      DialogUtils.hideLoading();
    }
  }
}
