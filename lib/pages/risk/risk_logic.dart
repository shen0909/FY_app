import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/https/api_service.dart';
import 'package:safe_app/utils/dialog_utils.dart';
import '../../models/risk_data_new.dart';
import '../../models/region_data.dart';
import 'risk_state.dart';

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
    // 初始化滚动控制器
    scrollController = ScrollController();
    _addScrollListener();
    
    try {
      await loadRegionData();
      await getRiskList();
      _updateCurrentUnitData();
      _updateCurrentRiskList();
      // 监听单位类型变化
      ever(state.chooseUint, (_) {
        _refreshData(); // 切换单位类型时刷新数据
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
    
    // 清空现有数据
    state.fengyun1List.clear();
    state.fengyun2List.clear();
    state.xingyunList.clear();
    
    await getRiskList();
    _updateCurrentUnitData();
    _updateCurrentRiskList();
    state.isLoading.value = false;
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

  // 获取风险预警列表数据（修改以支持分页）
  Future<void> getRiskList({bool isLoadMore = false}) async {
    final result = await ApiService().getRiskLists(
      currentPage: state.currentPage.value,
      zhName: state.searchKeyword.value.isEmpty ? null : state.searchKeyword.value,
      regionCode: state.selectedRegionCode.value.isEmpty ? null : state.selectedRegionCode.value,
    );
    
    if(result != null && result['执行结果'] == true) {
      RiskyDataNew riskyDataNew = RiskyDataNew.fromJson(result['返回数据']);
      int l0 = riskyDataNew.list.where((item) => item.customClassification == 0).length;
      int l1 = riskyDataNew.list.where((item) => item.customClassification == 1).length;
      int l2 = riskyDataNew.list.where((item) => item.customClassification == 2).length;
      int l3 = riskyDataNew.list.where((item) => item.customClassification == 3).length;
      if (isLoadMore) {
        // 追加数据
        state.fengyun1List.addAll(riskyDataNew.list.where((item) => item.customClassification == 1).toList());
        state.fengyun2List.addAll(riskyDataNew.list.where((item) => item.customClassification == 2).toList());
        state.xingyunList.addAll(riskyDataNew.list.where((item) => item.customClassification == 3).toList());
      } else {
        // 首次加载，清空后添加
        state.fengyun1List.clear();
        state.fengyun2List.clear();
        state.xingyunList.clear();
        state.fengyun1List.addAll(riskyDataNew.list.where((item) => item.customEntType == 1).toList());
        state.fengyun2List.addAll(riskyDataNew.list.where((item) => item.customEntType == 2).toList());
        state.xingyunList.addAll(riskyDataNew.list.where((item) => item.customEntType == 3).toList());
      }
      
      // 判断是否还有更多数据
      // 如果返回的数据少于每页大小，说明没有更多数据了
      if (riskyDataNew.list.length < 10) {
        state.hasMoreData.value = false;
      }
    } else {
      // API调用失败时，如果是加载更多，则标记没有更多数据
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

  // 更新当前单位数据（支持地区筛选）
  void _updateCurrentUnitData() {
    dealCurrentData(int index){
      List<RiskListElement> selectedList = [];
      if (index == 0) {
        selectedList = state.fengyun1List;
      } else if (index == 1) {
        selectedList = state.fengyun2List;
      } else if (index == 2) {
        selectedList = state.xingyunList;
      }

      // 应用地区筛选
      if (state.selectedRegionCode.value.isNotEmpty && state.selectedRegionCode.value != "all") {
        selectedList = selectedList.where((item) => 
          item.regionCode == state.selectedRegionCode.value ||
          item.regionCode.startsWith(state.selectedRegionCode.value)
        ).toList();
      }

      state.currentUnitData.value = {
        'high': {
          'title': '高风险',
          'count': selectedList.where((item) => item.riskType == 3).toList().length,
          'change': 0,
          'color': 0xFFFF6850
        },
        'medium': {
          'title': '中风险',
          'count': selectedList.where((item) => item.riskType == 2).toList().length,
          'change': 0,
          'color': 0xFFF6D500
        },
        'low': {
          'title': '低风险',
          'count': selectedList.where((item) => item.riskType == 1).toList().length,
          'change': 0,
          'color': 0xFF07CC89
        },
        'total': {
          'count': selectedList.length,
          'color': 0xFF1A1A1A
        },
      };
    }

    switch (state.chooseUint.value) {
      case 0:
        dealCurrentData(0);
        break;
      case 1:
        dealCurrentData(1);
        break;
      case 2:
        dealCurrentData(2);
        break;
      default:
        state.currentUnitData.value = {};
    }
  }

  // 更新当前风险列表（支持地区筛选）
  void _updateCurrentRiskList() {
    List<Map<String, dynamic>> newList = [];
    dealCurrentList(int index){
      List<RiskListElement> selectedList = [];
      if (index == 0) {
        selectedList = state.fengyun1List;
      } else if (index == 1) {
        selectedList = state.fengyun2List;
      } else if (index == 2) {
        selectedList = state.xingyunList;
      }

      // 应用地区筛选（本地筛选）
      if (state.selectedRegionCode.value.isNotEmpty && state.selectedRegionCode.value != "all") {
        selectedList = selectedList.where((item) => 
          item.regionCode == state.selectedRegionCode.value ||
          item.regionCode.startsWith(state.selectedRegionCode.value)
        ).toList();
      }

      newList = selectedList.map((company) => {
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
    }

    switch (state.chooseUint.value) {
      case 0:
        dealCurrentList(0);
        break;
      case 1:
        dealCurrentList(1);
        break;
      case 2:
        dealCurrentList(2);
        break;
    }
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

  // 切换单位（重置分页状态）
  changeUnit(int index) {
    state.chooseUint.value = index;
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
