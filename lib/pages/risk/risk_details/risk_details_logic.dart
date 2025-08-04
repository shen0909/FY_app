import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safe_app/https/api_service.dart';
import 'package:safe_app/models/new_risk_detail.dart';
import 'package:safe_app/models/enterprise_score_detail.dart';
import 'package:safe_app/pages/risk/risk_details/risk_details_view.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/utils/diolag_utils.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:async';
import '../../../models/risk_company_details.dart';
import 'risk_details_state.dart';

class RiskDetailsLogic extends GetxController {
  final state = RiskDetailsState();

  @override
  void onInit() {
    super.onInit();
    String companyId;
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      companyId = Get.arguments['id'];
      print('接收到企业ID: $companyId');
    } else{
      companyId = '401'; // 默认使用华为的数据
    }
    // 加载企业详情数据
    loadCompanyDetail(companyId);
  }

  /// 加载企业详情数据
  Future<void> loadCompanyDetail(String companyId) async {
    state.isLoading.value = true;
    
    try {
      final result = await ApiService().getRiskDetails(companyId);
      if(result != null && result['执行结果'] != false){
        state.riskCompanyDetail.value = RiskCompanyNew.fromJson(result['返回数据']);
        // 获取企业UUID用于加载评分详情
        final entUuid = state.riskCompanyDetail.value?.uuid;
        if (entUuid != null && entUuid.isNotEmpty) {
          await loadScoreDetail(entUuid);
        }
      }
    } catch (e) {
      print('加载企业详情出错: $e');
    } finally {
      state.isLoading.value = false;
    }
  }

  /// 加载企业评分详情
  Future<void> loadScoreDetail(String entUuid) async {
    state.isLoadingScoreDetail.value = true;
    
    try {
      final result = await ApiService().getEnterpriseScoreDetails(entUuid);
      print('🏆 企业评分详情接口响应: $result');
      
      if (result != null && result['执行结果'] == true) {
        final returnData = result['返回数据'];
        if (returnData != null) {
          // 处理四种可能的返回情况并记录日志
          final baseScore = returnData['base_score'];
          final newsScore = returnData['news_score'];
          
          if (baseScore != null && newsScore != null && (newsScore as Map).isNotEmpty) {
            print('情况1: base_score和news_score都有数据');
          } else if (baseScore != null && (newsScore == null || (newsScore as Map).isEmpty)) {
            print(' 情况2: base_score有数据，news_score为空');
          } else if (baseScore == null && newsScore != null && (newsScore as Map).isNotEmpty) {
            print('情况3: base_score为null，news_score有数据');
          } else {
            print('情况4: base_score为null，news_score为空');
          }
          
          // 解析评分详情数据
          state.scoreDetail.value = EnterpriseScoreDetail.fromApiData(returnData);
          final scoreDetail = state.scoreDetail.value!;
          // 更新 riskCompanyDetail 中的相关字段
          _updateRiskScoreComponents(scoreDetail);
        }
      } else {
        print('企业评分详情接口返回异常: $result');
        state.scoreDetail.value = null;
      }
    } catch (e) {
      print('获取企业评分详情失败: $e');
      state.scoreDetail.value = null;
    } finally {
      state.isLoadingScoreDetail.value = false;
    }
  }

  /// 更新 riskCompanyDetail 中的评分组件数据以匹配现有UI
  void _updateRiskScoreComponents(EnterpriseScoreDetail scoreDetail) {
    if (state.riskCompanyDetail.value == null) return;
    
    // 更新总分
    state.riskCompanyDetail.value!.riskScore = RiskScore(
      totalScore: scoreDetail.totalScore,
      riskLevel: _getRiskLevel(scoreDetail.totalScore),
      components: RiskComponents(
        externalRisk: ExternalRisk(
          score: scoreDetail.externalTotalScore,
          breakdown: null,
        ),
        internalRisk: InternalRisk(
          score: scoreDetail.internalTotalScore,
          breakdown: null,
        ),
        operationalImpact: {
          'score': scoreDetail.otherScores['运营分数']?.totalScore ?? 0
        },
        securityImpact: {
          'score': scoreDetail.otherScores['安全分数']?.totalScore ?? 0
        },
      ),
      trend: state.riskCompanyDetail.value!.riskScore.trend, // 保持原有趋势数据
    );
    
    print('🔄 已更新riskScore组件数据:');
    print('   外部风险: ${scoreDetail.externalTotalScore}分');
    print('   内部风险: ${scoreDetail.internalTotalScore}分');
    print('   运营影响: ${scoreDetail.otherScores['运营分数']?.totalScore ?? 0}分');
    print('   安全影响: ${scoreDetail.otherScores['安全分数']?.totalScore ?? 0}分');
  }

  /// 根据分数获取风险等级
  String _getRiskLevel(int score) {
    if (score >= 300) return '高风险';
    if (score >= 200) return '中风险';
    return '低风险';
  }
  
  /// 加载所有企业详情数据
  Future<void> loadAllCompanyDetails() async {
    try {
      // final companies = await _companyService.getAllCompanyDetails();
      // state.allCompanyDetails.value = companies;
      // print('成功加载 ${companies.length} 个企业详情');
    } catch (e) {
      print('加载所有企业详情失败: $e');
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
    FYDialogUtils.showBottomSheet(
        hasMaxHeightConstraint: true,
        heightMaxFactor: 0.9,
        SingleChildScrollView(
      child: RiskDetailsPage().buildRiskScoreDialog(),
    ));
  }

  showNewsResource(List<Source> listSource, String newsDate) {
    final news = listSource;
    if (news.isEmpty) return;
    FYDialogUtils.showBottomSheet(Container(
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
              padding: EdgeInsets.only(top: 17.w, left: 16.w, right: 16.w, bottom: 13.w),
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
                      child:
                          Icon(Icons.close, color: Color(0xFF666666), size: 16.w),
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
    ));
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
            onTap: () => openUrl(news.url!),
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
    FYDialogUtils.showBottomSheet(Container(
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
                      // width: 342.w,
                      height: 211.w,
                      decoration: BoxDecoration(
                          color: FYColors.color_F9FBFF,
                          borderRadius: BorderRadius.all(Radius.circular(8.w))),
                      padding: EdgeInsets.only(left: 16.w, top: 16.w),
                      child: Column(
                        children: [
                          companyItem('地区', state.riskCompanyDetail.value!.area),
                          companyItem('所处行业', state.riskCompanyDetail.value!.industry),
                          companyItem('公司类型', state.riskCompanyDetail.value!.enterpriseType),
                          companyItem('市值', state.riskCompanyDetail.value!.marketValue),
                          companyItem('股价', state.riskCompanyDetail.value!.stockPrice),
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
                      width: double.infinity,
                      // width: 342.w,
                      // height: 211.w,
                      decoration: BoxDecoration(
                          color: FYColors.color_F9FBFF,
                          borderRadius: BorderRadius.all(Radius.circular(8.w))),
                      padding: EdgeInsets.all(16.w),
                      child: Text(
                        state.riskCompanyDetail.value!.entProfile,
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
    );
  }

  void showMoreTimeline() {
    state.isExpandTimeLine.value = !state.isExpandTimeLine.value;
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
