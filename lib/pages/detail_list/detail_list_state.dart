import 'package:get/get.dart';

// 制裁类型数据模型
class SanctionType {
  final String name;
  final String code;
  final String description;
  final int color;
  final int bgColor;

  SanctionType({
    required this.name,
    required this.code,
    required this.description,
    required this.color,
    required this.bgColor,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'description': description,
      'color': color,
      'bgColor': bgColor,
    };
  }

  factory SanctionType.fromJson(Map<String, dynamic> json) {
    return SanctionType(
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String,
      color: json['color'] as int,
      bgColor: json['bgColor'] as int,
    );
  }

  static List<SanctionType> mockSanctionType (){
    return [
      SanctionType(
        name: '实体清单(EL)',
        code: 'EL',
        description: '实体清单',
        color: 0xFFFF2A08,
        bgColor: 0xFFFFECE9,
      ),
      SanctionType(
        name: '中国军工复合体清单 (NS-CMIC List)',
        code: 'NS-CMIC',
        description: '中国军工复合体清单',
        color: 0xFFFFA408,
        bgColor: 0xFFFFF7E9,
      ),
      SanctionType(
        name: '中国涉军企业清单 (CMC List)',
        code: 'CMC',
        description: '中国涉军企业清单',
        color: 0xFF07CC89,
        bgColor: 0xFFE7FEF8,
      ),
      SanctionType(
        name: '非SDN中国军事综合体企业清单 (Non-SDN CMIC)',
        code: 'Non-SDN CMIC',
        description: '非SDN中国军事综合体企业清单',
        color: 0xFF33A9FE,
        bgColor: 0xFFE7F4FE,
      ),
      SanctionType(
        name: '行业制裁名单 (SSI)',
        code: 'SSI',
        description: '行业制裁名单',
        color: 0xFF07CC89,
        bgColor: 0xFFE7FEF8,
      ),
      SanctionType(
        name: '未经核实清单 (UVL)',
        code: 'UVL',
        description: '未经核实清单',
        color: 0xFF1A1A1A,
        bgColor: 0xFFEDEDED,
      ),
      SanctionType(
        name: '被拒绝人员清单 (DPL)',
        code: 'DPL',
        description: '被拒绝人员清单',
        color: 0xFFFF2A08,
        bgColor: 0xFFFFECE9,
      ),
      SanctionType(
        name: '军事最终用户清单 (MEU)',
        code: 'MEU',
        description: '军事最终用户清单',
        color: 0xFF1A1A1A,
        bgColor: 0xFFEDEDED,
      ),
      SanctionType(
        name: '最终军事用户清单 (MEUL)',
        code: 'MEUL',
        description: '最终军事用户清单',
        color: 0xFF1A1A1A,
        bgColor: 0xFFEDEDED,
      ),
    ];
  }
}

class DetailListState {
  // 搜索关键词
  var searchText = ''.obs;
  
  // 筛选选项
  var typeFilter = ''.obs;
  var provinceFilter = ''.obs;
  var cityFilter = ''.obs;
  
  // 是否正在加载数据
  var isLoading = false.obs;
  
  // 企业清单数据
  var companyList = <CompanyItem>[].obs;
  
  // 总数量
  var totalCount = 10.obs;

  // 年度统计数据
  var yearlyStats = <YearlyStats>[].obs;

  // 制裁类型列表
  var sanctionTypes = <SanctionType>[].obs;
  
  DetailListState() {
    ///Initialize variables
    _initDemoData();
  }

  void _initDemoData() {
    // 初始化制裁类型列表
    sanctionTypes.addAll(SanctionType.mockSanctionType());

    // 初始化年度统计数据
    yearlyStats.addAll([
      YearlyStats(year: '2018', newCount: 63, totalCount: 63),
      YearlyStats(year: '2019', newCount: 151, totalCount: 214),
      YearlyStats(year: '2020', newCount: 240, totalCount: 100),
      YearlyStats(year: '2021', newCount: 157, totalCount: 60),
      YearlyStats(year: '2022', newCount: 43, totalCount: 70),
      YearlyStats(year: '2023', newCount: 73, totalCount: 200),
      YearlyStats(year: '2024', newCount: 136, totalCount: 20),
      YearlyStats(year: '2025(截至5月)', newCount: 54, totalCount: 90),
    ]);
  }
}

// 企业清单项目
class CompanyItem {
  final int id;
  final String name;
  final SanctionType sanctionType;
  final String region; // 地区
  final String time; // 时间
  final String removalTime; // 移除时间
  
  CompanyItem({
    required this.id,
    required this.name,
    required this.sanctionType,
    required this.region,
    required this.time,
    required this.removalTime,
  });
}

// 年度统计数据
class YearlyStats {
  final String year;
  final int newCount;
  final int totalCount;

  YearlyStats({
    required this.year,
    required this.newCount,
    required this.totalCount,
  });
}
