import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:safe_app/utils/shared_prefer.dart';
import 'cache_config.dart';
import 'cache_models.dart';

/// 内存缓存实现 - 基于LRU算法
class MemoryCache {
  final int maxSize;
  final int maxItems;
  final Map<String, CacheItem> _cache = {};
  int _currentSize = 0;

  MemoryCache({
    this.maxSize = CacheConfig.memoryMaxSize,
    this.maxItems = CacheConfig.memoryMaxItems,
  });

  /// 获取缓存项
  CacheItem? get(String key) {
    final item = _cache[key];
    if (item != null) {
      item.recordHit();
    }
    return item;
  }

  /// 设置缓存项
  void set(String key, CacheItem item) {
    // 如果已存在，先移除旧的
    if (_cache.containsKey(key)) {
      remove(key);
    }

    // 检查容量限制
    _ensureCapacity(item);

    _cache[key] = item;
    _currentSize += _calculateItemSize(item);
    
    debugPrint('💾 内存缓存设置: $key (${_cache.length}/${maxItems}项, ${(_currentSize/1024).toStringAsFixed(1)}KB)');
  }

  /// 移除缓存项
  void remove(String key) {
    final item = _cache.remove(key);
    if (item != null) {
      _currentSize -= _calculateItemSize(item);
    }
  }

  /// 按前缀移除
  void removeByPrefix(String prefix) {
    final keysToRemove = _cache.keys.where((key) => key.startsWith(prefix)).toList();
    for (final key in keysToRemove) {
      remove(key);
    }
    debugPrint('🗑️ 按前缀清理内存缓存: $prefix (${keysToRemove.length}项)');
  }

  /// 清空所有缓存
  void clear() {
    final count = _cache.length;
    _cache.clear();
    _currentSize = 0;
    debugPrint('🧹 清空内存缓存: $count 项');
  }

  /// 确保容量限制
  void _ensureCapacity(CacheItem newItem) {
    final newItemSize = _calculateItemSize(newItem);
    
    // 如果单个项目就超过最大容量，拒绝缓存
    if (newItemSize > maxSize) {
      throw CacheCapacityException(newItemSize, maxSize);
    }

    // 基于LRU和优先级清理空间
    while ((_currentSize + newItemSize > maxSize || _cache.length >= maxItems) && _cache.isNotEmpty) {
      _evictLeastValuable();
    }
  }

  /// 淘汰最不重要的缓存项
  void _evictLeastValuable() {
    if (_cache.isEmpty) return;

    // 计算所有项的LRU分数，分数越低越容易被淘汰
    final sortedEntries = _cache.entries.toList()
      ..sort((a, b) {
        // 关键数据永不淘汰
        if (a.value.priority == CachePriority.critical) return 1;
        if (b.value.priority == CachePriority.critical) return -1;
        
        return a.value.lruScore.compareTo(b.value.lruScore);
      });

    final victimKey = sortedEntries.first.key;
    remove(victimKey);
    
    debugPrint('🗑️ LRU淘汰: $victimKey');
  }

  /// 计算缓存项大小
  int _calculateItemSize(CacheItem item) {
    try {
      final jsonString = json.encode(item.toJson());
      return utf8.encode(jsonString).length;
    } catch (e) {
      // 估算大小
      return 1024; // 默认1KB
    }
  }

  /// 压缩内存 - 移除过期项
  int compress() {
    final expiredKeys = <String>[];
    
    for (final entry in _cache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      debugPrint('🗜️ 内存压缩完成: 移除${expiredKeys.length}个过期项');
    }

    return expiredKeys.length;
  }

  /// 清理过期缓存
  Future<int> cleanupExpired() async {
    return compress();
  }

  /// 获取当前大小
  int get currentSize => _currentSize;

  /// 获取缓存项数量
  int get itemCount => _cache.length;

  /// 获取内存使用率
  double get usageRatio => maxSize > 0 ? _currentSize / maxSize : 0.0;

  /// 获取统计信息
  Map<String, dynamic> getStats() {
    return {
      'itemCount': itemCount,
      'currentSize': currentSize,
      'maxSize': maxSize,
      'usageRatio': usageRatio,
      'avgItemSize': itemCount > 0 ? currentSize / itemCount : 0,
    };
  }
}

/// 本地存储缓存实现
class LocalStorageCache {
  static const String _cacheKeyPrefix = 'safe_app_cache_';
  static const String _metaKeyPrefix = 'safe_app_meta_';
  static const String _indexKey = 'safe_app_cache_index';
  
  late Map<String, CacheIndexEntry> _index;
  int _estimatedSize = 0;

  /// 初始化
  Future<void> initialize() async {
    await _loadIndex();
    await _calculateEstimatedSize();
    debugPrint('📱 本地缓存初始化完成: ${_index.length}项, ${(_estimatedSize/1024).toStringAsFixed(1)}KB');
  }

  /// 获取缓存项
  Future<CacheItem<T>?> get<T>(String key) async {
    try {
      final cacheKey = _cacheKeyPrefix + key;
      final jsonString = FYSharedPreferenceUtils.getString(cacheKey);
      
      if (jsonString.isEmpty) {
        return null;
      }

      final jsonData = json.decode(jsonString);
      final item = CacheItem.fromJson<T>(jsonData);

      // 更新访问时间
      _updateIndexAccess(key);
      
      return item;
    } catch (e) {
      debugPrint('❌ 本地缓存读取失败 $key: $e');
      await remove(key); // 移除损坏的缓存
      return null;
    }
  }

  /// 设置缓存项
  Future<void> set<T>(String key, CacheItem<T> item) async {
    try {
      final cacheKey = _cacheKeyPrefix + key;
      final jsonString = json.encode(item.toJson());
      final dataSize = utf8.encode(jsonString).length;

      // 检查存储空间
      await _ensureStorageCapacity(dataSize);

      // 保存数据
      await FYSharedPreferenceUtils.setString(cacheKey, jsonString);

      // 更新索引
      _updateIndex(key, dataSize, item.priority);
      await _saveIndex();

      debugPrint('💿 本地缓存保存: $key (${(dataSize/1024).toStringAsFixed(1)}KB)');
    } catch (e) {
      debugPrint('❌ 本地缓存保存失败 $key: $e');
      throw CacheException('本地缓存保存失败', key: key, originalError: e);
    }
  }

  /// 移除缓存项
  Future<void> remove(String key) async {
    try {
      final cacheKey = _cacheKeyPrefix + key;
      await FYSharedPreferenceUtils.remove(cacheKey);
      
      final indexEntry = _index.remove(key);
      if (indexEntry != null) {
        _estimatedSize -= indexEntry.size;
      }
      
      await _saveIndex();
    } catch (e) {
      debugPrint('❌ 本地缓存删除失败 $key: $e');
    }
  }

  /// 按前缀移除
  Future<void> removeByPrefix(String prefix) async {
    final keysToRemove = _index.keys.where((key) => key.startsWith(prefix)).toList();
    
    for (final key in keysToRemove) {
      await remove(key);
    }
    
    debugPrint('🗑️ 按前缀清理本地缓存: $prefix (${keysToRemove.length}项)');
  }

  /// 清空所有缓存
  Future<void> clear() async {
    try {
      final keys = List<String>.from(_index.keys);
      
      for (final key in keys) {
        await remove(key);
      }
      
      _index.clear();
      _estimatedSize = 0;
      await _saveIndex();
      
      debugPrint('🧹 清空本地缓存: ${keys.length} 项');
    } catch (e) {
      debugPrint('❌ 清空本地缓存失败: $e');
    }
  }

  /// 清理过期缓存
  Future<int> cleanupExpired() async {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    for (final entry in _index.entries) {
      final expireTime = entry.value.timestamp.add(entry.value.ttl);
      if (now.isAfter(expireTime)) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      await remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      debugPrint('🗑️ 清理过期本地缓存: ${expiredKeys.length}项');
    }

    return expiredKeys.length;
  }

  /// 获取关键数据键列表
  Future<List<String>> getCriticalKeys() async {
    return _index.entries
        .where((entry) => entry.value.priority == CachePriority.critical)
        .map((entry) => entry.key)
        .toList();
  }

  /// 确保存储容量
  Future<void> _ensureStorageCapacity(int newDataSize) async {
    const maxLocalSize = CacheConfig.localMaxSize;
    
    while (_estimatedSize + newDataSize > maxLocalSize && _index.isNotEmpty) {
      await _evictLeastValuableLocal();
    }
  }

  /// 淘汰最不重要的本地缓存项
  Future<void> _evictLeastValuableLocal() async {
    if (_index.isEmpty) return;

    // 按优先级和访问时间排序
    final sortedEntries = _index.entries.toList()
      ..sort((a, b) {
        // 关键数据永不淘汰
        if (a.value.priority == CachePriority.critical) return 1;
        if (b.value.priority == CachePriority.critical) return -1;
        
        // 优先级权重
        final aPriority = CacheConfig.priorityWeights[a.value.priority] ?? 0.5;
        final bPriority = CacheConfig.priorityWeights[b.value.priority] ?? 0.5;
        
        if (aPriority != bPriority) {
          return aPriority.compareTo(bPriority);
        }
        
        // 最后访问时间
        return a.value.lastAccess.compareTo(b.value.lastAccess);
      });

    final victimKey = sortedEntries.first.key;
    await remove(victimKey);
    
    debugPrint('🗑️ 本地存储LRU淘汰: $victimKey');
  }

  /// 加载索引
  Future<void> _loadIndex() async {
    try {
      final indexJson = FYSharedPreferenceUtils.getString(_indexKey);
      if (indexJson.isNotEmpty) {
        final Map<String, dynamic> indexData = json.decode(indexJson);
        _index = indexData.map((key, value) => MapEntry(
          key, 
          CacheIndexEntry.fromJson(value as Map<String, dynamic>)
        ));
      } else {
        _index = {};
      }
    } catch (e) {
      debugPrint('❌ 加载缓存索引失败: $e');
      _index = {};
    }
  }

  /// 保存索引
  Future<void> _saveIndex() async {
    try {
      final indexData = _index.map((key, value) => MapEntry(key, value.toJson()));
      final indexJson = json.encode(indexData);
      await FYSharedPreferenceUtils.setString(_indexKey, indexJson);
    } catch (e) {
      debugPrint('❌ 保存缓存索引失败: $e');
    }
  }

  /// 更新索引
  void _updateIndex(String key, int size, CachePriority priority) {
    final oldEntry = _index[key];
    if (oldEntry != null) {
      _estimatedSize -= oldEntry.size;
    }

    _index[key] = CacheIndexEntry(
      key: key,
      size: size,
      timestamp: DateTime.now(),
      lastAccess: DateTime.now(),
      priority: priority,
      ttl: Duration(minutes: 30), // 默认TTL
    );
    
    _estimatedSize += size;
  }

  /// 更新访问时间
  void _updateIndexAccess(String key) {
    final entry = _index[key];
    if (entry != null) {
      entry.lastAccess = DateTime.now();
    }
  }

  /// 计算估算大小
  Future<void> _calculateEstimatedSize() async {
    _estimatedSize = _index.values.fold(0, (sum, entry) => sum + entry.size);
  }

  /// 获取估算大小
  int get estimatedSize => _estimatedSize;

  /// 获取统计信息
  Map<String, dynamic> getStats() {
    return {
      'itemCount': _index.length,
      'estimatedSize': _estimatedSize,
      'maxSize': CacheConfig.localMaxSize,
      'usageRatio': _estimatedSize / CacheConfig.localMaxSize,
      'avgItemSize': _index.isNotEmpty ? _estimatedSize / _index.length : 0,
    };
  }
}

/// 缓存索引条目
class CacheIndexEntry {
  final String key;
  final int size;
  final DateTime timestamp;
  DateTime lastAccess;
  final CachePriority priority;
  final Duration ttl;

  CacheIndexEntry({
    required this.key,
    required this.size,
    required this.timestamp,
    required this.lastAccess,
    required this.priority,
    required this.ttl,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'size': size,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'lastAccess': lastAccess.millisecondsSinceEpoch,
      'priority': priority.index,
      'ttl': ttl.inMilliseconds,
    };
  }

  static CacheIndexEntry fromJson(Map<String, dynamic> json) {
    return CacheIndexEntry(
      key: json['key'],
      size: json['size'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      lastAccess: DateTime.fromMillisecondsSinceEpoch(json['lastAccess']),
      priority: CachePriority.values[json['priority']],
      ttl: Duration(milliseconds: json['ttl']),
    );
  }
} 