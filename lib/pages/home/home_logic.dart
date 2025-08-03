import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_app/https/api_service.dart';
import 'package:safe_app/routers/routers.dart';
import 'dart:async';
import 'package:safe_app/services/token_keep_alive_service.dart';
import 'package:safe_app/utils/shared_prefer.dart';
import 'package:flutter/foundation.dart';
import '../../utils/dialog_utils.dart';
import '../../cache/business_cache_service.dart';
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
    await getRiskScoreCount(); // 获取风险评分数量
  }

  @override
  void onClose() {
    pageController.dispose();
    _stopAutoPlay();
    // 停止Token保活服务
    _stopTokenKeepAlive();
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
      if (state.isBannerTouching.value) {
        return;
      }
      final bannerCount = state.bannerList.length;
      
      if (bannerCount > 1) {
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

  void setBannerTouchingState(bool isTouching) {
    // 避免重复设置相同的状态
    if (state.isBannerTouching.value == isTouching) {
      return;
    }
    state.isBannerTouching.value = isTouching;
  }

  // 更新轮播图当前索引
  void updateBannerIndex(int index) {
    state.currentBannerIndex = index;
    update();
  }

  // 处理轮播图点击
  void onBannerTap(int index) async {
    if (state.bannerList.isNotEmpty && index < state.bannerList.length) {
      final banner = state.bannerList[index];
      // 跳转到markdown内容页面
      Get.toNamed(Routers.bannerContent, arguments: {
        'title': banner.title,
        'content': banner.content,
      });
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

  /// 获取轮播图列表 - 缓存优化版
  Future<void> getBannerList() async {
    try {
      // 检查缓存服务是否可用
      if (!Get.isRegistered<BusinessCacheService>()) {
        if (kDebugMode) {
          print('⚠️ BusinessCacheService 未注册，跳过轮播图加载');
        }
        return;
      }
      
      // 使用缓存服务获取轮播图（无需显示Loading）
      final banners = await BusinessCacheService.instance.getBannerListWithCache();
      
      if (banners != null && banners.isNotEmpty) {
        state.bannerList.assignAll(banners);
        if (kDebugMode) {
          print('✅ 成功加载${banners.length}个轮播图');
        }
      } else {
        if (kDebugMode) {
          print('⚠️ 轮播图数据为空，保持当前状态');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 获取轮播图失败: $e');
      }
      // 发生错误时，可以选择显示默认轮播图
      // _loadDefaultBanners();
    }
  }

  /// 刷新轮播图列表
  Future<void> refreshBannerList() async {
    try {
      // 显示刷新指示器
      DialogUtils.showLoading();
      
      // 强制更新，跳过缓存
      final banners = await BusinessCacheService.instance.getBannerListWithCache(forceUpdate: true);

      if (banners != null) {
        state.bannerList.assignAll(banners);
        if (kDebugMode) {
          print('🔄 轮播图刷新成功');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 刷新轮播图失败: $e');
      }
    } finally {
      DialogUtils.hideLoading();
    }
  }

  /// 预加载轮播图（应用启动时调用）
  Future<void> preloadBannerData() async {
    await BusinessCacheService.instance.preloadBannerData();
  }

  // 获取风险评分数量
  Future<void> getRiskScoreCount() async {
    try {
      final result = await ApiService().getRiskScoreCount();
      if (kDebugMode) {
        print("获取风险评分数量结果: $result");
      }
      
      if (result != null && result['执行结果'] == true) {
        final returnData = result['返回数据'];
        if (returnData != null) {
          // 解析风险评分数量数据
          int highRisk = returnData['高风险'] ?? 0;
          int mediumRisk = returnData['中风险'] ?? 0;
          int lowRisk = returnData['低风险'] ?? 0;
          
          // 更新状态
          state.updateRiskScoreCount(
            highRisk: highRisk,
            mediumRisk: mediumRisk,
            lowRisk: lowRisk,
          );
          
          if (kDebugMode) {
            print("成功更新风险评分数量 - 高风险:$highRisk, 中风险:$mediumRisk, 低风险:$lowRisk");
          }
        }
      } else {
        if (kDebugMode) {
          print("风险评分数量接口返回数据异常，使用默认数据");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("获取风险评分数量出错: $e，使用默认数据");
      }
    }
  }
}
