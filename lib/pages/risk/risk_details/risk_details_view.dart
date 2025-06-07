import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/image_resource.dart';
import 'package:safe_app/styles/text_styles.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/risk_company_details.dart';
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
          Image.asset(
            FYImages.download_icon,
            width: 24.w,
            height: 24.w,
            fit: BoxFit.contain,
          ),
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
                child: Obx(() => Text(
                      '${state.riskCompanyDetail.value!.riskScore.totalScore}分',
                      style: TextStyle(
                          color: FYColors.whiteColor,
                          fontWeight: FontWeight.w500,
                          height: 0.6,
                          fontSize: 18.sp),
                    )),
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
      padding: EdgeInsets.only(left: 16.w, top: 13.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Obx(() => Text(
                    state.riskCompanyDetail.value!.companyInfo.name,
                    style: FYTextStyles.riskLocationTitleStyle()
                        .copyWith(fontSize: 20.sp),
                  )),
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
          Obx(() => Text(
                state.riskCompanyDetail.value!.companyInfo.englishName,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF345DFF),
                ),
              )),
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
    List<Widget> items = [];
    List<TimelineEvent> itemsPre =
        state.riskCompanyDetail.value!.timelineTracking;

    // 判断是否展开，如果未展开，只显示第一项
    int itemsToShow = state.isExpandTimeLine.value
        ? state.riskCompanyDetail.value!.timelineTracking.length
        : 1;

    for (int i = 0; i < itemsToShow; i++) {
      bool isLastItem = i == itemsToShow - 1;
      items.add(_buildTimelineItem(itemsPre[i], isLastItem));
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
                state.isExpandTimeLine.value
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
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
  Widget _buildTimelineItem(TimelineEvent item, bool isLast) {
    return GestureDetector(
      onTap: () => logic.showNewsResource(item.sources, item.date),
      child: Container(
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
                    item.date,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF326FFC),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 5.w),
                  Text(
                    item.content,
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
      ),
    );
  }

  // 风险因素部分
  Widget _buildRiskFactorsSection() {
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
                Obx(() => Wrap(
                      spacing: 8.w,
                      runSpacing: 10.w,
                      children: List.generate(
                        state.riskCompanyDetail.value!.riskFactors.length,
                        (index) => _buildRiskTag(
                            state.riskCompanyDetail.value!.riskFactors[index]),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 风险标签
  Widget _buildRiskTag(RiskFactor riskFactor) {
    return GestureDetector(
      onTap: () => _showRiskFactorDetails(riskFactor.details, riskFactor.title),
      child: Container(
        height: 36.w,
        constraints: BoxConstraints(minWidth: 124.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F5FF),
          borderRadius: BorderRadius.circular(8.w),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              riskFactor.title,
              style: TextStyle(
                fontSize: 14.sp,
                color: FYColors.color_3361FE,
              ),
            ),
            SizedBox(width: 8.w),
            Image.asset(
              FYImages.more_info,
              width: 16.w,
              height: 16.w,
              fit: BoxFit.contain,
            )
          ],
        ),
      ),
    );
  }

  // 显示风险因素详情弹窗
  void _showRiskFactorDetails(
      List<RiskFactorDetail> riskFactorDetailList, String title) {
    Get.bottomSheet(
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FYColors.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Container(
              padding: EdgeInsets.only(
                top: 17.w,
                left: 16.w,
                right: 16.w,
                bottom: 13.w,
              ),
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
                      child: Icon(
                        Icons.close,
                        color: const Color(0xFF666666),
                        size: 16.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 详情列表
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: (riskFactorDetailList)
                    .map((item) => _buildRiskFactorItem(
                          item.title,
                          item.description,
                        ))
                    .toList(),
              ),
            ),
            SizedBox(height: 24.w),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.black54,
    );
  }

  // 风险因素详情项
  Widget _buildRiskFactorItem(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 16.w),
          child: Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.w),
                  color: FYColors.color_3361FE,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8.w, left: 16.w),
          child: Text(
            description,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFFA6A6A6),
              height: 1.5,
            ),
          ),
        ),
      ],
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
                Obx(() {
                  final cases = state.riskCompanyDetail.value!.legalBasis;
                  final displayCases = state.isExpandCases.value
                      ? cases
                      : cases.take(1).toList();
                  return Column(
                    children: [
                      ...displayCases
                          .asMap()
                          .entries
                          .map((entry) => Padding(
                                padding: EdgeInsets.only(bottom: 8.w),
                                child: _buildCaseItem(
                                    entry.key + 1, entry.value.summary),
                              ))
                          ,
                      Text(
                        '建议企业加强合规管理，特别关注知识产权保护和环保合规问题。',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: FYColors.color_A6A6A6,
                        ),
                      ),
                      if (cases.length > 1)
                        InkWell(
                          onTap: () => state.isExpandCases.value =
                              !state.isExpandCases.value,
                          child: Container(
                            width: double.infinity,
                            height: 36.w,
                            margin: EdgeInsets.only(top: 8.w),
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
                                    state.isExpandCases.value ? '收起' : '展开更多',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: FYColors.color_3361FE,
                                    ),
                                  ),
                                  SizedBox(width: 5.w),
                                  Icon(
                                    state.isExpandCases.value
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: FYColors.color_3361FE,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 案例项
  Widget _buildCaseItem(int index, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            '$index. $content',
            style: TextStyle(
              fontSize: 14.sp,
              color: FYColors.color_A6A6A6,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget dialogWidget(Widget content, String title) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FYColors.whiteColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.r), topRight: Radius.circular(12.r)),
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

  Widget dialogTitle(String title) {
    return Container(
      padding:
          EdgeInsets.only(top: 17.w, left: 16.w, right: 16.w, bottom: 13.w),
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
              child:
                  Icon(Icons.close, color: const Color(0xFF666666), size: 16.w),
            ),
          ),
        ],
      ),
    );
  }

  // 风险评分详情弹窗
  Widget buildRiskScoreDialog() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FYColors.whiteColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.r), topRight: Radius.circular(12.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部标题区域
          Container(
            padding: EdgeInsets.only(
                top: 17.w, left: 16.w, right: 16.w, bottom: 13.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '风险评分详情',
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
          ),
          // 外部风险
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '外部风险',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    Obx(() => Text(
                          '${state.externalRiskScore}分',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF333333),
                          ),
                        )),
                  ],
                ),
                Divider(height: 35.w, color: const Color(0xFFE6E6E6)),
                ...state.externalRiskDetails
                    .map((item) => _buildExternalRiskItem(item))
                    .toList(),
              ],
            ),
          ),
          SizedBox(height: 16.w),
          // 内部风险
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '内部风险',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    Obx(() => Text(
                          '${state.internalRiskScore}分',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF333333),
                          ),
                        )),
                  ],
                ),
                Divider(height: 35.w, color: const Color(0xFFE6E6E6)),
                ...state.internalRiskDetails
                    .map((item) => _buildExternalRiskItem(item))
                    .toList(),
              ],
            ),
          ),
          SizedBox(height: 16.w),
          // 运营影响和安全影响
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '运营影响',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    Obx(() => Text(
                          '${state.operationalRiskScore}分',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF333333),
                          ),
                        )),
                  ],
                ),
                SizedBox(height: 16.w),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '安全影响',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    Obx(() => Text(
                          '${state.securityRiskScore}分',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF333333),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.w),
          // 综合评分
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            padding: EdgeInsets.symmetric(vertical: 12.w),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFFECE9),
              borderRadius: BorderRadius.circular(8.w),
              border: Border.all(color: const Color(0xFFFF6850)),
            ),
            child: Column(
              children: [
                Text(
                  '综合评分',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 4.w),
                Obx(() => Text(
                      '${state.riskScore}分',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF6850),
                      ),
                    )),
              ],
            ),
          ),
          SizedBox(height: 16.w),
          // 风险趋势图
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '风险分数趋势图',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 16.w),
                Container(
                  height: 200.w,
                  child: _buildRiskTrendChart(),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.w),
        ],
      ),
    );
  }

  // 构建风险趋势图
  Widget _buildRiskTrendChart() {
    return Obx(() {
      final spots = state.riskTrends.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value['score'] as double);
      }).toList();

      return LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: const Color(0xFFE6E6E6),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: const Color(0xFFE6E6E6),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= state.riskTrends.length)
                    return const Text('');
                  final date =
                      state.riskTrends[value.toInt()]['date'] as String;
                  return Padding(
                    padding: EdgeInsets.only(top: 8.w),
                    child: Transform.rotate(
                      angle: -0.785398, // 45度角
                      child: Text(
                        date,
                        style: TextStyle(
                          color: const Color(0xFFA6A6A6),
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}分',
                    style: TextStyle(
                      color: const Color(0xFFA6A6A6),
                      fontSize: 11.sp,
                    ),
                  );
                },
                reservedSize: 32,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          minX: 0,
          maxX: (state.riskTrends.length - 1).toDouble(),
          minY: 260,
          maxY: 340,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF2A08), Color(0xFFFF4629)],
              ),
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: const Color(0xFFFF2A08),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFF2A08).withOpacity(0.2),
                    const Color(0xFFFF4629).withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // 修复类型错误
  Widget _buildExternalRiskItem(Map<String, dynamic> item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            (item['name'] as String?) ?? '',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFFA6A6A6),
            ),
          ),
          Text(
            '${item['score']}分',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFFA6A6A6),
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
