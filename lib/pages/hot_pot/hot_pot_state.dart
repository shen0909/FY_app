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
  final RxString selectedNewsType = "全部".obs;
  final RxString selectedTimeRange = "全部".obs;
  final RxBool showFilterOptions = false.obs;
  
  // 搜索关键词
  final RxString searchKeyword = "".obs;
  
  // 日期范围选择
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().obs;
  final RxBool useCustomDateRange = false.obs;
  
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
    "负面舆情"
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

  // 热点新闻详情
  final Map<String, dynamic> hotNews = {
    'id': '123456',
    'title': '美国贸易代表办公室正式启动对中国新能源汽车产业的301调查',
    'source': '美国贸易代表办公室',
    'date': '2025.04.26',
    'summary':
        '美国贸易代表办公室正式启动对中国新能源汽车产业的301调查，涉及政府补贴、知识产权和技术转让等问题。此举可能导致美国对中国汽车征收高额关税，影响中国车企出口战略。',
    'content': '美国贸易代表办办公室根据301条款发起的调查，通常会导致对涉事国家的产品征收额外关税或实施其他贸易限制措施。',
    'isAIGenerated': true,
  };

  // 风险分析内容
  final Map<String, dynamic> riskAnalysis = {
    'content':
        '本次调查针对中国新能源汽车产业，涉及政府补贴、知识产权和技术转让等方面。美国贸易代表办公室根据301条款发起的调查，通常会导致对涉事国家的产品征收额外关税或实施其他贸易限制措施。',
    'keyPoints': [
      '可能导致对中国汽车及零部件征收最高25%的额外关税',
      '美国市场对中国新能源汽车出口的限制将显著影响相关企业的海外扩张战略',
      '调查过程中可能要求中国企业提供敏感商业信息，增加知识产权泄露风险',
      '此举或将引发连锁反应，促使欧盟等其他西方国家采取类似措施'
    ],
  };

  // 决策建议
  final Map<String, dynamic> suggestions = {
    'strategy': '密切关注调查进展，做好应对美国可能采取的各种贸易限制措施的准备。同时，加强与行业协会、商会的沟通协作，共同应对挑战。',
    'shortTerm': [
      '组建专门的应对团队，包括法律、贸易、公关等专业人士',
      '评估企业现有出口美国产品的风险敞口，做好应急预案',
      '准备相关材料，以应对美方可能的信息要求',
      '与行业协会保持紧密沟通，了解最新动态'
    ],
    'midTerm': [
      '评估调整供应链策略，考虑在第三国建立生产基地的可能性',
      '分散市场风险，加大对欧洲、东南亚等其他市场的开拓力度',
      '评估提前布局海外生产基地的可行性和成本效益',
      '加强自主研发投入，减少对进口关键技术的依赖'
    ],
  };

  // 原文与译文
  final Map<String, String> originalText = {
    'content':
        '''WASHINGTON, April 26, 2025 — The Office of the United States Trade Representative (USTR) today announced the initiation of a Section 301 investigation addressing China's policies and practices related to new energy vehicles (NEVs).

The investigation will examine China's acts, policies, and practices related to NEVs in four key areas:

• Market-distorting industrial policies,'''
  };

  // 按照时间序列排列的相关事件
  final List<Map<String, dynamic>> timelineEvents = [
    {'date': '2025.04.26', 'event': '美国贸易代表办公室正式启动301调查'},
    {'date': '2025.04.15', 'event': '美国总统发表演讲，暗示将对中国电动车采取贸易行动'},
    {'date': '2025.03.30', 'event': '美国汽车制造商联盟向贸易代表办公室提交申诉'},
    {'date': '2025.02.18', 'event': '中国新能源汽车出口量创历史新高，美欧市场份额大幅提升'},
  ];

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
}
