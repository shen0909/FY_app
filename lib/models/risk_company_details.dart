import 'dart:convert';

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
      companyId: json['company_id'] as String,
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

  factory RiskCompanyDetail.mock() => RiskCompanyDetail(
    companyId: "104",
    companyInfo: CompanyInfo.mock(),
    timelineTracking: [
      TimelineEvent(
        date: "2025年1月9日",
        content: "美国国防部进一步解释CMC清单目的与影响，对列入CMC清单企业的影响范围进行进一步说明。",
        sources: [
          Source(
            title: "美国国防部官方声明",
            url: "https://www.defense.gov/News/Releases/2025-01-09",
            source: "美国国防部",
          ),
        ],
      ),
      TimelineEvent(
        date: "2025年1月6日",
        content: "中船黄埔文冲被列入美国最新版\"中国涉军企业\"清单，美国财政部更新中国涉军企业清单。",
        sources: [
          Source(
            title: "美国联邦公报",
            url: "https://www.federalregister.gov/documents/2025/01/06",
            source: "美国联邦公报",
          ),
          Source(
            title: "路透社报道",
            url: "https://www.reuters.com/world/china/us-adds-chinese-firms-military-list-2025-01-06",
            source: "路透社",
          ),
        ],
      ),
      TimelineEvent(
        date: "2024年6月19日",
        content: "蓬莱巨涛因参与俄罗斯项目被美国列入SDN清单，美国财政部将蓬莱巨涛海洋工程重工有限公司列入SDN清单。",
        sources: [
          Source(
            title: "世界海事新闻报道",
            url: "https://www.worldoe.com/html/2024/Shipyards_0618/204002.html",
            source: "世界海事新闻",
          ),
        ],
      ),
      TimelineEvent(
        date: "2024年3月28日",
        content: "美国对航运及船舶行业制裁范围扩大，美国财政部宣布扩大对航运及船舶制造行业的制裁范围。",
        sources: [
          Source(
            title: "美国财政部新闻稿",
            url: "https://www.treasury.gov/press-releases/2024-03-28",
            source: "美国财政部",
          ),
        ],
      ),
      TimelineEvent(
        date: "2020年12月20日",
        content: "中国船舶集团下属25家机构被列入实体清单，美国商务部将中国船舶集团下属25家机构列入实体清单。",
        sources: [
          Source(
            title: "美国商务部公告",
            url: "https://www.commerce.gov/news/2020-12-20",
            source: "美国商务部",
          ),
        ],
      ),
    ],
    riskFactors: [
      RiskFactor(
        type: "sanction-risk",
        title: "制裁风险",
        level: "high",
        details: [
          RiskFactorDetail(
            title: "CMC清单影响",
            description: "被列入美国国防部中国涉军企业清单（CMC），面临美国投资者投资限制，可能影响国际融资渠道。",
          ),
          RiskFactorDetail(
            title: "实体清单连带影响",
            description: "母公司中国船舶集团已被列入实体清单，技术和设备采购受到严格限制。",
          ),
          RiskFactorDetail(
            title: "次级制裁风险",
            description: "国际合作伙伴可能因担心美国次级制裁而减少或终止合作。",
          ),
          RiskFactorDetail(
            title: "金融制裁可能性",
            description: "存在被列入SDN清单的风险，可能导致美元结算和国际金融服务受限。",
          ),
        ],
      ),
      RiskFactor(
        type: "supply-chain",
        title: "供应链风险",
        level: "medium",
        details: [
          RiskFactorDetail(
            title: "关键设备依赖",
            description: "船舶制造需要的部分高端设备和技术来自欧美供应商，可能面临断供风险。",
          ),
          RiskFactorDetail(
            title: "软件系统限制",
            description: "船舶设计和制造使用的CAD/CAM软件可能受到出口管制影响。",
          ),
          RiskFactorDetail(
            title: "认证体系影响",
            description: "国际船级社认证可能受到政治因素影响，影响船舶的国际市场准入。",
          ),
        ],
      ),
      RiskFactor(
        type: "market-access",
        title: "市场准入风险",
        level: "medium",
        details: [
          RiskFactorDetail(
            title: "国际订单影响",
            description: "部分国际客户可能因制裁担忧而减少订单，特别是与美国有业务往来的航运公司。",
          ),
          RiskFactorDetail(
            title: "融资渠道受限",
            description: "国际银行可能限制对公司的融资支持，增加资金成本。",
          ),
          RiskFactorDetail(
            title: "保险服务限制",
            description: "国际保险公司可能限制或拒绝为公司船舶提供保险服务。",
          ),
        ],
      ),
      RiskFactor(
        type: "tech-dependency",
        title: "技术依赖风险",
        level: "low",
        details: [
          RiskFactorDetail(
            title: "军用技术自主",
            description: "军用舰船核心技术基本实现自主可控，受外部技术限制影响较小。",
          ),
          RiskFactorDetail(
            title: "民用技术替代",
            description: "民用船舶技术有较多替代方案，可通过国产化降低依赖。",
          ),
        ],
      ),
    ],
    legalBasis: [
      LegalBasis(
        category: "entity-list",
        title: "实体清单机制",
        summary: "美国商务部工业与安全局(BIS)管理的出口管制清单，限制美国企业向清单实体出口、再出口或转让受管制物项。",
        details: LegalBasisDetail(
          legalFramework: "《出口管理条例》(EAR)第744.11条",
          implementation: "需要获得BIS许可证才能出口受管制物项，许可证申请采用'推定拒绝'政策",
          scope: "涵盖美国原产物项、含有超过最低限度美国成分的外国产品、使用美国技术或软件的直接产品",
          penalties: "违规可能面临刑事起诉、民事罚款、出口特权撤销等处罚",
        ),
      ),
      LegalBasis(
        category: "cmc-list",
        title: "中国涉军企业清单(CMC)",
        summary: "美国国防部认定的与中国军方有关联的企业清单，主要影响美国投资者的投资行为。",
        details: LegalBasisDetail(
          legalFramework: "《2021财年国防授权法》第1260H条",
          implementation: "禁止美国人购买或出售清单企业的公开交易证券",
          scope: "适用于所有美国人，包括美国公民、永久居民、美国境内的任何人、美国法律设立的实体",
          penalties: "违规投资可能面临民事和刑事处罚",
        ),
      ),
      LegalBasis(
        category: "similar-cases",
        title: "类似案例",
        summary: "其他中国造船企业面临的制裁情况和应对措施。",
        details: [
          SimilarCase(
            company: "江南造船（集团）有限责任公司",
            date: "2020年12月",
            action: "被列入实体清单",
            impact: "技术引进受限，但通过加强自主研发保持了业务稳定",
          ),
          SimilarCase(
            company: "大连船舶重工集团",
            date: "2020年12月",
            action: "被列入实体清单",
            impact: "国际合作项目受影响，转向国内市场和友好国家市场",
          ),
          SimilarCase(
            company: "蓬莱巨涛海洋工程",
            date: "2024年6月",
            action: "被列入SDN清单",
            impact: "美元结算完全中断，国际业务严重受损",
          ),
        ],
      ),
    ],
    riskScore: RiskScore(
      totalScore: 265,
      riskLevel: "medium",
      components: RiskComponents(
        externalRisk: ExternalRisk(
          score: 95,
          breakdown: RiskBreakdown(
            investigationAnnounced: 10,
            investigationOngoing: 15,
            personnelInfiltration: 0,
            personnelExtraction: 0,
            technicalAttacks: 10,
            sanctionsImplemented: 25,
            legalActions: 20,
            reputationAttacks: 5,
            decouplingPressure: 10,
            foreignInfiltration: 0,
          ),
        ),
        internalRisk: InternalRisk(
          score: 20,
          breakdown: RiskBreakdown(
            investigationAnnounced: 5,
            investigationOngoing: 0,
            personnelInfiltration: 0,
            personnelExtraction: 0,
            technicalAttacks: 0,
            sanctionsImplemented: 0,
            legalActions: 0,
            reputationAttacks: 5,
            decouplingPressure: 0,
            foreignInfiltration: 0,
          ),
        ),
        operationalImpact: '90',
        securityImpact: '60',
      ),
      trend: [
        TrendScore(month: "2024年8月", score: 220),
        TrendScore(month: "2024年9月", score: 225),
        TrendScore(month: "2024年10月", score: 235),
        TrendScore(month: "2024年11月", score: 245),
        TrendScore(month: "2024年12月", score: 255),
        TrendScore(month: "2025年1月", score: 265),
      ],
    ),
    lastUpdated: "2025-01-09T15:00:00+08:00",
  );
}

class CompanyInfo {
  final String name;
  final String englishName;
  final String industry;
  final String location;
  final String establishedDate;
  final String registeredCapital;
  final String employees;
  final String website;

  CompanyInfo({
    required this.name,
    required this.englishName,
    required this.industry,
    required this.location,
    required this.establishedDate,
    required this.registeredCapital,
    required this.employees,
    required this.website,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'english_name': englishName,
      'industry': industry,
      'location': location,
      'established_date': establishedDate,
      'registered_capital': registeredCapital,
      'employees': employees,
      'website': website,
    };
  }

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      name: json['name'] as String,
      englishName: json['english_name'] as String,
      industry: json['industry'] as String,
      location: json['location'] as String,
      establishedDate: json['established_date'] as String,
      registeredCapital: json['registered_capital'] as String,
      employees: json['employees'] as String,
      website: json['website'] as String,
    );
  }

  factory CompanyInfo.mock() => CompanyInfo(
    name: "中船黄埔文冲船舶有限公司",
    englishName: "CSSC Huangpu Wenchong Shipbuilding Company Limited",
    industry: "船舶制造业",
    location: "广东省广州市",
    establishedDate: "1948年",
    registeredCapital: "50亿元人民币",
    employees: "8000+",
    website: "http://www.cssc-hwwc.com",
  );
}

class TimelineEvent {
  final String date;
  final String content;
  final List<Source> sources;

  TimelineEvent({
    required this.date,
    required this.content,
    required this.sources,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'content': content,
      'sources': sources.map((e) => e.toJson()).toList(),
    };
  }

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      date: json['date'] as String,
      content: json['content'] as String,
      sources: (json['sources'] as List)
          .map((e) => Source.fromJson(e))
          .toList(),
    );
  }
}

class Source {
  final String title;
  final String url;
  final String source;

  Source({
    required this.title,
    required this.url,
    required this.source,
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
      title: json['title'] as String,
      url: json['url'] as String,
      source: json['source'] as String,
    );
  }
}

class RiskFactor {
  final String type;
  final String title;
  final String level;
  final List<RiskFactorDetail> details;

  RiskFactor({
    required this.type,
    required this.title,
    required this.level,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'level': level,
      'details': details.map((e) => e.toJson()).toList(),
    };
  }

  factory RiskFactor.fromJson(Map<String, dynamic> json) {
    return RiskFactor(
      type: json['type'] as String,
      title: json['title'] as String,
      level: json['level'] as String,
      details: (json['details'] as List)
          .map((e) => RiskFactorDetail.fromJson(e))
          .toList(),
    );
  }
}

class RiskFactorDetail {
  final String title;
  final String description;

  RiskFactorDetail({
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }

  factory RiskFactorDetail.fromJson(Map<String, dynamic> json) {
    return RiskFactorDetail(
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }
}

class LegalBasis {
  final String category;
  final String title;
  final String summary;
  final dynamic details; // LegalBasisDetail 或 List<SimilarCase>

  LegalBasis({
    required this.category,
    required this.title,
    required this.summary,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'title': title,
      'summary': summary,
      'details': _detailsToJson(details),
    };
  }

  dynamic _detailsToJson(dynamic details) {
    if (details is LegalBasisDetail) {
      return details.toJson();
    } else if (details is List<SimilarCase>) {
      return details.map((e) => e.toJson()).toList();
    }
    return details;
  }

  factory LegalBasis.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as String;
    dynamic details;

    if (category == 'entity-list' || category == 'cmc-list') {
      details = LegalBasisDetail.fromJson(json['details']);
    } else if (category == 'similar-cases') {
      details = (json['details'] as List)
          .map((e) => SimilarCase.fromJson(e))
          .toList();
    } else {
      details = json['details'];
    }

    return LegalBasis(
      category: category,
      title: json['title'] as String,
      summary: json['summary'] as String,
      details: details,
    );
  }
}

class LegalBasisDetail {
  final String legalFramework;
  final String implementation;
  final String scope;
  final String penalties;

  LegalBasisDetail({
    required this.legalFramework,
    required this.implementation,
    required this.scope,
    required this.penalties,
  });

  Map<String, dynamic> toJson() {
    return {
      'legal_framework': legalFramework,
      'implementation': implementation,
      'scope': scope,
      'penalties': penalties,
    };
  }

  factory LegalBasisDetail.fromJson(Map<String, dynamic> json) {
    return LegalBasisDetail(
      legalFramework: json['legal_framework'] as String,
      implementation: json['implementation'] as String,
      scope: json['scope'] as String,
      penalties: json['penalties'] as String,
    );
  }
}

class SimilarCase {
  final String company;
  final String date;
  final String action;
  final String impact;

  SimilarCase({
    required this.company,
    required this.date,
    required this.action,
    required this.impact,
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
      company: json['company'] as String,
      date: json['date'] as String,
      action: json['action'] as String,
      impact: json['impact'] as String,
    );
  }
}

class RiskScore {
  final int totalScore;
  final String riskLevel;
  final RiskComponents components;
  final List<TrendScore> trend;

  RiskScore({
    required this.totalScore,
    required this.riskLevel,
    required this.components,
    required this.trend,
  });

  Map<String, dynamic> toJson() {
    return {
      'total_score': totalScore,
      'risk_level': riskLevel,
      'components': components.toJson(),
      'trend': trend.map((e) => e.toJson()).toList(),
    };
  }

  factory RiskScore.fromJson(Map<String, dynamic> json) {
    return RiskScore(
      totalScore: json['total_score'] as int,
      riskLevel: json['risk_level'] as String,
      components: RiskComponents.fromJson(json['components']),
      trend: (json['trend'] as List)
          .map((e) => TrendScore.fromJson(e))
          .toList(),
    );
  }
}

class RiskComponents {
  final ExternalRisk externalRisk;
  final InternalRisk internalRisk;
  final String operationalImpact;
  final String securityImpact;

  RiskComponents({
    required this.externalRisk,
    required this.internalRisk,
    required this.operationalImpact,
    required this.securityImpact,
  });

  Map<String, dynamic> toJson() {
    return {
      'external_risk': externalRisk.toJson(),
      'internal_risk': internalRisk.toJson(),
      'operational_impact': operationalImpact,
      'security_impact': securityImpact,
    };
  }

  factory RiskComponents.fromJson(Map<String, dynamic> json) {
    return RiskComponents(
      externalRisk: ExternalRisk.fromJson(json['external_risk']),
      internalRisk: InternalRisk.fromJson(json['internal_risk']),
      operationalImpact: json['operational_impact'],
      securityImpact: json['security_impact'],
    );
  }
}

class ExternalRisk {
  final int score;
  final RiskBreakdown breakdown;

  ExternalRisk({
    required this.score,
    required this.breakdown,
  });

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'breakdown': breakdown.toJson(),
    };
  }

  factory ExternalRisk.fromJson(Map<String, dynamic> json) {
    return ExternalRisk(
      score: json['score'] as int,
      breakdown: RiskBreakdown.fromJson(json['breakdown']),
    );
  }
}

class InternalRisk {
  final int score;
  final RiskBreakdown breakdown;

  InternalRisk({
    required this.score,
    required this.breakdown,
  });

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'breakdown': breakdown.toJson(),
    };
  }

  factory InternalRisk.fromJson(Map<String, dynamic> json) {
    return InternalRisk(
      score: json['score'] as int,
      breakdown: RiskBreakdown.fromJson(json['breakdown']),
    );
  }
}

class ImpactScore {
  final int score;

  ImpactScore({
    required this.score,
  });

  Map<String, dynamic> toJson() {
    return {'score': score};
  }

  factory ImpactScore.fromJson(Map<String, dynamic> json) {
    return ImpactScore(score: json['score'] as int);
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
      investigationAnnounced: json['investigation_announced'] as int? ?? 0,
      investigationOngoing: json['investigation_ongoing'] as int? ?? 0,
      personnelInfiltration: json['personnel_infiltration'] as int? ?? 0,
      personnelExtraction: json['personnel_extraction'] as int? ?? 0,
      technicalAttacks: json['technical_attacks'] as int? ?? 0,
      sanctionsImplemented: json['sanctions_implemented'] as int? ?? 0,
      legalActions: json['legal_actions'] as int? ?? 0,
      reputationAttacks: json['reputation_attacks'] as int? ?? 0,
      decouplingPressure: json['decoupling_pressure'] as int? ?? 0,
      foreignInfiltration: json['foreign_infiltration'] as int? ?? 0,
    );
  }
}

class TrendScore {
  final String month;
  final int score;

  TrendScore({
    required this.month,
    required this.score,
  });

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'score': score,
    };
  }

  factory TrendScore.fromJson(Map<String, dynamic> json) {
    return TrendScore(
      month: json['month'] as String,
      score: json['score'] as int,
    );
  }
}