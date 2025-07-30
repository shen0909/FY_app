import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:safe_app/https/api_service.dart';
import 'package:safe_app/models/newslist_data.dart';
import 'package:safe_app/utils/shared_prefer.dart';

import 'hot_pot_state.dart';

class HotPotLogic extends GetxController {
  final HotPotState state = HotPotState();
  static const String _readNewsKey = 'read_news_ids';
  
  // 添加滚动控制器
  late ScrollController scrollController;

  @override
  Future<void> onInit() async {
    super.onInit();
    
    // 初始化滚动控制器
    scrollController = ScrollController();
    _addScrollListener();
    
    // 设置默认日期范围为最近30天
    final now = DateTime.now();
    state.endDate.value = now;
    state.startDate.value = now.subtract(const Duration(days: 30));
    // 加载已读新闻状态
    await _loadReadNewsIds();
    // 获取地区列表
    await getRegionList();
    // 获取热点列表
    await getNewsList();
  }

  // 添加滚动监听器
  void _addScrollListener() {
    scrollController.addListener(() {
      // 当滚动到距离底部200像素时触发加载更多
      if (scrollController.position.pixels >= 
          scrollController.position.maxScrollExtent - 200) {
        loadMore();
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
  
  // 从本地存储加载已读新闻ID
  Future<void> _loadReadNewsIds() async {
    try {
      final readNewsString = FYSharedPreferenceUtils.getString(_readNewsKey);
      if (readNewsString.isNotEmpty) {
        final List<dynamic> readNewsList = json.decode(readNewsString);
        final Set<String> readNewsIds = readNewsList.map((id) => id.toString()).toSet();
        state.setReadNewsIds(readNewsIds);
        print('从本地存储加载已读新闻ID: ${readNewsIds.length}条');
      }
    } catch (e) {
      print('加载已读新闻状态失败: $e');
    }
  }

  // 保存已读新闻ID到本地存储
  Future<void> _saveReadNewsIds() async {
    try {
      final readNewsList = state.readNewsIds.toList();
      await FYSharedPreferenceUtils.setString(_readNewsKey, json.encode(readNewsList));
      print('保存已读新闻ID到本地存储: ${readNewsList.length}条');
    } catch (e) {
      print('保存已读新闻状态失败: $e');
    }
  }
  
  // 切换标签页
  void changeTab(int index) {
    state.changeTab(index);
  }
  
  // 下载相关文件
  void downloadFile() {
    // 实际应用中这里会实现文件下载功能
    Get.snackbar(
      '下载提示', 
      '文件下载功能已触发',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  // 复制内容
  void copyContent(String content) {
    Clipboard.setData(ClipboardData(text: content));
    Get.snackbar(
      '复制成功', 
      '内容已复制到剪贴板',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  // 分享内容
  void shareContent() {
    // 实际应用中这里会调用分享API
    Get.snackbar(
      '分享提示', 
      '分享功能已触发',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  // 添加到收藏
  void addToFavorites() {
    // 实际应用中这里会实现收藏功能
    Get.snackbar(
      '收藏提示', 
      '已添加到收藏',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  // 显示筛选选项
  void showFilterOptions() {
    state.toggleFilterOptions();
  }
  
  // 选择区域
  void selectRegion(String region) {
    state.setSelectedRegion(region);
  }
  
  // 选择新闻类型
  void selectNewsType(String newsType) {
    state.setSelectedNewsType(newsType);
  }
  
  // 选择时间范围
  void selectTimeRange(String timeRange) {
    state.setSelectedTimeRange(timeRange);
    // 选择预设时间范围时，重置自定义日期范围
    if (timeRange != "全部") {
      state.useCustomDateRange.value = false;
    }
  }
  
  // 自定义时间范围
  void customTimeRange() {
    // 实际应用中这里会打开日期选择器
    Get.snackbar(
      '自定义时间', 
      '打开自定义时间选择器',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  // 设置搜索关键词
  void setSearchKeyword(String keyword) {
    state.searchKeyword.value = keyword;
  }
  
  // 设置起始日期
  void setStartDate(DateTime date) {
    // 确保开始日期不晚于结束日期
    if (date.isAfter(state.endDate.value)) {
      state.endDate.value = date; // 自动调整结束日期
    }
    state.startDate.value = date;
    state.useCustomDateRange.value = true;
    state.selectedTimeRange.value = "全部"; // 重置预设时间选择
  }
  
  // 设置结束日期
  void setEndDate(DateTime date) {
    // 确保结束日期不早于开始日期
    if (date.isBefore(state.startDate.value)) {
      state.startDate.value = date; // 自动调整开始日期
    }
    state.endDate.value = date;
    state.useCustomDateRange.value = true;
    state.selectedTimeRange.value = "全部"; // 重置预设时间选择
  }
  
  // 选择日期
  Future<void> selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? state.startDate.value : state.endDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      if (isStartDate) {
        setStartDate(picked);
      } else {
        setEndDate(picked);
      }
      
      // 日期选择后立即应用筛选
      applyFilters();
    }
  }
  
  // 应用筛选条件
  void applyFilters() {
    // 关闭筛选选项面板
    if (state.showFilterOptions.value) {
      state.toggleFilterOptions();
    }
    
    // 准备API参数
    String? dateFilter = state.useCustomDateRange.value ? null : state.selectedTimeRange.value;
    String? startDate = state.useCustomDateRange.value ? formatDate(state.startDate.value) : null;
    String? endDate = state.useCustomDateRange.value ? formatDate(state.endDate.value) : null;
    
    // 重置分页状态和清空数据
    state.resetPagination();
    state.newsList.clear();
    
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
  
  // 格式化日期为YYYY-MM-DD
  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
  
  // 导航到热点详情页面
  void navigateToDetails(int index) {
    // 获取对应的新闻项
    NewsItem newsItem = state.newsList[index];
    
    // 标记该新闻为已读
    state.markNewsAsRead(newsItem.newsId);
    
    // 保存已读状态到本地存储
    _saveReadNewsIds();
    
    print('标记新闻为已读: ${newsItem.newsId} - ${newsItem.newsTitle}');
    
    // 导航到详情页面并传递newsId
    Get.toNamed('/hot_details', arguments: {
      'newsId': newsItem.newsId,
      'title': newsItem.newsTitle
    });
  }

  // 获取地区列表
  Future<void> getRegionList() async {
    try {
      var result = await ApiService().getRegion();
      
      if (result != null && result['code'] == 10010 && result['data'] != null) {
        // 将结果转换为地区列表
        List<Map<String, dynamic>> regions = List<Map<String, dynamic>>.from(result['data']);
        
        // 确保"全部"选项在列表的第一位
        state.regionList.value = [{"id": "0", "region": "全部"}, ...regions];
      } else {
        print('获取地区列表失败: ${result['message'] ?? '未知错误'}');
        // 添加默认地区，以防API调用失败
        state.regionList.value = [{"id": "0", "region": "全部"}];
      }
    } catch (e) {
      print('获取地区列表异常: $e');
      // 添加默认地区，以防API调用失败
      state.regionList.value = [{"id": "0", "region": "全部"}];
    }
  }

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
    // 如果是加载更多，设置isLoadingMore为true
    // 否则设置isLoading为true
    if (isLoadMore) {
      state.isLoadingMore.value = true;
    } else {
      state.isLoading.value = true;
      state.errorMessage.value = '';
    }
    
    try {
      // 使用传入的页码或状态中的页码
      int page = currentPage ?? state.currentPage.value;
      int size = pageSize ?? state.pageSize.value;
      
      var result = await ApiService().getNewsList(
        currentPage: page,
        pageSize: size,
        newsType: newsType,
        region: region,
        dateFilter: dateFilter,
        startDate: startDate,
        endDate: endDate,
        search: search,
      );
      
      if (result != null && result['code'] == 10010 && result['data'] != null) {
        // 将JSON数据转换为NewsItem列表
        List<NewsItem> items = (result['data'] as List)
            .map((item) => NewsItem.fromJson(item))
            .toList();
        
        // 如果是加载更多，则将新数据添加到已有数据后面
        // 否则替换原有数据
        if (isLoadMore) {
          state.newsList.addAll(items);
        } else {
          state.newsList.value = items;
        }
        
        // 更新页码
        state.currentPage.value = page;
        
        // 判断是否还有更多数据
        if (items.isEmpty || items.length < size) {
          state.hasMoreData.value = false;
        } else {
          state.hasMoreData.value = true;
        }
      } else {
        state.errorMessage.value = result['msg'] ?? '获取数据失败';
        
        if (isLoadMore) {
          // 加载更多失败，页码回退
          state.currentPage.value = page - 1;
        } else {
          state.newsList.value = [];
        }
      }
    } catch (e) {
      state.errorMessage.value = e.toString();
      
      if (isLoadMore) {
        // 加载更多失败，页码回退
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
  
  // 加载更多数据
  Future<void> loadMore() async {
    // 如果没有更多数据或正在加载，则不执行任何操作
    if (!state.hasMoreData.value || state.isLoadingMore.value || state.isLoading.value) {
      return;
    }
    
    // 获取当前的筛选条件
    String? dateFilter = state.useCustomDateRange.value ? null : state.selectedTimeRange.value;
    String? startDate = state.useCustomDateRange.value ? formatDate(state.startDate.value) : null;
    String? endDate = state.useCustomDateRange.value ? formatDate(state.endDate.value) : null;
    
    // 请求下一页数据
    await getNewsList(
      currentPage: state.currentPage.value + 1,
      pageSize: state.pageSize.value,
      newsType: state.selectedNewsType.value,
      region: state.selectedRegion.value,
      dateFilter: dateFilter!,
      startDate: startDate,
      endDate: endDate,
      search: state.searchKeyword.value.isNotEmpty ? state.searchKeyword.value : null,
      isLoadMore: true,
    );
  }
}
