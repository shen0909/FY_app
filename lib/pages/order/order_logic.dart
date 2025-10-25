import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/utils/diolag_utils.dart';
import 'package:safe_app/https/api_service.dart';
import '../../models/order_event_model.dart';
import '../../routers/routers.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/toast_util.dart';
import 'order_state.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

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
      DialogUtils.showLoading();
      await Future.wait([
        loadSubscriptTopicUUidList(),
        loadSubscriptEventUUidList()]);
      // 并行获取各种数据
      await Future.wait([
        loadHotEvents(),
        loadTopicList(),
        loadMySubscriptionSummary(),
      ]);
      DialogUtils.hideLoading();
    } catch (e) {
      DialogUtils.hideLoading();
      ToastUtil.showShort('加载订阅数据失败', title: '错误');
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
        // 根据订阅的UUID列表更新isFollowed状态
        _updateHotEventsFollowedStatus(2);
        // state.allSubscriptionCategories.addAll(items);
      }
    } catch (e) {
      print('加载热门事件失败: $e');
    }
  }
  
  // 更新热门事件的isFollowed状态
  void _updateHotEventsFollowedStatus(int updateEvent) {
    // 更新专题
    if(updateEvent == 1){
      // 根据订阅的UUID列表更新isFollowed状态
      for (var topic in state.topicList) {
        topic.isFollowed = state.subscribedTopicUuids.contains(topic.uuid);
      }
      state.topicList.refresh();
    }
    // 更新事件关注
    else if (updateEvent == 2) {
      for (var event in state.hotEvents) {
        event.isFollowed = state.subscribedEventUuids.contains(event.uuid);
        event.isEvent = true;
      }
      state.hotEvents.refresh();
    }
    state.allSubscriptionCategories.refresh();
  }
  
  // 加载专题列表
  Future<void> loadTopicList() async {
    try {
      final result = await _apiService.getTopicSubscriptionList();
      if (result != null && result['执行结果'] == true) {
        state.topicList.clear();
        List<OrderEventModels> items = (result['返回数据'] as List)
            .map((item) => OrderEventModels.fromJson(item))
            .toList();
        state.topicList.addAll(items);
        // 根据订阅的UUID列表更新isFollowed状态
        for (var topic in state.topicList) {
          topic.isFollowed = state.subscribedTopicUuids.contains(topic.uuid);
          topic.isEvent = false;
        }
        state.allSubscriptionCategories.addAll(items);
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
        // 根据订阅的UUID列表更新isFollowed状态
        _updateMyFavoritesFollowedStatus();
      }
    } catch (e) {
      print('加载订阅汇总失败: $e');
    }
  }
  
  // 更新isFollowed状态
  void _updateMyFavoritesFollowedStatus() {
    for (var favorite in state.myFavorites) {
      favorite.isFollowed = state.subscribedTopicUuids.contains(favorite.uuid);
    }
    state.myFavorites.refresh();
    
    if (kDebugMode) {
      print('已更新我的关注列表的isFollowed状态');
    }
  }
  
  // 切换专题关注状态
  Future<void> toggleTopicFavorite(String topicUuid, bool isFavorite) async {
    try {
      DialogUtils.showLoading();
      final result = await _apiService.toggleTopicSubscription(subjectUuid: topicUuid, isFollow: !isFavorite);
      if(result != null && result['执行结果'] != false){
        await loadSubscriptTopicUUidList();
        _updateHotEventsFollowedStatus(1);
        state.myFavorites.clear();
        state.myFavorites.value = state.topicList.where((item) => item.isFollowed == true).toList();
      }
      DialogUtils.hideLoading();
    } catch (e) {
      DialogUtils.hideLoading();
    }
  }

  // 切换事件关注状态
  Future<void> toggleEventFavorite(String eventUid, bool isFavorite) async {
    try {
      DialogUtils.showLoading();
      final result = await _apiService.toggleEventSubscription(subjectUuid: eventUid, isFollow: !isFavorite);
      if(result != null){
        await loadSubscriptEventUUidList();
        _updateHotEventsFollowedStatus(2);
      }
      DialogUtils.hideLoading();
    } catch (e) {
      DialogUtils.hideLoading();
      Get.back();
      ToastUtil.showShort('操作失败: $e', title: '错误');
    }
  }

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
    final List<OrderEventModels> mySubscriptions = state.allSubscriptionCategories.where((item) => item.isFollowed == true).toList();
        
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
            item.name,
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
  
  // // 构建全部订阅项目列表
  // List<Widget> _buildAllSubscriptionItems() {
  //   return state.allSubscriptionCategories.map((item) {
  //     final bool isSubscribed = item.isFollowed == true;
  //     return Stack(
  //       children: [
  //         Container(
  //           width: double.infinity,
  //           padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
  //           decoration: BoxDecoration(
  //             color: FYColors.color_F9F9F9,
  //             borderRadius: BorderRadius.circular(8.r),
  //           ),
  //           child: Center(
  //             child: Text(
  //               item.name,
  //               style: TextStyle(
  //                 fontSize: 11.sp,
  //                 fontWeight: FontWeight.w500,
  //                 color: FYColors.color_1A1A1A,
  //               ),
  //               textAlign: TextAlign.center,
  //               maxLines: 2,
  //               overflow: TextOverflow.ellipsis,
  //             ),
  //           ),
  //         ),
  //         // 关注按钮（只在未订阅时显示）
  //         if (!isSubscribed)
  //           Positioned(
  //             top: 0,
  //             right: 0,
  //             child: GestureDetector(
  //               onTap: () => {},
  //               child: Container(
  //                 width: 40.w,
  //                 height: 16.h,
  //                 decoration: BoxDecoration(
  //                   color: FYColors.color_3361FE,
  //                   borderRadius: BorderRadius.only(
  //                     bottomLeft: Radius.circular(8.r),
  //                     topRight: Radius.circular(8.r),
  //                   ),
  //                 ),
  //                 alignment: Alignment.center,
  //                 child: Text(
  //                   '加关注',
  //                   style: TextStyle(
  //                     fontSize: 10.sp,
  //                     color: Colors.white,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //       ],
  //     );
  //   }).toList();
  // }
  
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
  void getNewsListByEvent(OrderEventModels models) {
    // 导航到事件详情页面
    Get.toNamed(Routers.orderEventDetail, arguments: {'is_event': true, 'models': models });
  }

  // 查看专题详情
  void viewTopicDetail(OrderEventModels topic) {
    // 模拟进入专题详情页面
    Get.toNamed(Routers.orderEventDetail, arguments: {'is_event': false, 'models': topic });
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
        final bool isSubscribed = item.isFollowed == true;
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
                  item.name,
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
                  onTap: () {
                    if(item.isEvent) {
                      toggleEventFavorite(item.uuid, item.isFollowed);
                    } else {
                      toggleTopicFavorite(item.uuid, item.isFollowed);
                    }
                  },
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

  Future<void> loadSubscriptTopicUUidList() async {
    final result = await _apiService.getSubscriptionTopic();
    if (result != null) {
      final returnData = result['返回数据'] as Map<String, dynamic>?;
      if (returnData != null && returnData['subject_uuid'] != null) {
        final List<dynamic> subscribedUuids = returnData['subject_uuid'] as List<dynamic>;
        
        // 清空并保存订阅的UUID列表
        state.subscribedTopicUuids.clear();
        state.subscribedTopicUuids.addAll(
          subscribedUuids.map((uuid) => uuid.toString()).toList()
        );
        
        if (kDebugMode) {
          print('已保存订阅的UUID列表，数量: ${state.subscribedTopicUuids.length}');
          print('订阅的UUID: ${state.subscribedTopicUuids}');
        }
      }
    }
  }

  Future<void> loadSubscriptEventUUidList() async {
    final result = await _apiService.getSubscriptionEvent();
    if (result != null) {
      // 清空并保存订阅的UUID列表
      List<String> eventUUidList = (result['返回数据'] as List).map((item) => item.toString()).toList();
      state.subscribedEventUuids.clear();
      state.subscribedEventUuids.addAll(eventUUidList);
      if (kDebugMode) {
        print('已保存订阅的UUID列表，数量: ${state.subscribedTopicUuids.length}');
        print('订阅的Event UUID: ${state.subscribedTopicUuids}');
      }
    }
  }
}
