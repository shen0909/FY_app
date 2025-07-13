import 'package:get/get.dart';
import 'package:safe_app/models/news_detail_data.dart';

class HotDetailsState {
  // 加载状态
  final RxBool isLoading = false.obs;
  
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

  HotDetailsState() {
    ///Initialize variables
  }
}

