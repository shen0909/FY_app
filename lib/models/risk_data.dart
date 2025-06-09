import 'dart:convert';

class RiskyData {
  final Metadata metadata;
  final Statistics statistics;
  final Location location;
  final Map<String, List<Company>> companies;
  final Map<String, List<UnreadMessage>> unreadMessages;
  final Map<String, RiskCategory> riskCategories;
  final Map<String, SeverityLevel> severityLevels;
  final Map<String, RiskLevel> riskLevels;
  final Map<String, AttentionLevel> attentionLevels;

  RiskyData({
    required this.metadata,
    required this.statistics,
    required this.location,
    required this.companies,
    required this.unreadMessages,
    required this.riskCategories,
    required this.severityLevels,
    required this.riskLevels,
    required this.attentionLevels,
  });

  Map<String, dynamic> toJson() {
    return {
      'metadata': metadata.toJson(),
      'statistics': statistics.toJson(),
      'location': location.toJson(),
      'companies': companies.map((key, value) => MapEntry(key, value.map((e) => e.toJson()).toList())),
      'unread_messages': unreadMessages.map((key, value) => MapEntry(key, value.map((e) => e.toJson()).toList())),
      'risk_categories': riskCategories.map((key, value) => MapEntry(key, value.toJson())),
      'severity_levels': severityLevels.map((key, value) => MapEntry(key, value.toJson())),
      'risk_levels': riskLevels.map((key, value) => MapEntry(key, value.toJson())),
      'attention_levels': attentionLevels.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  factory RiskyData.fromJson(Map<String, dynamic> json) {
    return RiskyData(
      metadata: Metadata.fromJson(json['metadata']),
      statistics: Statistics.fromJson(json['statistics']),
      location: Location.fromJson(json['location']),
      companies: (json['companies'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
          key,
          (value as List?)?.map((e) => Company.fromJson(e)).toList() ?? [],
        ),
      ) ?? {},
      unreadMessages: (json['unread_messages'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
          key,
          (value as List?)?.map((e) => UnreadMessage.fromJson(e)).toList() ?? [],
        ),
      ) ?? {},
      riskCategories: (json['risk_categories'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
          key,
          RiskCategory.fromJson(value),
        ),
      ) ?? {},
      severityLevels: (json['severity_levels'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
          key,
          SeverityLevel.fromJson(value),
        ),
      ) ?? {},
      riskLevels: (json['risk_levels'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
          key,
          RiskLevel.fromJson(value),
        ),
      ) ?? {},
      attentionLevels: (json['attention_levels'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
          key,
          AttentionLevel.fromJson(value),
        ),
      ) ?? {},
    );
  }
}

class Metadata {
  final String lastUpdated;
  final String version;
  final String description;
  final int totalCompanies;
  final int totalMessages;

  Metadata({
    required this.lastUpdated,
    required this.version,
    required this.description,
    required this.totalCompanies,
    required this.totalMessages,
  });

  Map<String, dynamic> toJson() {
    return {
      'lastUpdated': lastUpdated,
      'version': version,
      'description': description,
      'totalCompanies': totalCompanies,
      'totalMessages': totalMessages,
    };
  }

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      lastUpdated: json['lastUpdated'] as String? ?? '',
      version: json['version'] as String? ?? '',
      description: json['description'] as String? ?? '',
      totalCompanies: json['totalCompanies'] as int? ?? 0,
      totalMessages: json['totalMessages'] as int? ?? 0,
    );
  }
}

class Statistics {
  final FengyunStats fengyun1;
  final FengyunStats fengyun2;
  final XingyunStats xingyun;

  Statistics({
    required this.fengyun1,
    required this.fengyun2,
    required this.xingyun,
  });

  Map<String, dynamic> toJson() {
    return {
      'fengyun_1': fengyun1.toJson(),
      'fengyun_2': fengyun2.toJson(),
      'xingyun': xingyun.toJson(),
    };
  }

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      fengyun1: FengyunStats.fromJson(json['fengyun_1'] ?? {}),
      fengyun2: FengyunStats.fromJson(json['fengyun_2'] ?? {}),
      xingyun: XingyunStats.fromJson(json['xingyun'] ?? {}),
    );
  }
}

class FengyunStats {
  final String name;
  final String description;
  final Stats stats;

  FengyunStats({
    required this.name,
    required this.description,
    required this.stats,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'stats': stats.toJson(),
    };
  }

  factory FengyunStats.fromJson(Map<String, dynamic> json) {
    return FengyunStats(
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      stats: Stats.fromJson(json['stats'] ?? {}),
    );
  }
}

class Stats {
  final int highRisk;
  final int mediumRisk;
  final int lowRisk;
  final int total;
  final DailyChange dailyChange;

  Stats({
    required this.highRisk,
    required this.mediumRisk,
    required this.lowRisk,
    required this.total,
    required this.dailyChange,
  });

  Map<String, dynamic> toJson() {
    return {
      'high_risk': highRisk,
      'medium_risk': mediumRisk,
      'low_risk': lowRisk,
      'total': total,
      'daily_change': dailyChange.toJson(),
    };
  }

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      highRisk: json['high_risk'] as int? ?? 0,
      mediumRisk: json['medium_risk'] as int? ?? 0,
      lowRisk: json['low_risk'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      dailyChange: DailyChange.fromJson(json['daily_change'] ?? {}),
    );
  }
}

class DailyChange {
  final int highRisk;
  final int mediumRisk;
  final int lowRisk;

  DailyChange({
    required this.highRisk,
    required this.mediumRisk,
    required this.lowRisk,
  });

  Map<String, dynamic> toJson() {
    return {
      'high_risk': highRisk,
      'medium_risk': mediumRisk,
      'low_risk': lowRisk,
    };
  }

  factory DailyChange.fromJson(Map<String, dynamic> json) {
    return DailyChange(
      highRisk: json['high_risk'] as int? ?? 0,
      mediumRisk: json['medium_risk'] as int? ?? 0,
      lowRisk: json['low_risk'] as int? ?? 0,
    );
  }
}

class XingyunStats {
  final String name;
  final String description;
  final XingyunStatsData stats;

  XingyunStats({
    required this.name,
    required this.description,
    required this.stats,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'stats': stats.toJson(),
    };
  }

  factory XingyunStats.fromJson(Map<String, dynamic> json) {
    return XingyunStats(
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      stats: XingyunStatsData.fromJson(json['stats'] ?? {}),
    );
  }
}

class XingyunStatsData {
  final int keyFocus;
  final int generalFocus;
  final int total;
  final XingyunDailyChange dailyChange;

  XingyunStatsData({
    required this.keyFocus,
    required this.generalFocus,
    required this.total,
    required this.dailyChange,
  });

  Map<String, dynamic> toJson() {
    return {
      'key_focus': keyFocus,
      'general_focus': generalFocus,
      'total': total,
      'daily_change': dailyChange.toJson(),
    };
  }

  factory XingyunStatsData.fromJson(Map<String, dynamic> json) {
    return XingyunStatsData(
      keyFocus: json['key_focus'] as int? ?? 0,
      generalFocus: json['general_focus'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      dailyChange: XingyunDailyChange.fromJson(json['daily_change'] ?? {}),
    );
  }
}

class XingyunDailyChange {
  final int keyFocus;
  final int generalFocus;

  XingyunDailyChange({
    required this.keyFocus,
    required this.generalFocus,
  });

  Map<String, dynamic> toJson() {
    return {
      'key_focus': keyFocus,
      'general_focus': generalFocus,
    };
  }

  factory XingyunDailyChange.fromJson(Map<String, dynamic> json) {
    return XingyunDailyChange(
      keyFocus: json['key_focus'] as int? ?? 0,
      generalFocus: json['general_focus'] as int? ?? 0,
    );
  }
}

class Location {
  final String province;
  final List<City> cities;

  Location({
    required this.province,
    required this.cities,
  });

  Map<String, dynamic> toJson() {
    return {
      'province': province,
      'cities': cities.map((e) => e.toJson()).toList(),
    };
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      province: json['province'] as String? ?? '',
      cities: (json['cities'] as List?)?.map((e) => City.fromJson(e)).toList() ?? [],
    );
  }
}

class City {
  final String code;
  final String name;

  City({
    required this.code,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
    };
  }

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

class Company {
  final String id;
  final String name;
  final String englishName;
  final String description;
  final String riskLevel;
  final String riskLevelText;
  final String? attentionLevel;
  final String? attentionLevelText;
  final String city;
  final String updateDate;
  final int unreadCount;
  final String detailPage;
  final String industry;
  final String? marketCap;
  final String? stockPrice;
  final List<String> tags;

  Company({
    required this.id,
    required this.name,
    required this.englishName,
    required this.description,
    required this.riskLevel,
    required this.riskLevelText,
    required this.city,
    required this.updateDate,
    required this.unreadCount,
    required this.detailPage,
    required this.industry,
    this.marketCap,
    this.stockPrice,
    required this.tags,
    this.attentionLevel,
    this.attentionLevelText,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'english_name': englishName,
      'description': description,
      'risk_level': riskLevel,
      'risk_level_text': riskLevelText,
      'attention_level': attentionLevel,
      'attention_level_text': attentionLevelText,
      'city': city,
      'update_date': updateDate,
      'unread_count': unreadCount,
      'detail_page': detailPage,
      'industry': industry,
      'market_cap': marketCap,
      'stock_price': stockPrice,
      'tags': tags,
    };
  }

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      englishName: json['english_name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      riskLevel: json['risk_level'] as String? ?? '',
      riskLevelText: json['risk_level_text'] as String? ?? '',
      attentionLevel: json['attention_level'] as String?,
      attentionLevelText: json['attention_level_text'] as String?,
      city: json['city'] as String? ?? '',
      updateDate: json['update_date'] as String? ?? '',
      unreadCount: json['unread_count'] as int? ?? 0,
      detailPage: json['detail_page'] as String? ?? '',
      industry: json['industry'] as String? ?? '',
      marketCap: json['market_cap'] as String?,
      stockPrice: json['stock_price'] as String?,
      tags: (json['tags'] as List?)?.map((e) => e as String).toList() ?? [],
    );
  }
}

class UnreadMessage {
  final String id;
  final String title;
  final String content;
  final String date;
  final String source;
  final String sourceName;
  final bool read;
  final String category;
  final String severity;
  final List<String> tags;

  UnreadMessage({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.source,
    required this.sourceName,
    required this.read,
    required this.category,
    required this.severity,
    required this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date,
      'source': source,
      'source_name': sourceName,
      'read': read,
      'category': category,
      'severity': severity,
      'tags': tags,
    };
  }

  factory UnreadMessage.fromJson(Map<String, dynamic> json) {
    return UnreadMessage(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      date: json['date'] as String,
      source: json['source'] as String,
      sourceName: json['source_name'] as String,
      read: json['read'] as bool? ?? false,
      category: json['category'] as String,
      severity: json['severity'] as String,
      tags: (json['tags'] as List?)?.map((e) => e as String).toList() ?? [],
    );
  }
}

class RiskCategory {
  final String color;
  final int priority;
  final String description;

  RiskCategory({
    required this.color,
    required this.priority,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'color': color,
      'priority': priority,
      'description': description,
    };
  }

  factory RiskCategory.fromJson(Map<String, dynamic> json) {
    return RiskCategory(
      color: json['color'] as String? ?? '',
      priority: json['priority'] as int? ?? 0,
      description: json['description'] as String? ?? '',
    );
  }
}

class SeverityLevel {
  final String label;
  final String color;
  final String description;

  SeverityLevel({
    required this.label,
    required this.color,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'color': color,
      'description': description,
    };
  }

  factory SeverityLevel.fromJson(Map<String, dynamic> json) {
    return SeverityLevel(
      label: json['label'] as String? ?? '',
      color: json['color'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class RiskLevel {
  final String label;
  final String color;
  final String bgColor;
  final String borderColor;

  RiskLevel({
    required this.label,
    required this.color,
    required this.bgColor,
    required this.borderColor,
  });

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'color': color,
      'bg_color': bgColor,
      'border_color': borderColor,
    };
  }

  factory RiskLevel.fromJson(Map<String, dynamic> json) {
    return RiskLevel(
      label: json['label'] as String? ?? '',
      color: json['color'] as String? ?? '',
      bgColor: json['bg_color'] as String? ?? '',
      borderColor: json['border_color'] as String? ?? '',
    );
  }
}

class AttentionLevel {
  final String label;
  final String color;
  final String bgColor;
  final String borderColor;

  AttentionLevel({
    required this.label,
    required this.color,
    required this.bgColor,
    required this.borderColor,
  });

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'color': color,
      'bg_color': bgColor,
      'border_color': borderColor,
    };
  }

  factory AttentionLevel.fromJson(Map<String, dynamic> json) {
    return AttentionLevel(
      label: json['label'] as String? ?? '',
      color: json['color'] as String? ?? '',
      bgColor: json['bg_color'] as String? ?? '',
      borderColor: json['border_color'] as String? ?? '',
    );
  }
}