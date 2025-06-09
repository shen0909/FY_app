import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/risk_company_details.dart';

class RiskCompanyService {
  static final RiskCompanyService _instance = RiskCompanyService._internal();
  
  factory RiskCompanyService() {
    return _instance;
  }
  
  RiskCompanyService._internal();
  
  /// 根据公司ID获取公司详情
  Future<RiskCompanyDetail?> getCompanyDetail(String companyId) async {
    try {
      // 加载对应的JSON文件
      final String jsonString = await rootBundle.loadString('assets/company-details/$companyId-detail.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // 转换为RiskCompanyDetail对象
      return RiskCompanyDetail.fromJson(jsonData);
    } catch (e) {
      print('加载公司详情失败: $e');
      return null;
    }
  }
} 