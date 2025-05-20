import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:safe_app/https/api_service.dart';
import 'package:safe_app/models/newslist_data.dart';

import 'hot_pot_state.dart';

class HotPotLogic extends GetxController {
  final HotPotState state = HotPotState();

  @override
  Future<void> onInit() async {
    super.onInit();
    // 获取热点列表
    await getNewsList();
  }

  @override
  void onReady() {
    super.onReady();
    // 获取传入的热点数据
    if (Get.arguments != null) {
      // 在实际应用中，这里会根据传入的ID或其他参数加载对应的热点数据
      // 例如: loadHotNewsDetails(Get.arguments['id']);
    }
  }

  @override
  void onClose() {
    super.onClose();
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
    // 这里可以添加根据区域筛选数据的逻辑
    Get.snackbar(
      '区域筛选', 
      '已选择区域: $region',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  // 选择时间范围
  void selectTimeRange(String timeRange) {
    state.setSelectedTimeRange(timeRange);
    // 这里可以添加根据时间范围筛选数据的逻辑
    Get.snackbar(
      '时间筛选', 
      '已选择时间范围: $timeRange',
      snackPosition: SnackPosition.BOTTOM,
    );
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
  
  // 应用筛选条件
  void applyFilters() {
    // 关闭筛选选项面板
    if (state.showFilterOptions.value) {
      state.toggleFilterOptions();
    }
    
    // 根据筛选条件获取数据
    getNewsList(
      region: state.selectedRegion.value,
      dateFilter: state.selectedTimeRange.value,
    );
    
    Get.snackbar(
      '应用筛选', 
      '区域: ${state.selectedRegion.value}, 时间: ${state.selectedTimeRange.value}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  // 导航到热点详情页面
  void navigateToDetails(int index) {
    // 获取对应的新闻项
    NewsItem newsItem = state.newsList[index];
    // 导航到详情页面并传递newsId
    Get.toNamed('/hot_details', arguments: {
      'newsId': newsItem.newsId,
      'title': newsItem.newsTitle
    });
  }

  Future<void> getNewsList({
    int currentPage = 1,
    int pageSize = 10,
    String newsType = '全部',
    String region = '全部',
    String dateFilter = '全部',
    String? startDate = '2025-05-01',
    String? endDate = '2025-05-01',
    String? search,
  }) async {
    state.isLoading.value = true;
    state.errorMessage.value = '';
    
    try {
      var result = await ApiService().getNewsList(
        currentPage: currentPage,
        pageSize: pageSize,
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
        
        state.newsList.value = items;
      } else {
        state.errorMessage.value = result['msg'] ?? '获取数据失败';
      }
    } catch (e) {
      state.errorMessage.value = e.toString();
    } finally {
      state.isLoading.value = false;
    }
  }
}
