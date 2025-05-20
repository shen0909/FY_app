import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/main.dart';
import 'package:safe_app/styles/colors.dart';
import '../../widgets/custom_app_bar.dart';
import 'hot_pot_logic.dart';
import 'hot_pot_state.dart';
import 'package:safe_app/models/newslist_data.dart';

class HotPotPage extends StatelessWidget {
  HotPotPage({Key? key}) : super(key: key);

  final HotPotLogic logic = Get.put(HotPotLogic());
  final HotPotState state = Get.find<HotPotLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: FYAppBar(title: '舆情热点'),
      body: Stack(
        children: [
          Column(
            children: [
              _buildFilterBar(),
              Expanded(
                child: _buildHotNewsList(),
              ),
            ],
          ),
          _buildFilterOptions(),
        ],
      ),
    );
  }

  // 已迁移至FYAppBar

  // 构建筛选工具栏
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildFilterOption("类型", Icons.category_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFilterOption("地区", Icons.public),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFilterOption("时间", Icons.access_time),
          ),
        ],
      ),
    );
  }

  // 构建单个筛选选项
  Widget _buildFilterOption(String title, IconData icon) {
    return InkWell(
      onTap: () => logic.showFilterOptions(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Transform.rotate(
              angle: 90 * 3.14159 / 180,
              child: const Icon(
                Icons.chevron_right,
                color: Color(0xFF1A1A1A),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建筛选选项面板
  Widget _buildFilterOptions() {
    return Obx(() {
      if (!state.showFilterOptions.value) {
        return const SizedBox.shrink();
      }

      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withOpacity(0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 区域选择
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "选择区域",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: state.regions.map((region) {
                            return Obx(() {
                              final isSelected =
                                  state.selectedRegion.value == region;
                              return GestureDetector(
                                onTap: () => logic.selectRegion(region),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.blue.shade100
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    region,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.black87,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            });
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  // 时间选择
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "选择时间",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: state.timeRanges.map((timeRange) {
                            return Obx(() {
                              final isSelected =
                                  state.selectedTimeRange.value == timeRange;
                              return GestureDetector(
                                onTap: () => logic.selectTimeRange(timeRange),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.blue.shade100
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    timeRange,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.black87,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            });
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  // 按钮
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: ElevatedButton(
                      onPressed: () => logic.applyFilters(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "应用筛选",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // 构建热点新闻列表
  Widget _buildHotNewsList() {
    return Obx(() {
      // 加载中
      if (state.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      // 发生错误
      if (state.errorMessage.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('获取数据失败：${state.errorMessage.value}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => logic.getNewsList(),
                child: const Text('重试'),
              ),
            ],
          ),
        );
      }
      
      // 数据为空
      if (state.newsList.isEmpty) {
        return const Center(child: Text('暂无数据'));
      }
      
      // 显示列表
      return ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        itemCount: state.newsList.length,
        itemBuilder: (context, index) {
          return _buildNewsCard(state.newsList[index], index);
        },
      );
    });
  }

  // 构建单个新闻卡片
  Widget _buildNewsCard(NewsItem news, int index) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => logic.navigateToDetails(index),
          borderRadius: BorderRadius.circular(8.r),
          child: Padding(
            padding: EdgeInsets.only(top: 16.0.w,bottom: 12.w,left: 16.w,right: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news.newsTitle,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: FYColors.color_1A1A1A,
                  ),
                ),
                SizedBox(height: 12.w),
                Text(
                  news.newsSummary,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: FYColors.color_1A1A1A,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.w),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      news.publishTime,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: FYColors.color_A6A6A6
                      ),
                    ),
                    Text(
                      news.newsMedium,
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: FYColors.color_A6A6A6
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
