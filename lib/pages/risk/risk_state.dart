import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';

class RiskState {
  // 当前选择的单位类型 0-一类单位 1-二类单位
  RxInt chooseUint = 0.obs;
  
  // 地区
  final String location = "广东省广州市";

  // 单位类型分类数据
  final RxMap<String, RxMap<String, dynamic>> unitTypeData = {
    '0': <String, dynamic>{
      'high': {'title': '高风险', 'count': 4, 'change': 3, 'color': 0xFF4169E1},
      'medium': {'title': '中风险', 'count': 5, 'change': 2, 'color': 0xFF4169E1},
      'low': {'title': '低风险', 'count': 6, 'change': 1, 'color': 0xFF4169E1},
      'total': {'title': '总数', 'count': 15, 'color': 0xFF4169E1}
    }.obs,
    '1': <String, dynamic>{
      'key': {'title': '重点', 'count': 200, 'change': 2, 'color': 0xFF4169E1},
      'normal': {'title': '一般', 'count': 120, 'change': 2, 'color': 0xFF4169E1},
      'new': {'title': '新增', 'count': 100, 'change': 2, 'color': 0xFF4169E1},
      'total': {'title': '总数', 'count': 420, 'color': 0xFF4169E1}
    }.obs,
    '2': <String, dynamic>{
      'key': {'title': '重点', 'count': 200, 'change': 2, 'color': 0xFF4169E1},
      'normal': {'title': '一般', 'count': 120, 'change': 2, 'color': 0xFF4169E1},
      'new': {'title': '新增', 'count': 100, 'change': 2, 'color': 0xFF4169E1},
      'total': {'title': '总数', 'count': 420, 'color': 0xFF4169E1}
    }.obs
  }.obs;

  // 风险单位列表 - 一类单位
  RxList<Map<String, dynamic>> riskList1 = <Map<String, dynamic>>[
    {
      'name': '有限公司',
      'englishName': 'Company Limited',
      'description': '船舶制造行业领先企业，专注于高端船舶研发与制造',
      'updateTime': '2025-04-15',
      'riskLevel': '高风险',
      'riskLevelType': 1,
      'riskColor': 0xFFFF0000,
      'isRead': false,
      'unreadCount': 0,
      'borderColor' : FYColors.color_FF6850
    },
    {
      'name': '大学',
      'englishName': 'University of Technology',
      'description': '国家"双一流"建设高校，教育部直属全国重点大学',
      'updateTime': '2025-04-10',
      'riskLevel': '低风险',
      'riskLevelType': 2,
      'riskColor': 0xFFFF8C00,
      'isRead': true,
      'unreadCount': 0,
      'borderColor' : FYColors.color_07CC89
    }
  ].obs;

  // 风险单位列表 - 二类单位
  RxList<Map<String, dynamic>> riskList2 = <Map<String, dynamic>>[
    {
      'name': '有限公司',
      'englishName': 'Technology Co., Ltd.',
      'description': '专注于人工智能和大数据分析技术开发的科技企业',
      'updateTime': '2025-04-12',
      'riskColor': 0xFFFF8C00,
      'riskLevel': '★★',
      'bgColor': 0xFFFFF8DC,
      'isRead': false,
      'unreadCount': 2,
      'borderColor' : FYColors.color_07CC89
    },
    {
      'name': '有限公司',
      'englishName': 'Technology Group Co., Ltd.',
      'description': '市值: 102.3亿元 | 股价: 5.84元 (收市)',
      'updateTime': '2025-04-16',
      'riskLevel': '★★★',
      'riskColor': 0xFFFF0000,
      'bgColor': 0xFFFFB6C1,
      'isRead': false,
      'unreadCount': 4,
      'borderColor' : FYColors.color_07CC89
    }
  ].obs;

  // 获取当前选择的单位类型数据
  RxMap<String, dynamic> get currentUnitData =>
      unitTypeData[chooseUint.toString()]!;

  // 获取当前单位类型的风险列表
  RxList<Map<String, dynamic>> get currentRiskList =>
      chooseUint.value == 0 ? riskList1 : riskList2;
}
