import 'dart:convert';
import 'dart:core';
import 'dart:core';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

class RiskCompanyDetail {
  final String companyId;
  final CompanyInfo companyInfo;
  final List<TimelineEvent> timelineTracking;
  final List<RiskFactor> riskFactors;
  final List<LegalBasis> legalBasis;
  final RiskScore riskScore;
  final String lastUpdated;

  RiskCompanyDetail({
    required this.companyId,
    required this.companyInfo,
    required this.timelineTracking,
    required this.riskFactors,
    required this.legalBasis,
    required this.riskScore,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
      'company_info': companyInfo.toJson(),
      'timeline_tracking': timelineTracking.map((e) => e.toJson()).toList(),
      'risk_factors': riskFactors.map((e) => e.toJson()).toList(),
      'legal_basis': legalBasis.map((e) => e.toJson()).toList(),
      'risk_score': riskScore.toJson(),
      'last_updated': lastUpdated,
    };
  }

  factory RiskCompanyDetail.fromJson(Map<String, dynamic> json) {
    return RiskCompanyDetail(
      companyId: json['company_id'],
      companyInfo: CompanyInfo.fromJson(json['company_info']),
      timelineTracking: (json['timeline_tracking'] as List)
          .map((e) => TimelineEvent.fromJson(e))
          .toList(),
      riskFactors: (json['risk_factors'] as List)
          .map((e) => RiskFactor.fromJson(e))
          .toList(),
      legalBasis: (json['legal_basis'] as List)
          .map((e) => LegalBasis.fromJson(e))
          .toList(),
      riskScore: RiskScore.fromJson(json['risk_score']),
      lastUpdated: json['last_updated'] as String,
    );
  }

}

class CompanyInfo {
  final String? name;
  final String? englishName;
  final String? industry;
  final String? location;
  final String? businessScope;
  final String? companyType;
  final String? marketValue;
  final String? stockPrice;
  final String? establishedDate;
  final String? employees;
  final String? patents;
  final String? globalRanking;
  final String? financialPerformance;
  final String? description;
  final String? registeredCapital;
  final String? website;

  CompanyInfo({
    this.name,
    this.englishName,
    this.industry,
    this.location,
    this.businessScope,
    this.companyType,
    this.marketValue,
    this.stockPrice,
    this.establishedDate,
    this.employees,
    this.patents,
    this.globalRanking,
    this.financialPerformance,
    this.description,
    this.registeredCapital,
    this.website,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'english_name': englishName,
      'industry': industry,
      'location': location,
      'business_scope': businessScope,
      'company_type': companyType,
      'market_value': marketValue,
      'stock_price': stockPrice,
      'established_date': establishedDate,
      'employees': employees,
      'patents': patents,
      'global_ranking': globalRanking,
      'financial_performance': financialPerformance,
      'description': description,
      'registered_capital': registeredCapital,
      'website': website,
    };
  }

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      name: json['name'],
      englishName: json['english_name'],
      industry: json['industry'],
      location: json['location'],
      businessScope: json['business_scope'],
      companyType: json['company_type'],
      marketValue: json['market_value'],
      stockPrice: json['stock_price'],
      establishedDate: json['established_date'],
      employees: json['employees'],
      patents: json['patents'],
      globalRanking: json['global_ranking'],
      financialPerformance: json['financial_performance'],
      description: json['description'],
      registeredCapital: json['registered_capital'],
      website: json['website'],
    );
  }
}

class TimelineEvent {
  final String? date;
  final String? content;
  final List<Source>? sources;

  TimelineEvent({
    this.date,
    this.content,
    this.sources,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'content': content,
      'sources': sources?.map((e) => e.toJson()).toList(),
    };
  }

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      date: json['date'],
      content: json['content'],
      sources: json['sources'] != null
          ? (json['sources'] as List).map((e) => Source.fromJson(e)).toList()
          : null,
    );
  }
}

class Source {
  final String? title;
  final String? url;
  final String? source;

  Source({
    this.title,
    this.url,
    this.source,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'source': source,
    };
  }

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      title: json['title'],
      url: json['url'],
      source: json['source'],
    );
  }
}

class RiskFactor {
  final String? type;
  final String? title;
  final String? level;
  final List<RiskFactorDetail>? details;

  RiskFactor({
    this.type,
    this.title,
    this.level,
    this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'level': level,
      'details': details?.map((e) => e.toJson()).toList(),
    };
  }

  factory RiskFactor.fromJson(Map<String, dynamic> json) {
    return RiskFactor(
      type: json['type'],
      title: json['title'],
      level: json['level'],
      details: json['details'] != null
          ? (json['details'] as List).map((e) => RiskFactorDetail.fromJson(e)).toList()
          : null,
    );
  }
}

class RiskFactorDetail {
  final String? title;
  final String? description;

  RiskFactorDetail({
    this.title,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }

  factory RiskFactorDetail.fromJson(Map<String, dynamic> json) {
    return RiskFactorDetail(
      title: json['title'],
      description: json['description'],
    );
  }
}

class LegalBasis {
  final String? category;
  final String? title;
  final String? summary;
  final dynamic details;  // 可以是LegalBasisDetail对象或SimilarCase列表或字符串等

  LegalBasis({
    this.category,
    this.title,
    this.summary,
    this.details,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'category': category,
      'title': title,
      'summary': summary,
    };

    if (details != null) {
      if (details is LegalBasisDetail) {
        json['details'] = (details as LegalBasisDetail).toJson();
      } else if (details is List<SimilarCase>) {
        json['details'] = (details as List<SimilarCase>).map((e) => e.toJson()).toList();
      } else {
        json['details'] = details;
      }
    }

    return json;
  }

  factory LegalBasis.fromJson(Map<String, dynamic> json) {
    dynamic parsedDetails;
    if (json['details'] != null) {
      if (json['category'] == 'similar-cases' && json['details'] is List) {
        parsedDetails = (json['details'] as List).map((e) => SimilarCase.fromJson(e)).toList();
      } else if (json['details'] is Map) {
        if (json['details'].containsKey('legal_framework') || 
            json['details'].containsKey('implementation') ||
            json['details'].containsKey('scope') ||
            json['details'].containsKey('penalties')) {
          parsedDetails = LegalBasisDetail.fromJson(json['details']);
        } else {
          // 处理其他类型的details结构
          parsedDetails = json['details'];
        }
      } else {
        parsedDetails = json['details'];
      }
    }

    return LegalBasis(
      category: json['category'],
      title: json['title'],
      summary: json['summary'],
      details: parsedDetails,
    );
  }
}

class LegalBasisDetail {
  final String? legalFramework;
  final String? implementation;
  final String? scope;
  final String? penalties;
  final String? impact;

  LegalBasisDetail({
    this.legalFramework,
    this.implementation,
    this.scope,
    this.penalties,
    this.impact,
  });

  Map<String, dynamic> toJson() {
    return {
      'legal_framework': legalFramework,
      'implementation': implementation,
      'scope': scope,
      'penalties': penalties,
      'impact': impact,
    };
  }

  factory LegalBasisDetail.fromJson(Map<String, dynamic> json) {
    return LegalBasisDetail(
      legalFramework: json['legal_framework'],
      implementation: json['implementation'],
      scope: json['scope'],
      penalties: json['penalties'],
      impact: json['impact'],
    );
  }
}

class SimilarCase {
  final String? company;
  final String? date;
  final String? action;
  final String? impact;

  SimilarCase({
    this.company,
    this.date,
    this.action,
    this.impact,
  });

  Map<String, dynamic> toJson() {
    return {
      'company': company,
      'date': date,
      'action': action,
      'impact': impact,
    };
  }

  factory SimilarCase.fromJson(Map<String, dynamic> json) {
    return SimilarCase(
      company: json['company'],
      date: json['date'],
      action: json['action'],
      impact: json['impact'],
    );
  }
}

class RiskScore {
  final int? totalScore;
  final String? riskLevel;
  final RiskComponents? components;
  final List<TrendScore>? trend;

  RiskScore({
    this.totalScore,
    this.riskLevel,
    this.components,
    this.trend,
  });

  Map<String, dynamic> toJson() {
    return {
      'total_score': totalScore,
      'risk_level': riskLevel,
      'components': components?.toJson(),
      'trend': trend?.map((e) => e.toJson()).toList(),
    };
  }

  factory RiskScore.fromJson(Map<String, dynamic> json) {
    List<TrendScore>? trendScores;
    
    // 处理趋势数据，支持两种格式：
    // 1. risk_score.trend (老格式)
    // 2. risk_score.components.trend (新格式)
    if (json.containsKey('trend') && json['trend'] is List) {
      trendScores = (json['trend'] as List).map((e) => TrendScore.fromJson(e)).toList();
    } else if (json.containsKey('components') && 
               json['components'] is Map && 
               json['components'].containsKey('trend') && 
               json['components']['trend'] is List) {
      trendScores = (json['components']['trend'] as List).map((e) => TrendScore.fromJson(e)).toList();
    }

    return RiskScore(
      totalScore: json['total_score'] is int ? json['total_score'] : int.tryParse(json['total_score']?.toString() ?? '0'),
      riskLevel: json['risk_level'],
      components: json['components'] != null ? RiskComponents.fromJson(json['components']) : null,
      trend: trendScores,
    );
  }
}

class RiskComponents {
  final ExternalRisk? externalRisk;
  final InternalRisk? internalRisk;
  final dynamic operationalImpact;
  final dynamic securityImpact;

  RiskComponents({
    this.externalRisk,
    this.internalRisk,
    this.operationalImpact,
    this.securityImpact,
  });

  Map<String, dynamic> toJson() {
    return {
      'external_risk': externalRisk?.toJson(),
      'internal_risk': internalRisk?.toJson(),
      'operational_impact': operationalImpact,
      'security_impact': securityImpact,
    };
  }

  factory RiskComponents.fromJson(Map<String, dynamic> json) {
    return RiskComponents(
      externalRisk: json['external_risk'] != null ? ExternalRisk.fromJson(json['external_risk']) : null,
      internalRisk: json['internal_risk'] != null ? InternalRisk.fromJson(json['internal_risk']) : null,
      operationalImpact: json['operational_impact'],
      securityImpact: json['security_impact'],
    );
  }
}

class ExternalRisk {
  final int? score;
  final RiskBreakdown? breakdown;

  ExternalRisk({
    this.score,
    this.breakdown,
  });

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'breakdown': breakdown?.toJson(),
    };
  }

  factory ExternalRisk.fromJson(Map<String, dynamic> json) {
    return ExternalRisk(
      score: json['score'] is int ? json['score'] : int.tryParse(json['score']?.toString() ?? '0'),
      breakdown: json['breakdown'] != null ? RiskBreakdown.fromJson(json['breakdown']) : null,
    );
  }
}

class InternalRisk {
  final int? score;
  final InRiskBreakdown? breakdown;

  InternalRisk({
    this.score,
    this.breakdown,
  });

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'breakdown': breakdown?.toJson(),
    };
  }

  factory InternalRisk.fromJson(Map<String, dynamic> json) {
    return InternalRisk(
      score: json['score'] is int ? json['score'] : int.tryParse(json['score']?.toString() ?? '0'),
      breakdown: json['breakdown'] != null ? InRiskBreakdown.fromJson(json['breakdown']) : null,
    );
  }
}

class RiskBreakdown {
  final int investigationAnnounced;
  final int investigationOngoing;
  final int personnelInfiltration;
  final int personnelExtraction;
  final int technicalAttacks;
  final int sanctionsImplemented;
  final int legalActions;
  final int reputationAttacks;
  final int decouplingPressure;
  final int foreignInfiltration;

  RiskBreakdown({
    required this.investigationAnnounced,
    required this.investigationOngoing,
    required this.personnelInfiltration,
    required this.personnelExtraction,
    required this.technicalAttacks,
    required this.sanctionsImplemented,
    required this.legalActions,
    required this.reputationAttacks,
    required this.decouplingPressure,
    required this.foreignInfiltration,
  });

  Map<String, dynamic> toJson() {
    return {
      'investigation_announced': investigationAnnounced,
      'investigation_ongoing': investigationOngoing,
      'personnel_infiltration': personnelInfiltration,
      'personnel_extraction': personnelExtraction,
      'technical_attacks': technicalAttacks,
      'sanctions_implemented': sanctionsImplemented,
      'legal_actions': legalActions,
      'reputation_attacks': reputationAttacks,
      'decoupling_pressure': decouplingPressure,
      'foreign_infiltration': foreignInfiltration,
    };
  }

  factory RiskBreakdown.fromJson(Map<String, dynamic> json) {
    return RiskBreakdown(
      investigationAnnounced: json['investigation_announced'] is int ? json['investigation_announced'] : int.tryParse(json['investigation_announced']?.toString() ?? '0'),
      investigationOngoing: json['investigation_ongoing'] is int ? json['investigation_ongoing'] : int.tryParse(json['investigation_ongoing']?.toString() ?? '0'),
      personnelInfiltration: json['personnel_infiltration'] is int ? json['personnel_infiltration'] : int.tryParse(json['personnel_infiltration']?.toString() ?? '0'),
      personnelExtraction: json['personnel_extraction'] is int ? json['personnel_extraction'] : int.tryParse(json['personnel_extraction']?.toString() ?? '0'),
      technicalAttacks: json['technical_attacks'] is int ? json['technical_attacks'] : int.tryParse(json['technical_attacks']?.toString() ?? '0'),
      sanctionsImplemented: json['sanctions_implemented'] is int ? json['sanctions_implemented'] : int.tryParse(json['sanctions_implemented']?.toString() ?? '0'),
      legalActions: json['legal_actions'] is int ? json['legal_actions'] : int.tryParse(json['legal_actions']?.toString() ?? '0'),
      reputationAttacks: json['reputation_attacks'] is int ? json['reputation_attacks'] : int.tryParse(json['reputation_attacks']?.toString() ?? '0'),
      decouplingPressure: json['decoupling_pressure'] is int ? json['decoupling_pressure'] : int.tryParse(json['decoupling_pressure']?.toString() ?? '0'),
      foreignInfiltration: json['foreign_infiltration'] is int ? json['foreign_infiltration'] : int.tryParse(json['foreign_infiltration']?.toString() ?? '0'),
    );
  }
}
class InRiskBreakdown {
  final int informationLeakage;
  final int personnelMismanagement;
  final int networkMismanagement;
  final int facilityMismanagement;
  final int informationMismanagement;
  final int employeeWhistleblowing;
  final int technologyOutflow;
  final int negativePublicity;
  final int institutionalDeficiency;
  final int complianceOperations;

  InRiskBreakdown(
  {
    required this.informationLeakage,
    required this.personnelMismanagement,
    required this.networkMismanagement,
    required this.facilityMismanagement,
    required this.informationMismanagement,
    required this.employeeWhistleblowing,
    required this.technologyOutflow,
    required this.negativePublicity,
    required this.institutionalDeficiency,
    required this.complianceOperations,
}
  );

  Map<String, dynamic> toJson() {
    return {
      'information_leakage': informationLeakage,
      'personnel_mismanagement': personnelMismanagement,
      'network_mismanagement': networkMismanagement,
      'facility_mismanagement': facilityMismanagement,
      'information_mismanagement': informationMismanagement,
      'employee_whistleblowing': employeeWhistleblowing,
      'technology_outflow': technologyOutflow,
      'negative_publicity': negativePublicity,
      'institutional_deficiency': institutionalDeficiency,
      'compliance_operations': complianceOperations,
    };
  }

  factory InRiskBreakdown.fromJson(Map<String, dynamic> json) {
    return InRiskBreakdown(
      informationLeakage: json['information_leakage'] is int ? json['information_leakage'] : int.tryParse(json['information_leakage']?.toString() ?? '0'),
      personnelMismanagement: json['personnel_mismanagement'] is int ? json['personnel_mismanagement'] : int.tryParse(json['personnel_mismanagement']?.toString() ?? '0'),
      networkMismanagement: json['network_mismanagement'] is int ? json['network_mismanagement'] : int.tryParse(json['network_mismanagement']?.toString() ?? '0'),
      facilityMismanagement: json['facility_mismanagement'] is int ? json['facility_mismanagement'] : int.tryParse(json['facility_mismanagement']?.toString() ?? '0'),
      informationMismanagement: json['information_mismanagement'] is int ? json['information_mismanagement'] : int.tryParse(json['information_mismanagement']?.toString() ?? '0'),
      employeeWhistleblowing: json['employee_whistleblowing'] is int ? json['employee_whistleblowing'] : int.tryParse(json['employee_whistleblowing']?.toString() ?? '0'),
      technologyOutflow: json['technology_outflow'] is int ? json['technology_outflow'] : int.tryParse(json['technology_outflow']?.toString() ?? '0'),
      negativePublicity: json['negative_publicity'] is int ? json['negative_publicity'] : int.tryParse(json['negative_publicity']?.toString() ?? '0'),
      institutionalDeficiency: json['institutional_deficiency'] is int ? json['institutional_deficiency'] : int.tryParse(json['institutional_deficiency']?.toString() ?? '0'),
      complianceOperations: json['compliance_operations'] is int ? json['compliance_operations'] : int.tryParse(json['compliance_operations']?.toString() ?? '0'),
    );
  }
}

class TrendScore {
  final String? month;
  final int? score;

  TrendScore({
    this.month,
    this.score,
  });

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'score': score,
    };
  }

  factory TrendScore.fromJson(Map<String, dynamic> json) {
    return TrendScore(
      month: json['month'],
      score: json['score'] is int ? json['score'] : int.tryParse(json['score']?.toString() ?? '0'),
    );
  }
}