import 'package:get/get.dart';
import 'package:safe_app/models/newslist_data.dart';

class HotPotState {
  // 存储新闻列表数据
  final RxList<NewsItem> newsList = <NewsItem>[].obs;
  
  // 添加加载状态
  final RxBool isLoading = false.obs;
  
  // 添加错误信息
  final RxString errorMessage = ''.obs;

  // 当前活跃标签页索引
  final RxInt activeTabIndex = 0.obs;
  
  // 筛选参数
  final RxString selectedRegion = "全部".obs;
  final RxBool isSelectedRegion = false.obs;
  final RxBool isSelectedNewsType = false.obs;
  final RxBool isSelectedTimeRange = false.obs;
  final RxString selectedNewsType = "全部".obs;
  final RxString selectedTimeRange = "全部".obs;
  final RxBool showFilterOptions = false.obs;
  
  // 搜索关键词
  final RxString searchKeyword = "".obs;
  
  // 日期范围选择
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().obs;
  final RxBool useCustomDateRange = false.obs; //使用自定义的时间范围
  
  // 区域选项 - 将从接口获取
  final RxList<Map<String, dynamic>> regionList = <Map<String, dynamic>>[].obs;
  
  // 新闻类型选项 - 根据接口文档固定值
  final List<String> newsTypes = [
    "全部",
    "制裁打压",
    "起诉调查",
    "出口管制",
    "外资渗透",
    "专家人才",
    "负面舆情",
    "涉疆制裁",
  ];
  
  // 时间范围选项 - 根据接口文档固定值
  final List<String> timeRanges = [
    "全部",
    "3d",
    "7d",
    "30d"
  ];
  
  // 时间范围显示名称
  final Map<String, String> timeRangeNames = {
    "全部": "全部",
    "3d": "近三天",
    "7d": "近一周",
    "30d": "近一个月"
  };
  
  // 分页相关参数
  final RxInt currentPage = 1.obs; // 当前页码
  final RxInt pageSize = 10.obs; // 每页条数
  final RxBool hasMoreData = true.obs; // 是否还有更多数据
  final RxBool isLoadingMore = false.obs; // 是否正在加载更多

  // 已读新闻ID集合 - 用于跟踪用户已查看过的新闻
  final RxSet<String> readNewsIds = <String>{}.obs;

  HotPotState() {
    ///Initialize variables
  }

  // 切换标签页
  void changeTab(int index) {
    activeTabIndex.value = index;
  }
  
  // 切换筛选选项显示状态
  void toggleFilterOptions() {
    showFilterOptions.value = !showFilterOptions.value;
  }
  
  // 设置选中的区域
  void setSelectedRegion(String region) {
    selectedRegion.value = region;
  }
  
  // 设置选中的新闻类型
  void setSelectedNewsType(String newsType) {
    selectedNewsType.value = newsType;
  }
  
  // 设置选中的时间范围
  void setSelectedTimeRange(String timeRange) {
    selectedTimeRange.value = timeRange;
  }
  
  // 重置分页状态
  void resetPagination() {
    currentPage.value = 1;
    hasMoreData.value = true;
  }

  // 标记新闻为已读
  void markNewsAsRead(String newsId) {
    readNewsIds.add(newsId);
  }

  // 检查新闻是否已读
  bool isNewsRead(String newsId) {
    return readNewsIds.contains(newsId);
  }

  // 设置已读新闻ID集合（从本地存储加载时使用）
  void setReadNewsIds(Set<String> ids) {
    readNewsIds.clear();
    readNewsIds.addAll(ids);
  }
}
