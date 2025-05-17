import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/image_resource.dart';
import 'package:safe_app/pages/hot_pot/hot_details/hot_details_logic.dart';
import 'package:safe_app/pages/hot_pot/hot_details/hot_details_state.dart';

import '../../../widgets/custom_app_bar.dart';

class HotDetailsView extends StatelessWidget {
  HotDetailsView({Key? key}) : super(key: key);

  final HotDetailsLogic logic = Get.put(HotDetailsLogic());
  final HotDetailsState state = Get.find<HotDetailsLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FYAppBar(
        title: '热点详情',
        actions: [
          GestureDetector(
            onTap: () => logic.downloadFile(),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 72.w,
              height: 32.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: FYColors.color_F5F5F5
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(FYImages.download_icon,width: 16.w,height: 16.w),
                  SizedBox(width: 4.w),
                  Text(
                    '下载',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: FYColors.color_1A1A1A,
                      fontWeight: FontWeight.w400
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  // 已迁移至FYAppBar

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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "${state.hotNews['date']} | ${state.hotNews['source']}",
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFA6A6A6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.hotNews['summary'],
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1A1A1A),
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
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF0F5FF),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const Divider(
            height: 8,
            thickness: 8,
            color: Color(0xFFF5F5F5),
          ),
          Container(
            padding: const EdgeInsets.only(top: 6, bottom: 6),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F5FF),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF3362FE)),
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
                              color: isActive ? const Color(0xFF345DFF) : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                tabs[index],
                                style: TextStyle(
                                  color: isActive ? Colors.white : const Color(0xFF3361FE),
                                  fontSize: 14,
                                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
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
          _buildAIGeneratedBanner(),
          const SizedBox(height: 16),
          const Text(
            '风险分析',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            state.riskAnalysis['content'],
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1A1A1A),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '风险点分析:',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(state.riskAnalysis['keyPoints'].length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF3361FE),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      state.riskAnalysis['keyPoints'][index],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1A1A1A),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          const Text(
            '影响范围',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          _buildImpactScopeCard(),
        ],
      ),
    );
  }

  // 构建影响范围卡片
  Widget _buildImpactScopeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '直接影响行业',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              Spacer(),
              Text(
                '间接影响行业',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildIndustryItem('新能源汽车制造', const Color(0xFFFF3B30)),
              const Spacer(),
              _buildIndustryItem('矿产资源开发', const Color(0xFFFF3B30)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildIndustryItem('汽车零部件制造', const Color(0xFFFF3B30)),
              const Spacer(),
              _buildIndustryItem('物流运输', const Color(0xFFFF3B30)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildIndustryItem('电池制造', const Color(0xFFFF9719)),
              const Spacer(),
              _buildIndustryItem('金融服务', const Color(0xFFFF9719)),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '受影响企业',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          _buildCompanyList(),
        ],
      ),
    );
  }

  // 构建行业项
  Widget _buildIndustryItem(String name, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  // 构建公司列表
  Widget _buildCompanyList() {
    final companies = [
      {'name': '比亚迪汽车', 'logo': 'https://placeholder.com/20'},
      {'name': '宁德时代', 'logo': 'https://placeholder.com/20'},
      {'name': '小鹏汽车', 'logo': 'https://placeholder.com/20'},
      {'name': '蔚来汽车', 'logo': 'https://placeholder.com/20'},
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: companies.map((company) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              // 在实际应用中，这里应该是企业的logo
              // child: Image.network(company['logo']!),
            ),
            const SizedBox(width: 8),
            Text(
              company['name']!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // 时间序列标签页
  Widget _buildTimelineTab() {
    final timelineItems = [
      {'date': '2025年4月26日', 'event': '美国贸易代表办公室正式宣布对中国新能源汽车产业启动301调查'},
      {'date': '2025年4月15日', 'event': '美国汽车制造商联盟致信美国贸易代表办公室，要求调查中国新能源汽车产业'},
      {'date': '2025年3月20日', 'event': '美国商务部发布报告，称中国新能源汽车在美国市场份额快速上升'},
      {'date': '2025年2月10日', 'event': '美国总统在国情咨文中提及要保护美国汽车产业免受"不公平竞争"'},
      {'date': '2024年12月5日', 'event': '中国新能源汽车首次在美国车展上亮相，引发美国媒体广泛关注'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAIGeneratedBanner(),
          const SizedBox(height: 16),
          const Text(
            '事件发展时间线',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeline(timelineItems.length),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(timelineItems.length, (index) {
                    final item = timelineItems[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: index < timelineItems.length - 1 ? 56 : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['date']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF345DFF),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['event']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFFA6A6A6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Text(
            '未来发展预测',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '基于历史数据分析和政策动向，我们预测此次调查将经历以下阶段：',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFA6A6A6),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeline(4),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFutureTimelineItem('2025年5-6月', '调查正式启动，美方可能要求中国企业和相关部门提供补贴、市场准入等方面的详细资料'),
                    _buildFutureTimelineItem('2025年7-9月', '初步调查结果公布，可能发布临时性措施'),
                    _buildFutureTimelineItem('2025年10-12月', '最终调查结果出炉，可能实施额外关税'),
                    _buildFutureTimelineItem('2026年初', '中美可能就相关问题展开谈判，寻求解决方案'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建时间线
  Widget _buildTimeline(int count) {
    return Column(
      children: List.generate(count, (index) {
        return Column(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF345DFF), Color(0xFF2F89F8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            if (index < count - 1)
              Container(
                width: 1,
                height: 76,
                color: const Color(0xFF326FFC),
                margin: const EdgeInsets.only(top: 2, bottom: 2),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Flex(
                      direction: Axis.vertical,
                      mainAxisSize: MainAxisSize.max,
                      children: List.generate(
                        (constraints.maxHeight / 2).floor(),
                        (index) => Container(
                          height: 1,
                          width: 1,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 1),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      }),
    );
  }

  // 构建未来时间线项
  Widget _buildFutureTimelineItem(String date, String event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF345DFF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFA6A6A6),
            ),
          ),
        ],
      ),
    );
  }

  // 决策建议标签页
  Widget _buildSuggestionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAIGeneratedBanner(),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD4E3FF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '总体策略',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  state.suggestions['strategy'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '短期措施 (1-3个月)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(state.suggestions['shortTerm'].length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF3361FE),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      state.suggestions['shortTerm'][index],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1A1A1A),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
          const Text(
            '中期措施 (3-6个月)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(state.suggestions['midTerm'].length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF3361FE),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      state.suggestions['midTerm'][index],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1A1A1A),
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
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
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
        color: const Color(0xFFF0F5FF),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Color(0xFF3361FE),
              size: 14,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '内容由AI生成，仅供参考',
            style: TextStyle(
              color: Color(0xFF3361FE),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
