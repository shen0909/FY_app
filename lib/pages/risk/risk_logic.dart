import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/https/api_service.dart';
import 'package:safe_app/widgets/unread_message_dialog.dart';
import 'package:safe_app/models/risk_data.dart';
import 'package:safe_app/pages/risk/risk_details/risk_details_view.dart';
import 'package:safe_app/utils/dialog_utils.dart';

import '../../models/risk_company_details.dart';
import '../../models/risk_data.dart';
import '../../models/risk_data_new.dart';
import 'risk_state.dart';

class RiskLogic extends GetxController {
  final RiskState state = RiskState();

  // Overlay相关变量
  OverlayEntry? _overlayEntry;
  final GlobalKey locationKey = GlobalKey();

  getRiskList() async {
    final result = await ApiService().getRiskLists();
    if(result!=null && result['执行结果'] == true ) {
      List<dynamic> list = (result['返回数据']['list'] as List);
      RiskyDataNew riskyDataNew = RiskyDataNew.fromJson(result['返回数据']);
      state.fengyun1List.addAll(riskyDataNew.list.where((item) => item.customEntType == 1).toList());
      state.fengyun2List.addAll(riskyDataNew.list.where((item) => item.customEntType == 2).toList());
      state.xingyunList.addAll(riskyDataNew.list.where((item) => item.customEntType == 3).toList());
    }
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    try {
      await getRiskList();
      final filePath = 'assets/complete-risk-alerts-data.json';
      final fileContent = await rootBundle.loadString(filePath);
      final jsonData = json.decode(fileContent) as Map<String, dynamic>;

      print("数据数据:${jsonData}");
      state.riskyData.value = RiskyData.fromJson(jsonData);
      // 从RiskyData中获取城市列表
      _updateCitiesList();
      _updateCurrentUnitData();
      _updateCurrentRiskList();
      
      // 监听单位类型变化
      ever(state.chooseUint, (_) {
        _updateCurrentUnitData();
        _updateCurrentRiskList();
      });
      
      // 监听城市选择变化
      ever(state.selectedCity, (_) {
        _updateCurrentRiskList();
      });
      
      ever(state.riskyData, (_) {
        _updateCitiesList();
        _updateCurrentUnitData();
        _updateCurrentRiskList();
      });
    } catch (e, stackTrace) {
      print("解析风险数据出错: $e");
      print("错误堆栈: $stackTrace");
      
      // 确保UI不会因为数据解析错误而崩溃
      state.currentUnitData.value = {
        'high': {
          'title': '高风险',
          'count': 0,
          'change': 0,
          'color': 0xFFFF6850
        },
        'medium': {
          'title': '中风险',
          'count': 0,
          'change': 0,
          'color': 0xFFF6D500
        },
        'low': {
          'title': '低风险',
          'count': 0,
          'change': 0,
          'color': 0xFF07CC89
        },
        'total': {
          'count': 0,
          'color': 0xFF1A1A1A
        },
      };
      state.currentRiskList.clear();
    }
  }

  // 从RiskyData中更新城市列表
  void _updateCitiesList() {
    if (state.riskyData.value != null && state.riskyData.value!.location.cities.isNotEmpty) {
      // 始终保留"全部"选项作为第一个
      List<String> priority = [];
      List<String> others = [];
      
      // 从数据中提取城市名称
      for (var city in state.riskyData.value!.location.cities) {
        // // 判断是否是优先城市
        // if (["guangzhou", "shenzhen", "zhuhai"].contains(city.code)) {
        //   // 广州、深圳、珠海等重要城市放在优先列表
        //   priority.add(city.name);
        // } else if (city.code != "all") {
        //   others.add(city.name);
        // }
        others.add(city.name);
      }
      // 更新状态中的城市列表
      state.priorityCities.clear();
      // state.priorityCities.add("全部");
      state.priorityCities.addAll(priority);
      
      state.otherCities.clear();
      state.otherCities.addAll(others);
      
      print("城市列表更新完成 - 优先城市: ${state.priorityCities}, 其他城市: ${state.otherCities}");
    }
  }

  // 更新当前单位数据
  void _updateCurrentUnitData() {
    if (state.riskyData.value == null) {
      state.currentUnitData.value = {};
      return;
    }

    dealCurrentData(int index){
      List<RiskListElement> selectedList = [];
      if (index == 0) {
        selectedList = state.fengyun1List;
      } else if (index == 1) {
        selectedList = state.fengyun2List;
      } else if (index == 2) { // 如果有更多列表，就继续添加
        selectedList = state.xingyunList;
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

  // 更新当前风险列表
  void _updateCurrentRiskList() {
    if (state.riskyData.value == null) {
      state.currentRiskList.clear();
      return;
    }

    final companies = state.riskyData.value!.companies;
    List<Map<String, dynamic>> newList = [];
    dealCurrentList(int index){
      List<RiskListElement> selectedList = [];
      if (index == 0) {
        selectedList = state.fengyun1List;
      } else if (index == 1) {
        selectedList = state.fengyun2List;
      } else if (index == 2) {
        selectedList = state.fengyun2List;
        // selectedList = state.xingyunList;
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

  // 获取风险等级对应的颜色
  int _getRiskColor(int riskLevel) {
    switch (riskLevel) {
      case '3':
        return 0xFFFF6850;
      case '2':
        return 0xFFF6D500;
      case '1':
        return 0xFF07CC89;
      default:
        return 0xFF07CC89;
    }
  }

  // 获取风险等级对应的边框颜色
  int _getBorderColor(int riskLevel) {
    switch (riskLevel) {
      case '3':
        return 0xFFFFECE9;
      case '2':
        return 0xFFFFF7E6;
      case '1':
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
    _safeHideOverlay();
    super.onClose();
  }

  // 切换单位
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

  // 显示城市选择器浮层
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

  // 构建城市选择浮层
  Widget _buildCityOverlay(Offset position, Size size) {
    final scrollController = ScrollController();
    // 确保优先城市和其他城市列表以正确的顺序显示
    final List<String> allCities = [...state.priorityCities, ...state.otherCities];
    
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
          
          // 城市选择内容
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
                        itemCount: allCities.length,
                        itemBuilder: (context, index) {
                          final city = allCities[index];
                          final isSelected = state.selectedCity.value == city;
                          final isPriority = state.priorityCities.contains(city);
                          
                          return InkWell(
                            onTap: () {
                              state.selectedCity.value = city;
                              // 更新显示的地点名称
                              if (city == "全部") {
                                state.location.value = "广东省全部";
                              } else {
                                state.location.value = "广东省$city";
                              }
                              // 更新列表后隐藏浮层
                              hideOverlay();
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              color: isSelected ? Color(0xFFF0F5FF) : Colors.white,
                              child: Text(
                                city,
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

  // 根据城市名称获取城市代码
  String _getCityCodeByName(String cityName) {
    // 风险预警数据为空，筛选代码返回null
    if (state.riskyData.value == null) return "all";
    // 查找对应的城市代码
    for (var city in state.riskyData.value!.location.cities) {
      if (city.name == cityName) {
        return city.code;
      }
    }
    // 没有对应代码返回全部
    return 'all';
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
