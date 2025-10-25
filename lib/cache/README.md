# 企业级缓存系统使用说明

## 📖 概述

本缓存系统是专为Safe App项目设计的企业级缓存解决方案，支持多层级缓存、智能更新、性能监控等功能。

## 🏗️ 架构设计

```
┌─────────────────────────────────────────┐
│              业务层                       │
│  RiskLogic / HotPotLogic                │
├─────────────────────────────────────────┤
│        BusinessCacheService             │
│          业务缓存服务                     │
├─────────────────────────────────────────┤
│           CacheManager                  │
│          核心缓存管理器                   │
├─────────────────────────────────────────┤
│    MemoryCache    │  LocalStorageCache  │
│     内存缓存      │     本地存储缓存     │
├─────────────────────────────────────────┤
│          CacheMonitoring                │
│           性能监控                       │
└─────────────────────────────────────────┘
```

## 🚀 快速开始

### 1. 添加依赖

在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  crypto: ^3.0.3  # 用于缓存键哈希计算
```

### 2. 初始化缓存系统

在 `main.dart` 中：

```dart
import 'package:safe_app/cache/cache_manager.dart';
import 'package:safe_app/cache/business_cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化缓存系统
  await initializeCacheSystem();
  
  runApp(MyApp());
}

Future<void> initializeCacheSystem() async {
  try {
    // 注册缓存服务
    Get.put(CacheManager());
    Get.put(BusinessCacheService());
    
    // 缓存预热
    final businessCache = BusinessCacheService.instance;
    await businessCache.warmupCache();
    
    debugPrint('✅ 缓存系统初始化完成');
  } catch (e) {
    debugPrint('❌ 缓存系统初始化失败: $e');
  }
}
```

### 3. 在业务Logic中使用

```dart
// 风险预警模块
class RiskLogic extends GetxController {
  final BusinessCacheService _cacheService = BusinessCacheService.instance;
  
  Future<void> getRiskList() async {
    final riskyData = await _cacheService.getRiskListWithCache(
      currentPage: state.currentPage.value,
      classification: getCurrentClassification(),
    );
    
    if (riskyData != null) {
      // 处理数据...
    }
  }
}
```

## 📋 核心功能

### 多层级缓存

- **L1内存缓存**: 超快响应，基于LRU算法
- **L2本地存储**: 持久化缓存，应用重启后仍可用
- **L3网络请求**: 兜底数据源

### 智能TTL策略

```dart
// 根据数据类型自动设置缓存时间
- 高风险数据: 5分钟
- 中风险数据: 15分钟  
- 低风险数据: 1小时
- 最新舆情: 3分钟
- 历史舆情: 2小时
```

### 缓存优先级

```dart
enum CachePriority {
  critical, // 关键数据，永不被LRU淘汰
  high,     // 高优先级
  normal,   // 普通优先级
  low,      // 低优先级
}
```

### 性能监控

- 缓存命中率统计
- 内存使用情况监控
- 错误率跟踪
- 性能报告生成

## 🔧 配置选项

### 缓存配置

在 `cache_config.dart` 中可调整：

```dart
class CacheConfig {
  // 内存缓存配置
  static const int memoryMaxSize = 50 * 1024 * 1024; // 50MB
  static const int memoryMaxItems = 1000;
  
  // 本地存储配置
  static const int localMaxSize = 200 * 1024 * 1024; // 200MB
  
  // TTL配置
  static const Map<String, Duration> ttlConfig = {
    'risk_high': Duration(minutes: 5),
    'hotpot_latest': Duration(minutes: 3),
    // ...
  };
}
```

### 环境配置

```dart
// 开发环境: 启用详细日志和监控
// 生产环境: 关闭调试功能，优化性能
```

## 📊 使用示例

### 风险预警缓存

```dart
// 获取风险列表（自动缓存）
final riskyData = await cacheService.getRiskListWithCache(
  currentPage: 1,
  classification: 1, // 烽云一号
  regionCode: "440300", // 深圳
);

// 预加载数据
await cacheService.preloadRiskData(classification: 1);

// 清除特定缓存
await cacheService.clearRiskCache(classification: 1);
```

### 舆情热点缓存

```dart
// 获取舆情列表（自动缓存）
final newsItems = await cacheService.getHotPotListWithCache(
  currentPage: 1,
  pageSize: 10,
  dateFilter: '3d', // 最近3天
);

// 获取地区列表（长期缓存）
final regions = await cacheService.getRegionListWithCache();

// 清除过期缓存
await cacheService.clearHotPotCache(dateFilter: '3d');
```

### 缓存统计

```dart
// 获取缓存统计信息
final stats = cacheService.getCacheStatistics();
print('缓存命中率: ${(stats.memoryHitRate * 100).toStringAsFixed(1)}%');
print('内存使用: ${(stats.memorySize / 1024).toStringAsFixed(1)}KB');
```

## 🎯 性能优化建议

### 1. 预加载策略

```dart
// 应用启动时预加载关键数据
await businessCache.warmupCache();

// 用户操作时预加载相关数据
cacheService.preloadRiskData(classification: nextClassification);
```

### 2. 缓存清理

```dart
// 筛选条件变化时清理相关缓存
await cacheService.clearRiskCache(classification: oldClassification);

// 下拉刷新时强制更新
final data = await cacheService.getRiskListWithCache(
  forceUpdate: true,
  // ...其他参数
);
```

### 3. 内存管理

```dart
// 定期清理过期缓存（系统自动执行）
Timer.periodic(Duration(minutes: 10), (_) => 
  cacheManager.cleanupExpiredCache()
);

// LRU策略自动淘汰不常用数据
```

## 🐛 调试和监控

### 开发环境调试

```dart
// 查看缓存状态
final stats = cacheService.getCacheStatistics();
debugPrint(stats.toString());

// 查看缓存事件
// 自动输出详细的缓存日志
```

### 生产环境监控

```dart
// 性能报告（每小时生成）
final report = await monitoring.getLatestReport();

// 错误监控
monitoring.getRecentErrors();
```

## 📱 最佳实践

### 1. 缓存键设计

```dart
// ✅ 好的缓存键设计
"risk_list?page=1&region=440300&class=1"

// ❌ 避免的缓存键设计  
"getRiskData_user123_20241201_temp"
```

### 2. 错误处理

```dart
try {
  final data = await cacheService.getData();
  return data;
} catch (e) {
  // 缓存失败时自动降级到网络请求
  return await apiService.getData();
}
```

### 3. 生命周期管理

```dart
// 应用进入后台
void onAppPaused() {
  businessCache.backgroundSync();
}

// 应用恢复前台
void onAppResumed() {
  businessCache.warmupCache();
}

// 网络状态变化
void onNetworkChanged(bool isOnline) {
  if (isOnline) {
    businessCache.syncPendingData();
  }
}
```

## 🔍 故障排查

### 常见问题

1. **缓存未命中**
   - 检查缓存键是否正确
   - 确认TTL设置是否合理
   - 查看缓存是否被意外清除

2. **内存使用过高**
   - 调整内存缓存大小限制
   - 检查LRU淘汰策略是否生效
   - 确认没有内存泄漏

3. **数据不一致**
   - 检查缓存更新策略
   - 确认强制刷新逻辑
   - 验证TTL设置

### 调试命令

```dart
// 清空所有缓存
await cacheService.clearAllBusinessCache();

// 重置监控统计
monitoring.reset();

// 生成诊断报告
final report = await monitoring.generateReport();
```

## 📈 性能指标

### 目标指标

- **缓存命中率**: > 70%
- **响应时间提升**: > 60%
- **内存使用**: < 50MB
- **存储空间**: < 200MB

### 监控指标

- 每日缓存命中率趋势
- 内存使用情况
- 错误率统计
- 用户体验改善度量

## 🔄 版本升级

### v1.0.0 → v1.1.0

1. 备份现有缓存数据
2. 更新缓存文件
3. 执行数据迁移
4. 验证功能正常

### 兼容性

- 向后兼容旧版本缓存数据
- 自动处理数据格式变更
- 平滑升级，无感知更新

---

## 📞 技术支持

如有问题，请参考：
1. 查看控制台日志
2. 检查缓存统计信息
3. 参考集成示例代码
4. 联系开发团队 