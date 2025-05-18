import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/image_resource.dart';

import '../../widgets/custom_app_bar.dart';
import 'order_logic.dart';
import 'order_state.dart';

class OrderPage extends StatelessWidget {
  OrderPage({Key? key}) : super(key: key);

  final OrderLogic logic = Get.put(OrderLogic());
  final OrderState state = Get.find<OrderLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FYColors.whiteColor,
      appBar: FYAppBar(
        title: '我的订阅',
        actions: [
          TextButton.icon(
            onPressed: () => logic.showSubscriptionManage(),
            icon: Image.asset(FYImages.oder_share, width: 20.w,
              height: 20.w,
              fit: BoxFit.contain,),
            label: Text(
              '订阅管理',
              style: TextStyle(
                  color: FYColors.color_1A1A1A,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400
              ),
            ),
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
              Text(
                '热门事件',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w400,
                  color: FYColors.color_1A1A1A,
                ),
              ),
              RichText(
                  text: TextSpan(
                      style: TextStyle(
                        color: FYColors.color_A6A6A6,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        height: 0.8,
                        leadingDistribution: TextLeadingDistribution.even,
                      ),
                      children: [
                        const TextSpan(text: '共 '),
                        TextSpan(
                          text: '${state.hotEvents.length}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: FYColors.color_3361FE,
                          ),
                        ),
                        const TextSpan(text: ' 条'),
                      ]))
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
              Text(
                '自定义事件',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
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
    final bool isFollowed = event['isFavorite'] == true;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => logic.getNewsListByEvent(event['title']),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    event['title'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => logic.toggleEventFavorite(event),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isFollowed
                            ? Color(0x333361FE)
                            : Color(0xFF3361FE),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        isFollowed ? '已关注' : '加关注',
                        style: TextStyle(
                          fontSize: 12,
                          color: isFollowed ? Color(0xFF3361FE) : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.w),
              // if (event['description'] != null)
              Row(
                children: [
                  Text(
                    event['description'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFA6A6A6),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    event['updateTime'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFA6A6A6),
                    ),
                  )
                ],
              ),
              // if (event['updateTime'] != null)
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTopicSubscriptions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16.w, bottom: 10.w),
            child: Row(
              children: [
                Image.asset(FYImages.zhuanti_choose, width: 24.w, height: 24.w),
                SizedBox(width: 8.w),
                Text(
                  '专题列表',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: FYColors.color_1A1A1A,
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
    final bool isFollowed = topic['isFavorite'] == true;
    
    return Container(
      margin: EdgeInsets.only(bottom: 10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: FYColors.color_F9F9F9,
      ),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    topic['title'],
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: FYColors.color_1A1A1A,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => logic.toggleTopicFavorite(topic),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.w),
                      decoration: BoxDecoration(
                        color: isFollowed
                            ? Color(0x333361FE)
                            : FYColors.color_3361FE,
                        borderRadius: BorderRadius.circular(14.w),
                      ),
                      child: Text(
                        isFollowed ? '已关注' : '加关注',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isFollowed ? FYColors.color_3361FE : FYColors.whiteColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.w),
              Text(
                '相关事件: ${topic['count']}个',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: FYColors.color_A6A6A6,
                  fontWeight: FontWeight.w400
                ),
              ),
              SizedBox(height: 12.w),
              Wrap(
                spacing: 8.w,
                children: List.generate(
                  topic['tags'].length,
                  (tagIndex) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.w),
                    decoration: BoxDecoration(
                      color: FYColors.color_E7E7E7,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      topic['tags'][tagIndex],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: FYColors.color_1A1A1A,
                      ),
                    ),
                  ),
                ),
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
                Icon(Icons.event_note, color: Colors.amber),
                const SizedBox(width: 8),
                const Text(
                  '关注的事件',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: Color(0xFFF9F9F9),
                  child: ListTile(
                    title: Text(
                      event['title'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
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
                Icon(Icons.collections_bookmark, color: Color(0xFF3361FE)),
                const SizedBox(width: 8),
                const Text(
                  '关注的专题',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final favoriteTopics = state.topicList.where((
                  t) => t['isFavorite'] == true).toList();

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
    return Obx(() {
      return Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: FYColors.whiteColor,
          currentIndex: state.currentTabIndex.value,
          onTap: (index) => logic.switchTab(index),
          selectedItemColor: Color(0xFF3361FE),
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12.sp,
          unselectedFontSize: 12.sp,
          iconSize: 24,
          selectedIconTheme: IconThemeData(size: 24),
          unselectedIconTheme: IconThemeData(size: 24),
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(FYImages.calendar_unchoose, width: 24, height: 24),
              activeIcon: Image.asset(FYImages.calendar, width: 24, height: 24),
              label: '事件订阅',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(FYImages.zhuanti_unchoose, width: 24, height: 24),
              activeIcon: Image.asset(FYImages.zhuanti_choose, width: 24, height: 24),
              label: '专题订阅',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(FYImages.attention_unchoose, width: 24, height: 24),
              activeIcon: Image.asset(FYImages.attention_choose, width: 24, height: 24),
              label: '我的关注',
            ),
          ],
        ),
      );
    });
  }
}
