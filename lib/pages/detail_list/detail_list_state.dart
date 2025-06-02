import 'package:get/get.dart';

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
  
  DetailListState() {
    ///Initialize variables
    _initDemoData();
  }

  void _initDemoData() {
    // 初始化年度统计数据
    yearlyStats.addAll([
      YearlyStats(year: '2018', newCount: 63, totalCount: 63),
      YearlyStats(year: '2019', newCount: 151, totalCount: 214),
      YearlyStats(year: '2020', newCount: 240, totalCount: 454),
      YearlyStats(year: '2021', newCount: 157, totalCount: 611),
      YearlyStats(year: '2022', newCount: 43, totalCount: 654),
      YearlyStats(year: '2023', newCount: 73, totalCount: 727),
      YearlyStats(year: '2024', newCount: 136, totalCount: 863),
      YearlyStats(year: '2025(截至5月)', newCount: 54, totalCount: 917),
    ]);
  }
}

// 企业清单项目
class CompanyItem {
  final int id;
  final String name;
  final String sanctionType; // 制裁类型
  final String region; // 地区
  
  CompanyItem({
    required this.id,
    required this.name,
    required this.sanctionType,
    required this.region,
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
