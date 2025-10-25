import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'cache_storage.dart';
import 'cache_config.dart';
import 'cache_models.dart';
import 'cache_monitoring.dart';

/// 缓存管理器 - 系统核心组件
/// 负责协调内存缓存和本地存储缓存，提供统一的缓存API
class CacheManager extends GetxService {
  static CacheManager get instance => Get.find<CacheManager>();
  
  late final MemoryCache _memoryCache;
  late final LocalStorageCache _localCache;
  late final CacheMonitoring _monitoring;
  late final CacheConfig _config;
  
  bool _isInitialized = false;

  /// 初始化缓存管理器
  Future<CacheManager> init() async {
    if (_isInitialized) return this;
    
    try {
      // 初始化各个组件
      _memoryCache = MemoryCache(); // 内存缓存
      _localCache = LocalStorageCache(); // 本地缓存
      _monitoring = CacheMonitoring();
      _config = CacheConfig();
      // 初始化本地存储
      await _localCache.initialize();
      
      // 启动定期清理任务
      _startPeriodicCleanup();
      
      _isInitialized = true;
      debugPrint('✅ 缓存管理器初始化完成');
      
    } catch (e) {
      debugPrint('❌ 缓存管理器初始化失败: $e');
      rethrow;
    }
    
    return this;
  }

  /// 获取缓存数据
  Future<T?> get<T>(String key) async {
    if (!_isInitialized) {
      debugPrint('⚠️ 缓存管理器未初始化，跳过获取: $key');
      return null;
    }
    try {
      _monitoring.recordRequest(key);
      // 1. 先尝试内存缓存
      final memoryItem = _memoryCache.get(key);
      if (memoryItem != null && !memoryItem.isExpired) {
        _monitoring.recordHit(key, 'memory');
        debugPrint('🎯 内存缓存命中: $key');
        return memoryItem.data as T?;
      }
      
      // 2. 尝试本地存储缓存
      final localItem = await _localCache.get<T>(key);
      if (localItem != null && !localItem.isExpired) {
        _monitoring.recordHit(key, 'local');
        
        // 回写到内存缓存
        _memoryCache.set(key, localItem);
        debugPrint('💿 本地缓存命中: $key');
        return localItem.data;
      }
      
      // 3. 缓存未命中
      _monitoring.recordMiss(key, 'not_found');
      debugPrint('❌ 缓存未命中: $key');
      return null;
      
    } catch (e) {
      _monitoring.recordError(key, e.toString());
      debugPrint('❌ 获取缓存失败 $key: $e');
      return null;
    }
  }

  /// 设置缓存数据
  Future<void> set<T>(
    String key, 
    T data, {
    Duration? ttl,
    CachePriority? priority,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized) {
      debugPrint('⚠️ 缓存管理器未初始化，跳过设置: $key');
      return;
    }
    
    try {
      // 使用配置的默认值
      final effectiveTtl = ttl ?? _config.getDefaultTTL(key);
      final effectivePriority = priority ?? _config.getBusinessPriority(key);
      
      // 创建缓存项
      final cacheItem = CacheItem<T>(
        key: key,
        data: data,
        timestamp: DateTime.now(),
        ttl: effectiveTtl,
        priority: effectivePriority,
        metadata: metadata,
      );
      
      // 设置到内存缓存
      _memoryCache.set(key, cacheItem);
      
      // 设置到本地存储缓存
      await _localCache.set(key, cacheItem);
      
      _monitoring.recordSet(key, _calculateDataSize(data));
      debugPrint('✅ 缓存设置成功: $key');
      
    } catch (e) {
      _monitoring.recordError(key, e.toString());
      debugPrint('❌ 设置缓存失败 $key: $e');
      throw CacheException('设置缓存失败', key: key, originalError: e);
    }
  }

  /// 移除缓存
  Future<void> remove(String key) async {
    if (!_isInitialized) {
      debugPrint('⚠️ 缓存管理器未初始化，跳过移除: $key');
      return;
    }
    
    try {
      _memoryCache.remove(key);
      await _localCache.remove(key);
      
      _monitoring.recordRemove(key);
      debugPrint('🗑️ 缓存移除成功: $key');
      
    } catch (e) {
      _monitoring.recordError(key, e.toString());
      debugPrint('❌ 移除缓存失败 $key: $e');
    }
  }

  /// 按前缀移除缓存
  Future<void> removeByPrefix(String prefix) async {
    if (!_isInitialized) {
      debugPrint('⚠️ 缓存管理器未初始化，跳过前缀移除: $prefix');
      return;
    }
    
    try {
      _memoryCache.removeByPrefix(prefix);
      await _localCache.removeByPrefix(prefix);
      
      _monitoring.recordBatchRemove(prefix);
      debugPrint('🗑️ 前缀缓存移除成功: $prefix');
      
    } catch (e) {
      debugPrint('❌ 前缀移除缓存失败 $prefix: $e');
    }
  }

  /// 清空所有缓存
  Future<void> clear() async {
    if (!_isInitialized) {
      debugPrint('⚠️ 缓存管理器未初始化，跳过清空');
      return;
    }
    
    try {
      _memoryCache.clear();
      await _localCache.clear();
      
      _monitoring.recordClear();
      debugPrint('🧹 所有缓存已清空');
      
    } catch (e) {
      debugPrint('❌ 清空缓存失败: $e');
    }
  }

  /// 批量设置缓存
  Future<void> setBatch(Map<String, dynamic> dataMap, {Duration? ttl}) async {
    final futures = dataMap.entries.map((entry) {
      return set(entry.key, entry.value, ttl: ttl);
    });
    
    await Future.wait(futures);
  }

  /// 获取缓存统计信息
  Map<String, dynamic> getStats() {
    if (!_isInitialized) {
      return {'initialized': false};
    }
    
    return {
      'initialized': true,
      'memory': _memoryCache.getStats(),
      'local': _localCache.getStats(),
      'monitoring': _monitoring.getOverallStats(),
    };
  }

  /// 清理过期缓存
  Future<void> cleanupExpiredCache() async {
    if (!_isInitialized) {
      debugPrint('⚠️ 缓存管理器未初始化，跳过清理');
      return;
    }
    
    try {
      // 清理过期的本地缓存
      final expiredCount = await _localCache.cleanupExpired();
      
      if (expiredCount > 0) {
        debugPrint('🧹 手动清理完成，移除 $expiredCount 个过期项');
      }
      
    } catch (e) {
      debugPrint('❌ 手动清理失败: $e');
    }
  }

  /// 生成性能报告
  Future<void> generatePerformanceReport() async {
    if (!_isInitialized) {
      debugPrint('⚠️ 缓存管理器未初始化，跳过报告生成');
      return;
    }
    
    try {
      await _monitoring.generateReport();
      debugPrint('📊 性能报告生成完成');
    } catch (e) {
      debugPrint('❌ 性能报告生成失败: $e');
    }
  }

  /// 启动定期清理任务
  void _startPeriodicCleanup() {
    Timer.periodic(CacheConfig.defaultCleanupInterval, (_) {
      _performCleanup();
    });
  }

  /// 执行清理任务
  Future<void> _performCleanup() async {
    try {
      // 清理过期的本地缓存
      final expiredCount = await _localCache.cleanupExpired();
      
      // 清理内存缓存（LRU会自动处理）
      
      if (expiredCount > 0) {
        debugPrint('🧹 定期清理完成，移除 $expiredCount 个过期项');
      }
      
    } catch (e) {
      debugPrint('❌ 定期清理失败: $e');
    }
  }

  /// 计算数据大小（简化版本）
  int _calculateDataSize(dynamic data) {
    try {
      if (data == null) return 0;
      if (data is String) return data.length * 2; // UTF-16 编码
      if (data is List) return data.length * 8; // 估算
      if (data is Map) return data.length * 16; // 估算
      return 64; // 默认估算
    } catch (e) {
      return 64; // 出错时的默认值
    }
  }

  @override
  void onClose() {
    debugPrint('🔄 缓存管理器关闭');
    super.onClose();
  }
}