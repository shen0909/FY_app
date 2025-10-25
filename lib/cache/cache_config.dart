import 'package:flutter/foundation.dart';

/// 缓存配置管理
/// 统一管理所有缓存相关的配置项
class CacheConfig {
  // 内存缓存配置
  static const int memoryMaxSize = 50 * 1024 * 1024; // 50MB
  static const int memoryMaxItems = 1000; // 最大缓存项数
  
  // 本地存储配置
  static const int localMaxSize = 200 * 1024 * 1024; // 200MB
  static const Duration defaultCleanupInterval = Duration(hours: 6);
  
  // TTL配置映射 - 根据不同业务数据设置不同的生存时间
  static const Map<String, Duration> ttlConfig = {
    // 轮播图相关 (新增)
    'banner_list': Duration(hours: 6),      // 轮播图列表6小时
    'banner_detail': Duration(hours: 12),   // 轮播图详情12小时
    'banner_config': Duration(days: 1),     // 轮播图配置1天
    
    // 风险预警相关
    'risk_high': Duration(minutes: 5),      // 高风险数据5分钟
    'risk_medium': Duration(minutes: 15),   // 中风险数据15分钟
    'risk_low': Duration(hours: 1),         // 低风险数据1小时
    'risk_list': Duration(minutes: 10),     // 风险列表10分钟
    'risk_detail': Duration(minutes: 30),   // 风险详情30分钟
    'risk_region': Duration(hours: 24),     // 地区数据24小时
    
    // 舆情热点相关
    'hotpot_latest': Duration(minutes: 3),  // 最新舆情3分钟
    'hotpot_recent': Duration(minutes: 10), // 近期舆情10分钟
    'hotpot_history': Duration(hours: 2),   // 历史舆情2小时
    'hotpot_detail': Duration(minutes: 30), // 舆情详情30分钟
    'hotpot_region': Duration(hours: 6),    // 地区列表6小时
    
    // 通用数据
    'user_data': Duration(hours: 4),        // 用户数据4小时
    'config_data': Duration(hours: 12),     // 配置数据12小时
    'static_data': Duration(days: 7),       // 静态数据7天
  };
  
  // 优先级权重配置
  static const Map<CachePriority, double> priorityWeights = {
    CachePriority.critical: 1.0,   // 关键数据，永不被LRU淘汰
    CachePriority.high: 0.8,       // 高优先级
    CachePriority.normal: 0.5,     // 普通优先级
    CachePriority.low: 0.2,        // 低优先级
  };
  
  // 缓存键前缀定义
  static const Map<String, String> keyPrefixes = {
    'risk_list': 'risk_list',
    'risk_detail': 'risk_detail',
    'hotpot_list': 'hotpot_list',
    'hotpot_detail': 'hotpot_detail',
    'region_data': 'region_data',
    'user_pref': 'user_pref',
  };
  
  // 压缩配置
  static const bool enableCompression = true;
  static const int compressionThreshold = 1024; // 1KB以上数据启用压缩
  
  // 监控配置
  static const bool enableMonitoring = kDebugMode; // Debug模式下启用监控
  static const Duration monitoringReportInterval = Duration(hours: 1);
  
  /// 获取指定键的默认TTL
  Duration getDefaultTTL(String key) {
    // 根据键前缀匹配TTL
    for (final entry in ttlConfig.entries) {
      if (key.startsWith(entry.key)) {
        return entry.value;
      }
    }
    
    // 默认TTL - 根据时间段动态调整
    return _getDynamicTTL();
  }
  
  /// 动态TTL计算 - 根据当前时间和使用模式
  Duration _getDynamicTTL() {
    final now = DateTime.now();
    final hour = now.hour;
    
    // 工作时间(9-18点)缓存时间较短，保证数据新鲜度
    if (hour >= 9 && hour <= 18) {
      return Duration(minutes: 15);
    }
    
    // 非工作时间缓存时间较长，减少不必要的网络请求
    return Duration(hours: 1);
  }
  
  /// 获取业务优先级
  CachePriority getBusinessPriority(String key) {
    // 轮播图优先级判断 (新增)
    if (key == 'banner_list') {
      return CachePriority.high; // 首页轮播图高优先级
    }
    if (key.startsWith('banner_detail')) {
      return CachePriority.normal; // 轮播图详情普通优先级
    }
    
    if (key.contains('high_risk') || key.contains('critical')) {
      return CachePriority.critical;
    }
    
    if (key.contains('latest') || key.contains('real_time')) {
      return CachePriority.high;
    }
    
    if (key.contains('history') || key.contains('archive')) {
      return CachePriority.low;
    }
    
    return CachePriority.normal;
  }
  
  /// 是否启用预加载
  bool shouldPreload(String key) {
    // 关键业务数据启用预加载
    return key.startsWith('banner_list') ||    // 轮播图列表启用预加载 (新增)
           key.startsWith('risk_list') || 
           key.startsWith('hotpot_latest') ||
           key.startsWith('region_data');
  }
  
  /// 获取压缩配置
  CompressionConfig getCompressionConfig(String key, int dataSize) {
    return CompressionConfig(
      enabled: enableCompression && dataSize > compressionThreshold,
      level: _getCompressionLevel(key, dataSize),
      algorithm: CompressionAlgorithm.gzip,
    );
  }
  
  /// 获取压缩级别
  int _getCompressionLevel(String key, int dataSize) {
    // 大数据使用高压缩比
    if (dataSize > 10 * 1024) return 6; // 10KB以上
    
    // 中等数据使用中等压缩比
    if (dataSize > 1024) return 4; // 1KB-10KB
    
    // 小数据使用低压缩比，保证速度
    return 1;
  }
  
  /// 获取网络策略配置
  NetworkStrategy getNetworkStrategy(String key) {
    // 关键数据优先使用网络
    if (key.contains('critical') || key.contains('real_time')) {
      return NetworkStrategy.networkFirst;
    }
    
    // 一般数据优先使用缓存
    return NetworkStrategy.cacheFirst;
  }
  
  /// 获取同步策略
  SyncStrategy getSyncStrategy(String key) {
    if (key.startsWith('user_') || key.contains('preference')) {
      return SyncStrategy.immediate; // 用户数据立即同步
    }
    
    if (key.contains('critical')) {
      return SyncStrategy.priority; // 关键数据优先同步
    }
    
    return SyncStrategy.batch; // 批量同步
  }
}

/// 缓存优先级
enum CachePriority {
  critical, // 关键数据
  high,     // 高优先级
  normal,   // 普通优先级
  low,      // 低优先级
}

/// 压缩配置
class CompressionConfig {
  final bool enabled;
  final int level;
  final CompressionAlgorithm algorithm;
  
  CompressionConfig({
    required this.enabled,
    required this.level,
    required this.algorithm,
  });
}

/// 压缩算法
enum CompressionAlgorithm {
  gzip,
  deflate,
  lz4,
}

/// 网络策略
enum NetworkStrategy {
  cacheFirst,   // 缓存优先
  networkFirst, // 网络优先
  cacheOnly,    // 仅缓存
  networkOnly,  // 仅网络
}

/// 同步策略
enum SyncStrategy {
  immediate, // 立即同步
  priority,  // 优先同步
  batch,     // 批量同步
  manual,    // 手动同步
}

/// 缓存环境配置
class CacheEnvironment {
  static bool get isProduction => kReleaseMode;
  static bool get isDevelopment => kDebugMode;
  
  /// 开发环境配置
  static const Map<String, dynamic> developmentConfig = {
    'enableDebugLogs': true,
    'enableMonitoring': true,
    'compressionEnabled': false, // 开发环境关闭压缩便于调试
    'memorySize': 30 * 1024 * 1024, // 30MB
    'cleanupInterval': Duration(minutes: 1), // 1分钟清理一次
  };
  
  /// 生产环境配置
  static const Map<String, dynamic> productionConfig = {
    'enableDebugLogs': false,
    'enableMonitoring': false,
    'compressionEnabled': true,
    'memorySize': 50 * 1024 * 1024, // 50MB
    'cleanupInterval': Duration(hours: 6), // 6小时清理一次
  };
  
  /// 获取当前环境配置
  static Map<String, dynamic> get currentConfig {
    return isProduction ? productionConfig : developmentConfig;
  }
} 