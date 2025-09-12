import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_file/open_file.dart';
import 'package:safe_app/https/api_service.dart';
import 'package:safe_app/models/detail_list_data.dart';
import 'package:safe_app/utils/diolag_utils.dart';
import 'package:safe_app/utils/area_data_manager.dart';
import 'package:safe_app/utils/toast_util.dart';
import '../../styles/colors.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/file_utils.dart';
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
    // 初始化数据
    loadData();
    // 加载趋势数据
    loadTrendData();
    // 初始化滚动控制器
    yearlyStatsController = ScrollController();
    leftVerticalController = ScrollController();
    rightVerticalController = ScrollController();
    horizontalScrollController = ScrollController();

    // 确保制裁类型列表已初始化
    if (state.sanctionTypes.isEmpty) {
      state.sanctionTypes.addAll(SanctionType.mockSanctionType());
    }

    // 初始化省市数据
    try {
      await AreaDataManager.instance.loadAreaData();
      print('省市数据初始化完成');
    } catch (e) {
      print('省市数据初始化失败: $e');
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
      
      // 检测是否滑动到底部，触发加载更多
      // _checkIfNeedLoadMore();
    });
  }
  //
  // @override
  // void onReady() {
  //   // 初始化数据
  //   loadData();
  //   super.onReady();
  // }

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

  /// 加载实体清单趋势数据
  Future<void> loadTrendData() async {
    try {
      state.isTrendLoading.value = true;

      final trendDataList = await ApiService().getEntityListTrendData();

      if (trendDataList != null && trendDataList.isNotEmpty) {
        final trends = trendDataList.map((item) => EntityTrendData.fromJson(item)).toList();
        // 按年份排序
        trends.sort((a, b) => a.year.compareTo(b.year));
        // 更新状态
        state.trendData.assignAll(trends);
        print('实体清单趋势数据加载成功: ${trends.length}条数据');
      } else {
        print('实体清单趋势数据为空，保持现有数据');
      }
    } catch (e) {
      print('加载实体清单趋势数据失败: $e');
      // 出错时可以设置一些默认数据或显示错误提示
    } finally {
      state.isTrendLoading.value = false;
    }
  }

  /// 刷新趋势数据
  Future<void> refreshTrendData() async {
    await loadTrendData();
  }

  // 返回拦截
  canPopFunction(bool didPop){
    if (didPop) return;
    if(_overlayEntry != null){
      hideOverlay();
      return;
    }
    Get.back();
  }

  // 加载清单数据
  Future<void> loadData({bool isRefresh = false}) async {
    // 如果是刷新，重置分页状态
    if (isRefresh) {
      state.isRefreshing.value = true;
      state.currentPage.value = 1;
      state.hasMoreData.value = true;
    } else {
      state.isLoading.value = true;
    }

    try {
      // 构建搜索参数
      String sanctionTypeParam = state.typeFilter.value.isNotEmpty ? state.typeFilter.value : "全部";
      String provinceParam = state.provinceFilter.value.isNotEmpty ? state.provinceFilter.value : "全部";
      String cityParam = state.cityFilter.value.isNotEmpty ? state.cityFilter.value : "全部";
      String searchParam = state.searchText.value;

      // 调用API获取数据
      SanctionListResponse? response = await ApiService().getSanctionList(
        currentPage: state.currentPage.value,
        pageSize: state.pageSize.value,
        sanctionType: sanctionTypeParam,
        province: provinceParam,
        city: cityParam,
        zhName: searchParam,
      );

      if (response != null && response.success && response.data != null) {
        final newEntities = response.data!.entities;
        // if (isRefresh || state.currentPage.value == 1) {
        //   // 刷新或首次加载：替换数据
        //   state.sanctionList.value = newEntities;
        // } else {
        //   state.sanctionList.addAll(newEntities);
        // }
        // 替换数据
        state.sanctionList.clear();
        state.sanctionList.value = newEntities;
        state.totalCount.value = response.data!.allCount;
        state.searchCount.value = response.data!.search_all_num;
        state.updateTime.value = response.data!.update_time;
        state.removeNum.value = response.data!.removeCount;
        // 检查是否还有更多数据
        final totalPages = (response.data!.allCount / state.pageSize.value).ceil();
        state.hasMoreData.value = state.currentPage.value < totalPages;
        // 数据加载完成后计算表格宽度
        calculateTableWidth();
        
      } else {
        // API调用失败
        print('API调用失败: ${response?.message ?? "响应为空"}');
        if (isRefresh || state.currentPage.value == 1) {
          state.sanctionList.clear();
          state.totalCount.value = 0;
          state.searchCount.value = 0;
          state.updateTime.value = "";
        }
        state.hasMoreData.value = false;
      }
    } catch (e) {
      print('加载数据时发生错误: $e');
      if (isRefresh || state.currentPage.value == 1) {
        state.sanctionList.clear();
        state.totalCount.value = 0;
        state.searchCount.value = 0;
        state.updateTime.value = "";
      }
      state.hasMoreData.value = false;
    } finally {
      state.isLoading.value = false;
      state.isRefreshing.value = false;
    }
  }

  // 计算表格宽度
  void calculateTableWidth() {
    if (state.sanctionList.isEmpty) {
      // 如果没有数据，设置一个默认宽度
      state.totalTableWidth.value = 600.w;
      return;
    }
    
    // 计算每列需要的最大宽度
    double maxNameWidth = 150.w; // 名称列最小宽度
    double maxSanctionTypeWidth = 0.0; // 制裁类型列，需要计算最大宽度
    double maxRegionWidth = 100.w; // 地区列最小宽度
    double timeWidth = 80.w; // 时间列
    double removalTimeWidth = 80.w; // 移除时间列
    
    // 测量每个制裁类型的宽度
    TextStyle sanctionTextStyle = TextStyle(fontSize: 12.sp, color: Colors.black);
    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    
    // 为每个制裁类型计算所需宽度
    for (var item in state.sanctionList) {
      // 获取制裁类型
      final sanctionType = item.getSanctionType(state.sanctionTypes);
      
      // 计算文本宽度
      textPainter.text = TextSpan(text: sanctionType.name, style: sanctionTextStyle);
      textPainter.layout();
      // 文本宽度 + 图标宽度(14.w) + 图标与文本间距(4.w) + 内边距(8.w * 2) + 额外缓冲(20.w)
      double totalWidth = textPainter.width + 14.w + 4.w + 16.w + 20.w;
      
      if (totalWidth > maxSanctionTypeWidth) {
        maxSanctionTypeWidth = totalWidth;
      }
    }
    
    // 确保制裁类型宽度至少有一个最小值
    maxSanctionTypeWidth = maxSanctionTypeWidth < 150.w ? 150.w : maxSanctionTypeWidth;
    
    // 保存制裁类型列宽度到state中
    state.maxSanctionTypeWidth.value = maxSanctionTypeWidth;
    
    // 计算总宽度
    state.totalTableWidth.value = maxNameWidth + 
        maxSanctionTypeWidth + 
        maxRegionWidth + 
        timeWidth + 
        removalTimeWidth;
  }

  // 搜索
  void search(String keyword) {
    state.searchText.value = keyword;
    refreshData();
  }

  // 刷新数据
  void refreshData() {
    state.currentPage.value = 1;
    loadData(isRefresh: true);
  }

  // 设置类型筛选
  void setTypeFilter(String typeName) {
    state.typeFilter.value = typeName;
    refreshData();
  }

  // 设置省份筛选
  void setProvinceFilter(String province) {
    state.provinceFilter.value = province;
    
    // 省份改变时，重置城市筛选（实现级联效果）
    if (province == '全部') {
      // 如果选择"全部"省份，城市筛选也重置为"全部"
      state.cityFilter.value = '';
    } else {
      // 如果选择了具体省份，检查当前选择的城市是否属于该省份
      String currentCity = state.cityFilter.value;
      if (currentCity.isNotEmpty && currentCity != '全部') {
        // 检查当前城市是否属于新选择的省份
        List<String> newCities = AreaDataManager.instance.getCityListByProvince(province);
        if (!newCities.contains(currentCity)) {
          // 如果当前城市不属于新省份，重置城市选择
          state.cityFilter.value = '';
        }
      } else {
        // 如果之前没有选择城市，保持为空
        state.cityFilter.value = '';
      }
    }
    
    refreshData();
  }

  // 设置城市筛选
  void setCityFilter(String city) {
    state.cityFilter.value = city;
    refreshData();
  }

  // 清除所有筛选条件
  void clearFilters() {
    state.typeFilter.value = '';
    state.provinceFilter.value = '';
    state.cityFilter.value = '';
    state.searchText.value = '';
    refreshData();
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
    // 从AreaDataManager获取省份数据
    return AreaDataManager.instance.getProvinceList();
  }

  // 获取城市选项
  List<String> getCityOptions() {
    // 如果没有选择省份，返回空列表禁用城市选择
    if (state.provinceFilter.value.isEmpty || state.provinceFilter.value == '全部') {
      return [];
    }
    
    // 根据选择的省份返回对应的城市列表
    return AreaDataManager.instance.getCityListByProvince(state.provinceFilter.value);
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

  // 检测是否需要加载更多数据
  void _checkIfNeedLoadMore() {
    if (state.isLoadingMore.value || !state.hasMoreData.value) return;
    
    final maxScroll = rightVerticalController.position.maxScrollExtent;
    final currentScroll = rightVerticalController.position.pixels;
    
    // 当滚动到距离底部100像素时开始加载更多
    if (maxScroll - currentScroll <= 100) {
      loadMoreData();
    }
  }

  // 加载更多数据
  Future<void> loadMoreData() async {
    if (state.isLoadingMore.value || !state.hasMoreData.value) return;
    
    state.isLoadingMore.value = true;
    state.currentPage.value++;
    
    try {
      await loadData();
    } catch (e) {
      // 加载失败时回退页码
      state.currentPage.value--;
      print('加载更多数据失败: $e');
    } finally {
      state.isLoadingMore.value = false;
    }
  }

  // 跳转到指定页面
  void goToPage(int page) {
    if (page != state.currentPage.value) {
      state.currentPage.value = page;
      
      // 重置滚动位置
      if (leftVerticalController.hasClients) {
        leftVerticalController.jumpTo(0);
      }
      if (rightVerticalController.hasClients) {
        rightVerticalController.jumpTo(0);
      }
      
      loadData();
    }
  }

  downloadExcel() async {
    DialogUtils.showLoading('正在导出Excel文件');
    final result = await ApiService().getEntityListExcel();
    DialogUtils.hideLoading();
    if(result == null) {
      ToastUtil.showShort('导出失败');
      return false;
    }
    DialogUtils.showCustomDialog(Container(
      padding: EdgeInsets.fromLTRB(16.w, 40.h, 16.w, 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 成功图标
          Container(
            width: 64.w,
            height: 64.h,
            decoration: const BoxDecoration(
              color: Color(0xFF3361FE),
              shape: BoxShape.circle
            ),
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 40.w,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Excel生成成功',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 20.h),
          // 操作按钮
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => downloadAndPreviewReport(result),
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: FYColors.loginBtn,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '下载并预览',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  downloadAndPreviewReport(String link) async {
    // 1. 检查链接是否为空
    if (link.isEmpty) {
      ToastUtil.showShort('暂无下载链接', title: '提示');
      return;
    }
    Get.back(); // 关闭前一个弹窗
    try {
      ToastUtil.showShort('开始下载报告...', title: '下载中');

      final uri = Uri.parse(link);
      String fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '报告.xlsx';

      if (!fileName.toLowerCase().endsWith('.xlsx')) {
        fileName = '$fileName.xlsx';
      }
      final dirPath = await FileUtil.getDownloadDirectoryPath();
      if (dirPath == null) {
        ToastUtil.showShort('获取存储权限或路径失败', title: '下载失败');
        return Future.value(false);
      }
      final savePath = '$dirPath/$fileName';
      await Dio().download(
        link,
        savePath,
        options: Options(responseType: ResponseType.bytes, followRedirects: true),
        onReceiveProgress: (count, total) {
          if (total > 0) {
            final percent = (count / total * 100).toStringAsFixed(0);
            print('下载进度: $percent%');
          }
        },
      );
      ToastUtil.showShort('报告已下载', title: '成功');
      await OpenFile.open(savePath);
    } catch (e) {
      ToastUtil.showShort('下载失败');
    }
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
