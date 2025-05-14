import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderState {
  // 热门事件列表
  final RxList<Map<String, dynamic>> hotEvents = <Map<String, dynamic>>[].obs;
  
  // 自定义事件列表
  final RxList<Map<String, dynamic>> customEvents = <Map<String, dynamic>>[].obs;
  
  // 专题列表
  final RxList<Map<String, dynamic>> topicList = <Map<String, dynamic>>[].obs;
  
  // 我的关注列表
  final RxList<Map<String, dynamic>> myFavorites = <Map<String, dynamic>>[].obs;
  
  // 全部订阅类别
  final RxList<Map<String, dynamic>> allSubscriptionCategories = <Map<String, dynamic>>[].obs;
  
  // 当前选中的底部tab索引
  final RxInt currentTabIndex = 0.obs;
  
  // 是否显示订阅管理弹窗
  final RxBool isShowingManageDialog = false.obs;

  OrderState() {
    ///Initialize variables
    _initDemoData();
  }
  
  // 初始化演示数据
  void _initDemoData() {
    // 添加热门事件示例数据
    hotEvents.addAll([
      {
        'title': '贸易战',
        'description': '相关资讯 12 条',
        'updateTime': '更新: 2025-04-26 10:00',
        'isFavorite': true
      },
      {
        'title': '海关新规',
        'description': '相关资讯 8 条',
        'updateTime': '更新: 2025-04-25 15:30',
        'isFavorite': false
      },
      {
        'title': '地区政策',
        'description': '相关资讯 5 条',
        'updateTime': '更新: 2025-04-24 09:20',
        'isFavorite': false
      },
      {
        'title': '岛屿争端',
        'description': '相关资讯 3 条',
        'updateTime': '更新: 2025-04-23 11:45',
        'isFavorite': false
      }
    ]);
    
    // 添加专题列表示例数据
    topicList.addAll([
      {
        'title': '科技安全',
        'count': 24,
        'tags': ['科技', '安全'],
        'isFavorite': true
      },
      {
        'title': '网络安全',
        'count': 18,
        'tags': ['网络', '安全'],
        'isFavorite': true
      },
      {
        'title': '生物安全',
        'count': 12,
        'tags': ['生物', '安全'],
        'isFavorite': true
      },
      {
        'title': '粮食安全',
        'count': 15,
        'tags': ['粮食', '安全'],
        'isFavorite': true
      }
    ]);
    
    // 添加全部订阅类别示例数据
    allSubscriptionCategories.addAll([
      {
        'title': '政治安全',
        'isSubscribed': false
      },
      {
        'title': '军事安全',
        'isSubscribed': false
      },
      {
        'title': '国土安全',
        'isSubscribed': false
      },
      {
        'title': '经济安全',
        'isSubscribed': false
      },
      {
        'title': '金融安全',
        'isSubscribed': false
      },
      {
        'title': '网络安全',
        'isSubscribed': true
      },
      {
        'title': '科技安全',
        'isSubscribed': true
      },
      {
        'title': '粮食安全',
        'isSubscribed': true
      }
    ]);
    
    // 添加我的关注列表示例数据
    myFavorites.add({
      'title': '贸易战',
      'isFavorite': true
    });
    
    myFavorites.addAll(topicList.where((topic) => topic['isFavorite'] == true).toList());
  }
}
