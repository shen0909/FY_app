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
import '../../models/banner_models.dart';
import 'home_state.dart';

class HomeLogic extends GetxController {
  final HomeState state = HomeState();
  late PageController pageController;
  Timer? _autoPlayTimer;
  Timer? _debounceTimer; // 防抖定时器
  bool _isAnimating = false; // 是否正在执行动画

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    // 启动Token保活服务
    _startTokenKeepAlive();
  }

  Future<void> onReady() async {
    super.onReady();
    await getHomePageData(); // 获取首页数据（轮播图+风险预警+实体清单）
    // 启动自动轮播
    _startAutoPlay();
  }

  @override
  void onClose() {
    pageController.dispose();
    _stopAutoPlay();
    _debounceTimer?.cancel(); // 取消防抖定时器
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
      if (state.isBannerTouching.value || _isAnimating) {
        return;
      }
      final bannerCount = state.bannerList.length;
      
      if (bannerCount > 1) {
        _isAnimating = true;
        
        if (state.currentBannerIndex.value < bannerCount - 1) {
          pageController.nextPage(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          ).then((_) {
            _isAnimating = false;
          });
        } else {
          pageController.animateToPage(
            0,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          ).then((_) {
            _isAnimating = false;
          });
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
    
    if (isTouching) {
      // 立即设置为触摸状态，停止自动轮播
      state.isBannerTouching.value = true;
      _debounceTimer?.cancel();
    } else {
      // 用户抬起手指时，延迟恢复自动轮播
      _debounceTimer?.cancel();
      _debounceTimer = Timer(Duration(milliseconds: 1500), () {
        state.isBannerTouching.value = false;
      });
    }
  }

  // 更新轮播图当前索引
  void updateBannerIndex(int index) {
    state.currentBannerIndex.value = index;
    // 移除 update() 调用，避免重建整个GetBuilder导致闪烁
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

  /// 获取首页数据（缓存优先，后台更新策略）
  Future<void> getHomePageData() async {
    try {
      // 1. 首先尝试从缓存加载数据（立即显示）
      await _loadHomeDataFromCache();

      // 2. 后台调用接口更新数据
      _updateHomeDataInBackground();
      
    } catch (e) {
      if (kDebugMode) {
        print("❌ 获取首页数据出错: $e");
      }
    }
  }

  /// 从缓存加载首页数据（立即显示）
  Future<void> _loadHomeDataFromCache() async {
    try {
      if (kDebugMode) {
        print("🔄 尝试从缓存加载首页数据");
      }
      
      // 尝试从首页数据缓存加载
      final cachedHomeData = await BusinessCacheService.instance.getHomePageDataWithCache();
      
      if (cachedHomeData != null) {
        // 处理轮播图数据
        if (cachedHomeData['banner'] != null) {
          await _processBannerData(cachedHomeData['banner']);
        }
        
        // 处理风险预警数据
        if (cachedHomeData['enterprise'] != null) {
          _processEnterpriseData(cachedHomeData['enterprise']);
        }
        
        // 处理实体清单数据
        if (cachedHomeData['sanction'] != null) {
          _processSanctionData(cachedHomeData['sanction']);
        }
        
        if (kDebugMode) {
          print("✅ 成功从缓存加载首页数据");
        }
      } else {
        if (kDebugMode) {
          print("⚠️ 缓存中没有首页数据");
        }
      }
      
    } catch (e) {
      if (kDebugMode) {
        print("❌ 从缓存加载首页数据失败: $e");
      }
    }
  }

  /// 后台更新首页数据
  Future<void> _updateHomeDataInBackground() async {
    try {
      if (kDebugMode) {
        print("🔄 后台更新首页数据");
      }
      
      // 强制更新首页数据缓存
      final updatedHomeData = await BusinessCacheService.instance.getHomePageDataWithCache(forceUpdate: true);
      
      if (updatedHomeData != null) {
        // 处理轮播图数据
        if (updatedHomeData['banner'] != null) {
          await _processBannerData(updatedHomeData['banner']);
        }
        
        // 处理风险预警数据
        if (updatedHomeData['enterprise'] != null) {
          _processEnterpriseData(updatedHomeData['enterprise']);
        }
        
        // 处理实体清单数据
        if (updatedHomeData['sanction'] != null) {
          _processSanctionData(updatedHomeData['sanction']);
        }
        
        if (kDebugMode) {
          print("✅ 后台数据更新完成");
        }
      } else {
        if (kDebugMode) {
          print("⚠️ 后台数据更新失败，保持缓存数据");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ 后台数据更新异常: $e，保持缓存数据");
      }
    }
  }



  /// 处理轮播图数据
  Future<void> _processBannerData(dynamic bannerData) async {
    try {
      if (bannerData != null && bannerData is List) {
        List<BannerModels> banners = bannerData
            .map<BannerModels>((item) => BannerModels.fromJson(item))
            .where((banner) => banner.enable) // 只显示启用的轮播图
            .toList();
        
        // 按sort字段排序
        banners.sort((a, b) => a.sort.compareTo(b.sort));
        
        state.bannerList.assignAll(banners);
        
        if (kDebugMode) {
          print("✅ 成功处理${banners.length}个轮播图数据");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ 处理轮播图数据失败: $e");
      }
    }
  }

  /// 处理企业风险数据
  void _processEnterpriseData(dynamic enterpriseData) {
    try {
      if (enterpriseData != null) {
        int highRisk = enterpriseData['高风险'] ?? 0;
        int mediumRisk = enterpriseData['中风险'] ?? 0;
        int lowRisk = enterpriseData['低风险'] ?? 0;
        
        state.updateRiskScoreCount(
          highRisk: highRisk,
          mediumRisk: mediumRisk,
          lowRisk: lowRisk,
        );
        
        if (kDebugMode) {
          print("✅ 成功更新风险评分数量 - 高风险:$highRisk, 中风险:$mediumRisk, 低风险:$lowRisk");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ 处理企业风险数据失败: $e");
      }
    }
  }

  /// 处理实体清单数据
  void _processSanctionData(dynamic sanctionData) {
    try {
      if (sanctionData != null) {
        int allCount = sanctionData['all_count'] ?? 0;
        String updateDate = sanctionData['update_date'] ?? '';
        
        state.updateSanctionData(
          totalCount: allCount,
          updateDate: updateDate,
        );
        
        if (kDebugMode) {
          print("✅ 成功更新实体清单数据 - 总数:$allCount, 更新时间:$updateDate");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ 处理实体清单数据失败: $e");
      }
    }
  }
}
