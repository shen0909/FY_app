import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'order_logic.dart';
import 'order_state.dart';

class OrderPage extends StatelessWidget {
  OrderPage({Key? key}) : super(key: key);

  final OrderLogic logic = Get.put(OrderLogic());
  final OrderState state = Get.find<OrderLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('我的订阅'),
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: () => logic.showSubscriptionManage(),
            icon: const Icon(Icons.settings_outlined),
            label: const Text('订阅管理'),
            style: TextButton.styleFrom(foregroundColor: Colors.black54),
          )
        ],
      ),
      body: Obx(() => _buildBody()),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
  
  Widget _buildBody() {
    if (state.currentTabIndex.value == 0) {
      return _buildEventSubscriptions();
    } else if (state.currentTabIndex.value == 1) {
      return _buildTopicSubscriptions();
    } else {
      return _buildMyFavorites();
    }
  }
  
  Widget _buildEventSubscriptions() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHotEventsSection(),
          _buildCustomEventsSection(),
        ],
      ),
    );
  }
  
  Widget _buildHotEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.red),
                  const SizedBox(width: 8),
                  const Text(
                    '热门事件',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' 共 ${state.hotEvents.length} 条',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.hotEvents.length,
          itemBuilder: (context, index) {
            final event = state.hotEvents[index];
            return _buildEventItem(event);
          },
        ),
      ],
    );
  }
  
  Widget _buildCustomEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '自定义事件',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => logic.showEventManage(),
                child: Row(
                  children: const [
                    Icon(Icons.edit, size: 16, color: Colors.blue),
                    SizedBox(width: 4),
                    Text(
                      '添加自定义事件',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (state.customEvents.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                '暂无自定义事件，点击右上角添加',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.customEvents.length,
            itemBuilder: (context, index) {
              final event = state.customEvents[index];
              return _buildEventItem(event);
            },
          ),
      ],
    );
  }
  
  Widget _buildEventItem(Map<String, dynamic> event) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () => logic.getNewsListByEvent(event['title']),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (event['description'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          event['description'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    if (event['updateTime'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          event['updateTime'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  event['isFavorite'] ? Icons.star : Icons.star_border,
                  color: event['isFavorite'] ? Colors.amber : Colors.grey,
                ),
                onPressed: () => logic.toggleEventFavorite(event),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTopicSubscriptions() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                const Icon(Icons.collections_bookmark, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  '专题列表',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: state.topicList.length,
              itemBuilder: (context, index) {
                final topic = state.topicList[index];
                return _buildTopicItem(topic);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTopicItem(Map<String, dynamic> topic) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '相关事件: ${topic['count']}个',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 8,
                        children: List.generate(
                          topic['tags'].length,
                          (tagIndex) => Chip(
                            label: Text(
                              topic['tags'][tagIndex],
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: Colors.grey.shade200,
                            padding: const EdgeInsets.all(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  topic['isFavorite'] ? Icons.star : Icons.star_border,
                  color: topic['isFavorite'] ? Colors.amber : Colors.grey,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMyFavorites() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                const Icon(Icons.event_note, color: Colors.amber),
                const SizedBox(width: 8),
                const Text(
                  '关注的事件',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            final favoriteEvents = state.myFavorites.where((e) => 
              !state.topicList.any((t) => t['title'] == e['title'])).toList();
            
            if (favoriteEvents.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    '暂无关注的事件',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: favoriteEvents.length,
              itemBuilder: (context, index) {
                final event = favoriteEvents[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(event['title']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.star, color: Colors.amber),
                        Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                const Icon(Icons.collections_bookmark, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  '关注的专题',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final favoriteTopics = state.topicList.where((t) => t['isFavorite'] == true).toList();
              
              if (favoriteTopics.isEmpty) {
                return const Center(
                  child: Text(
                    '暂无关注的专题',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: favoriteTopics.length,
                itemBuilder: (context, index) {
                  final topic = favoriteTopics[index];
                  return _buildTopicItem(topic);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: state.currentTabIndex.value,
      onTap: (index) => logic.switchTab(index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.event_note),
          label: '事件订阅',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.collections_bookmark),
          label: '专题订阅',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.star),
          label: '我的关注',
        ),
      ],
    );
  }
}
