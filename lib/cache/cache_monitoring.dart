import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:safe_app/utils/shared_prefer.dart';
import 'cache_config.dart';

/// 缓存性能监控
class CacheMonitoring {
  // 统计数据
  final Map<String, CacheMetrics> _keyMetrics = {};
  final List<CacheEvent> _eventHistory = [];
  
  // 全局统计
  int _totalRequests = 0;
  int _totalHits = 0;
  int _totalMisses = 0;
  int _totalErrors = 0;
  int _totalSets = 0;
  int _totalRemoves = 0;
  
  // 时间窗口统计（最近1小时）
  final List<TimeWindowStat> _hourlyStats = [];
  Timer? _statsTimer;
  
  // 错误记录
  final List<CacheError> _recentErrors = [];
  static const int maxErrorHistory = 100;
  
  // 性能阈值
  static const Duration slowOperationThreshold = Duration(milliseconds: 100);
  static const double lowHitRateThreshold = 0.7; // 70%
  
  CacheMonitoring() {
    _startPeriodicStatsCollection();
  }

  /// 记录缓存请求
  void recordRequest(String key) {
    _totalRequests++;
    _getOrCreateMetrics(key).recordRequest();
    
    _addEvent(CacheEvent(
      type: CacheEventType.request,
      key: key,
      timestamp: DateTime.now(),
    ));
  }

  /// 记录缓存命中
  void recordHit(String key, String source) {
    _totalHits++;
    _getOrCreateMetrics(key).recordHit(source);
    
    _addEvent(CacheEvent(
      type: CacheEventType.hit,
      key: key,
      timestamp: DateTime.now(),
      metadata: {'source': source},
    ));
  }

  /// 记录缓存未命中
  void recordMiss(String key, String reason) {
    _totalMisses++;
    _getOrCreateMetrics(key).recordMiss(reason);
    
    _addEvent(CacheEvent(
      type: CacheEventType.miss,
      key: key,
      timestamp: DateTime.now(),
      metadata: {'reason': reason},
    ));
  }

  /// 记录缓存设置
  void recordSet(String key, int dataSize) {
    _totalSets++;
    _getOrCreateMetrics(key).recordSet(dataSize);
    
    _addEvent(CacheEvent(
      type: CacheEventType.set,
      key: key,
      timestamp: DateTime.now(),
      metadata: {'size': dataSize},
    ));
  }

  /// 记录缓存移除
  void recordRemove(String key) {
    _totalRemoves++;
    _getOrCreateMetrics(key).recordRemove();
    
    _addEvent(CacheEvent(
      type: CacheEventType.remove,
      key: key,
      timestamp: DateTime.now(),
    ));
  }

  /// 记录批量移除
  void recordBatchRemove(String prefix) {
    _addEvent(CacheEvent(
      type: CacheEventType.batchRemove,
      key: prefix,
      timestamp: DateTime.now(),
    ));
  }

  /// 记录缓存清空
  void recordClear() {
    _addEvent(CacheEvent(
      type: CacheEventType.clear,
      key: 'all',
      timestamp: DateTime.now(),
    ));
  }

  /// 记录强制同步
  void recordForceSync(String key) {
    _addEvent(CacheEvent(
      type: CacheEventType.forceSync,
      key: key,
      timestamp: DateTime.now(),
    ));
  }

  /// 记录错误
  void recordError(String key, String error) {
    _totalErrors++;
    _getOrCreateMetrics(key).recordError(error);
    
    final cacheError = CacheError(
      key: key,
      error: error,
      timestamp: DateTime.now(),
      stackTrace: StackTrace.current.toString(),
    );
    
    _recentErrors.add(cacheError);
    if (_recentErrors.length > maxErrorHistory) {
      _recentErrors.removeAt(0);
    }
    
    _addEvent(CacheEvent(
      type: CacheEventType.error,
      key: key,
      timestamp: DateTime.now(),
      metadata: {'error': error},
    ));
    
    debugPrint('❌ 缓存错误: $key - $error');
  }

  /// 获取或创建键的指标
  CacheMetrics _getOrCreateMetrics(String key) {
    return _keyMetrics.putIfAbsent(key, () => CacheMetrics(key));
  }

  /// 添加事件到历史记录
  void _addEvent(CacheEvent event) {
    _eventHistory.add(event);
    
    // 保持事件历史在合理范围内
    const maxEventHistory = 1000;
    if (_eventHistory.length > maxEventHistory) {
      _eventHistory.removeRange(0, _eventHistory.length - maxEventHistory);
    }
  }

  /// 开始定期统计收集
  void _startPeriodicStatsCollection() {
    _statsTimer = Timer.periodic(Duration(minutes: 5), (_) {
      _collectTimeWindowStats();
      _checkPerformanceAlerts();
    });
  }

  /// 收集时间窗口统计
  void _collectTimeWindowStats() {
    final now = DateTime.now();
    final stat = TimeWindowStat(
      timestamp: now,
      totalRequests: _totalRequests,
      hitRate: getOverallHitRate(),
      errorRate: getErrorRate(),
      avgResponseTime: _calculateAverageResponseTime(),
    );
    
    _hourlyStats.add(stat);
    
    // 保持最近24小时的统计（每5分钟一个点，共288个点）
    const maxHourlyStats = 288;
    if (_hourlyStats.length > maxHourlyStats) {
      _hourlyStats.removeAt(0);
    }
  }

  /// 检查性能警报
  void _checkPerformanceAlerts() {
    final hitRate = getOverallHitRate();
    
    // 命中率过低警报
    if (hitRate < lowHitRateThreshold && _totalRequests > 50) {
      debugPrint('⚠️ 缓存命中率过低: ${(hitRate * 100).toStringAsFixed(1)}%');
      _recordPerformanceAlert('低命中率', '当前命中率: ${(hitRate * 100).toStringAsFixed(1)}%');
    }
    
    // 错误率过高警报
    final errorRate = getErrorRate();
    if (errorRate > 0.1) { // 10%
      debugPrint('⚠️ 缓存错误率过高: ${(errorRate * 100).toStringAsFixed(1)}%');
      _recordPerformanceAlert('高错误率', '当前错误率: ${(errorRate * 100).toStringAsFixed(1)}%');
    }
  }

  /// 记录性能警报
  void _recordPerformanceAlert(String type, String message) {
    _addEvent(CacheEvent(
      type: CacheEventType.alert,
      key: 'performance',
      timestamp: DateTime.now(),
      metadata: {'alertType': type, 'message': message},
    ));
  }

  /// 计算平均响应时间
  Duration _calculateAverageResponseTime() {
    if (_eventHistory.isEmpty) return Duration.zero;
    
    final recentEvents = _eventHistory
        .where((e) => DateTime.now().difference(e.timestamp) < Duration(minutes: 5))
        .toList();
    
    if (recentEvents.isEmpty) return Duration.zero;
    
    // 简化的响应时间计算（实际实现中需要更精确的计时）
    return Duration(milliseconds: 50); // 平均估值
  }

  /// 获取总体命中率
  double getOverallHitRate() {
    if (_totalRequests == 0) return 0.0;
    return _totalHits / _totalRequests;
  }

  /// 获取指定类型的命中率
  double getHitRate(String source) {
    final hits = _eventHistory
        .where((e) => e.type == CacheEventType.hit && e.metadata?['source'] == source)
        .length;
    
    if (_totalRequests == 0) return 0.0;
    return hits / _totalRequests;
  }

  /// 获取错误率
  double getErrorRate() {
    if (_totalRequests == 0) return 0.0;
    return _totalErrors / _totalRequests;
  }

  /// 获取总请求数
  int get totalRequests => _totalRequests;

  /// 获取错误数
  int get errorCount => _totalErrors;

  /// 获取总体统计信息
  Map<String, dynamic> getOverallStats() {
    return {
      'totalRequests': _totalRequests,
      'totalHits': _totalHits,
      'totalMisses': _totalMisses,
      'totalErrors': _totalErrors,
      'overallHitRate': getOverallHitRate(),
      'errorRate': getErrorRate(),
      'memoryHitRate': getHitRate('memory'),
      'localHitRate': getHitRate('local'),
    };
  }



  /// 生成性能报告
  Future<void> generateReport() async {
    if (!CacheConfig.enableMonitoring) return;
    
    final report = CachePerformanceReport(
      generatedAt: DateTime.now(),
      totalRequests: _totalRequests,
      totalHits: _totalHits,
      totalMisses: _totalMisses,
      totalErrors: _totalErrors,
      overallHitRate: getOverallHitRate(),
      errorRate: getErrorRate(),
      topPerformingKeys: _getTopPerformingKeys(),
      problemKeys: _getProblemKeys(),
      recentErrors: List.from(_recentErrors.take(10)),
      hourlyTrends: List.from(_hourlyStats.take(24)), // 最近2小时
    );
    
    await _saveReport(report);
    
    if (kDebugMode) {
      debugPrint('📊 缓存性能报告已生成:');
      debugPrint('  总请求: ${report.totalRequests}');
      debugPrint('  命中率: ${(report.overallHitRate * 100).toStringAsFixed(1)}%');
      debugPrint('  错误率: ${(report.errorRate * 100).toStringAsFixed(1)}%');
    }
  }

  /// 获取表现最好的键
  List<String> _getTopPerformingKeys() {
    final sortedMetrics = _keyMetrics.entries.toList()
      ..sort((a, b) => b.value.hitRate.compareTo(a.value.hitRate));
    
    return sortedMetrics
        .take(10)
        .where((e) => e.value.requests > 5) // 至少有5次请求
        .map((e) => e.key)
        .toList();
  }

  /// 获取问题键
  List<String> _getProblemKeys() {
    final problemKeys = <String>[];
    
    for (final entry in _keyMetrics.entries) {
      final metrics = entry.value;
      
      // 命中率低于阈值
      if (metrics.requests > 5 && metrics.hitRate < lowHitRateThreshold) {
        problemKeys.add(entry.key);
      }
      
      // 错误率高
      if (metrics.requests > 5 && metrics.errorCount / metrics.requests > 0.1) {
        problemKeys.add(entry.key);
      }
    }
    
    return problemKeys;
  }

  /// 保存报告
  Future<void> _saveReport(CachePerformanceReport report) async {
    try {
      const key = 'cache_performance_report';
      final jsonString = json.encode(report.toJson());
      await FYSharedPreferenceUtils.setString(key, jsonString);
    } catch (e) {
      debugPrint('❌ 保存缓存性能报告失败: $e');
    }
  }

  /// 获取最近的性能报告
  Future<CachePerformanceReport?> getLatestReport() async {
    try {
      const key = 'cache_performance_report';
      final jsonString = FYSharedPreferenceUtils.getString(key);
      
      if (jsonString.isNotEmpty) {
        final jsonData = json.decode(jsonString);
        return CachePerformanceReport.fromJson(jsonData);
      }
    } catch (e) {
      debugPrint('❌ 加载缓存性能报告失败: $e');
    }
    
    return null;
  }

  /// 重置统计数据
  void reset() {
    _keyMetrics.clear();
    _eventHistory.clear();
    _hourlyStats.clear();
    _recentErrors.clear();
    
    _totalRequests = 0;
    _totalHits = 0;
    _totalMisses = 0;
    _totalErrors = 0;
    _totalSets = 0;
    _totalRemoves = 0;
    
    debugPrint('📊 缓存统计数据已重置');
  }

  /// 释放资源
  void dispose() {
    _statsTimer?.cancel();
  }
}

/// 单个键的缓存指标
class CacheMetrics {
  final String key;
  int requests = 0;
  int hits = 0;
  int misses = 0;
  int errorCount = 0;
  int sets = 0;
  int removes = 0;
  int totalDataSize = 0;
  DateTime? firstRequest;
  DateTime? lastRequest;
  final Map<String, int> hitSources = {}; // memory, local等
  final Map<String, int> missReasons = {}; // not_found, expired等

  CacheMetrics(this.key);

  void recordRequest() {
    requests++;
    final now = DateTime.now();
    firstRequest ??= now;
    lastRequest = now;
  }

  void recordHit(String source) {
    hits++;
    hitSources[source] = (hitSources[source] ?? 0) + 1;
  }

  void recordMiss(String reason) {
    misses++;
    missReasons[reason] = (missReasons[reason] ?? 0) + 1;
  }

  void recordSet(int dataSize) {
    sets++;
    totalDataSize += dataSize;
  }

  void recordRemove() {
    removes++;
  }

  void recordError(String error) {
    errorCount++;
  }

  double get hitRate => requests > 0 ? hits / requests : 0.0;
  int get avgDataSize => sets > 0 ? totalDataSize ~/ sets : 0;
}

/// 缓存事件
class CacheEvent {
  final CacheEventType type;
  final String key;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  CacheEvent({
    required this.type,
    required this.key,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'key': key,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  static CacheEvent fromJson(Map<String, dynamic> json) {
    return CacheEvent(
      type: CacheEventType.values.firstWhere((e) => e.name == json['type']),
      key: json['key'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      metadata: json['metadata']?.cast<String, dynamic>(),
    );
  }
}

/// 缓存事件类型
enum CacheEventType {
  request,
  hit,
  miss,
  set,
  remove,
  batchRemove,
  clear,
  error,
  alert,
  forceSync,
}

/// 时间窗口统计
class TimeWindowStat {
  final DateTime timestamp;
  final int totalRequests;
  final double hitRate;
  final double errorRate;
  final Duration avgResponseTime;

  TimeWindowStat({
    required this.timestamp,
    required this.totalRequests,
    required this.hitRate,
    required this.errorRate,
    required this.avgResponseTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'totalRequests': totalRequests,
      'hitRate': hitRate,
      'errorRate': errorRate,
      'avgResponseTime': avgResponseTime.inMilliseconds,
    };
  }

  static TimeWindowStat fromJson(Map<String, dynamic> json) {
    return TimeWindowStat(
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      totalRequests: json['totalRequests'],
      hitRate: json['hitRate'],
      errorRate: json['errorRate'],
      avgResponseTime: Duration(milliseconds: json['avgResponseTime']),
    );
  }
}

/// 缓存错误
class CacheError {
  final String key;
  final String error;
  final DateTime timestamp;
  final String stackTrace;

  CacheError({
    required this.key,
    required this.error,
    required this.timestamp,
    required this.stackTrace,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'error': error,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'stackTrace': stackTrace,
    };
  }

  static CacheError fromJson(Map<String, dynamic> json) {
    return CacheError(
      key: json['key'],
      error: json['error'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      stackTrace: json['stackTrace'],
    );
  }
}

/// 缓存性能报告
class CachePerformanceReport {
  final DateTime generatedAt;
  final int totalRequests;
  final int totalHits;
  final int totalMisses;
  final int totalErrors;
  final double overallHitRate;
  final double errorRate;
  final List<String> topPerformingKeys;
  final List<String> problemKeys;
  final List<CacheError> recentErrors;
  final List<TimeWindowStat> hourlyTrends;

  CachePerformanceReport({
    required this.generatedAt,
    required this.totalRequests,
    required this.totalHits,
    required this.totalMisses,
    required this.totalErrors,
    required this.overallHitRate,
    required this.errorRate,
    required this.topPerformingKeys,
    required this.problemKeys,
    required this.recentErrors,
    required this.hourlyTrends,
  });

  Map<String, dynamic> toJson() {
    return {
      'generatedAt': generatedAt.millisecondsSinceEpoch,
      'totalRequests': totalRequests,
      'totalHits': totalHits,
      'totalMisses': totalMisses,
      'totalErrors': totalErrors,
      'overallHitRate': overallHitRate,
      'errorRate': errorRate,
      'topPerformingKeys': topPerformingKeys,
      'problemKeys': problemKeys,
      'recentErrors': recentErrors.map((e) => e.toJson()).toList(),
      'hourlyTrends': hourlyTrends.map((e) => e.toJson()).toList(),
    };
  }

  static CachePerformanceReport fromJson(Map<String, dynamic> json) {
    return CachePerformanceReport(
      generatedAt: DateTime.fromMillisecondsSinceEpoch(json['generatedAt']),
      totalRequests: json['totalRequests'],
      totalHits: json['totalHits'],
      totalMisses: json['totalMisses'],
      totalErrors: json['totalErrors'],
      overallHitRate: json['overallHitRate'],
      errorRate: json['errorRate'],
      topPerformingKeys: List<String>.from(json['topPerformingKeys']),
      problemKeys: List<String>.from(json['problemKeys']),
      recentErrors: (json['recentErrors'] as List)
          .map((e) => CacheError.fromJson(e))
          .toList(),
      hourlyTrends: (json['hourlyTrends'] as List)
          .map((e) => TimeWindowStat.fromJson(e))
          .toList(),
    );
  }
} 