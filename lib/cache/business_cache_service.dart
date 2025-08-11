import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:safe_app/https/api_service.dart';
import 'package:safe_app/models/risk_data_new.dart';
import 'package:safe_app/models/newslist_data.dart';
import '../models/banner_models.dart';
import 'cache_manager.dart';

import 'cache_config.dart';
import 'cache_models.dart';

/// 业务缓存服务 - 专门处理业务层的缓存逻辑
class BusinessCacheService extends GetxService {
  static BusinessCacheService get instance => Get.find<BusinessCacheService>();
  
  CacheManager? _cacheManager;
  ApiService? _apiService;
  bool _isInitialized = false;

  /// 获取缓存管理器（延迟初始化）
  CacheManager get cacheManager {
    _cacheManager ??= CacheManager.instance;
    return _cacheManager!;
  }

  /// 获取API服务（延迟初始化）
  ApiService get apiService {
    _apiService ??= ApiService();
    return _apiService!;
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    
    // 防止重复初始化
    if (_isInitialized) {
      debugPrint('ℹ️ BusinessCacheService 已经初始化，跳过重复初始化');
      return;
    }
    
    try {
      // 确保CacheManager已初始化
      if (!Get.isRegistered<CacheManager>()) {
        await Get.putAsync(() => CacheManager().init());
      }
      
      // 预初始化依赖项
      _cacheManager = CacheManager.instance;
      _apiService = ApiService();
      _isInitialized = true;
      
      debugPrint('✅ BusinessCacheService 初始化完成');
    } catch (e) {
      debugPrint('❌ BusinessCacheService 初始化失败: $e');
      _isInitialized = false; // 重置状态以便重试
      rethrow;
    }
  }

  // ==================== 轮播图相关缓存 (新增) ====================

  /// 获取轮播图列表（带缓存）
  Future<List<BannerModels>?> getBannerListWithCache({bool forceUpdate = false}) async {
    try {
      const cacheKey = 'banner_list';

      // 首先尝试从缓存获取
      if (!forceUpdate) {
        final cachedData = await cacheManager.get<List<dynamic>>(cacheKey);
        if (cachedData != null) {
          debugPrint('🎯 轮播图缓存命中');
          return cachedData
              .map((item) => BannerModels.fromJson(item as Map<String, dynamic>))
              .where((banner) => banner.enable)
              .toList()
            ..sort((a, b) => a.sort.compareTo(b.sort));
        }
      }

      // 缓存未命中，从网络获取
      debugPrint('🌐 轮播图网络请求');
      final result = await apiService.getBannerLists();

      if (result != null && result['执行结果'] == true) {
        final bannerData = result['返回数据'];
        if (bannerData is List) {
          // 存入缓存
          await cacheManager.set(
            cacheKey,
            bannerData,
            ttl: const Duration(hours: 6),
            priority: CachePriority.high,
            metadata: {
              'requestTime': DateTime.now().millisecondsSinceEpoch,
              'dataType': 'banner_list',
              'itemCount': bannerData.length,
            },
          );

          // 解析并返回数据
          final banners = bannerData
              .map((item) => BannerModels.fromJson(item as Map<String, dynamic>))
              .where((banner) => banner.enable)
              .toList();
          banners.sort((a, b) => a.sort.compareTo(b.sort));
          
          return banners;
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ 获取轮播图失败: $e');
      return null;
    }
  }

  /// 预加载轮播图数据
  Future<void> preloadBannerData() async {
    try {
      await getBannerListWithCache();
      debugPrint('✅ 轮播图数据预加载完成');
    } catch (e) {
      debugPrint('❌ 轮播图预加载失败: $e');
    }
  }

  /// 清理轮播图缓存
  Future<void> clearBannerCache() async {
    try {
      await cacheManager.removeByPrefix('banner_');
      debugPrint('🗑️ 轮播图缓存已清理');
    } catch (e) {
      debugPrint('❌ 清理轮播图缓存失败: $e');
    }
  }

  /// 获取轮播图详情（带缓存）
  Future<BannerModels?> getBannerDetailWithCache(String uuid) async {
    try {
      final cacheKey = 'banner_detail_$uuid';

      // 尝试从缓存获取
      final cachedData = await cacheManager.get<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        debugPrint('🎯 轮播图详情缓存命中: $uuid');
        return BannerModels.fromJson(cachedData);
      }

      // 缓存未命中，从轮播图列表中查找
      final bannerList = await getBannerListWithCache();
      if (bannerList != null) {
        final banner = bannerList.firstWhere(
          (b) => b.uuid == uuid,
          orElse: () => throw Exception('轮播图不存在'),
        );

        // 缓存单个轮播图详情
        await cacheManager.set(
          cacheKey,
          banner.toJson(),
          ttl: const Duration(hours: 12),
          priority: CachePriority.normal,
        );

        return banner;
      }

      return null;
    } catch (e) {
      debugPrint('❌ 获取轮播图详情失败: $e');
      return null;
    }
  }

  // ==================== 风险预警相关缓存 ====================

  /// 获取风险列表数据（带缓存）
  Future<RiskyDataNew?> getRiskListWithCache({
    required int currentPage,
    String? zhName,
    String? regionCode,
    int? classification,
    bool forceUpdate = false,
  }) async {
    try {
      // 构建缓存键
      final cacheKey = _buildRiskListCacheKey(
        currentPage: currentPage,
        zhName: zhName,
        regionCode: regionCode,
        classification: classification,
      );

      // 首先尝试从缓存获取
      if (!forceUpdate) {
        final cachedData = await cacheManager.get<Map<String, dynamic>>(cacheKey);
        if (cachedData != null) {
          debugPrint('🎯 风险列表缓存命中: $cacheKey');
          return RiskyDataNew.fromJson(cachedData);
        }
      }

      // 缓存未命中，从网络获取
      debugPrint('🌐 风险列表网络请求: $cacheKey');
      final result = await apiService.getRiskLists(
        currentPage: currentPage,
        zhName: zhName,
        regionCode: regionCode,
        classification: classification,
      );

      if (result != null && result['执行结果'] == true) {
        final riskyData = RiskyDataNew.fromJson(result['返回数据']);
        
        // 存入缓存
        await cacheManager.set(
          cacheKey,
          result['返回数据'],
          ttl: _getRiskCacheTTL(classification),
          priority: _getRiskCachePriority(classification),
          metadata: {
            'requestTime': DateTime.now().millisecondsSinceEpoch,
            'dataType': 'risk_list',
            'classification': classification,
            'pageSize': riskyData.list.length,
          },
        );

        return riskyData;
      }

      return null;
    } catch (e) {
      debugPrint('❌ 获取风险列表失败: $e');
      return null;
    }
  }

  /// 预加载风险数据
  Future<void> preloadRiskData({
    required int classification,
    String? regionCode,
  }) async {
    try {
      // 预加载第一页数据
      await getRiskListWithCache(
        currentPage: 1,
        classification: classification,
        regionCode: regionCode,
      );

      debugPrint('📦 风险数据预加载完成: classification=$classification');
    } catch (e) {
      debugPrint('❌ 风险数据预加载失败: $e');
    }
  }

  /// 清除风险相关缓存
  Future<void> clearRiskCache({int? classification}) async {
    if (classification != null) {
      await cacheManager.removeByPrefix('risk_list_$classification');
    } else {
      await cacheManager.removeByPrefix('risk_list');
    }
    debugPrint('🗑️ 清除风险缓存: classification=$classification');
  }

  // ==================== 舆情热点相关缓存 ====================

  /// 获取舆情热点列表（带缓存）
  Future<List<NewsItem>?> getHotPotListWithCache({
    required int currentPage,
    required int pageSize,
    String newsType = '全部',
    String region = '全部',
    String dateFilter = '全部',
    String? startDate,
    String? endDate,
    String? search,
    bool forceUpdate = false,
  }) async {
    try {
      // 构建缓存键
      final cacheKey = _buildHotPotListCacheKey(
        currentPage: currentPage,
        pageSize: pageSize,
        newsType: newsType,
        region: region,
        dateFilter: dateFilter,
        startDate: startDate,
        endDate: endDate,
        search: search,
      );

      // 首先尝试从缓存获取
      if (!forceUpdate) {
        final cachedData = await cacheManager.get<List<dynamic>>(cacheKey);
        if (cachedData != null && cachedData.length >0) {
          debugPrint('🎯 舆情热点缓存命中: $cacheKey');
          return cachedData.map((item) => NewsItem.fromJson(item)).toList();
        }
      }

      // 缓存未命中，从网络获取
      debugPrint('🌐 舆情热点网络请求: $cacheKey');
      final result = await apiService.getNewsList(
        currentPage: currentPage,
        pageSize: pageSize,
        newsType: newsType,
        region: region,
        dateFilter: dateFilter,
        startDate: startDate,
        endDate: endDate,
        search: search,
      );

      if (result != null && result['code'] == 10010 && result['data'] != null) {
        final newsData = result['data'] as List;
        final newsItems = newsData.map((item) => NewsItem.fromJson(item)).toList();
        
        // 存入缓存
        await cacheManager.set(
          cacheKey,
          newsData,
          ttl: _getHotPotCacheTTL(dateFilter),
          priority: _getHotPotCachePriority(dateFilter),
          metadata: {
            'requestTime': DateTime.now().millisecondsSinceEpoch,
            'dataType': 'hotpot_list',
            'newsType': newsType,
            'dateFilter': dateFilter,
            'itemCount': newsItems.length,
          },
        );

        return newsItems;
      }

      return null;
    } catch (e) {
      debugPrint('❌ 获取舆情热点失败: $e');
      return null;
    }
  }

  /// 获取地区列表（带缓存）
  Future<List<Map<String, dynamic>>?> getRegionListWithCache({
    bool forceUpdate = false,
  }) async {
    try {
      const cacheKey = 'region_list_hotpot';

      // 首先尝试从缓存获取
      if (!forceUpdate) {
        final cachedData = await cacheManager.get<List<dynamic>>(cacheKey);
        if (cachedData != null && cachedData.length> 1) {
          debugPrint('🎯 地区列表缓存命中');
          return cachedData.cast<Map<String, dynamic>>();
        }
      }

      // 缓存未命中，从网络获取
      debugPrint('🌐 地区列表网络请求');
      final result = await apiService.getRegion();

      if (result != null && result['code'] == 10010 && result['data'] != null) {
        final regionData = (result['data'] as List)
            .cast<Map>()
            .map((e) => {
                  'id': (e['id'] ?? '').toString(),
                  'region': (e['region'] ?? '').toString(),
                })
            .where((e) => (e['region'] as String).isNotEmpty)
            .toList();
        final regions = [{"id": "0", "region": "全部"}, ...regionData];
        
        // 存入缓存（地区数据缓存时间较长）
        await cacheManager.set(
          cacheKey,
          regions,
          ttl: const Duration(hours: 24), // 24小时
          priority: CachePriority.high,
          metadata: {
            'requestTime': DateTime.now().millisecondsSinceEpoch,
            'dataType': 'region_list',
            'itemCount': regions.length,
          },
        );

        return regions.cast<Map<String, dynamic>>();
      }

      return null;
    } catch (e) {
      debugPrint('❌ 获取地区列表失败: $e');
      return null;
    }
  }

  /// 预加载舆情热点数据
  Future<void> preloadHotPotData() async {
    try {
      // 预加载最新舆情（第一页）
      await getHotPotListWithCache(
        currentPage: 1,
        pageSize: 10,
        dateFilter: '3d', // 最近3天的数据
      );

      // 预加载地区列表
      await getRegionListWithCache();

      debugPrint('📦 舆情热点数据预加载完成');
    } catch (e) {
      debugPrint('❌ 舆情热点数据预加载失败: $e');
    }
  }

  /// 清除舆情热点相关缓存
  Future<void> clearHotPotCache({String? dateFilter}) async {
    if (dateFilter != null) {
      await cacheManager.removeByPrefix('hotpot_list_$dateFilter');
    } else {
      await cacheManager.removeByPrefix('hotpot_list');
    }
    debugPrint('🗑️ 清除舆情热点缓存: dateFilter=$dateFilter');
  }

  // ==================== 缓存策略相关方法 ====================

  /// 构建风险列表缓存键
  String _buildRiskListCacheKey({
    required int currentPage,
    String? zhName,
    String? regionCode,
    int? classification,
  }) {
    return CacheKeyBuilder('risk_list')
        .addParam('page', currentPage)
        .addParam('name', zhName)
        .addParam('region', regionCode)
        .addParam('class', classification)
        .build();
  }

  /// 构建舆情热点列表缓存键
  String _buildHotPotListCacheKey({
    required int currentPage,
    required int pageSize,
    required String newsType,
    required String region,
    required String dateFilter,
    String? startDate,
    String? endDate,
    String? search,
  }) {
    return CacheKeyBuilder('hotpot_list')
        .addParam('page', currentPage)
        .addParam('size', pageSize)
        .addParam('type', newsType)
        .addParam('region', region)
        .addParam('date', dateFilter)
        .addParam('start', startDate)
        .addParam('end', endDate)
        .addParam('search', search)
        .build();
  }

  /// 获取风险数据缓存TTL
  Duration _getRiskCacheTTL(int? classification) {
    // 根据分类设置不同的缓存时间
    switch (classification) {
      case 1: // 烽云一号 - 高风险，缓存时间较短
        return const Duration(minutes: 5);
      case 2: // 烽云二号 - 中风险
        return const Duration(minutes: 10);
      case 3: // 星云 - 低风险，缓存时间较长
        return const Duration(minutes: 20);
      default:
        return const Duration(minutes: 10);
    }
  }

  /// 获取风险数据缓存优先级
  CachePriority _getRiskCachePriority(int? classification) {
    switch (classification) {
      case 1: // 烽云一号 - 高优先级
        return CachePriority.high;
      case 2: // 烽云二号 - 普通优先级
        return CachePriority.normal;
      case 3: // 星云 - 低优先级
        return CachePriority.low;
      default:
        return CachePriority.normal;
    }
  }

  /// 获取舆情热点缓存TTL
  Duration _getHotPotCacheTTL(String dateFilter) {
    switch (dateFilter) {
      case '3d':
        return const Duration(minutes: 3); // 最新数据，3分钟缓存
      case '7d':
        return const Duration(minutes: 10); // 一周数据，10分钟缓存
      case '30d':
        return const Duration(hours: 1); // 一月数据，1小时缓存
      default:
        return const Duration(minutes: 15); // 默认15分钟
    }
  }

  /// 获取舆情热点缓存优先级
  CachePriority _getHotPotCachePriority(String dateFilter) {
    switch (dateFilter) {
      case '3d':
        return CachePriority.high; // 最新数据高优先级
      case '7d':
        return CachePriority.normal;
      case '30d':
        return CachePriority.low; // 历史数据低优先级
      default:
        return CachePriority.normal;
    }
  }

  // ==================== 缓存管理方法 ====================

  /// 应用启动时的缓存预热
  Future<void> warmupCache() async {
    try {
      debugPrint('🔥 开始缓存预热...');
      
      // 并行预加载关键数据
      await Future.wait([
        preloadRiskData(classification: 1), // 烽云一号
        preloadHotPotData(), // 舆情热点
      ]);
      
      debugPrint('✅ 缓存预热完成');
    } catch (e) {
      debugPrint('❌ 缓存预热失败: $e');
    }
  }

  /// 应用进入后台时的缓存同步
  Future<void> backgroundSync() async {
    try {
      // 清理过期缓存
      await cacheManager.cleanupExpiredCache();
      
      // 生成性能报告
      await cacheManager.generatePerformanceReport();
      
      debugPrint('📤 后台缓存同步完成');
    } catch (e) {
      debugPrint('❌ 后台缓存同步失败: $e');
    }
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getCacheStatistics() {
    return cacheManager.getStats();
  }

  /// 手动清理所有业务缓存
  Future<void> clearAllBusinessCache() async {
    await Future.wait([
      clearRiskCache(),
      clearHotPotCache(),
      clearBannerCache(),
      cacheManager.removeByPrefix('region_'),
    ]);
    debugPrint('🧹 所有业务缓存已清理');
  }

  /// 网络状态变化处理
  void onNetworkStateChanged(bool isOnline) {
    if (isOnline) {
      // 网络恢复时，可以选择刷新关键数据
      warmupCache();
    }
  }

  /// 应用升级后的缓存处理
  Future<void> onAppVersionUpdate() async {
    // 清理旧版本的缓存数据
    await clearAllBusinessCache();
    debugPrint('🔄 应用升级，缓存已清理');
  }
}

/// 缓存刷新策略
enum CacheRefreshStrategy {
  manual,      // 手动刷新
  automatic,   // 自动刷新
  background,  // 后台刷新
  realTime,    // 实时刷新
}

/// 缓存预热配置
class CacheWarmupConfig {
  final bool enabled;
  final List<String> criticalKeys;
  final Duration timeout;
  final int retryCount;

  const CacheWarmupConfig({
    this.enabled = true,
    this.criticalKeys = const [],
    this.timeout = const Duration(seconds: 30),
    this.retryCount = 3,
  });
}

/// 业务缓存统计
class BusinessCacheStats {
  final int riskCacheHits;
  final int riskCacheMisses;
  final int hotPotCacheHits;
  final int hotPotCacheMisses;
  final Duration averageResponseTime;
  final double dataFreshness;

  BusinessCacheStats({
    required this.riskCacheHits,
    required this.riskCacheMisses,
    required this.hotPotCacheHits,
    required this.hotPotCacheMisses,
    required this.averageResponseTime,
    required this.dataFreshness,
  });

  double get riskHitRate {
    final total = riskCacheHits + riskCacheMisses;
    return total > 0 ? riskCacheHits / total : 0.0;
  }

  double get hotPotHitRate {
    final total = hotPotCacheHits + hotPotCacheMisses;
    return total > 0 ? hotPotCacheHits / total : 0.0;
  }

  double get overallHitRate {
    final totalHits = riskCacheHits + hotPotCacheHits;
    final totalRequests = riskCacheHits + riskCacheMisses + hotPotCacheHits + hotPotCacheMisses;
    return totalRequests > 0 ? totalHits / totalRequests : 0.0;
  }
} 