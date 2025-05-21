import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safe_app/styles/colors.dart';

import 'order_state.dart';

class OrderLogic extends GetxController {
  final OrderState state = OrderState();

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
  void loadSubscriptionData() {
    // 实际项目中应该从API获取数据
    // 这里使用了state中的示例数据
  }
  
  // 切换底部Tab
  void switchTab(int index) {
    state.currentTabIndex.value = index;
  }
  
  // 显示订阅管理弹窗
  void showSubscriptionManage() {
    Get.bottomSheet(
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
                child: Column(
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
                          ),
                          Text(
                            '点击进入订阅',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: FYColors.color_1A1A1A,
                            ),
                          ),
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
                      child: Wrap(
                        spacing: 8.w,
                        runSpacing: 10.h,
                        children: _buildAllSubscriptionItems(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black.withOpacity(0.7),
      isScrollControlled: true,
      enableDrag: true,
    );
  }
  
  // 构建我的订阅项目列表
  List<Widget> _buildMySubscriptionItems() {
    final List<Map<String, dynamic>> mySubscriptions = state.allSubscriptionCategories
        .where((item) => item['isSubscribed'] == true)
        .toList();
        
    return mySubscriptions.map((item) {
      return Container(
        width: 80.w,
        height: 46.h,
        decoration: BoxDecoration(
          color: FYColors.color_F9F9F9,
          borderRadius: BorderRadius.circular(8.r),
        ),
        alignment: Alignment.center,
        child: Text(
          item['title'],
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: FYColors.color_1A1A1A,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }).toList();
  }
  
  // 构建全部订阅项目列表
  List<Widget> _buildAllSubscriptionItems() {
    return state.allSubscriptionCategories.map((item) {
      final bool isSubscribed = item['isSubscribed'] == true;
      
      return Container(
        width: 80.w,
        height: 46.h,
        decoration: BoxDecoration(
          color: FYColors.color_F9F9F9,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSubscribed ? FYColors.color_3361FE.withOpacity(0.2) : Colors.transparent,
            width: isSubscribed ? 1 : 0,
          ),
        ),
        child: Stack(
          children: [
            // 标题
            Center(
              child: Text(
                item['title'],
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: FYColors.color_1A1A1A,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // 关注按钮（只在未订阅时显示）
            if (!isSubscribed)
              Positioned(
                top: 0,
                right: 0,
                child: InkWell(
                  onTap: () => toggleSubscription(item),
                  child: Container(
                    width: 45.w,
                    height: 18.h,
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
                        fontSize: 11.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }).toList();
  }
  
  // 切换订阅状态
  void toggleSubscription(Map<String, dynamic> item) {
    final index = state.allSubscriptionCategories.indexWhere(
      (e) => e['title'] == item['title']
    );
    
    if (index != -1) {
      state.allSubscriptionCategories[index]['isSubscribed'] = 
        !state.allSubscriptionCategories[index]['isSubscribed'];
      state.allSubscriptionCategories.refresh();
    }
  }
  
  // 显示事件订阅管理
  void showEventManage() {
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
                        event['title'], 
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      trailing: GestureDetector(
                        onTap: () => toggleEventFavorite(event),
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
                              onTap: () => toggleEventFavorite(event),
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
  }
  
  // 切换事件收藏状态
  void toggleEventFavorite(Map<String, dynamic> event) {
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
  }
  
  // 删除自定义事件
  void deleteCustomEvent(int index) {
    if (index >= 0 && index < state.customEvents.length) {
      final eventTitle = state.customEvents[index]['title'];
      state.customEvents.removeAt(index);
      state.myFavorites.removeWhere((e) => e['title'] == eventTitle);
      
      state.customEvents.refresh();
      state.myFavorites.refresh();
    }
  }
  
  // 添加自定义事件
  void addCustomEvent() {
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
  }
  
  // 获取资讯列表
  void getNewsListByEvent(String title) {
    // 导航到事件详情页面
    Get.toNamed('/order_event_detail', arguments: {'eventTitle': title});
  }

  // 切换专题收藏状态
  void toggleTopicFavorite(Map<String, dynamic> topic) {
    final index = state.topicList.indexWhere(
      (t) => t['title'] == topic['title']
    );
    
    if (index != -1) {
      state.topicList[index]['isFavorite'] = !state.topicList[index]['isFavorite'];
      state.topicList.refresh();
      
      // 更新我的关注列表
      if (state.topicList[index]['isFavorite']) {
        if (!state.myFavorites.any((e) => e['title'] == topic['title'])) {
          state.myFavorites.add({
            'title': topic['title'],
            'isFavorite': true
          });
        }
      } else {
        state.myFavorites.removeWhere((e) => e['title'] == topic['title']);
      }
      
      // 刷新列表
      state.myFavorites.refresh();
    }
  }

  // 查看专题详情
  void viewTopicDetail(Map<String, dynamic> topic) {
    // 模拟进入专题详情页面
    Get.snackbar(
      '提示', 
      '正在查看 ${topic['title']} 专题详情',
      backgroundColor: Colors.white,
      colorText: Color(0xFF1A1A1A),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
