import 'package:get/get.dart';

import '../../../models/new_risk_detail.dart';
import '../../../models/risk_company_details.dart';

class RiskDetailsState {
  // 企业详情数据
  Rx<RiskCompanyNew?> riskCompanyDetail = Rx<RiskCompanyNew?>(null);

  // 添加企业详情数据列表
  RxList<RiskCompanyDetail> allCompanyDetails = <RiskCompanyDetail>[].obs;
  
  // 添加加载状态
  RxBool isLoading = true.obs;
  
  // 展开/收起时间线
  RxBool isExpandTimeLine = false.obs;

  // 基本信息
  final companyName = '华为技术有限公司'.obs;
  final companyNameEn = 'Huawei Technologies Co., Ltd.'.obs;
  final riskScore = 335.obs;
  final location = '总部位于中国广东省深圳市龙岗区'.obs;
  final industry = '全球领先的信息与通信技术（ICT）基础设施和智能终端提供商'.obs;
  final businessAreas = '运营商网络、企业解决方案、智能终端、云计算、汽车终端、人工智能、5G技术'.obs;
  final companyType = '民营企业，员工持股制度'.obs;
  final marketValue = '未公开上市，估值受制裁影响但仍保持全球科技企业前列'.obs;
  final stockPrice = '未公开上市，无股价信息'.obs;
  final companyIntro = '华为创立于1987年，由任正非创立，致力于构建万物互联的智能世界。其业务遍及170多个国家和地区，服务全球30多亿人口。华为在5G、人工智能、云计算等领域处于全球领先地位，拥有超过15万件有效授权专利。近年来，华为持续加大研发投入，2024年研发费用支出达人民币1,797亿元，占全年收入的20.8%。'.obs;

  // 风险评分详情
  final externalRiskScore = 120.obs;
  // final externalRiskDetails = [
  //   {'name': '宣布调查', 'score': 10},
  //   {'name': '实施调查', 'score': 20},
  //   {'name': '技术攻击', 'score': 10},
  //   {'name': '实施制裁', 'score': 30},
  //   {'name': '司法诉讼', 'score': 25},
  //   {'name': '攻击抹黑', 'score': 5},
  //   {'name': '脱钩断链', 'score': 20}
  // ].obs;

  final internalRiskScore = 25.obs;
  // final internalRiskDetails = [
  //   {'name': '失密泄密', 'score': 10},
  //   {'name': '人员失管', 'score': 10},
  //   {'name': '负面舆情', 'score': 5}
  // ].obs;

  final operationalRiskScore = 120.obs;
  final securityRiskScore = 70.obs;

  // 是否显示风险评分详情对话框
  final RxBool showRiskScoreDialog = false.obs;

  // 是否展开过往判例依据
  final RxBool isExpandCases = false.obs;

  RiskDetailsState() {}

  // 外部风险详情列表
  List<Map<String, dynamic>> get externalRiskDetails {
    // todo:风险预警详情接口未返回
    return [];
    if (riskCompanyDetail.value == null) return [];
    
    // final breakdown = riskCompanyDetail.value!.riskScore.components!.externalRisk!.breakdown;
    // return [
    //   {'name': '宣布调查', 'score': breakdown?.investigationAnnounced},
    //   {'name': '实施调查', 'score': breakdown?.investigationOngoing},
    //   {'name': '人员打入', 'score': breakdown?.personnelInfiltration},
    //   {'name': '人员拉出', 'score': breakdown?.personnelExtraction},
    //   {'name': '技术攻击', 'score': breakdown?.technicalAttacks},
    //   {'name': '实施制裁', 'score': breakdown?.sanctionsImplemented},
    //   {'name': '司法诉讼', 'score': breakdown?.legalActions},
    //   {'name': '攻击抹黑', 'score': breakdown?.reputationAttacks},
    //   {'name': '脱钩断链', 'score': breakdown?.decouplingPressure},
    //   {'name': '外资渗透', 'score': breakdown?.foreignInfiltration},
    // ].where((item) => (item['score'] as int) > 0).toList(); // 只显示分数大于0的项目
  }

  // 内部风险详情列表
  List<Map<String, dynamic>> get internalRiskDetails {
    // todo:风险预警详情接口未返回
    return [];
    if (riskCompanyDetail.value == null) return [];
    
    // final breakdown = riskCompanyDetail.value!.riskScore.components!.internalRisk!.breakdown;
    // return [
    //   {'name': '失密泄密', 'score': breakdown!.informationLeakage},
    //   {'name': '人员失管', 'score': breakdown.personnelMismanagement},
    //   {'name': '网络失管', 'score': breakdown.networkMismanagement},
    //   {'name': '场所失管', 'score': breakdown.facilityMismanagement},
    //   {'name': '信息失管', 'score': breakdown.informationMismanagement},
    //   {'name': '员工举报', 'score': breakdown.employeeWhistleblowing},
    //   {'name': '技术外流', 'score': breakdown.technologyOutflow},
    //   {'name': '负面舆情', 'score': breakdown.negativePublicity},
    //   {'name': '制度缺失', 'score': breakdown.institutionalDeficiency},
    //   {'name': '合规经营', 'score': breakdown.complianceOperations},
    // ].where((item) => (item['score'] as int) > 0).toList(); // 只显示分数大于0的项目
  }

  // 获取风险趋势数据
  List<Map<String, dynamic>> get riskTrends {
    // todo:风险预警详情接口未返回
    return [];
    // if (riskCompanyDetail.value == null) return [];
    // return riskCompanyDetail.value!.riskScore.trend!
    //     .map((trend) => {
    //           'month': trend.month,
    //           'score': trend.score,
    //         })
    //     .toList();
  }
}
