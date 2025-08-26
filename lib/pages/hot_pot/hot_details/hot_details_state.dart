import 'package:get/get.dart';
import 'package:safe_app/models/news_detail_data.dart';
import 'package:safe_app/models/news_effect_company.dart';

class HotDetailsState {
  // 加载状态
  final RxBool isLoading = false.obs;
  // 是否已成功加载过一次
  final RxBool hasLoadedOnce = false.obs;
  // 是否处于下拉刷新中
  final RxBool isRefreshing = false.obs;
  
  // 错误信息
  final RxString errorMessage = ''.obs;
  
  // 新闻ID
  final RxString newsId = ''.obs;
  
  // 详情数据
  final Rx<Map<String, dynamic>> newsDetail = Rx<Map<String, dynamic>>({});

  final List<String> translateTabs = ['原文', '译文'];

  // 类型化的详情数据对象
  final Rx<NewsDetail?> newsDetailData = Rx<NewsDetail?>(null);

  // 当前活跃标签页索引
  final RxInt activeTabIndex = 0.obs;
  final RxInt activeTranslateIndex = 0.obs;

  // 影响企业相关状态
  final RxBool isLoadingEffectCompany = false.obs;
  final RxList<EffectCompany> effectCompanyList = <EffectCompany>[].obs;
  final RxInt effectCompanyTotalCount = 0.obs;
  final RxInt effectCompanyCurrentPage = 1.obs;
  final RxInt effectCompanyPageSize = 10.obs;
  final RxBool hasMoreEffectCompany = true.obs;
  final RxString effectCompanyErrorMessage = ''.obs;

  HotDetailsState() {
    ///Initialize variables
  }
}

