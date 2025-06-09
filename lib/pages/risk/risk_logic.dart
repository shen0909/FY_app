import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/widgets/unread_message_dialog.dart';

import '../../models/risk_company_details.dart';
import '../../models/risk_data.dart';
import 'risk_state.dart';

class RiskLogic extends GetxController {
  final RiskState state = RiskState();

  // Overlay相关变量
  OverlayEntry? _overlayEntry;
  final GlobalKey locationKey = GlobalKey();

  @override
  Future<void> onInit() async {
    super.onInit();
    try {
      final filePath = 'assets/complete-risk-alerts-data.json';
      final fileContent = await rootBundle.loadString(filePath);
      final jsonData = json.decode(fileContent) as Map<String, dynamic>;

      print("数据数据:${jsonData}");
      state.riskyData.value = RiskyData.fromJson(jsonData);
      _updateCurrentUnitData();
      _updateCurrentRiskList();
      
      // 监听单位类型变化
      ever(state.chooseUint, (_) {
        _updateCurrentUnitData();
        _updateCurrentRiskList();
      });
      ever(state.riskyData, (_) {
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

  // 更新当前单位数据
  void _updateCurrentUnitData() {
    if (state.riskyData.value == null) {
      state.currentUnitData.value = {};
      return;
    }
    
    switch (state.chooseUint.value) {
      case 0:
        final stats = state.riskyData.value!.statistics.fengyun1.stats;
        state.currentUnitData.value = {
          'high': {
            'title': '高风险',
            'count': stats.highRisk,
            'change': stats.dailyChange.highRisk,
            'color': 0xFFFF6850
          },
          'medium': {
            'title': '中风险',
            'count': stats.mediumRisk,
            'change': stats.dailyChange.mediumRisk,
            'color': 0xFFF6D500
          },
          'low': {
            'title': '低风险',
            'count': stats.lowRisk,
            'change': stats.dailyChange.lowRisk,
            'color': 0xFF07CC89
          },
          'total': {
            'count': stats.total,
            'color': 0xFF1A1A1A
          },
        };
        break;
      case 1:
        final stats = state.riskyData.value!.statistics.fengyun2.stats;
        state.currentUnitData.value = {
          'high': {
            'title': '高风险',
            'count': stats.highRisk,
            'change': stats.dailyChange.highRisk,
            'color': 0xFFFF6850
          },
          'medium': {
            'title': '中风险',
            'count': stats.mediumRisk,
            'change': stats.dailyChange.mediumRisk,
            'color': 0xFFF6D500
          },
          'low': {
            'title': '低风险',
            'count': stats.lowRisk,
            'change': stats.dailyChange.lowRisk,
            'color': 0xFF07CC89
          },
          'total': {
            'count': stats.total,
            'color': 0xFF1A1A1A
          },
        };
        break;
      case 2:
        final stats = state.riskyData.value!.statistics.xingyun.stats;
        state.currentUnitData.value = {
          'high': {
            'title': '重点关注',
            'count': stats.keyFocus,
            'change': stats.dailyChange.keyFocus,
            'color': 0xFFFF6850
          },
          'medium': {
            'title': '一般关注',
            'count': stats.generalFocus,
            'change': stats.dailyChange.generalFocus,
            'color': 0xFF07CC89
          },
          'total': {
            'count': stats.total,
            'color': 0xFF1A1A1A
          },
        };
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

    switch (state.chooseUint.value) {
      case 0:
        if (companies.containsKey('fengyun_1')) {
          newList = companies['fengyun_1']!.map((company) => {
            'id': company.id,
            'name': company.name,
            'englishName': company.englishName,
            'description': company.description,
            'riskLevel': company.riskLevel,
            'riskLevelText': company.riskLevelText,
            'riskColor': _getRiskColor(company.riskLevel),
            'borderColor': _getBorderColor(company.riskLevel),
            'updateTime': company.updateDate,
            'unreadCount': company.unreadCount,
            'isRead': false,
          }).toList();
        }
        break;
      case 1:
        if (companies.containsKey('fengyun_2')) {
          newList = companies['fengyun_2']!.map((company) => {
            'id': company.id,
            'name': company.name,
            'englishName': company.englishName,
            'description': company.description,
            'riskLevel': company.riskLevel,
            'riskLevelText': company.riskLevelText,
            'riskColor': _getRiskColor(company.riskLevel),
            'borderColor': _getBorderColor(company.riskLevel),
            'updateTime': company.updateDate,
            'unreadCount': company.unreadCount,
            'isRead': false,
          }).toList();
        }
        break;
      case 2:
        if (companies.containsKey('xingyun')) {
          newList = companies['xingyun']!.map((company) => {
            'id': company.id,
            'name': company.name,
            'englishName': company.englishName,
            'description': company.description,
            'riskLevel': company.riskLevelText,
            'riskColor': _getRiskColor(company.riskLevel),
            'borderColor': _getBorderColor(company.riskLevel),
            'updateTime': company.updateDate,
            'unreadCount': company.unreadCount,
            'isRead': false,
            'attentionLevel': company.attentionLevel,
            'attentionLevelText': company.attentionLevelText,
          }).toList();
        }
        break;
    }

    state.currentRiskList.assignAll(newList);
  }

  // 获取风险等级对应的颜色
  int _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'high':
        return 0xFFFF6850;
      case 'medium':
        return 0xFFF6D500;
      case 'low':
        return 0xFF07CC89;
      default:
        return 0xFF07CC89;
    }
  }

  // 获取风险等级对应的边框颜色
  int _getBorderColor(String riskLevel) {
    switch (riskLevel) {
      case 'high':
        return 0xFFFFECE9;
      case 'medium':
        return 0xFFFFF7E6;
      case 'low':
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
    hideOverlay();
    // TODO: implement onClose
    super.onClose();
  }

  // 切换单位
  changeUnit(int index) {
    state.chooseUint.value = index;
  }
  
  // 显示未读消息弹窗
  void showMessageDialog(String companyId) {
    if (state.riskyData.value == null) return;

    try {
      // 获取当前单位类型对应的key
      String unitKey;
      switch (state.chooseUint.value) {
        case 0:
          unitKey = 'fengyun_1';
          break;
        case 1:
          unitKey = 'fengyun_2';
          break;
        case 2:
          unitKey = 'xingyun';
          break;
        default:
          return;
      }

      // 从riskyData中获取对应公司的未读消息
      final unreadMessages = state.riskyData.value!.unreadMessages[companyId];
      if (unreadMessages == null || unreadMessages.isEmpty) return;

      // 转换未读消息格式
      final messages = unreadMessages.map((msg) => {
        'title': msg.title,
        'date': msg.date,
        'content': msg.content,
        'company': msg.sourceName,
        'isRead': msg.read,
        'category': msg.category,
        'severity': msg.severity,
        'tags': msg.tags,
      }).toList();

      state.currentUnreadMessages.assignAll(messages);

      Get.bottomSheet(
        UnreadMessageDialog(
          messages: state.currentUnreadMessages,
          onClose: () => Get.back(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        isDismissible: true,
        enableDrag: true,
        isScrollControlled: true,
        shape:  RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
      );
    } catch (e) {
      print("显示消息弹窗出错: $e");
    }
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
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // 构建城市选择浮层
  Widget _buildCityOverlay(Offset position, Size size) {
    final scrollController = ScrollController();
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
                              if (city == "全部") {
                                state.location.value = "广东省广州市";
                              } else {
                                state.location.value = "广东省$city";
                              }
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
