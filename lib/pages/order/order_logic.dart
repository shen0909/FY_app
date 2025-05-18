import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    Get.dialog(
      AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '订阅管理',
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
          height: Get.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '我的订阅', 
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              _buildSubscriptionList(isMySubscription: true),
              const SizedBox(height: 20),
              const Text(
                '全部订阅', 
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              _buildSubscriptionList(isMySubscription: false),
            ],
          ),
        ),
      ),
    );
  }
  
  // 构建订阅列表部件
  Widget _buildSubscriptionList({required bool isMySubscription}) {
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 2.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: isMySubscription 
            ? state.allSubscriptionCategories.where((e) => e['isSubscribed'] == true).length
            : state.allSubscriptionCategories.length,
        itemBuilder: (context, index) {
          final List<Map<String, dynamic>> data = isMySubscription
              ? state.allSubscriptionCategories.where((e) => e['isSubscribed'] == true).toList()
              : state.allSubscriptionCategories;
          
          if (index >= data.length) return const SizedBox();
          
          final item = data[index];
          
          return GestureDetector(
            onTap: () => toggleSubscription(item),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              decoration: BoxDecoration(
                border: Border.all(
                  color: item['isSubscribed'] ? Color(0xFF3361FE) : Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item['title'],
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: item['isSubscribed'] ? Color(0xFF3361FE) : Colors.black87,
                      ),
                    ),
                  ),
                  if (!isMySubscription || index >= 4)
                    Icon(
                      item['isSubscribed'] ? Icons.check : Icons.add,
                      size: 16,
                      color: item['isSubscribed'] ? Color(0xFF3361FE) : Colors.grey,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
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
    // 模拟进入资讯列表页面
    Get.snackbar(
      '提示', 
      '正在查看 $title 相关资讯',
      backgroundColor: Colors.white,
      colorText: Color(0xFF1A1A1A),
      snackPosition: SnackPosition.BOTTOM,
    );
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
