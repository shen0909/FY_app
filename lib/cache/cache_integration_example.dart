import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:safe_app/models/risk_data_new.dart';
import 'package:safe_app/models/newslist_data.dart';
import 'business_cache_service.dart';

/// 风险预警Logic的缓存集成示例
/// 这展示了如何在现有的RiskLogic中集成缓存功能
class RiskLogicCacheIntegration {
  static void integrate() {
    debugPrint('''
🔧 风险预警模块缓存集成方案：

1. 在 risk_logic.dart 的 onInit() 方法中添加：
   ```dart
   @override
   Future<void> onInit() async {
     super.onInit();
     
     // 现有代码...
     
     // 🆕 集成缓存服务
     if (!Get.isRegistered<BusinessCacheService>()) {
       Get.put(BusinessCacheService());
     }
   }
   ```

2. 修改 getRiskList() 方法使用缓存：
   ```dart
   Future<void> getRiskList({bool isLoadMore = false}) async {
     // 获取缓存服务
     final cacheService = BusinessCacheService.instance;
     
     int? classification;
     switch (state.chooseUint.value) {
       case 0: classification = 1; break;
       case 1: classification = 2; break;
       case 2: classification = 3; break;
     }

     try {
       // 🆕 使用缓存服务获取数据
       final riskyDataNew = await cacheService.getRiskListWithCache(
         currentPage: state.currentPage.value,
         zhName: state.searchKeyword.value.isEmpty ? null : state.searchKeyword.value,
         regionCode: state.selectedRegionCode.value.isEmpty ? null : state.selectedRegionCode.value,
         classification: classification,
         forceUpdate: isLoadMore ? false : false, // 加载更多时不强制更新
       );

       if (riskyDataNew != null) {
         // 处理数据，与原有逻辑相同
         if (isLoadMore) {
           switch (state.chooseUint.value) {
             case 0: state.fengyun1List.addAll(riskyDataNew.list); break;
             case 1: state.fengyun2List.addAll(riskyDataNew.list); break;
             case 2: state.xingyunList.addAll(riskyDataNew.list); break;
           }
         } else {
           switch (state.chooseUint.value) {
             case 0: 
               state.fengyun1List.clear();
               state.fengyun1List.addAll(riskyDataNew.list);
               break;
             // ... 其他case
           }
         }
         
         // 判断是否还有更多数据
         if (riskyDataNew.list.length < 10) {
           state.hasMoreData.value = false;
         } else {
           state.hasMoreData.value = true;
         }
       } else {
         // 处理错误情况
         if (isLoadMore) {
           state.hasMoreData.value = false;
         }
       }
     } catch (e) {
       debugPrint('获取风险数据失败: \$e');
       // 错误处理...
     }
   }
   ```

3. 添加下拉刷新支持：
   ```dart
   Future<void> onRefresh() async {
     // 🆕 强制刷新缓存
     state.currentPage.value = 1;
     state.hasMoreData.value = true;
     
     final cacheService = BusinessCacheService.instance;
     await cacheService.clearRiskCache(classification: _getCurrentClassification());
     
     await getRiskList();
     debugPrint('✅ 风险数据刷新完成');
   }
   ```

4. 在单位切换时预加载数据：
   ```dart
   void changeUnit(int index) {
     state.chooseUint.value = index;
     
     // 🆕 预加载新选择单位的数据
     final cacheService = BusinessCacheService.instance;
     cacheService.preloadRiskData(
       classification: index + 1,
       regionCode: state.selectedRegionCode.value.isEmpty ? null : state.selectedRegionCode.value,
     );
   }
   ```
''');
  }
}

/// 舆情热点Logic的缓存集成示例
class HotPotLogicCacheIntegration {
  static void integrate() {
    debugPrint('''
🔧 舆情热点模块缓存集成方案：

1. 在 hot_pot_logic.dart 的 onInit() 方法中添加：
   ```dart
   @override
   Future<void> onInit() async {
     super.onInit();
     
     // 现有代码...
     
     // 🆕 集成缓存服务
     if (!Get.isRegistered<BusinessCacheService>()) {
       Get.put(BusinessCacheService());
     }
     
     // 预加载地区列表
     await _loadRegionListWithCache();
     
     // 获取热点列表
     await getNewsList();
   }
   ```

2. 添加带缓存的地区列表加载：
   ```dart
   Future<void> _loadRegionListWithCache() async {
     try {
       final cacheService = BusinessCacheService.instance;
       final regions = await cacheService.getRegionListWithCache();
       
       if (regions != null) {
         state.regionList.value = regions;
         debugPrint('🎯 地区列表已从缓存加载');
       }
     } catch (e) {
       debugPrint('❌ 加载地区列表失败: \$e');
       // 降级到现有的 getRegionList() 方法
       await getRegionList();
     }
   }
   ```

3. 修改 getNewsList() 方法使用缓存：
   ```dart
   Future<void> getNewsList({
     int? currentPage,
     int? pageSize,
     String newsType = '全部',
     String region = '全部',
     String dateFilter = '全部',
     String? startDate,
     String? endDate,
     String? search,
     bool isLoadMore = false,
   }) async {
     if (isLoadMore) {
       state.isLoadingMore.value = true;
     } else {
       state.isLoading.value = true;
       state.errorMessage.value = '';
     }
     
     try {
       // 🆕 使用缓存服务获取数据
       final cacheService = BusinessCacheService.instance;
       
       final newsItems = await cacheService.getHotPotListWithCache(
         currentPage: currentPage ?? state.currentPage.value,
         pageSize: pageSize ?? state.pageSize.value,
         newsType: newsType,
         region: region,
         dateFilter: dateFilter,
         startDate: startDate,
         endDate: endDate,
         search: search,
         forceUpdate: false, // 根据需要设置是否强制更新
       );

       if (newsItems != null) {
         // 如果是加载更多，则将新数据添加到已有数据后面
         if (isLoadMore) {
           state.newsList.addAll(newsItems);
         } else {
           state.newsList.value = newsItems;
         }
         
         // 更新页码
         state.currentPage.value = currentPage ?? state.currentPage.value;
         
         // 判断是否还有更多数据
         if (newsItems.isEmpty || newsItems.length < (pageSize ?? state.pageSize.value)) {
           state.hasMoreData.value = false;
         } else {
           state.hasMoreData.value = true;
         }
       } else {
         state.errorMessage.value = '获取数据失败';
         
         if (isLoadMore) {
           state.currentPage.value = (currentPage ?? state.currentPage.value) - 1;
         } else {
           state.newsList.value = [];
         }
       }
     } catch (e) {
       state.errorMessage.value = e.toString();
       
       if (isLoadMore) {
         state.currentPage.value = (currentPage ?? state.currentPage.value) - 1;
       } else {
         state.newsList.value = [];
       }
     } finally {
       if (isLoadMore) {
         state.isLoadingMore.value = false;
       } else {
         state.isLoading.value = false;
       }
     }
   }
   ```

4. 修改 applyFilters() 方法优化缓存：
   ```dart
   void applyFilters() {
     // 关闭筛选选项面板
     if (state.showFilterOptions.value) {
       state.toggleFilterOptions();
     }
     
     // 🆕 清除相关缓存，确保获取最新筛选结果
     final cacheService = BusinessCacheService.instance;
     
     // 只清除当前筛选条件相关的缓存
     String? dateFilter = state.useCustomDateRange.value ? null : state.selectedTimeRange.value;
     if (dateFilter != null) {
       cacheService.clearHotPotCache(dateFilter: dateFilter);
     }
     
     // 重置分页状态和清空数据
     state.resetPagination();
     state.newsList.clear();
     
     // 准备API参数
     String? startDate = state.useCustomDateRange.value ? formatDate(state.startDate.value) : null;
     String? endDate = state.useCustomDateRange.value ? formatDate(state.endDate.value) : null;
     
     // 根据筛选条件获取数据
     getNewsList(
       currentPage: state.currentPage.value,
       pageSize: state.pageSize.value,
       newsType: state.selectedNewsType.value,
       region: state.selectedRegion.value,
       dateFilter: dateFilter!,
       startDate: startDate,
       endDate: endDate,
       search: state.searchKeyword.value.isNotEmpty ? state.searchKeyword.value : null,
     );
   }
   ```

5. 添加下拉刷新支持：
   ```dart
   Future<void> onRefresh() async {
     // 🆕 清除当前条件的缓存
     final cacheService = BusinessCacheService.instance;
     await cacheService.clearHotPotCache();
     
     // 重置状态并重新加载
     state.resetPagination();
     state.newsList.clear();
     
     await getNewsList();
     debugPrint('✅ 舆情热点数据刷新完成');
   }
   ```
''');
  }
}

/// 应用启动时的缓存初始化示例
class AppCacheInitialization {
  static void initializeAppCache() {
    debugPrint('''
🚀 应用缓存初始化方案：

1. 在 main.dart 中添加缓存服务初始化：
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     
     // 🆕 初始化缓存系统
     await initializeCacheSystem();
     
     runApp(MyApp());
   }

   Future<void> initializeCacheSystem() async {
     try {
       // 注册缓存服务
       await Get.putAsync(() => CacheManager().onInit().then((_) => CacheManager()));
       await Get.putAsync(() => BusinessCacheService().onInit().then((_) => BusinessCacheService()));
       
       // 缓存预热
       final businessCache = BusinessCacheService.instance;
       await businessCache.warmupCache();
       
       debugPrint('✅ 缓存系统初始化完成');
     } catch (e) {
       debugPrint('❌ 缓存系统初始化失败: \$e');
     }
   }
   ```

2. 在应用生命周期中处理缓存：
   ```dart
   class MyApp extends StatefulWidget {
     @override
     _MyAppState createState() => _MyAppState();
   }

   class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
     @override
     void initState() {
       super.initState();
       WidgetsBinding.instance.addObserver(this);
     }

     @override
     void dispose() {
       WidgetsBinding.instance.removeObserver(this);
       super.dispose();
     }

     @override
     void didChangeAppLifecycleState(AppLifecycleState state) {
       super.didChangeAppLifecycleState(state);
       
       final businessCache = BusinessCacheService.instance;
       
       switch (state) {
         case AppLifecycleState.paused:
           // 🆕 应用进入后台，执行缓存同步
           businessCache.backgroundSync();
           break;
         case AppLifecycleState.resumed:
           // 🆕 应用从后台恢复，可以选择刷新关键数据
           businessCache.warmupCache();
           break;
         // ...其他状态
       }
     }
   }
   ```

3. 添加调试面板查看缓存状态：
   ```dart
   class CacheDebugPanel extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       if (!kDebugMode) return SizedBox.shrink();
       
       return FloatingActionButton(
         onPressed: () => _showCacheStats(),
         child: Icon(Icons.memory),
         backgroundColor: Colors.orange,
       );
     }

     void _showCacheStats() {
       final businessCache = BusinessCacheService.instance;
       final stats = businessCache.getCacheStatistics();
       
       Get.dialog(
         AlertDialog(
           title: Text('缓存统计'),
           content: Text(stats.toString()),
           actions: [
             TextButton(
               onPressed: () => businessCache.clearAllBusinessCache(),
               child: Text('清空缓存'),
             ),
             TextButton(
               onPressed: () => Get.back(),
               child: Text('关闭'),
             ),
           ],
         ),
       );
     }
   }
   ```
''');
  }
}

/// 完整的集成检查清单
class CacheIntegrationChecklist {
  static void printChecklist() {
    debugPrint('''
✅ 缓存集成检查清单：

📋 必须完成的步骤：
  ☐ 1. 在 pubspec.yaml 中添加依赖：crypto
  ☐ 2. 创建 lib/cache/ 目录并放置所有缓存文件
  ☐ 3. 在 main.dart 中初始化缓存系统
  ☐ 4. 修改 RiskLogic 集成风险预警缓存
  ☐ 5. 修改 HotPotLogic 集成舆情热点缓存
  ☐ 6. 添加应用生命周期管理
  ☐ 7. 添加网络状态监听（可选）
  ☐ 8. 测试各种场景的缓存行为

🧪 测试验证步骤：
  ☐ 1. 冷启动应用，验证数据加载速度
  ☐ 2. 切换筛选条件，验证缓存命中
  ☐ 3. 下拉刷新，验证强制更新
  ☐ 4. 离线状态，验证缓存可用性
  ☐ 5. 长时间使用，验证内存使用情况
  ☐ 6. 应用后台恢复，验证数据同步
  ☐ 7. 网络异常恢复，验证自动同步

🎯 性能目标：
  • 缓存命中率 > 70%
  • 首屏加载时间减少 60%+
  • 列表滚动流畅度提升明显
  • 内存使用增加 < 20MB
  • 存储空间使用 < 200MB

⚠️ 注意事项：
  • 开发环境下会有详细的缓存日志
  • 生产环境下监控功能自动关闭
  • 缓存失效时会自动降级到网络请求
  • 定期清理过期缓存，防止存储空间膨胀
''');
  }
} 