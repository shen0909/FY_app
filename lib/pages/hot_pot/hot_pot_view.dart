import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/image_resource.dart';
import 'package:safe_app/utils/dialog_utils.dart';
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
              _buildSearchBar(),
              Expanded(
                child: _buildHotNewsList(),
              ),
            ],
          ),
          // 筛选选项浮层
          Positioned(
            top: 36.h,
            left: 0,
            right: 0,
            child: Obx(() => 
              state.showFilterOptions.value 
                ? _buildFilterOptionsOverlay() 
                : const SizedBox.shrink()
            ),
          ),
        ],
      ),
    );
  }

  // 构建筛选工具栏
  Widget _buildFilterBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, ),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildFilterOption("类型", state.selectedNewsType.value),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildFilterOption("地区", state.selectedRegion.value),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildFilterOption("时间", state.timeRangeNames[state.selectedTimeRange.value] ?? state.selectedTimeRange.value),
          ),
          SizedBox(width: 9.w),
          GestureDetector(
            onTap: () {
              state.activeTabIndex.value = 3; // 设置为日期选择模式
              state.toggleFilterOptions();
            },
            child: Image.asset(FYImages.calendar_black, width: 24.w, height: 24.w),
          )
        ],
      ),
    );
  }

  // 构建搜索栏
  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: Colors.white,
      child: Container(
        height: 36.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE6E6E6)),
        ),
        child: TextField(
          onChanged: (value) => logic.setSearchKeyword(value),
          onSubmitted: (value) {
            // 显示建设中提示
            DialogUtils.showUnderConstructionDialog();
            // 注释掉原有逻辑
            // logic.applyFilters();
          },
          decoration: InputDecoration(
            hintText: '搜索关键词',
            hintStyle: TextStyle(
              fontSize: 14,
              color: Color(0xFFA6A6A6),
            ),
            prefixIcon: GestureDetector(
              onTap: () {
                // 显示建设中提示
                DialogUtils.showUnderConstructionDialog();
              },
              child: Icon(Icons.search, size: 20, color: Color(0xFF3A3A3A)),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 9.h),
          ),
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
    );
  }

  // 构建单个筛选选项
  Widget _buildFilterOption(String title, String selectedValue) {
    return InkWell(
      onTap: () {
        switch (title) {
          case "类型":
            state.activeTabIndex.value = 0;
            state.toggleFilterOptions();
            break;
          case "地区":
            state.activeTabIndex.value = 1;
            state.toggleFilterOptions();
            break;
          case "时间":
            state.activeTabIndex.value = 2;
            state.toggleFilterOptions();
            break;
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
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

  // 构建筛选选项浮层
  Widget _buildFilterOptionsOverlay() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 根据当前选择的筛选类型显示不同的选项
              if (state.activeTabIndex.value == 0)
                _buildNewsTypeFilterOptions()
              else if (state.activeTabIndex.value == 1)
                _buildRegionFilterOptions()
              else if (state.activeTabIndex.value == 2)
                _buildTimeFilterOptions()
              else if (state.activeTabIndex.value == 3)
                _buildDateRangeSelector(),
                
              // 分割线
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => logic.showFilterOptions(),
          child: Container(
            width: double.infinity,
            height: 1000.h, // 足够大的高度覆盖剩余屏幕
            color: Colors.black.withOpacity(0.4),
          ),
        ),
      ],
    );
  }

  // 构建新闻类型筛选选项
  Widget _buildNewsTypeFilterOptions() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: state.newsTypes.map((type) => 
          _buildTypeItem(type, state.selectedNewsType.value == type)
        ).toList(),
      ),
    );
  }

  // 构建地区筛选选项
  Widget _buildRegionFilterOptions() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: state.regionList.map((region) {
          final regionName = region["region"] as String;
          return _buildTypeItem(regionName, state.selectedRegion.value == regionName);
        }).toList(),
      ),
    );
  }

  // 构建时间筛选选项
  Widget _buildTimeFilterOptions() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: state.timeRanges.map((timeRange) {
          final displayName = state.timeRangeNames[timeRange] ?? timeRange;
          return _buildTypeItem(displayName, state.selectedTimeRange.value == timeRange);
        }).toList(),
      ),
    );
  }
  
  // 构建日期范围选择器
  Widget _buildDateRangeSelector() {
    return Obx(() => Container(
      padding: EdgeInsets.all(10.w),
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => logic.selectDate(Get.context!, true),
              child: Container(
                height: 32.h,
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        logic.formatDate(state.startDate.value),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const Spacer(),
                      Image.asset(
                        FYImages.calendar_black,
                        width: 24.w,
                        height: 24.w,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            "至",
            style: TextStyle(
              fontSize: 12.sp,
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: GestureDetector(
              onTap: () => logic.selectDate(Get.context!, false),
              child: Container(
                height: 32.h,
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      logic.formatDate(state.endDate.value),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const Spacer(),
                    Image.asset(
                      FYImages.calendar_black,
                      width: 24.w,
                      height: 24.w,
                      fit: BoxFit.contain,
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 11.w),
          GestureDetector(
            onTap: () => logic.applyFilters(),
            child: Container(
              width: 56.w,
              height: 32.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                color: Color(0xFF3361FE),
              ),
              child: Center(
                child: Text(
                  "应用",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  // 构建单个新闻卡片
  Widget _buildNewsCard(NewsItem news, int index) {
    return Container(
      margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 10.h),
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

  // 构建单个类型选项
  Widget _buildTypeItem(String type, bool isSelected) {
    double itemWidth = 80.w;
    String displayText = type.length > 4 ? type.substring(0, 4) : type;
    
    return GestureDetector(
      onTap: () {
        // 根据当前活跃标签类型调用不同的选择方法
        switch (state.activeTabIndex.value) {
          case 0: // 新闻类型
            logic.selectNewsType(type);
            logic.showFilterOptions(); // 选择后自动关闭弹窗
            logic.applyFilters(); // 选择后立即应用筛选
            break;
          case 1: // 地区
            logic.selectRegion(type);
            logic.showFilterOptions(); // 选择后自动关闭弹窗
            logic.applyFilters(); // 选择后立即应用筛选
            break;
          case 2: // 时间
            // 对于时间，需要将显示名称转回实际值
            final actualTimeValue = state.timeRanges.firstWhere(
              (timeRange) => (state.timeRangeNames[timeRange] ?? timeRange) == type,
              orElse: () => type
            );
            logic.selectTimeRange(actualTimeValue);
            logic.showFilterOptions(); // 选择后自动关闭弹窗
            logic.applyFilters(); // 选择后立即应用筛选
            break;
        }
      },
      child: Container(
        width: itemWidth,
        height: 32.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF3361FE) : Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          displayText,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: isSelected ? Colors.white : Color(0xFF1A1A1A),
          ),
        ),
      ),
    );
  }

  // 构建应用按钮
  Widget _buildApplyButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: ElevatedButton(
        onPressed: () => logic.applyFilters(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: EdgeInsets.symmetric(vertical: 12.h),
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
    );
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
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              FYImages.blank_page,
              width: 120.w,
              height: 120.w,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 16.w),
            Text('暂无数据'),
          ],
        );
      }
      
      // 显示列表
      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          // 检测是否滚动到底部
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            // 触发加载更多
            if (state.hasMoreData.value && !state.isLoadingMore.value) {
              logic.loadMore();
            }
          }
          return true;
        },
        child: ListView.builder(
          padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
          itemCount: state.newsList.length + (state.hasMoreData.value ? 1 : 0),
          itemBuilder: (context, index) {
            // 如果是最后一项且还有更多数据，显示加载中
            if (index == state.newsList.length) {
              return Obx(() => state.isLoadingMore.value
                ? Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  )
                : Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    alignment: Alignment.center,
                    child: Text('上拉加载更多', style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    )),
                  )
              );
            }
            return _buildNewsCard(state.newsList[index], index);
          },
        ),
      );
    });
  }
}
