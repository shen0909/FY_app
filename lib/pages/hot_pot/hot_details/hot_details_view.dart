import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/models/news_detail_data.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/image_resource.dart';
import 'package:safe_app/styles/text_styles.dart';
import 'package:safe_app/pages/hot_pot/hot_details/hot_details_logic.dart';
import 'package:safe_app/pages/hot_pot/hot_details/hot_details_state.dart';
import 'package:safe_app/utils/dialog_utils.dart';

import '../../../widgets/custom_app_bar.dart';

// 虚线绘制器
class DashedLinePainter extends CustomPainter {
  final Color color;
  
  DashedLinePainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    const double dashHeight = 4;
    const double dashSpace = 3;
    double startY = 0;
    
    while (startY < size.height) {
      // 绘制虚线
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
              margin: EdgeInsets.only(right: 16.w),
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
                SizedBox(height: 16.w),
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
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              _buildTabBar(),
              _buildTabContentForScrollView(), // 使用适合SingleChildScrollView的内容构建方法
            ],
          ),
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
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  detail.newsTitle,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.w),
          Text(
            "${detail.publishTime} | ${detail.newsMedium}",
            style: TextStyle(
              fontSize: 14.w,
              color: Color(0xFFA6A6A6),
            ),
          ),
          SizedBox(height: 8.w),
          Text(
            detail.newsSummary,
            style: TextStyle(
              fontSize: 14.w,
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
    return Column(
      children: [
         Divider(
          height: 8.w,
          thickness: 8.w,
          color: Color(0xFFF5F5F5),
        ),
        Container(
          padding: EdgeInsets.only(top: 6.w, bottom: 6.w),
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 17.w),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0F5FF),
                borderRadius: BorderRadius.circular(4.r),
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
                          height: 36.w,
                          decoration: BoxDecoration(
                            border: Border(right:BorderSide(color: !isActive ? Color(0xFF345DFF) : Colors.transparent)),
                            color: isActive ? const Color(0xFF345DFF) : Colors.transparent,
                            // borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              tabs[index],
                              style: TextStyle(
                                color: isActive ? Colors.white : const Color(0xFF3361FE),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
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
    );
  }

  // 为SingleChildScrollView构建标签内容
  Widget _buildTabContentForScrollView() {
    return Obx(() {
      final index = state.activeTabIndex.value;
      final NewsDetail? detail = state.newsDetailData.value;
      
      if (detail == null) {
        return const SizedBox.shrink();
      }
      
      switch (index) {
        case 0:
          if (detail.riskAnalysis.isEmpty) {
            return _buildEmptyContent();
          }
          
          return Padding(
            padding: EdgeInsets.only(top: 12.w,right: 16.w,left: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAIGeneratedBanner(),
                SizedBox(height: 24.w),
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
        case 1:
          // 检查时间序列数据是否为空
          if (detail.relevantNews.isEmpty && detail.futureProgression.isEmpty) {
            return _buildEmptyContent();
          }
          return Padding(
            padding: EdgeInsets.only(top: 12.w,right: 16.w,left: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAIGeneratedBanner(),
                SizedBox(height: 24.w),
                // 相关新闻
                if (detail.relevantNews.isNotEmpty) ...[
                  Text(
                    '事件发展时间线',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16.w),
                  ...List.generate(detail.relevantNews.length, (index) {
                    final news = detail.relevantNews[index];
                    // 转换数据格式
                    final Map<String, dynamic> itemData = {
                      'date': news.time,
                      'content': news.title,
                    };
                    return _buildTimelineItem(
                      itemData, 
                      index == detail.relevantNews.length - 1 && detail.futureProgression.isEmpty
                    );
                  }),
                ],

                // 情势预测
                if (detail.futureProgression.isNotEmpty) ...[
                  if (detail.relevantNews.isEmpty) ...[
                    Text(
                      '相关新闻',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16.w),
                  ] else ...[
                    SizedBox(height: 24.w),
                  ],
                  ...List.generate(detail.futureProgression.length, (index) {
                    final future = detail.futureProgression[index];
                    // 转换数据格式
                    final Map<String, dynamic> itemData = {
                      'date': future.time,
                      'content': future.title,
                    };
                    return _buildTimelineItem(
                      itemData, 
                      index == detail.futureProgression.length - 1
                    );
                  }),
                ],
              ],
            ),
          );
        case 2:
          // 决策建议
          // 检查决策建议内容是否为空
          if (detail.decisionSuggestion == null || 
              (detail.decisionSuggestion.overallStrategy.isEmpty &&
               detail.decisionSuggestion.shortTermMeasures.isEmpty &&
               detail.decisionSuggestion.midTermMeasures.isEmpty &&
               detail.decisionSuggestion.longTermMeasures.isEmpty)) {
            return _buildEmptyContent();
          }
          return Padding(
            padding: EdgeInsets.only(top: 12.w,right: 16.w,left: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAIGeneratedBanner(),
                SizedBox(height: 24.w),
                // 整体策略标题
                Container(
                  width: double.infinity,
                  child: Text(
                    '应对建议',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 12.w),
                // 整体策略容器
                Stack(
                  children: [
                    // 这是你主要的卡片内容
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0XFFEBEEFF), FYColors.whiteColor]),
                          borderRadius: BorderRadius.all(Radius.circular(8.r))),
                      child: Column( // 保持原来的 Column 结构
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '总体策略',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8.w),
                          Text(
                            detail.decisionSuggestion.overallStrategy,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: FYColors.color_A6A6A6,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 0, // 距离左边 0
                      top: 0, // 距离顶部 0
                      bottom: 0,
                      child: Container(
                        width: 4.w, // 蓝色条的宽度
                        decoration: BoxDecoration(
                          color: const Color(0xFF4285F4), // 蓝色
                          // 因为Positioned放在卡片内容之上，所以蓝色条的圆角也要与卡片左侧的圆角匹配
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8.r),
                            bottomLeft: Radius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.w),
                // 短期措施
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Color(0xffF9F9F9),
                    borderRadius: BorderRadius.all(Radius.circular(8.r))
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '短期措施（1-3个月）',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: detail.decisionSuggestion.shortTermMeasures
                            .map((measure) => measureItem(measure))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.w),
                // 中期措施
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                      color: Color(0xffF9F9F9),
                      borderRadius: BorderRadius.all(Radius.circular(8.r))
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '中期措施（3-6个月）',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: detail.decisionSuggestion.midTermMeasures
                            .map((measure) => measureItem(measure))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.w),
                // 长期措施
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                      color: Color(0xffF9F9F9),
                      borderRadius: BorderRadius.all(Radius.circular(8.r))
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '长期措施（6个月以上）',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: detail.decisionSuggestion.longTermMeasures
                            .map((measure) => measureItem(measure))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.w),
              ],
            ),
          );
        case 3:
          // 原文与译文
          // 检查原文与译文内容是否为空
          if (detail.originContext.isEmpty && detail.translatedContext.isEmpty) {
            return _buildEmptyContent();
          }
          return Padding(
            padding: EdgeInsets.only(top: 12.w, right: 16.w, left: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F5FF),
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(color: const Color(0xFF3362FE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(state.translateTabs.length, (index) {
                      return translateTap(index);
                    }),
                  ),
                ),
                // 显示选择的内容
                Obx(() {
                  if (state.activeTranslateIndex.value == 0) {
                    // 原文
                    return Container(
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
                            color: FYColors.color_A6A6A6,
                            height: 1.5,
                          ),
                        ),
                      );
                  } else {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: FYColors.color_F9F9F9,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        detail.translatedContext,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: FYColors.color_A6A6A6,
                          height: 1.5,
                        ),
                      ),
                    );
                  }
                }),
                SizedBox(height: 16.w),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // 显示建设中提示
                        DialogUtils.showUnderConstructionDialog();
                      },
                      child: Container(
                        width: 96.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: FYColors.color_F5F5F5,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(FYImages.report_icon,width: 16.w,height: 16.w,fit: BoxFit.contain,),
                            SizedBox(width: 8.w),
                            Text('查看原文',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 14.sp),),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "来源:${detail.newsMedium}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFA6A6A6),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 35.w),
              ],
            ),
          );
        default:
          return const SizedBox.shrink();
      }
    });
  }

  // 决策建议措施item
  Widget measureItem(String measure){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          margin: EdgeInsets.only(top: 6.w),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(4.r),
            color: FYColors.color_3361FE,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            measure,
            softWrap: true,
            style: TextStyle(
              fontSize: 14.sp,
              color: FYColors.color_A6A6A6,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget translateTap(int index) {
    final isActive = state.activeTranslateIndex.value == index;
    return
      GestureDetector(
        onTap: () => logic.changeTranslate(index),
        child: Container(
          height: 36.w,
          width: 60.w,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF345DFF) : Colors.transparent,
          ),
          child: Center(
            child: Text(
              state.translateTabs[index],
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF3361FE),
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      );
  }

  // 构建风险措施表格
  Widget _buildRiskMeasureTable(List<RiskMeasure> riskMeasures) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: riskMeasures.map<Widget>((measure) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1.w,
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

  // 构建单个时间线项目
  Widget _buildTimelineItem(Map<String, dynamic> item, bool isLast) {
    return Container(
      padding: EdgeInsets.only(left: 16.w, right: 16.w),
      // height: 78.w,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF345DFF), Color(0xFF2F89F8)],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(
                width: 1,
                height: 68.w,
                child: CustomPaint(
                  painter: DashedLinePainter(color: const Color(0xFF326FFC)),
                ),
              ),
            ],
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['date'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF326FFC),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5.w),
                Text(
                  item['content'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: FYColors.color_A6A6A6,
                    height: 1.4,
                  ),
                ),
              ],
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
            width: 20.w,
            height: 20.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(
              Icons.smart_toy,
              color: Color(0xFF3361FE),
              size: 14.w,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '内容由AI生成，仅供参考',
            style: TextStyle(
              color: Color(0xFF3361FE),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  // 构建空内容页面展示
  Widget _buildEmptyContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 100.w),
          Image.asset(
            FYImages.blank_page,
            width: 120.w,
            height: 120.w,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 16.w),
          Text(
            '暂无数据',
            style: TextStyle(
              fontSize: 14.sp,
              color: FYColors.color_A6A6A6,
            ),
          ),
        ],
      ),
    );
  }
}
