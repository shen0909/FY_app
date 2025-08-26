/// 新闻影响企业数据模型
class NewsEffectCompanyResponse {
  final int allCount;
  final List<EffectCompany> list;

  NewsEffectCompanyResponse({
    required this.allCount,
    required this.list,
  });

  factory NewsEffectCompanyResponse.fromJson(Map<String, dynamic> json) {
    return NewsEffectCompanyResponse(
      allCount: json['all_count'] ?? 0,
      list: (json['list'] as List<dynamic>?)
          ?.map((item) => EffectCompany.fromJson(item))
          .toList() ?? [],
    );
  }
}

/// 影响企业信息
class EffectCompany {
  final String uuid;
  final String zhName;
  final String enName;
  final String entProfile;
  final String regionCode;
  final int customClassification;
  final int customEntType;
  final String createdAt;
  final String updatedAt;
  final String reason;
  final String effectType;

  EffectCompany({
    required this.uuid,
    required this.zhName,
    required this.enName,
    required this.entProfile,
    required this.regionCode,
    required this.customClassification,
    required this.customEntType,
    required this.createdAt,
    required this.updatedAt,
    required this.reason,
    required this.effectType,
  });

  factory EffectCompany.fromJson(Map<String, dynamic> json) {
    return EffectCompany(
      uuid: json['uuid']?.toString() ?? '',
      zhName: json['zh_name']?.toString() ?? '',
      enName: json['en_name']?.toString() ?? '',
      entProfile: json['ent_profile']?.toString() ?? '',
      regionCode: json['region_code']?.toString() ?? '',
      customClassification: json['custom_classification'] ?? 0,
      customEntType: json['custom_ent_type'] ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      effectType: json['effect_type']?.toString() ?? '',
    );
  }
}

/// 请求参数模型
class NewsEffectCompanyRequest {
  final String newsUuid;
  final int currentPage;
  final int pageSize;
  final int? effectType;

  NewsEffectCompanyRequest({
    required this.newsUuid,
    required this.currentPage,
    required this.pageSize,
    this.effectType,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'news_uuid': newsUuid,
      'current_page': currentPage,
      'page_size': pageSize,
    };
    
    if (effectType != null) {
      data['effect_type'] = effectType;
    }
    
    return data;
  }
} 