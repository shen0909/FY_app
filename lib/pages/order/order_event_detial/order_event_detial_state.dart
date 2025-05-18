import 'package:get/get.dart';

class OrderEventDetialState {
  // 事件标题
  final RxString eventTitle = ''.obs;
  
  // 事件日期
  final RxString eventDate = ''.obs;
  
  // 事件查看数
  final RxInt viewCount = 0.obs;
  
  // 事件关注数
  final RxInt followCount = 0.obs;
  
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

  OrderEventDetialState() {
    ///初始化变量
  }
}
