import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:safe_app/https/api_service.dart';
import 'package:safe_app/models/newslist_data.dart';

import 'hot_pot_state.dart';

class HotPotLogic extends GetxController {
  final HotPotState state = HotPotState();

  @override
  Future<void> onInit() async {
    super.onInit();
    
    // 设置默认日期范围为最近30天
    final now = DateTime.now();
    state.endDate.value = now;
    state.startDate.value = now.subtract(Duration(days: 30));
    
    // 获取地区列表
    await getRegionList();
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
    
    // 打印日志，便于调试
    print('应用筛选: 类型=${state.selectedNewsType.value}, 地区=${state.selectedRegion.value}, ' +
          '时间=${dateFilter ?? "自定义"}, ' +
          '开始日期=$startDate, 结束日期=$endDate, ' +
          '搜索关键词=${state.searchKeyword.value}');
    
    // 根据筛选条件获取数据
    getNewsList(
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
    int currentPage = 1,
    int pageSize = 10,
    String newsType = '全部',
    String region = '全部',
    String dateFilter = '全部',
    String? startDate,
    String? endDate,
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
        state.errorMessage.value = result['message'] ?? '获取数据失败';
      }
    } catch (e) {
      state.errorMessage.value = e.toString();
    } finally {
      state.isLoading.value = false;
    }
  }
}
