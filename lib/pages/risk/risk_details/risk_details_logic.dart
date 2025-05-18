import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safe_app/styles/colors.dart';

import 'risk_details_state.dart';

class RiskDetailsLogic extends GetxController {
  final RiskDetailsState state = RiskDetailsState();

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

  // 显示风险评分详情对话框
  void showRiskScoreDetails() {
    Get.bottomSheet(
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FYColors.whiteColor,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(12.r), topRight: Radius.circular(12.r)),
        ),
        child: Column(
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
                    ...state.riskScores
                        .map((score) => _buildRiskScoreItem(score)),
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
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
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

  // 展开更多时间线
  void showMoreTimeline() {
    state.isExpandTimeLine.value = !state.isExpandTimeLine.value;
  }

  companyDetail() {
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
                      child:Text(
                          style: TextStyle(fontSize: 14.sp,fontWeight: FontWeight.w400)
,                          '广州金发科技股份有限公司成立于1993年，是一家专注于新型化工材料研发与生产的大型企业集团，主要业务包括改性塑料、特种工程塑料、生物基材料等产品的研发、生产和销售。公司总部位于广州科学城，现有员工超过5000人，在国内外拥有多个研发中心和生产基地。作为行业龙头企业，具有较强的技术实力和市场影响力。'),
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
}
