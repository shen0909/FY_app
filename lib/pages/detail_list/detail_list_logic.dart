import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safe_app/https/api_service.dart';
import 'package:safe_app/models/detail_list_data.dart';
import 'package:safe_app/utils/diolag_utils.dart';

import 'detail_list_state.dart';

class DetailListLogic extends GetxController {
  final DetailListState state = DetailListState();

  // 滚动控制器
  late ScrollController yearlyStatsController;
  late ScrollController leftVerticalController;
  late ScrollController rightVerticalController;
  late ScrollController horizontalScrollController;

  // Overlay相关变量
  OverlayEntry? _overlayEntry;
  final GlobalKey typeKey = GlobalKey();
  final GlobalKey provinceKey = GlobalKey();
  final GlobalKey cityKey = GlobalKey();

  @override
  Future<void> onInit() async {
    super.onInit();
    // 初始化滚动控制器
    yearlyStatsController = ScrollController();
    leftVerticalController = ScrollController();
    rightVerticalController = ScrollController();
    horizontalScrollController = ScrollController();

    // 确保制裁类型列表已初始化
    if (state.sanctionTypes.isEmpty) {
      state.sanctionTypes.addAll(SanctionType.mockSanctionType());
    }

    // 同步左右两侧的垂直滚动
    leftVerticalController.addListener(() {
      if (rightVerticalController.offset != leftVerticalController.offset) {
        rightVerticalController.jumpTo(leftVerticalController.offset);
      }
    });

    rightVerticalController.addListener(() {
      if (leftVerticalController.offset != rightVerticalController.offset) {
        leftVerticalController.jumpTo(rightVerticalController.offset);
      }
    });
  }

  @override
  void onReady() {
    // 初始化数据
    loadData();
    super.onReady();
  }

  @override
  void onClose() {
    // 释放控制器
    yearlyStatsController.dispose();
    leftVerticalController.dispose();
    rightVerticalController.dispose();
    horizontalScrollController.dispose();
    // 确保关闭overlay
    hideOverlay();
    super.onClose();
  }

  // 加载清单数据
  Future<void> loadData() async {
    state.isLoading.value = true;

    try {
      // 构建搜索参数
      String sanctionTypeParam = state.typeFilter.value.isNotEmpty ? state.typeFilter.value : "全部";
      String provinceParam = state.provinceFilter.value.isNotEmpty ? state.provinceFilter.value : "全部";
      String cityParam = state.cityFilter.value.isNotEmpty ? state.cityFilter.value : "全部";
      String searchParam = state.searchText.value;

      // 调用API获取数据
      SanctionListResponse? response = await ApiService().getSanctionList(
        currentPage: 1,
        pageSize: 50, // 可以根据需要调整页面大小
        sanctionType: sanctionTypeParam,
        province: provinceParam,
        city: cityParam,
        search: searchParam,
      );

      if (response != null && response.success && response.data != null) {
        // 直接使用SanctionEntity数据
        state.sanctionList.value = response.data!.entities;
        state.totalCount.value = response.data!.allCount;
      } else {
        // API调用失败，清空数据
        print('API调用失败: ${response?.message ?? "响应为空"}');
        state.sanctionList.clear();
        state.totalCount.value = 0;
      }
    } catch (e) {
      print('加载数据时发生错误: $e');
      // 发生错误时清空数据
      state.sanctionList.clear();
      state.totalCount.value = 0;
    } finally {
      state.isLoading.value = false;
    }
  }

  // 搜索
  void search(String keyword) {
    state.searchText.value = keyword;
    loadData();
  }

  // 设置类型筛选
  void setTypeFilter(String typeName) {
    state.typeFilter.value = typeName;
    loadData();
  }

  // 设置省份筛选
  void setProvinceFilter(String province) {
    state.provinceFilter.value = province;
    loadData();
  }

  // 设置城市筛选
  void setCityFilter(String city) {
    state.cityFilter.value = city;
    loadData();
  }

  // 清除所有筛选条件
  void clearFilters() {
    state.typeFilter.value = '';
    state.provinceFilter.value = '';
    state.cityFilter.value = '';
    state.searchText.value = '';
    loadData(); // 使用真实API调用
  }

  // 显示筛选器浮层
  void showFilterOverlay(
      BuildContext context, String filterType, GlobalKey key) {
    // 先隐藏可能存在的浮层
    hideOverlay();

    // 获取按钮位置
    final RenderBox renderBox =
        key.currentContext?.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    // 创建浮层
    _overlayEntry = OverlayEntry(
      builder: (context) => _buildOverlayContent(filterType, position, size),
    );

    // 显示浮层
    Overlay.of(context).insert(_overlayEntry!);
  }

  // 隐藏浮层
  void hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // 构建浮层内容
  Widget _buildOverlayContent(String filterType, Offset position, Size size) {
    List<String> options = [];
    double maxHeight = 300.0.w;
    // 根据筛选类型设置宽度
    double overlayWidth = 200.0.w;

    // 根据不同筛选类型获取选项
    if (filterType == "类型") {
      options = getTypeOptions();
      overlayWidth = 200.0.w; // 类型筛选器保持现有宽度
    } else if (filterType == "省份") {
      options = getProvinceOptions();
      overlayWidth = size.width; // 与上方筛选框宽度一致
    } else if (filterType == "城市") {
      options = getCityOptions();
      overlayWidth = size.width; // 与上方筛选框宽度一致
    }

    // 声明一个controller
    final scrollController = ScrollController();

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

          // 筛选内容
          Positioned(
            left: position.dx,
            top: position.dy + size.height,
            width: overlayWidth, // 使用根据类型设置的宽度
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
                maxHeight: maxHeight,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 选项列表
                  Flexible(
                    child: _DynamicScrollbarWrapper(
                      scrollController: scrollController,
                      child: ListView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.only(right: 10),
                          // 为滚动条留出空间
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final option = options[index];
                            bool isSelected = false;
                            if (filterType == "类型") {
                              isSelected = state.typeFilter.value == option;
                            } else if (filterType == "省份") {
                              isSelected = state.provinceFilter.value == option;
                            } else if (filterType == "城市") {
                              isSelected = state.cityFilter.value == option;
                            }

                            return InkWell(
                              onTap: () {
                                if (filterType == "类型") {
                                  setTypeFilter(option);
                                } else if (filterType == "省份") {
                                  setProvinceFilter(option);
                                } else if (filterType == "城市") {
                                  setCityFilter(option);
                                }
                                hideOverlay();
                              },
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                color: isSelected
                                    ? Color(0xFFF0F5FF)
                                    : Colors.white,
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSelected
                                        ? Color(0xFF3361FE)
                                        : Color(0xFF1A1A1A),
                                  ),
                                ),
                              ),
                            );
                          }),
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

  // 获取类型选项
  List<String> getTypeOptions() {
    return state.sanctionTypes.map((type) => type.name).toList();
  }

  // 获取省份选项
  List<String> getProvinceOptions() {
    return [
      "广东",
      "北京",
      "上海",
      "江苏",
      "浙江",
      "四川",
      "福建",
      "湖北",
      "山东",
      "安徽",
      "辽宁",
      "湖南",
      "河北",
      "江西",
      "中国香港",
      "中国澳门",
      "中国台湾"
    ];
  }

  // 获取城市选项
  List<String> getCityOptions() {
    return [
      "全部",
      "广州",
      "深圳",
      "北京",
      "上海",
      "杭州",
      "合肥",
      "香港",
      "苏州",
      "南京",
      "成都",
      "福州",
      "武汉",
      "济南",
      "青岛",
      "长沙",
      "石家庄",
      "南昌",
      "沈阳",
      "大连"
    ];
  }

  // 根据类型名称获取类型数据
  SanctionType? getSanctionTypeByName(String name) {
    try {
      return state.sanctionTypes.firstWhere((type) => type.name == name);
    } catch (e) {
      return null;
    }
  }

  // 根据类型代码获取类型数据
  SanctionType? getSanctionTypeByCode(String code) {
    try {
      return state.sanctionTypes.firstWhere((type) => type.code == code);
    } catch (e) {
      return null;
    }
  }

  // 显示制裁类型详情弹窗
  void showSanctionDetailOverlay(SanctionType sanctionType) {
    // 获取制裁类型详情数据
    SanctionTypeDetail detail = SanctionTypeDetail.getDetailByCode(sanctionType.code);
    FYDialogUtils.showBottomSheet(
      Container(
        width: double.infinity,
        height: MediaQuery.of(Get.context!).size.height * 0.5,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                // color: Color(detail.sanctionType.bgColor),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '制裁类型',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.close,
                      size: 20.w,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
            // 内容区域
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: detail.details.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Color(0xFFEEEEEE),
                ),
                itemBuilder: (context, index) {
                  final item = detail.details[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 详情标题
                        Text(
                          item['title'] ?? '',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        if (item['content']!.isNotEmpty) ...[
                          SizedBox(height: 8.h),
                          // 详情内容
                          Text(
                            item['content'] ?? '',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      )
    );
  }
}

// 自定义滚动条包装器，处理动态滑块逻辑
class _DynamicScrollbarWrapper extends StatefulWidget {
  final ScrollController scrollController;
  final Widget child;

  const _DynamicScrollbarWrapper({
    Key? key,
    required this.scrollController,
    required this.child,
  }) : super(key: key);

  @override
  State<_DynamicScrollbarWrapper> createState() =>
      _DynamicScrollbarWrapperState();
}

class _DynamicScrollbarWrapperState extends State<_DynamicScrollbarWrapper> {
  double _scrollPosition = 0.0;
  double _contentHeight = 0.0;
  double _viewportHeight = 0.0;
  final double _thumbHeight = 32.0; // 固定滑块高度为6像素

  @override
  void initState() {
    super.initState();

    // 延迟添加监听器，确保ScrollController已初始化
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
        _contentHeight = widget.scrollController.position.maxScrollExtent +
            widget.scrollController.position.viewportDimension;
        _viewportHeight = widget.scrollController.position.viewportDimension;
      }
    } catch (e) {
      // 捕获任何可能的异常
      print("Error updating scroll data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 计算滑块位置
    double thumbPositionRatio = 0.0;
    if (_contentHeight > 0 && _viewportHeight > 0) {
      thumbPositionRatio = _scrollPosition / (_contentHeight - _viewportHeight);
      thumbPositionRatio = thumbPositionRatio.clamp(0.0, 1.0);
    }

    double trackHeight = _viewportHeight > 0 ? _viewportHeight : 100;
    double availableTrackSpace = trackHeight - _thumbHeight;
    double thumbPosition = thumbPositionRatio * availableTrackSpace;

    // 是否显示滚动条
    bool showScrollbar = _contentHeight > _viewportHeight;

    return Stack(
      children: [
        // 子组件
        widget.child,

        // 滚动条轨道
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

        // 滚动条滑块（仅当需要滚动时显示）
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
