import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/utils/diolag_utils.dart';
import 'package:safe_app/https/api_service.dart';

import '../../models/order_event_model.dart';
import 'order_state.dart';

class OrderLogic extends GetxController {
  final OrderState state = OrderState();
  final ApiService _apiService = ApiService();

  @override
  void onReady() {
    super.onReady();
    // 加载数据
    loadSubscriptionData();
  }

  @override
  void onClose() {
    super.onClose();
  }
  
  // 加载订阅数据
  Future<void> loadSubscriptionData() async {
    try {
      // 显示加载状态
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      
      // 并行获取各种数据
      await Future.wait([
        loadHotEvents(),
        loadTopicList(),
        loadMySubscriptionSummary(),
      ]);
      
      // 关闭加载对话框
      Get.back();
    } catch (e) {
      Get.back(); // 关闭加载对话框
      Get.snackbar(
        '错误', 
        '加载订阅数据失败: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  // 加载热门事件
  Future<void> loadHotEvents() async {
    try {
      final result = await _apiService.getHotEventsList(
        currentPage: 1,
        pageSize: 20,
      );
      
      if (result != null && result['执行结果'] == true) {
        state.hotEvents.clear();
        List<OrderEventModels> items = (result['返回数据'] as List)
            .map((item) => OrderEventModels.fromJson(item))
            .toList();
        state.hotEvents.addAll(items);
      }
    } catch (e) {
      print('加载热门事件失败: $e');
    }
  }
  
  // 加载专题列表
  Future<void> loadTopicList() async {
    try {
      final result = await _apiService.getTopicSubscriptionList(
        currentPage: 1,
        pageSize: 20,
        isActive: true,
      );
      
      if (result != null && result['执行结果'] == true) {
        state.topicList.clear();
        List<OrderEventModels> items = (result['返回数据'] as List)
            .map((item) => OrderEventModels.fromJson(item))
            .toList();
        state.topicList.addAll(items);
      }
    } catch (e) {
      print('加载专题列表失败: $e');
    }
  }
  
  // 加载我的订阅汇总
  Future<void> loadMySubscriptionSummary() async {
    try {
      // 加载专题订阅
      final result = await _apiService.getMySubscriptionSummary();
      
      if (result != null && result['执行结果'] == true) {
        // 更新我的关注列表
        state.myFavorites.clear();
        List<OrderEventModels> items = (result['返回数据'] as List)
            .map((item) => OrderEventModels.fromJson(item))
            .toList();
        // 添加关注的事件
        state.myFavorites.addAll(items);
      }
    } catch (e) {
      print('加载订阅汇总失败: $e');
    }
  }
  
  // 切换事件关注状态（新API版本）
  Future<void> toggleEventFavorite(String eventUuid, bool isFavorite) async {
    // try {
    //   if (isFavorite) {
    //     // 取消关注
    //     final result = await _apiService.deleteEventSubscription(eventUuid);
    //     if (result != null && result['执行结果'] == true) {
    //       // 更新本地状态
    //       final index = state.hotEvents.indexWhere((event) => event.uuid == eventUuid);
    //       if (index != -1) {
    //         state.hotEvents[index] = false;
    //       }
    //
    //       // 从我的关注中移除
    //       state.myFavorites.removeWhere((item) => item['uuid'] == eventUuid);
    //
    //       Get.snackbar('成功', '已取消关注该事件');
    //     }
    //   } else {
    //     // 添加关注
    //     final event = state.hotEvents.firstWhere((e) => e.uuid == eventUuid);
    //     final result = await _apiService.addEventSubscription(
    //       eventName: event.name,
    //       eventDescription: event.description,
    //       keywords: event.keyword,
    //       tags: event['tags'] ?? [],
    //       eventType: event['eventType'] ?? '',
    //     );
    //
    //     if (result != null && result['执行结果'] == true) {
    //       // 更新本地状态
    //       final index = state.hotEvents.indexWhere((e) => e['uuid'] == eventUuid);
    //       if (index != -1) {
    //         state.hotEvents[index]['isFavorite'] = true;
    //       }
    //
    //       // 添加到我的关注
    //       state.myFavorites.add({
    //         'uuid': eventUuid,
    //         'title': event['title'],
    //         'description': event['description'],
    //         'updateTime': event['updateTime'],
    //         'isFavorite': true,
    //         'type': 'event',
    //       });
    //
    //       Get.snackbar('成功', '已关注该事件');
    //     }
    //   }
    // } catch (e) {
    //   Get.snackbar('错误', '操作失败: $e');
    // }
  }
  
  // 切换专题关注状态
  Future<void> toggleTopicFavorite(String topicUuid, bool isFavorite) async {
    try {
      final result = await _apiService.topicSubscription(subjectUuid: topicUuid,isFollow: true);

      /*if (isFavorite) {
        // 取消关注
        final result = await _apiService.deleteTopicSubscription(topicUuid);
        if (result != null && result['执行结果'] == true) {
          // // 更新本地状态
          // final index = state.topicList.indexWhere((topic) => topic['uuid'] == topicUuid);
          // if (index != -1) {
          //   state.topicList[index]['isFavorite'] = false;
          // }
          //
          // // 从我的关注中移除
          // state.myFavorites.removeWhere((item) => item['uuid'] == topicUuid);

          Get.snackbar('成功', '已取消关注该专题');
        }
      } else {
        // 添加关注
        final topic = state.topicList.firstWhere((t) => t['uuid'] == topicUuid);
        final result = await _apiService.topicSubscription(
          topicName: topic['title'],
          topicDescription: topic['description'] ?? '',
          keywords: topic['tags'] ?? [],
          tags: topic['tags'] ?? [],
        );

        if (result != null && result['执行结果'] == true) {
          // 更新本地状态
          final index = state.topicList.indexWhere((t) => t['uuid'] == topicUuid);
          if (index != -1) {
            state.topicList[index]['isFavorite'] = true;
          }

          // 添加到我的关注
          state.myFavorites.add({
            'uuid': topicUuid,
            'title': topic['title'],
            'count': topic['count'],
            'tags': topic['tags'],
            'isFavorite': true,
            'type': 'topic',
            'isTopic': true,
          });

          Get.snackbar('成功', '已关注该专题');
        }
      }*/
    } catch (e) {
      Get.snackbar('错误', '操作失败: $e');
    }
  }
  
  // // 新增专题订阅
  // Future<void> addNewTopicSubscription({
  //   required String topicName,
  //   required String topicDescription,
  //   List<String>? keywords,
  //   List<String>? tags,
  // }) async {
  //   try {
  //     final result = await _apiService.topicSubscription(
  //       topicName: topicName,
  //       topicDescription: topicDescription,
  //       keywords: keywords ?? [],
  //       tags: tags ?? [],
  //     );
  //
  //     if (result != null && result['执行结果'] == true) {
  //       Get.snackbar('成功', '专题订阅创建成功');
  //       // 重新加载数据
  //       await loadTopicList();
  //     } else {
  //       Get.snackbar('错误', '创建专题订阅失败');
  //     }
  //   } catch (e) {
  //     Get.snackbar('错误', '创建专题订阅失败: $e');
  //   }
  // }
  
  // 新增事件订阅
  Future<void> addNewEventSubscription({
    required String eventName,
    required String eventDescription,
    List<String>? keywords,
    List<String>? tags,
    String? eventType,
  }) async {
    try {
      final result = await _apiService.addEventSubscription(
        eventName: eventName,
        eventDescription: eventDescription,
        keywords: keywords ?? [],
        tags: tags ?? [],
        eventType: eventType ?? '',
      );
      
      if (result != null && result['执行结果'] == true) {
        Get.snackbar('成功', '事件订阅创建成功');
        // 重新加载数据
        await loadHotEvents();
      } else {
        Get.snackbar('错误', '创建事件订阅失败');
      }
    } catch (e) {
      Get.snackbar('错误', '创建事件订阅失败: $e');
    }
  }
  
  // 删除订阅项目
  // Future<void> deleteSubscriptionItem(String uuid, String type) async {
  //   try {
  //     bool success = false;
  //
  //     if (type == 'event') {
  //       final result = await _apiService.deleteEventSubscription(uuid);
  //       success = result != null && result['执行结果'] == true;
  //     } else if (type == 'topic') {
  //       final result = await _apiService.deleteTopicSubscription(uuid);
  //       success = result != null && result['执行结果'] == true;
  //     }
  //
  //     if (success) {
  //       // 从我的关注中移除
  //       state.myFavorites.removeWhere((item) => item['uuid'] == uuid);
  //       Get.snackbar('成功', '已删除订阅');
  //     } else {
  //       Get.snackbar('错误', '删除订阅失败');
  //     }
  //   } catch (e) {
  //     Get.snackbar('错误', '删除订阅失败: $e');
  //   }
  // }
  
  // 批量删除订阅
  // Future<void> batchDeleteSubscriptions(List<String> uuids, String type) async {
  //   try {
  //     bool success = false;
  //
  //     if (type == 'event') {
  //       final result = await _apiService.batchDeleteEventSubscriptions(uuids);
  //       success = result != null && result['执行结果'] == true;
  //     } else if (type == 'topic') {
  //       final result = await _apiService.batchDeleteTopicSubscriptions(uuids);
  //       success = result != null && result['执行结果'] == true;
  //     }
  //
  //     if (success) {
  //       // 从我的关注中移除选中的项目
  //       for (String uuid in uuids) {
  //         state.myFavorites.removeWhere((item) => item['uuid'] == uuid);
  //       }
  //       Get.snackbar('成功', '批量删除成功');
  //     } else {
  //       Get.snackbar('错误', '批量删除失败');
  //     }
  //   } catch (e) {
  //     Get.snackbar('错误', '批量删除失败: $e');
  //   }
  // }
  
  // 切换底部Tab
  void switchTab(int index) {
    state.currentTabIndex.value = index;
  }
  
  // 显示订阅管理弹窗
  void showSubscriptionManage() {
    FYDialogUtils.showBottomSheet(
      Container(
        height: 500.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部标题栏
            Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '订阅管理',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: FYColors.color_1A1A1A,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: FYColors.color_1A1A1A),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 我的订阅部分
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '我的订阅',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: FYColors.color_1A1A1A,
                            ),
                          )
                        ],
                      ),
                    ),

                    // 我的订阅内容
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Wrap(
                        spacing: 8.w,
                        runSpacing: 10.h,
                        children: _buildMySubscriptionItems(),
                      ),
                    ),

                    // 全部订阅部分
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '全部订阅',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: FYColors.color_1A1A1A,
                            ),
                          ),
                          Text(
                            '点击添加订阅',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: FYColors.color_1A1A1A,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 全部订阅内容
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 50.h),
                      child: _buildAllSubscriptionGrid(),
                    ),
                  ],
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建我的订阅项目列表
  List<Widget> _buildMySubscriptionItems() {
    final List<Map<String, dynamic>> mySubscriptions = state.allSubscriptionCategories
        .where((item) => item['isSubscribed'] == true)
        .toList();
        
    return mySubscriptions.map((item) {
      return IntrinsicWidth(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
          decoration: BoxDecoration(
            color: FYColors.color_F9F9F9,
            borderRadius: BorderRadius.circular(8.r),
          ),
          alignment: Alignment.center,
          child: Text(
            item['title'],
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: FYColors.color_1A1A1A,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }).toList();
  }
  
  // 构建全部订阅项目列表
  List<Widget> _buildAllSubscriptionItems() {
    return state.allSubscriptionCategories.map((item) {
      final bool isSubscribed = item['isSubscribed'] == true;
      return Stack(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
            decoration: BoxDecoration(
              color: FYColors.color_F9F9F9,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                item['title'],
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: FYColors.color_1A1A1A,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // 关注按钮（只在未订阅时显示）
          if (!isSubscribed)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => toggleSubscription(item),
                child: Container(
                  width: 40.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: FYColors.color_3361FE,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8.r),
                      topRight: Radius.circular(8.r),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '加关注',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }).toList();
  }
  
  // 切换订阅状态
  void toggleSubscription(Map<String, dynamic> item) {
    print('点击了加关注按钮，项目: ${item['title']}');
    final index = state.allSubscriptionCategories.indexWhere(
      (e) => e['title'] == item['title']
    );
    
    if (index != -1) {
      final oldStatus = state.allSubscriptionCategories[index]['isSubscribed'];
      state.allSubscriptionCategories[index]['isSubscribed'] = !oldStatus;
      state.allSubscriptionCategories.refresh();
    }
  }
  
  // 显示事件订阅管理
  /*void showEventManage() {
    Get.dialog(
      AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '事件订阅管理',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Get.back(),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Container(
          width: double.maxFinite,
          height: Get.height * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '热门事件', 
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: state.hotEvents.length,
                  itemBuilder: (context, index) {
                    final event = state.hotEvents[index];
                    return ListTile(
                      title: Text(
                        event.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      *//*trailing: GestureDetector(
                        onTap: () => toggleEventFavorite(event['uuid'], event['isFavorite']),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: event['isFavorite'] 
                                ? Color(0x333361FE) 
                                : Color(0xFF3361FE),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            event['isFavorite'] ? '已关注' : '加关注',
                            style: TextStyle(
                              fontSize: 12,
                              color: event['isFavorite'] ? Color(0xFF3361FE) : Colors.white,
                            ),
                          ),
                        ),
                      ),*//*
                    );
                  },
                ),
              ),
              const Divider(),
              const Text(
                '自定义事件', 
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: GestureDetector(
                  onTap: () => addCustomEvent(),
                  child: Row(
                    children: const [
                      Icon(Icons.add_circle_outline, color: Color(0xFF3361FE)),
                      SizedBox(width: 5),
                      Text(
                        '添加自定义事件', 
                        style: TextStyle(
                          color: Color(0xFF3361FE),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.customEvents.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.customEvents.length,
                    itemBuilder: (context, index) {
                      final event = state.customEvents[index];
                      return ListTile(
                        title: Text(
                          event['title'], 
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => toggleEventFavorite(event['uuid'], event['isFavorite']),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: event['isFavorite'] 
                                      ? Color(0x333361FE) 
                                      : Color(0xFF3361FE),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  event['isFavorite'] ? '已关注' : '加关注',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: event['isFavorite'] ? Color(0xFF3361FE) : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.grey),
                              onPressed: () => deleteCustomEvent(index),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }*/
  
  // 切换事件收藏状态（旧版本，兼容UI调用）
 /* void toggleEventFavoriteLegacy(Map<String, dynamic> event) {
    // 如果有uuid，使用新的API方法
    if (event['uuid'] != null) {
      final bool isFavorite = event['isFavorite'] ?? false;
      toggleEventFavorite(event['uuid'], isFavorite);
      return;
    }
    
    // 否则使用旧的本地状态切换逻辑
    final index = state.hotEvents.indexWhere(
      (e) => e['title'] == event['title']
    );
    
    if (index != -1) {
      state.hotEvents[index]['isFavorite'] = !state.hotEvents[index]['isFavorite'];
      state.hotEvents.refresh();
      
      // 更新我的关注列表
      if (state.hotEvents[index]['isFavorite']) {
        if (!state.myFavorites.any((e) => e['title'] == event['title'])) {
          state.myFavorites.add({
            'title': event['title'],
            'isFavorite': true
          });
        }
      } else {
        state.myFavorites.removeWhere((e) => e['title'] == event['title']);
      }
    } else {
      // 检查自定义事件
      final customIndex = state.customEvents.indexWhere(
        (e) => e['title'] == event['title']
      );
      
      if (customIndex != -1) {
        state.customEvents[customIndex]['isFavorite'] = !state.customEvents[customIndex]['isFavorite'];
        state.customEvents.refresh();
        
        // 更新我的关注列表
        if (state.customEvents[customIndex]['isFavorite']) {
          if (!state.myFavorites.any((e) => e['title'] == event['title'])) {
            state.myFavorites.add({
              'title': event['title'],
              'isFavorite': true
            });
          }
        } else {
          state.myFavorites.removeWhere((e) => e['title'] == event['title']);
        }
      }
    }
    
    // 刷新列表
    state.myFavorites.refresh();
  }*/
  
  // 删除自定义事件
  /*void deleteCustomEvent(int index) {
    if (index >= 0 && index < state.customEvents.length) {
      final eventTitle = state.customEvents[index].name;
      state.customEvents.removeAt(index);
      state.myFavorites.removeWhere((e) => e['title'] == eventTitle);
      
      state.customEvents.refresh();
      state.myFavorites.refresh();
    }
  }*/
  
  // 添加自定义事件
  /*void addCustomEvent() {
    final TextEditingController controller = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Text(
          '添加自定义事件',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '输入事件名称',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              '取消',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                state.customEvents.add({
                  'title': controller.text,
                  'description': '暂无相关资讯',
                  'updateTime': '更新: ${DateTime.now().toString().substring(0, 16)}',
                  'isFavorite': true
                });
                
                state.myFavorites.add({
                  'title': controller.text,
                  'isFavorite': true
                });
                
                Get.back();
              }
            },
            child: const Text(
              '确定',
              style: TextStyle(
                color: Color(0xFF3361FE),
              ),
            ),
          ),
        ],
      ),
    );
  }*/
  
  // 获取资讯列表
  void getNewsListByEvent(String title) {
    // 导航到事件详情页面
    Get.toNamed('/order_event_detail', arguments: {'eventTitle': title});
  }

  // 切换专题收藏状态（旧版本，兼容UI调用）
  void toggleTopicFavoriteLegacy(OrderEventModels topic) {
    // 如果有uuid，使用新的API方法
    // final bool isFavorite = topic['isFavorite'] ?? false;
    // toggleTopicFavorite(topic['uuid'], isFavorite);
    // return;
    }

  // 查看专题详情
  void viewTopicDetail(OrderEventModels topic) {
    // 模拟进入专题详情页面
    Get.snackbar(
      '提示', 
      '正在查看 ${topic.name} 专题详情',
      backgroundColor: Colors.white,
      colorText: Color(0xFF1A1A1A),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // 构建全部订阅内容网格
  Widget _buildAllSubscriptionGrid() {
    // 计算每个item的合理高度
    final screenWidth = Get.width;
    final itemWidth = (screenWidth - 32.w - (3 * 8.w)) / 4; // 减去左右padding和间距
    final itemHeight = 45.h; // 固定高度，可根据需要调整
    final aspectRatio = itemWidth / itemHeight;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: aspectRatio, // 使用动态计算的宽高比
      ),
      itemCount: state.allSubscriptionCategories.length,
      itemBuilder: (context, index) {
        final item = state.allSubscriptionCategories[index];
        final bool isSubscribed = item['isSubscribed'] == true;
        return Stack(
          children: [
            Container(
              width: double.infinity,
              height: itemHeight, // 设置固定高度
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
              decoration: BoxDecoration(
                color: FYColors.color_F9F9F9,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(
                  item['title'],
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: FYColors.color_1A1A1A,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // 关注按钮（只在未订阅时显示）
            if (!isSubscribed)
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => toggleSubscription(item),
                  child: Container(
                    width: 40.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: FYColors.color_3361FE,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8.r),
                        topRight: Radius.circular(8.r),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '加关注',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
