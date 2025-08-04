/// 缓存系统初始化器
/// 负责在应用启动时正确初始化所有缓存组件

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'cache_manager.dart';
import 'business_cache_service.dart';

/// 缓存系统初始化器
class CacheInitializer {
  static bool _isInitialized = false;
  
  /// 初始化缓存系统
  /// 应该在main.dart中的runApp()之前调用
  static Future<void> initialize() async {
    // 完全幂等的初始化 - 即使被多次调用也安全
    if (_isInitialized && 
        Get.isRegistered<CacheManager>() && 
        Get.isRegistered<BusinessCacheService>()) {
      debugPrint('ℹ️ 缓存系统已完全初始化，跳过重复初始化');
      return;
    }
    
    try {
      if (!_isInitialized) {
        debugPrint('🚀 开始初始化缓存系统...');
      }
      
      // 步骤1: 初始化核心缓存管理器
      if (!Get.isRegistered<CacheManager>()) {
        await Get.putAsync(() => CacheManager().init(), permanent: true);
        debugPrint('✅ CacheManager 初始化完成');
      } else {
        debugPrint('ℹ️ CacheManager 已注册，跳过初始化');
      }
      
      // 步骤2: 初始化业务缓存服务
      if (!Get.isRegistered<BusinessCacheService>()) {
        await Get.putAsync(() async {
          final service = BusinessCacheService();
          await service.onInit();
          return service;
        }, permanent: true);
        debugPrint('✅ BusinessCacheService 初始化完成');
      } else {
        debugPrint('ℹ️ BusinessCacheService 已注册，跳过初始化');
      }
      
      if (!_isInitialized) {
        _isInitialized = true;
        debugPrint('🎉 缓存系统初始化完成');
        
        // 可选：预加载关键数据
        await _preloadCriticalData();
      }
      
    } catch (e) {
      debugPrint('❌ 缓存系统初始化失败: $e');
      rethrow;
    }
  }
  
  /// 预加载关键数据
  static Future<void> _preloadCriticalData() async {
    try {
      if (Get.isRegistered<BusinessCacheService>()) {
        final cacheService = BusinessCacheService.instance;

        Future.wait([
          // // 预加载轮播图数据
          // cacheService.preloadBannerData().catchError((e) {
          //   debugPrint('⚠️ 轮播图预加载失败: $e');
          // }),
          // 预加载高风险数据（烽云一号）
          cacheService.preloadRiskData(classification: 1).catchError((e) {
            debugPrint('⚠️ 高风险数据预加载失败: $e');
          }),
          
          // // 预加载舆情热点数据
          // cacheService.preloadHotPotData().catchError((e) {
          //   debugPrint('⚠️ 舆情热点预加载失败: $e');
          // }),
        ]);
        
        debugPrint('🔄 关键数据预加载已启动');
      }
    } catch (e) {
      debugPrint('⚠️ 预加载关键数据失败: $e');
    }
  }
  
  /// 检查缓存系统是否已初始化
  static bool get isInitialized => _isInitialized;
  
  /// 获取缓存统计信息（用于调试）
  static Map<String, dynamic> getDebugInfo() {
    return {
      'isInitialized': _isInitialized,
      'cacheManagerRegistered': Get.isRegistered<CacheManager>(),
      'businessCacheServiceRegistered': Get.isRegistered<BusinessCacheService>(),
      'cacheStats': _isInitialized && Get.isRegistered<CacheManager>() 
          ? CacheManager.instance.getStats() 
          : null,
    };
  }
  
  /// 重置缓存系统（主要用于测试）
  static Future<void> reset() async {
    try {
      if (Get.isRegistered<BusinessCacheService>()) {
        await Get.delete<BusinessCacheService>();
      }
      
      if (Get.isRegistered<CacheManager>()) {
        await Get.delete<CacheManager>();
      }
      
      _isInitialized = false;
      debugPrint('🔄 缓存系统已重置');
    } catch (e) {
      debugPrint('❌ 重置缓存系统失败: $e');
    }
  }
}