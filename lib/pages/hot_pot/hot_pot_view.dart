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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
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
        '舆情热点',
        style: TextStyle(
          color: Color(0xFF101148),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }
  
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

  // 构建热点新闻列表
  Widget _buildHotNewsList() {
    // 从设计图中获取的新闻条目
    final List<Map<String, dynamic>> newsItems = [
      {
        'title': '美国对中国汽车启动301调查',
        'summary': '美国贸易代表办公室正式启动对中国新能源汽车产业的301调查，涉及政府补贴、知识产权和技术转让等问题。此举可能导致美国对中国汽车征收高额关税，影响中...',
        'date': '2025.04.26',
        'source': '美国贸易代表办公室'
      },
      {
        'title': '外资加速收购国内半导体设备制造商',
        'summary': '近期多家美国投资基金联合收购国内三家领先的半导体设备制造商，控制比例超过70%。专家警告，此举可能导致中国在半导体设备领域的自主研发能力受到限制...',
        'date': '2025.04.26',
        'source': '产业安全观察'
      },
      {
        'title': '美日韩组建半导体"护城河联盟"排除中国',
        'summary': '美国、日本和韩国正式建立半导体"护城河联盟"，共享技术、人才和资源，协调出口管制政策，明确排除中国参与。这将加剧全球半导体产业链的分裂，对中国芯片产...',
        'date': '2025.04.26',
        'source': '国际科技政策中心'
      },
      {
        'title': '社交媒体曝光某手机制造商产品质量问题',
        'summary': '某国产手机品牌最新款旗舰机型被曝屏幕故障问题，多个国家用户在社交媒体分享故障视频，相关话题阅读量突破5亿。公司股价应声下跌7%，多国消费者协会已发起调查...',
        'date': '2025.04.26',
        'source': '消费者权益报道'
      },
      {
        'title': '美国将5家中国量子计算企业列入管制清单',
        'summary': '某国产手机品牌最新款旗舰机型被曝屏幕故障问题，多个国家用户在社交媒体分享故障视频，相关话题阅读量突破5亿。公司股价应声下跌7%，多国消费者协会已发起调查...',
        'date': '2025.04.26',
        'source': '消费者权益报道'
      },
    ];
    
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      itemCount: newsItems.length,
      itemBuilder: (context, index) {
        final item = newsItems[index];
        return _buildNewsCard(item, index);
      },
    );
  }

  // 构建单个新闻卡片
  Widget _buildNewsCard(Map<String, dynamic> news, int index) {
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
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  news['summary'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1A1A1A),
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      news['date'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFA6A6A6),
                      ),
                    ),
                    Text(
                      news['source'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFA6A6A6),
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
