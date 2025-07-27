import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/order_event_model.dart';

class OrderState {
  // 热门事件列表
  // final RxList<Map<String, dynamic>> hotEvents = <Map<String, dynamic>>[].obs;
  final RxList<OrderEventModels> hotEvents = <OrderEventModels>[].obs;

  // 自定义事件列表
  final RxList<OrderEventModels> customEvents = <OrderEventModels>[].obs;
  
  // 专题列表
  final RxList<OrderEventModels> topicList = <OrderEventModels>[].obs;
  
  // 我的关注列表
  // final RxList<Map<String, dynamic>> myFavorites = <Map<String, dynamic>>[].obs;
  final RxList<OrderEventModels> myFavorites = <OrderEventModels>[].obs;

  // 全部订阅类别
  final RxList<Map<String, dynamic>> allSubscriptionCategories = <Map<String, dynamic>>[].obs;

  // 当前选中的底部tab索引
  final RxInt currentTabIndex = 0.obs;
  
  // 是否显示订阅管理弹窗
  final RxBool isShowingManageDialog = false.obs;

  // 订阅的专题UUID列表
  final RxList<String> subscribedTopicUuids = <String>[].obs;
  final RxList<String> subscribedEventUuids = <String>[].obs;

  OrderState() {
    ///Initialize variables
    _initDemoData();
  }
  
  // 初始化演示数据
  void _initDemoData() {
    // 添加全部订阅类别示例数据
    // allSubscriptionCategories.addAll([
    //   {
    //     'title': '政治安全',
    //     'isSubscribed': false
    //   },
    //   {
    //     'title': '军事安全',
    //     'isSubscribed': false
    //   },
    //   {
    //     'title': '国土安全',
    //     'isSubscribed': false
    //   },
    //   {
    //     'title': '经济安全',
    //     'isSubscribed': false
    //   },
    //   {
    //     'title': '金融安全',
    //     'isSubscribed': false
    //   },
    //   {
    //     'title': '文化安全',
    //     'isSubscribed': false
    //   },
    //   {
    //     'title': '社会安全',
    //     'isSubscribed': false
    //   },
    //   {
    //     'title': '科技安全',
    //     'isSubscribed': false
    //   },
    //   {
    //     'title': '网络安全',
    //     'isSubscribed': true
    //   },
    //   {
    //     'title': '粮食安全',
    //     'isSubscribed': true
    //   },
    //   {
    //     'title': '生态安全',
    //     'isSubscribed': false
    //   },
    //   {
    //     'title': '资源安全',
    //     'isSubscribed': false
    //   },
    //   {
    //     'title': '核安全',
    //     'isSubscribed': false
    //   },
    //   {
    //     'title': '海外利益安全',
    //     'isSubscribed': false
    //   },
    //   {
    //     'title': '太空安全',
    //     'isSubscribed': false
    //   },
    //   {
    //     'title': '深海安全',
    //     'isSubscribed': false
    //   },
    //   {
    //     'title': '极地安全',
    //     'isSubscribed': false
    //   },
    //   {
    //     'title': '生物安全',
    //     'isSubscribed': false
    //   },
    //   {
    //     'title': '人工智能安全',
    //     'isSubscribed': false
    //   },
    //   {
    //     'title': '数据安全',
    //     'isSubscribed': false
    //   }
    // ]);
    
    // 添加我的关注列表示例数据，确保包含所有必要字段

    
    // 从热门事件添加完整的关注数据
    // for (var event in hotEvents) {
    //   if (event['isFavorite'] == true) {
    //     myFavorites.add({
    //       'title': event['title'],
    //       'description': event['description'] ?? '暂无相关资讯',
    //       'updateTime': event['updateTime'] ?? '暂无更新时间',
    //       'isFavorite': true
    //     });
    //   }
    // }

  }
}
