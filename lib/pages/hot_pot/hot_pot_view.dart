import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'hot_pot_logic.dart';
import 'hot_pot_state.dart';

class HotPotPage extends StatelessWidget {
  HotPotPage({Key? key}) : super(key: key);

  final HotPotLogic logic = Get.put(HotPotLogic());
  final HotPotState state = Get.find<HotPotLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              _buildFilterBar(),
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: _buildTabContent(),
              ),
            ],
          ),
          _buildFilterOptions(),
        ],
      ),
    );
  }

  // 构建顶部导航栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
        onPressed: () => Get.back(),
      ),
      title: const Text(
        '热点',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.file_download_outlined, color: Colors.red),
          onPressed: () => logic.downloadFile(),
        ),
      ],
    );
  }
  
  // 构建筛选工具栏
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => logic.showFilterOptions(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.filter_list, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Obx(() => Text(
                        "地区: ${state.selectedRegion.value}",
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      )),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: () => logic.showFilterOptions(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time, color: Colors.blue, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Obx(() => Text(
                        "时间: ${state.selectedTimeRange.value}",
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      )),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () => logic.customTimeRange(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
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
            const SizedBox(height: 80), // 留出AppBar的高度
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
                              final isSelected = state.selectedRegion.value == region;
                              return GestureDetector(
                                onTap: () => logic.selectRegion(region),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    region,
                                    style: TextStyle(
                                      color: isSelected ? Colors.blue : Colors.black87,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                              final isSelected = state.selectedTimeRange.value == timeRange;
                              return GestureDetector(
                                onTap: () => logic.selectTimeRange(timeRange),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    timeRange,
                                    style: TextStyle(
                                      color: isSelected ? Colors.blue : Colors.black87,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

  // 构建头部信息
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  state.hotNews['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                state.hotNews['date'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '|',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                state.hotNews['source'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            state.hotNews['summary'],
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // 构建标签栏
  Widget _buildTabBar() {
    final tabs = ['风险分析', '时间序列', '决策建议', '原文与译文'];
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Obx(() {
        return Row(
          children: List.generate(tabs.length, (index) {
            final isActive = state.activeTabIndex.value == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => logic.changeTab(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isActive ? Colors.red : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    tabs[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isActive ? Colors.red : Colors.black54,
                      fontSize: 15,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  // 构建标签内容区域
  Widget _buildTabContent() {
    return Obx(() {
      final index = state.activeTabIndex.value;
      switch (index) {
        case 0:
          return _buildRiskAnalysisTab();
        case 1:
          return _buildTimelineTab();
        case 2:
          return _buildSuggestionsTab();
        case 3:
          return _buildOriginalTextTab();
        default:
          return _buildRiskAnalysisTab();
      }
    });
  }

  // 风险分析标签页
  Widget _buildRiskAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          state.hotNews['isAIGenerated'] ? _buildAIGeneratedBanner() : const SizedBox.shrink(),
          const SizedBox(height: 16),
          Text(
            '风险分析',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            state.riskAnalysis['content'],
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '风险点分析:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(state.riskAnalysis['keyPoints'].length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      state.riskAnalysis['keyPoints'][index],
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 时间序列标签页
  Widget _buildTimelineTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.timelineEvents.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final event = state.timelineEvents[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                if (index < state.timelineEvents.length - 1)
                  Container(
                    width: 2,
                    height: 50,
                    color: Colors.blue.shade200,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['date'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event['event'],
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // 决策建议标签页
  Widget _buildSuggestionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          state.hotNews['isAIGenerated'] ? _buildAIGeneratedBanner() : const SizedBox.shrink(),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '总体策略',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  state.suggestions['strategy'],
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '短期措施 (1-3个月)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(state.suggestions['shortTerm'].length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      state.suggestions['shortTerm'][index],
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          Text(
            '中期措施 (3-6个月)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(state.suggestions['midTerm'].length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      state.suggestions['midTerm'][index],
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 原文与译文标签页
  Widget _buildOriginalTextTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTextTabButton('原文', true),
              _buildTextTabButton('译文', false),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.originalText['content']!,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 原文/译文选项按钮
  Widget _buildTextTabButton(String title, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.red : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black54,
          fontSize: 14,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // AI生成内容提示横幅
  Widget _buildAIGeneratedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome,
            color: Colors.blue.shade700,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '内容由AI生成，仅供参考',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
