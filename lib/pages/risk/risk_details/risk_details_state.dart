import 'package:get/get.dart';

class RiskDetailsState {
  // 企业基本信息
  final Map<String, dynamic> companyInfo = {
    'name': '有限公司',
    'englishName': 'ice & Technology Co., Ltd.',
    'score': 78,
    'timeline': [
      {
        'date': '2025-04-15',
        'content': '与美国某化工企业的专利纠纷案开庭审理，涉及高性能聚合物技术'
      }
    ]
  };
  
  // 是否显示风险评分详情对话框
  final RxBool showRiskScoreDialog = false.obs;
  final RxBool isExpandTimeLine = false.obs; // 是否展开时序跟踪

  // 风险因素列表
  final List<Map<String, dynamic>> riskFactors = [
    {'name': '知识产权纠纷', 'type': 'tag'},
    {'name': '环保合规风险', 'type': 'tag'},
    {'name': '海外投资风险', 'type': 'tag'},
    {'name': '贸易摩擦影响', 'type': 'tag'},
    {'name': '原材料依赖', 'type': 'tag'},
    {'name': '技术安全隐患', 'type': 'tag'},
  ];
  
  // 风险评分详情
  final List<Map<String, dynamic>> riskScores = [
    {'name': '综合风险值', 'score': 78, 'color': 0xFFFF5252},
    {'name': '知识产权风险', 'score': 86, 'color': 0xFFFF5252},
    {'name': '环保合规风险', 'score': 82, 'color': 0xFFFF5252},
    {'name': '海外投资风险', 'score': 65, 'color': 0xFFFFAB40},
    {'name': '贸易摩擦风险', 'score': 75, 'color': 0xFFFF5252},
    {'name': '原材料风险', 'score': 60, 'color': 0xFFFFAB40},
    {'name': '技术安全风险', 'score': 79, 'color': 0xFFFF5252},
  ];
  
  RiskDetailsState() {
    ///Initialize variables
  }
}
