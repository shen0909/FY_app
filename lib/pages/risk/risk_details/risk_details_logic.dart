import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safe_app/pages/risk/risk_details/risk_details_view.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../models/risk_company_details.dart';
import 'risk_details_state.dart';

class RiskDetailsLogic extends GetxController {
  final state = RiskDetailsState();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    state.riskCompanyDetail.value = RiskCompanyDetail.mock();
  }

  @override
  void onReady() {
    super.onReady();
    // 获取传入的企业数据，实际项目中可以在这里加载详细数据
    if (Get.arguments != null) {
      // 这里可以用于处理接收到的参数
      // 例如：state.companyInfo = Get.arguments['companyInfo'];
    }
  }

  @override
  void onClose() {
    super.onClose();
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
              fontWeight: FontWeight.w700,
              color: FYColors.color_1A1A1A,
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

  void showRiskScoreDetails() {
    Get.bottomSheet(
      Container(
        color: Colors.transparent,
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(Get.context!).size.height * 0.9),
        child: SingleChildScrollView(
          child: RiskDetailsPage().buildRiskScoreDialog(),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  showNewsResource(List<Source> listSource, String newsDate) {
    final news = listSource;
    if (news.isEmpty) return;

    Get.bottomSheet(
      Container(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    EdgeInsets.only(top: 17, left: 16, right: 16, bottom: 13),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      newsDate,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF0F0F0),
                        ),
                        child: Icon(Icons.close,
                            color: Color(0xFF666666), size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                constraints: BoxConstraints(maxHeight: Get.height * 0.6),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...news.map((item) => _buildNewsItem(item)).toList(),
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.black54,
    );
  }

  Widget _buildNewsItem(Source news) {
    return Container(
      margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 10.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
      width: double.infinity,
      decoration: BoxDecoration(
          color: const Color(0xffF9FBFF),
          borderRadius: BorderRadius.all(Radius.circular(8.r))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            news.title ?? '',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () => openUrl(news.url),
            child: Text(
              news.url ?? '',
              style: TextStyle(
                fontSize: 14.sp,
                color: FYColors.color_3361FE,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void companyDetail() {
    Get.bottomSheet(
      Container(
        width: double.infinity,
        height: 605.w,
        decoration: BoxDecoration(
          color: FYColors.whiteColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r), topRight: Radius.circular(12.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部标题区域
            dialogTitle('单位信息'),
            // 内容区域
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 342.w,
                      height: 211.w,
                      decoration: BoxDecoration(
                          color: FYColors.color_F9FBFF,
                          borderRadius: BorderRadius.all(Radius.circular(8.w))),
                      padding: EdgeInsets.only(left: 16.w, top: 16.w),
                      child: Column(
                        children: [
                          companyItem('地区', '浙江省杭州市'),
                          companyItem('所处行业', '浙江省杭州市'),
                          companyItem('地区', '浙江省杭州市'),
                          companyItem('地区', '浙江省杭州市'),
                          companyItem('地区', '浙江省杭州市'),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.w),
                    Text(
                      '单位介绍',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                        color: FYColors.color_1A1A1A,
                      ),
                    ),
                    SizedBox(height: 16.w),
                    Container(
                      // width: 342.w,
                      // height: 211.w,
                      decoration: BoxDecoration(
                          color: FYColors.color_F9FBFF,
                          borderRadius: BorderRadius.all(Radius.circular(8.w))),
                      padding: EdgeInsets.all(16.w),
                      child: Text(
                          style: TextStyle(
                              fontSize: 14.sp, fontWeight: FontWeight.w400),
                          '广州金发科技股份有限公司成立于1993年，是一家专注于新型化工材料研发与生产的大型企业集团，主要业务包括改性塑料、特种工程塑料、生物基材料等产品的研发、生产和销售。公司总部位于广州科学城，现有员工超过5000人，在国内外拥有多个研发中心和生产基地。作为行业龙头企业，具有较强的技术实力和市场影响力。'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
    );
  }

  void showMoreTimeline() {
    state.isExpandTimeLine.value = !state.isExpandTimeLine.value;
  }

  Widget _buildRiskScoreDialog() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 顶部标题区域
        dialogTitle('风险评分详情'),
        // 内容区域
        Container(
          constraints: BoxConstraints(maxHeight: Get.height * 0.6),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 风险评分列表
                // ...state.riskScores
                //     .map((score) => _buildRiskScoreItem(score)),
                // 趋势图部分
                Padding(
                  padding: EdgeInsets.only(top: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '风险分数趋势图',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      SizedBox(height: 12.w),
                      Container(
                        height: 160.w,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.circular(8.w),
                        ),
                        child: Center(
                          child: Text(
                            '趋势图区域',
                            style: TextStyle(
                              color: const Color(0xFF999999),
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.w),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 风险评分项目
  Widget _buildRiskScoreItem(Map<String, dynamic> score) {
    return Container(
      padding: EdgeInsets.only(top: 12.w, bottom: 8.w),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: FYColors.color_E6E6E6, width: 1.w)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            score['name'],
            style: TextStyle(
              fontSize: 16.sp,
              color: FYColors.color_1A1A1A,
              fontWeight: FontWeight.w400,
            ),
          ),
          Container(
            width: 35.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: Color(score['color']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4.w),
            ),
            child: Center(
              child: Text(
                '${score['score']}',
                style: TextStyle(
                  color: Color(score['color']),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget companyItem(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.w),
      child: Row(
        children: [
          SizedBox(
              width: 64.w,
              height: 27.w,
              child: Text(
                title,
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: FYColors.color_1A1A1A),
              )),
          SizedBox(width: 23.w),
          Expanded(
            child: SizedBox(
                height: 20.w,
                child: Text(
                  content,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: FYColors.color_A6A6A6),
                )),
          ),
        ],
      ),
    );
  }

  // 获取风险等级描述
  String getRiskLevelDescription(int score) {
    if (score >= 300) return '高风险';
    if (score >= 200) return '中风险';
    return '低风险';
  }

  // 获取风险等级颜色
  int getRiskLevelColor(int score) {
    if (score >= 300) return 0xFFFF6850;
    if (score >= 200) return 0xFFF6D500;
    return 0xFF07CC89;
  }

  // 获取风险因素详情
  Map<String, List<Map<String, String>>> getRiskFactorDetails() {
    return {
      '技术依赖风险': [
        {'title': '芯片设计工具依赖', 'description': '华为海思半导体依赖美国EDA工具进行芯片设计'},
        {'title': '高端芯片制造依赖', 'description': '华为自研的麒麟芯片需要台积电等代工厂使用美国设备进行生产'},
      ],
      '供应链风险': [
        {
          'title': '供应链断裂',
          'description': '美国"实体清单"和"直接产品原则"的扩大适用，导致华为无法从全球供应商处获取关键组件'
        },
        {'title': '替代供应商有限', 'description': '全球半导体产业高度集中，美国企业在多个关键环节占据主导地位'},
      ],
      '市场准入风险': [
        {'title': '5G设备市场限制', 'description': '多个国家限制或禁止在其5G网络中使用华为设备'},
        {'title': '智能手机市场受阻', 'description': '无法获取Google移动服务授权，影响海外市场销售'},
      ],
      '国际关系风险': [
        {'title': '地缘政治影响', 'description': '中美贸易摩擦持续，科技领域成为重点关注领域'},
        {'title': '国际合作受限', 'description': '部分国家对华为在关键基础设施领域的参与持谨慎态度'},
      ],
      '法律合规风险': [
        {'title': '出口管制合规', 'description': '需要严格遵守美国等国家的出口管制规定'},
        {'title': '知识产权纠纷', 'description': '面临多起专利诉讼和技术许可争议'},
      ],
      '出口管制风险': [
        {'title': '实体清单限制', 'description': '被列入美国商务部实体清单，限制获取美国技术和产品'},
        {'title': '直接产品规则', 'description': '受美国扩大的外国直接产品规则影响，芯片供应受限'},
      ],
    };
  }

  openUrl(String url) async {
    await launchUrlString(
      url,
      mode: LaunchMode.externalApplication, // 使用外部浏览器打开
      webViewConfiguration: const WebViewConfiguration(
        enableJavaScript: true,
        enableDomStorage: true,
      ),
    );
  }
}
