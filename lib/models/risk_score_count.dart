/// 风险评分数量响应模型
class RiskScoreCount {
  final int highRisk;    // 高风险
  final int mediumRisk;  // 中风险
  final int lowRisk;     // 低风险

  RiskScoreCount({
    required this.highRisk,
    required this.mediumRisk,
    required this.lowRisk,
  });

  /// 从JSON创建实例
  factory RiskScoreCount.fromJson(Map<String, dynamic> json) {
    return RiskScoreCount(
      highRisk: json['高风险'] ?? 0,
      mediumRisk: json['中风险'] ?? 0,
      lowRisk: json['低风险'] ?? 0,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      '高风险': highRisk,
      '中风险': mediumRisk,
      '低风险': lowRisk,
    };
  }

  /// 获取总数
  int get total => highRisk + mediumRisk + lowRisk;

  @override
  String toString() {
    return 'RiskScoreCount(高风险: $highRisk, 中风险: $mediumRisk, 低风险: $lowRisk, 总数: $total)';
  }
} 