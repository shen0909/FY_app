import 'dart:convert';

/// 新的风险因素数据模型
/// 对应API返回的risk_factor字段格式
class RiskFactorNew {
  /// 风险因素名称
  final String factorName;
  
  /// 风险因素项目列表
  final List<RiskFactorItem> factorItems;

  RiskFactorNew({
    required this.factorName,
    required this.factorItems,
  });

  factory RiskFactorNew.fromJson(Map<String, dynamic> json) {
    return RiskFactorNew(
      factorName: json['factor_name'] ?? '',
      factorItems: (json['factor_item'] as List<dynamic>?)
          ?.map((item) => RiskFactorItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'factor_name': factorName,
      'factor_item': factorItems.map((item) => item.toJson()).toList(),
    };
  }
}

/// 风险因素项目
class RiskFactorItem {
  /// 风险因素项目名称
  final String factorItemName;
  
  /// 风险因素项目内容
  final String factorItemContent;

  RiskFactorItem({
    required this.factorItemName,
    required this.factorItemContent,
  });

  factory RiskFactorItem.fromJson(Map<String, dynamic> json) {
    return RiskFactorItem(
      factorItemName: json['factor_item_name'] ?? '',
      factorItemContent: json['factor_item_content'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'factor_item_name': factorItemName,
      'factor_item_content': factorItemContent,
    };
  }
}

/// 风险因素解析工具类
class RiskFactorParser {
  /// 处理三种情况：""、"[]"、"[具体内容]"
  static List<RiskFactorNew> parseRiskFactor(String? riskFactorString) {
    if (riskFactorString == null || riskFactorString.isEmpty) {
      return [];
    }
    // 去除首尾空白字符
    final trimmed = riskFactorString.trim();
    // 空字符串情况
    if (trimmed.isEmpty) {
      return [];
    }
    // 空数组字符串情况
    if (trimmed == '[]') {
      return [];
    }
    try {
      // 尝试解析JSON数组
      final List<dynamic> jsonList = jsonDecode(trimmed);
      
      return jsonList
          .map((item) => RiskFactorNew.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('解析风险因素失败: $e');
      print('原始数据: $riskFactorString');
      return [];
    }
  }
}