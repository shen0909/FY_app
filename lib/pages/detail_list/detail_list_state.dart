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
  
  DetailListState() {
    ///Initialize variables
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
