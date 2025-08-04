import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/https/api_service.dart';
import 'package:safe_app/utils/dialog_utils.dart';
import '../../models/risk_data_new.dart';
import '../../models/region_data.dart';
import '../../cache/business_cache_service.dart';
import 'risk_state.dart';
import 'package:flutter/foundation.dart';

class RiskLogic extends GetxController {
  final RiskState state = RiskState();

  // Overlay相关变量
  OverlayEntry? _overlayEntry;
  final GlobalKey locationKey = GlobalKey();
  // 添加滚动控制器
  late ScrollController scrollController;

  @override
  Future<void> onInit() async {
    super.onInit();
    // 设置初始加载状态
    state.isLoading.value = true;
    // 初始化滚动控制器
    scrollController = ScrollController();
    _addScrollListener();
    
    try {
      await loadRegionData();
      // 预加载当前分类的风险数据
      await _preloadRiskData();
      await getRiskList();
      _updateCurrentUnitData();
      _updateCurrentRiskList();
      // 监听单位类型变化 - 优化：使用智能切换
      ever(state.chooseUint, (_) {
        _smartSwitchUnit(); // 智能切换单位类型
      });

      // 监听地区选择变化
      ever(state.selectedRegionCode, (_) {
        _refreshData(); // 切换地区时刷新数据
      });

      debounce(state.searchKeyword, (_) async {
        _refreshData(); // 搜索时刷新数据
      }, time: Duration(milliseconds: 500));
      
    } catch (e, stackTrace) {
      print("解析风险数据出错: $e");
      print("错误堆栈: $stackTrace");
      
      // 确保UI不会因为数据解析错误而崩溃
      state.currentUnitData.value = {
        'high': {'title': '高风险', 'count': 0, 'change': 0, 'color': 0xFFFF6850},
        'medium': {'title': '中风险', 'count': 0, 'change': 0, 'color': 0xFFF6D500},
        'low': {'title': '低风险', 'count': 0, 'change': 0, 'color': 0xFF07CC89},
        'total': {'count': 0, 'color': 0xFF1A1A1A},
      };
      state.currentRiskList.clear();
    } finally {
      // 完成加载后隐藏loading
      state.isLoading.value = false;
    }
  }

  // 添加滚动监听器
  void _addScrollListener() {
    scrollController.addListener(() {
      // 当滚动到距离底部200像素时触发加载更多
      if (scrollController.position.pixels >= 
          scrollController.position.maxScrollExtent - 200) {
        loadMoreData();
      }
    });
  }

  // 刷新数据（重置分页状态）
  Future<void> _refreshData() async {
    state.currentPage.value = 1;
    state.hasMoreData.value = true;
    state.isLoading.value = true;
    switch (state.chooseUint.value) {
      case 0:
        state.fengyun1List.clear();
        break;
      case 1:
        state.fengyun2List.clear();
        break;
      case 2:
        state.xingyunList.clear();
        break;
    }
    
    await getRiskList();
    _updateCurrentUnitData();
    _updateCurrentRiskList();
    state.isLoading.value = false;
  }

  /// 智能切换单位类型（优化版本）
  Future<void> _smartSwitchUnit() async {
    if (kDebugMode) {
      print('🔄 智能切换到单位类型: ${state.chooseUint.value}');
    }

    // 获取当前选择的单位对应的列表
    List<RiskListElement> currentList = _getCurrentUnitList();
    
    // 如果当前单位类型已有缓存数据，直接切换显示
    if (currentList.isNotEmpty) {
      if (kDebugMode) {
        print('📦 使用缓存数据，避免重新加载 - 数据条数: ${currentList.length}');
      }
      _updateCurrentUnitData();
      _updateCurrentRiskList();
    } else {
      // 如果没有缓存数据，则后台加载
      if (kDebugMode) {
        print('🌐 缓存为空，后台加载数据');
      }
      _loadUnitDataInBackground();
    }
  }

  /// 后台加载单位数据（不显示loading状态）
  Future<void> _loadUnitDataInBackground() async {
    try {
      // 重置当前单位的分页状态
      state.currentPage.value = 1;
      state.hasMoreData.value = true;
      
      // 预加载当前分类的数据
      await _preloadRiskData();
      await getRiskList();
      _updateCurrentUnitData();
      _updateCurrentRiskList();
      
      if (kDebugMode) {
        print('✅ 后台数据加载完成');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 后台数据加载失败: $e');
      }
    }
  }

  /// 下拉刷新（强制刷新当前数据）
  Future<void> onRefresh() async {
    if (state.isRefreshing.value) return;
    
    state.isRefreshing.value = true;
    
    try {
      if (kDebugMode) {
        print('🔽 开始下拉刷新');
      }
      
      // 重置分页状态但不清空显示数据
      state.currentPage.value = 1;
      state.hasMoreData.value = true;
      
      // 强制刷新当前单位类型的数据
      await getRiskList(forceRefresh: true);
      _updateCurrentUnitData();
      _updateCurrentRiskList();
      
      if (kDebugMode) {
        print('✅ 下拉刷新完成');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 下拉刷新失败: $e');
      }
      Get.snackbar(
        '提示',
        '刷新失败，请稍后重试',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      state.isRefreshing.value = false;
    }
  }

  /// 获取当前单位类型对应的列表
  List<RiskListElement> _getCurrentUnitList() {
    switch (state.chooseUint.value) {
      case 0:
        return state.fengyun1List;
      case 1:
        return state.fengyun2List;
      case 2:
        return state.xingyunList;
      default:
        return state.fengyun1List;
    }
  }

  // 加载更多数据
  Future<void> loadMoreData() async {
    // 防止重复加载
    if (state.isLoadingMore.value || !state.hasMoreData.value) {
      return;
    }
    
    state.isLoadingMore.value = true;
    state.currentPage.value++;
    
    try {
      await getRiskList(isLoadMore: true);
      _updateCurrentUnitData();
      _updateCurrentRiskList();
    } catch (e) {
      print("加载更多数据失败: $e");
      // 加载失败时回退页数
      state.currentPage.value--;
    } finally {
      state.isLoadingMore.value = false;
    }
  }

  // 获取风险预警列表数据
  Future<void> getRiskList({bool isLoadMore = false, bool forceRefresh = false}) async {
    try {
      // 0-烽云一号 1-烽云二号 2-星云 -> 1-FY一号 2-FY二号 3-星云
      int? classification;
      switch (state.chooseUint.value) {
        case 0:
          classification = 1; // 烽云一号 -> FY一号
          break;
        case 1:
          classification = 2; // 烽云二号 -> FY二号  
          break;
        case 2:
          classification = 3; // 星云
          break;
      }

      // 使用缓存服务获取数据
      final cacheService = BusinessCacheService.instance;
      final riskyDataNew = await cacheService.getRiskListWithCache(
        currentPage: state.currentPage.value,
        zhName: state.searchKeyword.value.isEmpty ? null : state.searchKeyword.value,
        regionCode: state.selectedRegionCode.value.isEmpty ? null : state.selectedRegionCode.value,
        classification: classification,
        forceUpdate: forceRefresh,
      );
      
      if (riskyDataNew != null) {
        if (isLoadMore) {
          // 加载更多时，将数据追加到当前选择的列表
          switch (state.chooseUint.value) {
            case 0:
              state.fengyun1List.addAll(riskyDataNew.list);
              break;
            case 1:
              state.fengyun2List.addAll(riskyDataNew.list);
              break;
            case 2:
              state.xingyunList.addAll(riskyDataNew.list);
              break;
          }
        } else {
          // 首次加载时，清空当前选择的列表并添加新数据
          switch (state.chooseUint.value) {
            case 0:
              state.fengyun1List.clear();
              state.fengyun1List.addAll(riskyDataNew.list);
              break;
            case 1:
              state.fengyun2List.clear();
              state.fengyun2List.addAll(riskyDataNew.list);
              break;
            case 2:
              state.xingyunList.clear();
              state.xingyunList.addAll(riskyDataNew.list);
              break;
          }
        }
        
        // 判断是否还有更多数据
        // 如果返回的数据少于每页大小，说明没有更多数据了
        if (riskyDataNew.list.length < 10) {
          state.hasMoreData.value = false;
        } else {
          state.hasMoreData.value = true;
        }
        
        if (kDebugMode) {
          print('✅ 风险数据获取成功 - 分类: $classification, 页数: ${state.currentPage.value}, 数据条数: ${riskyDataNew.list.length}');
        }
      } else {
        if (kDebugMode) {
          print('❌ 风险数据获取失败');
        }
        // 数据获取失败时，如果是加载更多，则标记没有更多数据
        if (isLoadMore) {
          state.hasMoreData.value = false;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 获取风险列表异常: $e');
      }
      // 异常处理：如果是加载更多，则标记没有更多数据
      if (isLoadMore) {
        state.hasMoreData.value = false;
      }
    }
  }

  // 加载地区数据
  Future<void> loadRegionData() async {
    try {
      final String regionJson = await rootBundle.loadString('assets/risk_region.json');
      final List<dynamic> regionList = json.decode(regionJson);
      final List<RegionData> regions = regionList.map((region) => RegionData.fromJson(region)).toList();
      state.allRegions.assignAll(regions);
      // 默认选择广东省
      final guangdong = regions.firstWhere((region) => region.name == "广东省", orElse: () => regions.first);
      state.selectedProvince.value = guangdong;
      _updateCitiesList();
    } catch (e) {
      print("加载地区数据出错: $e");
    }
  }

  // 从地区数据中更新城市列表
  void _updateCitiesList() {
    if (state.selectedProvince.value != null) {
      List<String> cities = ["全部"];
      cities.addAll(state.selectedProvince.value!.children.map((city) => city.name));
      
      // 分离优先城市和其他城市
      List<String> priority = ["全部"];
      List<String> others = [];
      
      for (var city in state.selectedProvince.value!.children) {
        // 广东省的重要城市优先显示
        if (state.selectedProvince.value!.name == "广东省" && 
            ["广州市", "深圳市", "珠海市", "佛山市", "东莞市", "中山市"].contains(city.name)) {
          priority.add(city.name);
        } else {
          others.add(city.name);
        }
      }
      
      state.priorityCities.assignAll(priority);
      state.otherCities.assignAll(others);
      
    }
  }

  // 更新当前单位数据
  void _updateCurrentUnitData() {
    List<RiskListElement> currentList = [];
    // 获取当前选择的列表
    switch (state.chooseUint.value) {
      case 0:
        currentList = state.fengyun1List;
        break;
      case 1:
        currentList = state.fengyun2List;
        break;
      case 2:
        currentList = state.xingyunList;
        break;
    }
    state.currentUnitData.value = {
      'high': {
        'title': '高风险',
        'count': currentList.where((item) => item.riskType == 3).length,
        'change': 0,
        'color': 0xFFFF6850
      },
      'medium': {
        'title': '中风险',
        'count': currentList.where((item) => item.riskType == 2).length,
        'change': 0,
        'color': 0xFFF6D500
      },
      'low': {
        'title': '低风险',
        'count': currentList.where((item) => item.riskType == 1).length,
        'change': 0,
        'color': 0xFF07CC89
      },
      'total': {
        'count': currentList.length,
        'color': 0xFF1A1A1A
      },
    };
  }

  // 更新当前风险列表
  void _updateCurrentRiskList() {
    List<RiskListElement> currentList = [];
    switch (state.chooseUint.value) {
      case 0:
        currentList = state.fengyun1List;
        break;
      case 1:
        currentList = state.fengyun2List;
        break;
      case 2:
        currentList = state.xingyunList;
        break;
    }
    List<Map<String, dynamic>> newList = currentList.map((company) => {
      'id': company.uuid,
      'name': company.zhName,
      'englishName': company.enName,
      'description': company.entProfile,
      'riskLevel': company.riskType,
      'riskLevelText': company.riskType == 1 ? "低风险" : company.riskType == 2 ? "中风险" : "高风险",
      'riskColor': _getRiskColor(company.riskType),
      'borderColor': _getBorderColor(company.riskType),
      'updateTime': company.updatedAt,
      'unreadCount': 0,
      'isRead': true,
    }).toList();

    state.currentRiskList.assignAll(newList);
  }

  // 搜索企业
  void searchCompany(String keyword) {
    state.searchKeyword.value = keyword;
  }

  // 选择地区
  void selectRegion(String regionName, String regionCode) {
    state.selectedRegionName.value = regionName;
    state.selectedRegionCode.value = regionCode;
    // 更新显示的地区名称
    if (regionName == "全部") {
      state.location.value = "${state.selectedProvince.value?.name ?? ''}全部";
    } else {
      state.location.value = "${state.selectedProvince.value?.name ?? ''}$regionName";
    }
  }

  // 获取风险等级对应的颜色
  int _getRiskColor(int riskLevel) {
    switch (riskLevel) {
      case 3:
        return 0xFFFF6850;
      case 2:
        return 0xFFF6D500;
      case 1:
        return 0xFF07CC89;
      default:
        return 0xFF07CC89;
    }
  }

  // 获取风险等级对应的边框颜色
  int _getBorderColor(int riskLevel) {
    switch (riskLevel) {
      case 3:
        return 0xFFFFECE9;
      case 2:
        return 0xFFFFF7E6;
      case 1:
        return 0xFFE7FEF8;
      default:
        return 0xFFE7FEF8;
    }
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    scrollController.dispose();
    _safeHideOverlay();
    super.onClose();
  }

  /// 切换单位类型
  void changeUnit(int index) {
    if (kDebugMode) {
      print('🔄 用户切换到单位类型: $index');
    }
    state.chooseUint.value = index;
    // 智能切换逻辑由ever监听器处理
  }

  // ==================== 缓存管理相关方法 ====================

  /// 预加载风险数据
  Future<void> _preloadRiskData() async {
    try {
      final cacheService = BusinessCacheService.instance;
      
      // 根据当前选择的单位类型预加载数据
      int classification;
      switch (state.chooseUint.value) {
        case 0:
          classification = 1; // 烽云一号
          break;
        case 1:
          classification = 2; // 烽云二号
          break;
        case 2:
          classification = 3; // 星云
          break;
        default:
          classification = 1;
      }
      
      // 预加载当前地区的风险数据
      await cacheService.preloadRiskData(
        classification: classification,
        regionCode: state.selectedRegionCode.value.isEmpty ? null : state.selectedRegionCode.value,
      );
      
      if (kDebugMode) {
        print('📦 风险数据预加载完成 - 分类: $classification');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 风险数据预加载失败: $e');
      }
    }
  }

  /// 手动刷新数据（强制从网络获取）
  Future<void> refreshData() async {
    state.isLoading.value = true;
    state.currentPage.value = 1;
    state.hasMoreData.value = true;
    
    // 清空当前列表
    switch (state.chooseUint.value) {
      case 0:
        state.fengyun1List.clear();
        break;
      case 1:
        state.fengyun2List.clear();
        break;
      case 2:
        state.xingyunList.clear();
        break;
    }
    
    try {
      // 强制刷新数据
      await getRiskList(forceRefresh: true);
      _updateCurrentUnitData();
      _updateCurrentRiskList();
      
      if (kDebugMode) {
        print('🔄 风险数据手动刷新完成');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 风险数据刷新失败: $e');
      }
    } finally {
      state.isLoading.value = false;
    }
  }

  /// 清除当前分类的风险缓存
  Future<void> clearCurrentRiskCache() async {
    try {
      final cacheService = BusinessCacheService.instance;
      
      int classification;
      switch (state.chooseUint.value) {
        case 0:
          classification = 1;
          break;
        case 1:
          classification = 2;
          break;
        case 2:
          classification = 3;
          break;
        default:
          classification = 1;
      }
      
      await cacheService.clearRiskCache(classification: classification);
      
      if (kDebugMode) {
        print('🗑️ 清除风险缓存完成 - 分类: $classification');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 清除风险缓存失败: $e');
      }
    }
  }

  /// 获取缓存统计信息（用于调试）
  Map<String, dynamic> getCacheStats() {
    try {
      final cacheService = BusinessCacheService.instance;
      return cacheService.getCacheStatistics();
    } catch (e) {
      if (kDebugMode) {
        print('❌ 获取缓存统计失败: $e');
      }
      return {};
    }
  }
  
  // 显示未读消息弹窗
  void showMessageDialog(String companyId) {
    // 显示建设中提示
    DialogUtils.showUnderConstructionDialog();
    return;
    
    // 注释掉原有逻辑
    // if (state.riskyData.value == null) return;

    // try {
    //   // 获取当前单位类型对应的key
    //   String unitKey;
    //   switch (state.chooseUint.value) {
    //     case 0:
    //       unitKey = 'fengyun_1';
    //       break;
    //     case 1:
    //       unitKey = 'fengyun_2';
    //       break;
    //     case 2:
    //       unitKey = 'xingyun';
    //       break;
    //     default:
    //       return;
    //   }

    //   // 从riskyData中获取对应公司的未读消息
    //   final unreadMessages = state.riskyData.value!.unreadMessages[companyId];
    //   if (unreadMessages == null || unreadMessages.isEmpty) return;

    //   // 转换未读消息格式
    //   final messages = unreadMessages.map((msg) => {
    //     'title': msg.title,
    //     'date': msg.date,
    //     'content': msg.content,
    //     'company': msg.sourceName,
    //     'isRead': msg.read,
    //     'category': msg.category,
    //     'severity': msg.severity,
    //     'tags': msg.tags,
    //   }).toList();

    //   state.currentUnreadMessages.assignAll(messages);

    //   showModalBottomSheet(
    //     builder: (_){
    //       return UnreadMessageDialog(
    //         messages: state.currentUnreadMessages,
    //         onClose: () => Get.back(),
    //       );
    //     },
    //     constraints: BoxConstraints(
    //       maxWidth: MediaQuery.of(Get.context!).size.width, // 强制宽度为屏幕宽度
    //       minWidth: MediaQuery.of(Get.context!).size.width, // 防止最小宽度限制
    //     ),
    //     backgroundColor: Colors.transparent,
    //     elevation: 0,
    //     isDismissible: true,
    //     enableDrag: true,
    //     isScrollControlled: true,
    //     shape:  RoundedRectangleBorder(
    //       borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
    //     ),
    //     context: Get.context!,
    //   );
    // } catch (e) {
    //   print("显示消息弹窗出错: $e");
    // }
  }
  
  // 关闭未读消息弹窗
  void closeMessageDialog() {
    Get.back();
  }
  
  // 将消息标记为已读
  void markMessageAsRead(int index) {
    if (index >= 0 && index < state.currentUnreadMessages.length) {
      final updatedMessage = Map<String, dynamic>.from(state.currentUnreadMessages[index]);
      updatedMessage['isRead'] = true;
      state.currentUnreadMessages[index] = updatedMessage;
    }
  }
  
  // 将所有消息标记为已读
  void markAllMessagesAsRead() {
    final updatedMessages = state.currentUnreadMessages.map((message) {
      final updatedMessage = Map<String, dynamic>.from(message);
      updatedMessage['isRead'] = true;
      return updatedMessage;
    }).toList();
    
    state.currentUnreadMessages.assignAll(updatedMessages);
  }

  // 显示地区选择器浮层
  void showCitySelector(BuildContext context) {
    // 先隐藏可能存在的浮层
    hideOverlay();

    // 获取按钮位置
    final RenderBox renderBox = locationKey.currentContext?.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    // 创建浮层
    _overlayEntry = OverlayEntry(
      builder: (context) => _buildCityOverlay(position, size),
    );

    // 显示浮层
    Overlay.of(context).insert(_overlayEntry!);
  }

  // 隐藏浮层
  void hideOverlay() {
    _safeHideOverlay();
  }

  // 安全地隐藏浮层
  void _safeHideOverlay() {
    try {
      if (_overlayEntry != null) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    } catch (e) {
      // 如果移除过程中出现异常（比如上下文已失效），直接置空引用
      _overlayEntry = null;
      print('清理城市选择浮层时出现异常: $e');
    }
  }

  // 构建地区选择浮层
  Widget _buildCityOverlay(Offset position, Size size) {
    final scrollController = ScrollController();
    // 构建地区列表：全部 + 当前省份的所有城市
    final List<Map<String, String>> regionOptions = [
      {'name': '全部', 'code': 'all'}
    ];
    
    if (state.selectedProvince.value != null) {
      regionOptions.addAll(state.selectedProvince.value!.children.map((city) => {
        'name': city.name,
        'code': city.code
      }).toList());
    }
    
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // 背景遮罩，点击后关闭浮层
          GestureDetector(
            onTap: hideOverlay,
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          
          // 地区选择内容
          Positioned(
            left: (position.dx - 16).w,
            top: position.dy + size.height,
            width: 160,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              constraints: BoxConstraints(
                maxHeight: 170.h
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: _DynamicScrollbarWrapper(
                      scrollController: scrollController,
                      child: ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.only(right: 10),
                        shrinkWrap: true,
                        itemCount: regionOptions.length,
                        itemBuilder: (context, index) {
                          final region = regionOptions[index];
                          final isSelected = state.selectedRegionCode.value == region['code'] ||
                                           (state.selectedRegionCode.value.isEmpty && region['code'] == 'all');
                          final isPriority = state.priorityCities.contains(region['name']);
                          
                          return InkWell(
                            onTap: () {
                              selectRegion(region['name']!, region['code']!);
                              hideOverlay();
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              color: isSelected ? Color(0xFFF0F5FF) : Colors.white,
                              child: Text(
                                region['name']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected ? Color(0xFF3361FE) : Color(0xFF1A1A1A),
                                  fontWeight: isPriority ? FontWeight.w500 : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 处理物理返回按钮事件
  canPopFunction(bool didPop) {
    if (didPop) return;

    // 如果有城市选择浮层显示，优先关闭浮层
    if (_overlayEntry != null) {
      hideOverlay();
      return;
    }
    
    // 否则正常返回
    Get.back();
  }
}

// 自定义滚动条包装器
class _DynamicScrollbarWrapper extends StatefulWidget {
  final ScrollController scrollController;
  final Widget child;
  
  const _DynamicScrollbarWrapper({
    Key? key,
    required this.scrollController,
    required this.child,
  }) : super(key: key);
  
  @override
  State<_DynamicScrollbarWrapper> createState() => _DynamicScrollbarWrapperState();
}

class _DynamicScrollbarWrapperState extends State<_DynamicScrollbarWrapper> {
  double _scrollPosition = 0.0;
  double _contentHeight = 0.0;
  double _viewportHeight = 0.0;
  final double _thumbHeight = 32.0;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateScrollData();
        widget.scrollController.addListener(_handleScrollChange);
      }
    });
  }
  
  @override
  void dispose() {
    widget.scrollController.removeListener(_handleScrollChange);
    super.dispose();
  }
  
  void _handleScrollChange() {
    if (mounted) {
      setState(() {
        _updateScrollData();
      });
    }
  }
  
  void _updateScrollData() {
    try {
      if (widget.scrollController.hasClients) {
        _scrollPosition = widget.scrollController.position.pixels;
        _contentHeight = widget.scrollController.position.maxScrollExtent + widget.scrollController.position.viewportDimension;
        _viewportHeight = widget.scrollController.position.viewportDimension;
      }
    } catch (e) {
      print("Error updating scroll data: $e");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    double thumbPositionRatio = 0.0;
    if (_contentHeight > 0 && _viewportHeight > 0) {
      thumbPositionRatio = _scrollPosition / (_contentHeight - _viewportHeight);
      thumbPositionRatio = thumbPositionRatio.clamp(0.0, 1.0);
    }
    
    double trackHeight = _viewportHeight > 0 ? _viewportHeight : 100;
    double availableTrackSpace = trackHeight - _thumbHeight;
    double thumbPosition = thumbPositionRatio * availableTrackSpace;
    
    bool showScrollbar = _contentHeight > _viewportHeight;
    
    return Stack(
      children: [
        widget.child,
        
        Positioned(
          right: 2,
          top: 0,
          bottom: 0,
          width: 4,
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFE7E7E7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        
        if (showScrollbar) 
          Positioned(
            right: 2,
            top: thumbPosition,
            width: 4,
            height: _thumbHeight,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF3361FE),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
      ],
    );
  }
}
