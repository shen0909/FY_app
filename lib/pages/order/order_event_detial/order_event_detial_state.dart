import 'package:get/get.dart';

// 报告生成状态枚举
enum ReportGenerationStatus {
  none,        // 未生成
  generating,  // 生成中
  success,     // 生成成功
  failed       // 生成失败
}

class OrderEventDetialState {
  // 事件标题
  final RxString eventTitle = ''.obs;
  
  // 事件日期
  final RxString eventDate = ''.obs;
  
  // 事件UUID
  final RxString eventUuid = ''.obs;
  
  // 事件查看数
  final RxInt viewCount = 0.obs;
  
  // 事件关注数
  final RxInt followCount = 0.obs;
  
  // 是否已关注
  final RxBool isFollowed = false.obs;
  
  // 事件描述
  final RxString eventDescription = ''.obs;
  
  // 事件标签
  final RxList<String> eventTags = <String>[].obs;
  
  // 最新动态列表
  final RxList<Map<String, dynamic>> latestUpdates = <Map<String, dynamic>>[].obs;
  
  // 是否处于批量选择模式
  RxBool isBatchCheck = false.obs;
  
  // 已选中的项目索引列表
  final RxList<int> selectedItems = <int>[].obs;
  
  // 已选中的项目数量
  RxInt get selectedCount => selectedItems.length.obs;

  // 是否正在生成报告
  RxBool isGeneratingReport = false.obs;
  
  // 报告生成状态
  Rx<ReportGenerationStatus> reportGenerationStatus = ReportGenerationStatus.none.obs;
  
  // 报告信息
  RxMap<String, dynamic> reportInfo = <String, dynamic>{}.obs;

  OrderEventDetialState() {
    ///初始化变量
  }
}
