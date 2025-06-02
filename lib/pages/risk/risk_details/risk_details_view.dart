import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/image_resource.dart';
import 'package:safe_app/styles/text_styles.dart';
import 'package:safe_app/widgets/widgets.dart';

import '../../../widgets/custom_app_bar.dart';
import 'risk_details_logic.dart';
import 'risk_details_state.dart';

class RiskDetailsPage extends StatelessWidget {
  RiskDetailsPage({super.key});

  final RiskDetailsLogic logic = Get.put(RiskDetailsLogic());
  final RiskDetailsState state = Get.find<RiskDetailsLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FYColors.whiteColor,
      appBar: FYAppBar(
        title: '单位详情',
        fontWeight: FontWeight.bold,
        fontSize: 18,
        titleColor: Colors.black,
        actions: [
          Image.asset(FYImages.download_icon,width: 24.w,height: 24.w,fit: BoxFit.contain,),
          SizedBox(width: 12.w),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => logic.showRiskScoreDetails(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [Color(0xFFFF2A08), Color(0xFFFF4629)],
                    stops: [0.0, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(8.w),
                ),
                child: Text(
                  '78分',
                  style: TextStyle(
                      color: FYColors.whiteColor,
                      fontWeight: FontWeight.w500,
                      height: 0.6,
                      fontSize: 18.sp),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCompanyHeader(),
            SizedBox(height: 24.w),
            _buildTimelineSection(),
            SizedBox(height: 24.w),
            _buildRiskFactorsSection(),
            SizedBox(height: 24.w),
            _buildCaseHistorySection(),
          ],
        ),
      ),
    );
  }

  // 公司头部信息
  Widget _buildCompanyHeader() {
    return Container(
      width: double.infinity,
      color: FYColors.whiteColor,
      padding: EdgeInsets.only(left: 16.w,top: 13.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '中船黄埔文冲船舶有限公司',
                style: FYTextStyles.riskLocationTitleStyle().copyWith(fontSize: 20.sp),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => logic.companyDetail(),
                child: Image.asset(
                  FYImages.tip_icon,
                  width: 24.w,
                  height: 24.w,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.w),
          Text(
            'CSSC Huangpu Wenchong Shipbuilding Company Limited',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF345DFF),
            ),
          ),
        ],
      ),
    );
  }

  // 时间线部分
  Widget _buildTimelineSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('时序跟踪', style: FYTextStyles.mediumBodyTextStyle()),
          SizedBox(height: 10.w),
          Container(
            decoration: BoxDecoration(
                color: FYColors.color_F9F9F9,
                borderRadius: BorderRadius.all(Radius.circular(8.w))),
            padding: EdgeInsets.symmetric(vertical: 16.w),
            child: Obx(() {
              return Column(children: _buildTimelineItems());
            }),
          ),
        ],
      ),
    );
  }

  // 构建时间线项目列表
  List<Widget> _buildTimelineItems() {
    final timelineItems = [
      {'date': '2025-04-15', 'content': '与美国某化工企业的专利纠纷案开庭审理涉及高性能聚合物技术'},
      {'date': '2025-04-15', 'content': '广州工厂因环保问题被当地环保部门责令整改，限期30天'},
      {'date': '2025-04-15', 'content': '在东南亚地区的合资工厂投产，但当地政策存在不确定性'},
      {'date': '2025-04-15', 'content': '被列入美国商务部实体清单观察名单，部分产品出口受限'},
      {'date': '2025-04-15', 'content': '被列入美国商务部实体清单观察名单，部分产品出口受限'},
      {'date': '2025-04-15', 'content': '被列入美国商务部实体清单观察名单，部分产品出口受限'},
    ];

    List<Widget> items = [];

    // 判断是否展开，如果未展开，只显示第一项
    int itemsToShow = state.isExpandTimeLine.value ? timelineItems.length : 1;

    for (int i = 0; i < itemsToShow; i++) {
      bool isLastItem = i == itemsToShow - 1;
      items.add(_buildTimelineItem(timelineItems[i], isLastItem));
    }

    items.add(InkWell(
      onTap: () => logic.showMoreTimeline(),
      child: Container(
        width: 297.w,
        height: 36.w,
        padding: EdgeInsets.symmetric(vertical: 10.w),
        decoration: BoxDecoration(
          color: FYColors.whiteColor,
          borderRadius: BorderRadius.circular(8.w),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.isExpandTimeLine.value ? '收起' : '展开更多',
                style: FYTextStyles.riskUnitTypeUnselectedStyle(),
              ),
              SizedBox(width: 5.w),
              Icon(
                state.isExpandTimeLine.value ? Icons.keyboard_arrow_up : Icons
                    .keyboard_arrow_down,
                color: FYColors.color_3361FE,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    ));

    return items;
  }

  // 时间线项
  Widget _buildTimelineItem(Map<String, dynamic> item, bool isLast) {
    return Container(
      padding: EdgeInsets.only(left: 16.w, right: 16.w),
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

  // 风险因素部分
  Widget _buildRiskFactorsSection() {
    // 风险因素标签列表
    final riskTags = [
      '知识产权争议',
      '环保合规风险',
      '海外投资风险',
      '贸易摩擦影响',
      '原材料依赖',
      '技术安全隐患',
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      color: FYColors.whiteColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('风险因素', style: FYTextStyles.mediumBodyTextStyle()),
          SizedBox(height: 10.w),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(left: 12.w, top: 12.w, bottom: 11.w),
            decoration: BoxDecoration(
                color: FYColors.color_F9F9F9,
                borderRadius: BorderRadius.circular(8.w)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '根据最新风险评估，该企业存在以下主要风险因素：',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: FYColors.color_A6A6A6,
                  ),
                ),
                SizedBox(height: 15.w),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 10.w,
                  children: List.generate(
                    riskTags.length,
                        (index) => _buildRiskTag(riskTags[index]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 风险标签
  Widget _buildRiskTag(String tagName) {
    return Container(
      width: 102.w,
      height: 36.w,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5FF),
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Center(
        child: Text(
          tagName,
          style: TextStyle(
            fontSize: 14.sp,
            color: FYColors.color_3361FE,
          ),
        ),
      ),
    );
  }

  // 过往判例依据部分
  Widget _buildCaseHistorySection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      color: FYColors.whiteColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('过往判例依据', style: FYTextStyles.mediumBodyTextStyle()),
          SizedBox(height: 10.w),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              color: FYColors.color_F9F9F9,
              borderRadius: BorderRadius.circular(8.w),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '相关判例显示，类似企业在以下情况下存在法律风险：',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: FYColors.color_A6A6A6,
                  ),
                ),
                SizedBox(height: 15.w),
                _buildCaseItem('2024年某化工企业因环境污染被处罚2000万元案例'),
                SizedBox(height: 8.w),
                _buildCaseItem('2023年化工行业知识产权纠纷典型案例3起'),
                SizedBox(height: 8.w),
                _buildCaseItem('2022年出口管制违规处罚案例5起'),
                SizedBox(height: 15.w),
                Text(
                  '建议企业加强合规管理，特别关注知识产权保护和环保合规问题。',
                  style: TextStyle(
                    fontSize: 14.sp,
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

  // 案例项
  Widget _buildCaseItem(String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '•',
          style: TextStyle(
            fontSize: 14.sp,
            color: FYColors.color_A6A6A6,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              color: FYColors.color_A6A6A6,
            ),
          ),
        ),
      ],
    );
  }

  Widget dialogWidget(Widget content,String title){
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FYColors.whiteColor,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(12.r), topRight: Radius.circular(12.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部标题区域
            dialogTitle(title),
            content
          ],
        ),
      );
  }

  Widget dialogTitle(String title){
    return Container(
      padding: EdgeInsets.only(top: 17.w, left: 16.w, right: 16.w, bottom: 13.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
          ),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 24.w,
              height: 24.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF0F0F0),
              ),
              child: Icon(Icons.close,
                  color: const Color(0xFF666666), size: 16.w),
            ),
          ),
        ],
      ),
    );

  }

}

// 虚线绘制
class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const dashWidth = 1.0;
    const dashSpace = 3.0;
    double startY = 0.0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
