import 'dart:convert';
import 'cache_config.dart';

/// 缓存项模型 - 包装实际缓存的数据
class CacheItem<T> {
  final String key;
  final T data;
  final DateTime timestamp;
  final Duration ttl;
  final CachePriority priority;
  final Map<String, dynamic>? metadata;
  DateTime lastAccess;
  int hitCount;
  
  CacheItem({
    required this.key,
    required this.data,
    required this.timestamp,
    required this.ttl,
    this.priority = CachePriority.normal,
    this.metadata,
  }) : lastAccess = DateTime.now(),
       hitCount = 0;

  /// 检查是否过期
  bool get isExpired {
    return DateTime.now().isAfter(timestamp.add(ttl));
  }

  /// 获取年龄（创建后经过的时间）
  Duration get age {
    return DateTime.now().difference(timestamp);
  }

  /// 获取上次访问后经过的时间
  Duration get timeSinceLastAccess {
    return DateTime.now().difference(lastAccess);
  }

  /// 计算LRU权重分数
  double get lruScore {
    final ageWeight = 0.3;
    final accessWeight = 0.4;
    final hitWeight = 0.3;
    
    // 年龄分数（越新分数越高）
    final ageScore = 1.0 - (age.inMilliseconds / (24 * 60 * 60 * 1000));
    
    // 访问时间分数（越近访问分数越高）
    final accessScore = 1.0 - (timeSinceLastAccess.inMilliseconds / (60 * 60 * 1000));
    
    // 命中次数分数（归一化）
    final hitScore = hitCount / (hitCount + 10.0);
    
    return (ageScore * ageWeight + accessScore * accessWeight + hitScore * hitWeight)
           * CacheConfig.priorityWeights[priority]!;
  }

  /// 记录命中
  void recordHit() {
    hitCount++;
    lastAccess = DateTime.now();
  }

  /// 序列化为JSON
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'data': _serializeData(data),
      'timestamp': timestamp.millisecondsSinceEpoch,
      'ttl': ttl.inMilliseconds,
      'priority': priority.index,
      'metadata': metadata,
      'lastAccess': lastAccess.millisecondsSinceEpoch,
      'hitCount': hitCount,
    };
  }

  /// 从JSON反序列化
  static CacheItem<T> fromJson<T>(Map<String, dynamic> json) {
    return CacheItem<T>(
      key: json['key'],
      data: _deserializeData<T>(json['data']),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      ttl: Duration(milliseconds: json['ttl']),
      priority: CachePriority.values[json['priority'] ?? 2], // 默认normal
      metadata: json['metadata']?.cast<String, dynamic>(),
    )
      ..lastAccess = DateTime.fromMillisecondsSinceEpoch(json['lastAccess'] ?? json['timestamp'])
      ..hitCount = json['hitCount'] ?? 0;
  }

  /// 序列化数据
  static dynamic _serializeData(dynamic data) {
    if (data == null) return null;
    
    try {
      // 如果数据已经是基本类型，直接返回
      if (data is String || data is num || data is bool) {
        return data;
      }
      
      // 如果是Map或List，可以直接JSON序列化
      if (data is Map || data is List) {
        return data;
      }
      
      // 其他类型尝试通过toJson方法序列化
      if (data is Object && data.runtimeType.toString().contains('toJson')) {
        return (data as dynamic).toJson();
      }
      
      // 最后尝试JSON编码
      return jsonDecode(jsonEncode(data));
    } catch (e) {
      // 序列化失败，返回字符串表示
      return data.toString();
    }
  }

  /// 反序列化数据
  static T _deserializeData<T>(dynamic serializedData) {
    if (serializedData == null) return null as T;
    
    try {
      // 如果T是基本类型，直接转换
      if (T == String || T == int || T == double || T == bool) {
        return serializedData as T;
      }
      
      // 如果是Map或List，直接返回
      if (T == Map || T == List) {
        return serializedData as T;
      }
      
      // 动态类型，直接返回
      if (T == dynamic) {
        return serializedData as T;
      }
      
      // 其他类型返回序列化数据
      return serializedData as T;
    } catch (e) {
      throw CacheSerializationException('反序列化失败: $e');
    }
  }

  @override
  String toString() {
    return 'CacheItem{key: $key, age: ${age.inMinutes}min, hits: $hitCount, priority: $priority}';
  }
}

/// 缓存统计信息
class CacheStats {
  final String key;
  final int hitCount;
  final int missCount;
  final DateTime firstAccess;
  final DateTime lastAccess;
  final int dataSize;
  final Duration averageAccessTime;

  CacheStats({
    required this.key,
    required this.hitCount,
    required this.missCount,
    required this.firstAccess,
    required this.lastAccess,
    required this.dataSize,
    required this.averageAccessTime,
  });

  double get hitRate {
    final total = hitCount + missCount;
    return total > 0 ? hitCount / total : 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'hitCount': hitCount,
      'missCount': missCount,
      'firstAccess': firstAccess.millisecondsSinceEpoch,
      'lastAccess': lastAccess.millisecondsSinceEpoch,
      'dataSize': dataSize,
      'averageAccessTime': averageAccessTime.inMilliseconds,
      'hitRate': hitRate,
    };
  }
}

/// 缓存元数据
class CacheMetadata {
  final String? contentType;
  final String? etag;
  final DateTime? lastModified;
  final Map<String, String>? headers;
  final String? compression;
  final int? originalSize;
  final int? compressedSize;

  CacheMetadata({
    this.contentType,
    this.etag,
    this.lastModified,
    this.headers,
    this.compression,
    this.originalSize,
    this.compressedSize,
  });

  Map<String, dynamic> toJson() {
    return {
      'contentType': contentType,
      'etag': etag,
      'lastModified': lastModified?.millisecondsSinceEpoch,
      'headers': headers,
      'compression': compression,
      'originalSize': originalSize,
      'compressedSize': compressedSize,
    };
  }

  static CacheMetadata fromJson(Map<String, dynamic> json) {
    return CacheMetadata(
      contentType: json['contentType'],
      etag: json['etag'],
      lastModified: json['lastModified'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['lastModified'])
          : null,
      headers: json['headers']?.cast<String, String>(),
      compression: json['compression'],
      originalSize: json['originalSize'],
      compressedSize: json['compressedSize'],
    );
  }
}

/// 缓存查询结果
class CacheQueryResult<T> {
  final T? data;
  final CacheHitType hitType;
  final Duration accessTime;
  final String? source;
  final CacheMetadata? metadata;

  CacheQueryResult({
    this.data,
    required this.hitType,
    required this.accessTime,
    this.source,
    this.metadata,
  });

  bool get isHit => hitType != CacheHitType.miss;
  bool get isMiss => hitType == CacheHitType.miss;
}

/// 缓存命中类型
enum CacheHitType {
  memoryHit,  // 内存命中
  localHit,   // 本地存储命中
  miss,       // 未命中
}

/// 缓存操作结果
class CacheOperationResult {
  final bool success;
  final String? error;
  final Duration operationTime;
  final int? dataSize;

  CacheOperationResult({
    required this.success,
    this.error,
    required this.operationTime,
    this.dataSize,
  });

  static CacheOperationResult createSuccess({
    required Duration operationTime,
    int? dataSize,
  }) {
    return CacheOperationResult(
      success: true,
      operationTime: operationTime,
      dataSize: dataSize,
    );
  }

  static CacheOperationResult failure({
    required String error,
    required Duration operationTime,
  }) {
    return CacheOperationResult(
      success: false,
      error: error,
      operationTime: operationTime,
    );
  }
}

/// 批量缓存操作结果
class BatchCacheResult {
  final int successCount;
  final int failureCount;
  final List<String> errors;
  final Duration totalTime;

  BatchCacheResult({
    required this.successCount,
    required this.failureCount,
    required this.errors,
    required this.totalTime,
  });

  int get totalCount => successCount + failureCount;
  double get successRate => totalCount > 0 ? successCount / totalCount : 0.0;
}

/// 缓存键构建器
class CacheKeyBuilder {
  final String prefix;
  final Map<String, dynamic> params;

  CacheKeyBuilder(this.prefix) : params = {};

  CacheKeyBuilder addParam(String key, dynamic value) {
    if (value != null) {
      params[key] = value.toString();
    }
    return this;
  }

  CacheKeyBuilder addParams(Map<String, dynamic> newParams) {
    params.addAll(newParams.map((k, v) => MapEntry(k, v?.toString())));
    return this;
  }

  String build() {
    if (params.isEmpty) {
      return prefix;
    }

    final sortedParams = Map.fromEntries(
      params.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );

    final paramString = sortedParams.entries
        .where((e) => e.value != null && e.value!.isNotEmpty)
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    return paramString.isEmpty ? prefix : '${prefix}?$paramString';
  }
}

/// 缓存异常类
class CacheException implements Exception {
  final String message;
  final String? key;
  final dynamic originalError;

  CacheException(this.message, {this.key, this.originalError});

  @override
  String toString() {
    return 'CacheException: $message${key != null ? ' (key: $key)' : ''}';
  }
}

/// 缓存序列化异常
class CacheSerializationException extends CacheException {
  CacheSerializationException(String message, {String? key}) 
      : super(message, key: key);
}

/// 缓存容量超限异常
class CacheCapacityException extends CacheException {
  final int currentSize;
  final int maxSize;

  CacheCapacityException(this.currentSize, this.maxSize) 
      : super('缓存容量超限: $currentSize > $maxSize');
}

/// 缓存过期异常
class CacheExpiredException extends CacheException {
  final DateTime expiredTime;

  CacheExpiredException(String key, this.expiredTime) 
      : super('缓存已过期', key: key);
} 