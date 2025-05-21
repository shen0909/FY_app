import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/models/news_detail_data.dart';
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
              child: Image.asset(FYImages.download_icon,width: 24.w,height: 24.w,fit: BoxFit.contain,),

            ),
          ),
        ],
      ),
      body: Obx(() {
        // 加载中状态
        if (state.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // 错误状态
        if (state.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('获取数据失败：${state.errorMessage.value}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => logic.fetchNewsDetail(),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }
        
        // 数据为空状态
        if (state.newsDetail.value.isEmpty) {
          return const Center(child: Text('暂无详情数据'));
        }
        
        // 显示详情数据
        return Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        );
      }),
    );
  }

  // 构建头部信息
  Widget _buildHeader() {
    // 使用类型化的数据对象
    final NewsDetail? detail = state.newsDetailData.value;
    
    // 如果数据为空，显示空内容
    if (detail == null) {
      return const SizedBox.shrink();
    }
    
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
                  detail.newsTitle,
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
            "${detail.publishTime} | ${detail.newsMedium}",
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFA6A6A6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            detail.newsSummary,
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
    final NewsDetail? detail = state.newsDetailData.value;
    
    if (detail == null) {
      return const SizedBox.shrink();
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 风险分析内容
          Text(
            '风险分析',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.w),
          Text(
            detail.riskAnalysis,
            style: TextStyle(
              fontSize: 14.sp,
              color: FYColors.color_1A1A1A,
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.w),

          // 风险措施表格（如果有）
          if (detail.riskMeasure.isNotEmpty) ...[
            Text(
              '风险措施',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.w),
            _buildRiskMeasureTable(detail.riskMeasure),
          ],
        ],
      ),
    );
  }

  // 构建风险措施表格
  Widget _buildRiskMeasureTable(List<RiskMeasure> riskMeasures) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: riskMeasures.map<Widget>((measure) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    measure.riskScenario,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: FYColors.color_1A1A1A,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    measure.possibility,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: FYColors.color_1A1A1A,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    measure.impactLevel,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: FYColors.color_1A1A1A,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    measure.countermeasures,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: FYColors.color_1A1A1A,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // 构建时间序列标签页
  Widget _buildTimelineTab() {
    final NewsDetail? detail = state.newsDetailData.value;
    
    if (detail == null) {
      return const SizedBox.shrink();
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 相关新闻
          if (detail.relevantNews.isNotEmpty) ...[
            Text(
              '相关新闻',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16.w),
            ...detail.relevantNews.map<Widget>((news) {
              return _buildTimelineItem(
                title: news.title,
                date: news.time,
                isPast: true,
              );
            }).toList(),
          ],

          // 情势预测
          if (detail.futureProgression.isNotEmpty) ...[
            SizedBox(height: 24.w),
            Text(
              '情势预测',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16.w),
            ...detail.futureProgression.map<Widget>((future) {
              return _buildTimelineItem(
                title: future.title,
                date: future.time,
                isPast: false,
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  // 构建单个时间线项目
  Widget _buildTimelineItem({
    required String title,
    required String date,
    required bool isPast,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间点
          Container(
            width: 12.w,
            height: 12.w,
            margin: EdgeInsets.only(top: 4.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPast ? Colors.blue : Colors.grey,
            ),
          ),
          SizedBox(width: 16.w),
          // 内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: FYColors.color_1A1A1A,
                  ),
                ),
                SizedBox(height: 4.w),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: FYColors.color_A6A6A6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建决策建议标签页
  Widget _buildSuggestionsTab() {
    final NewsDetail? detail = state.newsDetailData.value;
    
    if (detail == null) {
      return const SizedBox.shrink();
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 整体策略
          Text(
            '整体策略',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.w),
          Text(
            detail.decisionSuggestion.overallStrategy,
            style: TextStyle(
              fontSize: 14.sp,
              color: FYColors.color_1A1A1A,
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.w),

          // 短期措施
          Text(
            '短期措施',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.w),
          Text(
            detail.decisionSuggestion.shortTermMeasures,
            style: TextStyle(
              fontSize: 14.sp,
              color: FYColors.color_1A1A1A,
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.w),

          // 中期措施
          Text(
            '中期措施',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.w),
          Text(
            detail.decisionSuggestion.midTermMeasures,
            style: TextStyle(
              fontSize: 14.sp,
              color: FYColors.color_1A1A1A,
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.w),

          // 长期措施
          Text(
            '长期措施',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.w),
          Text(
            detail.decisionSuggestion.longTermMeasures,
            style: TextStyle(
              fontSize: 14.sp,
              color: FYColors.color_1A1A1A,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // 构建原文与译文标签页
  Widget _buildOriginalTextTab() {
    final NewsDetail? detail = state.newsDetailData.value;
    
    if (detail == null) {
      return const SizedBox.shrink();
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 原文
          Text(
            '原文',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.w),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: FYColors.color_F5F5F5,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              detail.originContext,
              style: TextStyle(
                fontSize: 14.sp,
                color: FYColors.color_1A1A1A,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 24.w),

          // 译文
          Text(
            '译文',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.w),
          Text(
            detail.translatedContext,
            style: TextStyle(
              fontSize: 14.sp,
              color: FYColors.color_1A1A1A,
              height: 1.5,
            ),
          ),
        ],
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
