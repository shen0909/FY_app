import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

class RiskCompanyDetail {
  String companyId;
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

  // 添加一个静态方法，返回所有mock数据的列表
  static List<RiskCompanyDetail> mockList() {
    final List<RiskCompanyDetail> mockList = [
      // 添加104-detail.json的数据
      RiskCompanyDetail(
        companyId: "104",
        companyInfo: CompanyInfo(
          name: "中船黄埔文冲船舶有限公司",
          englishName: "CSSC Huangpu Wenchong Shipbuilding Company Limited",
          industry: "船舶制造业",
          location: "广东省广州市",
          establishedDate: "1948年",
          registeredCapital: "50亿元人民币",
          employees: "8000+",
          website: "http://www.cssc-hwwc.com",
        ),
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
          totalScore: 125,
          riskLevel: "medium",
          components: RiskComponents(
            externalRisk: ExternalRisk(
              score: 35,
              breakdown: RiskBreakdown(
                investigationAnnounced: 0,
                investigationOngoing: 10,
                personnelInfiltration: 0,
                personnelExtraction: 0,
                technicalAttacks: 10,
                sanctionsImplemented: 15,
                legalActions: 0,
                reputationAttacks: 0,
                decouplingPressure: 0,
                foreignInfiltration: 0,
              ),
            ),
            internalRisk: InternalRisk(
              score: 10,
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
            operationalImpact: '0',
            securityImpact: '80',
          ),
          trend: [
            TrendScore(month: "2024年8月", score: 0),
            TrendScore(month: "2024年12月", score: 105),
            TrendScore(month: "2025年1月", score: 125),
          ],
        ),
        lastUpdated: "2025-05-09T15:00:00+08:00",
      ),
      // 添加401-detail.json的数据
      RiskCompanyDetail(
        companyId: "401",
        companyInfo: CompanyInfo(
          name: "华为技术有限公司",
          englishName: "Huawei Technologies Co., Ltd.",
          industry: "全球领先的信息与通信技术（ICT）解决方案供应商",
          location: "总部位于中国广东省深圳市龙岗区",
          establishedDate: "1987年",
          registeredCapital: "约403亿元人民币",
          employees: "197000+",
          website: "https://www.huawei.com",
        ),
        timelineTracking: [
          TimelineEvent(
            date: "2025年5月15-22日",
            content: "中国商务部和外交部先后五次对美国制裁措施表态，称美方措施是典型的单边霸凌行为，严重违反市场经济原则和国际经贸规则，敦促美方立即纠正错误做法，停止无理打压中国企业。",
            sources: [
              Source(
                title: "中国商务部新闻发言人就美国企图全球禁用中国先进计算芯片发表谈话",
                url: "https://www.mofcom.gov.cn/xwfb/xwfyrth/art/2025/art_9eadf7e9c71c4a4f80d7ca5ea5759a28.html",
                source: "中国商务部",
              ),
              Source(
                title: "中国敦促美国纠正在人工智能芯片限制方面的错误做法",
                url: "https://www.reuters.com/world/china/china-urges-us-correct-wrongdoings-chinese-ai-chip-curb-2025-05-19/",
                source: "路透社",
              ),
            ],
          ),
          TimelineEvent(
            date: "2025年5月14日",
            content: "美国商务部发布指导意见称，在世界上任何地方使用华为的昇腾人工智能（AI）芯片都会违反出口管制规定，警告未经华盛顿批准使用华为升腾芯片的企业可能面临严重的刑事和行政处罚，最高刑罚包括监禁、罚款、失去出口权或其它限制。",
            sources: [
              Source(
                title: "美国商务部工业与安全局官方网站",
                url: "https://www.bis.gov/media/documents/general-prohibition-10-guidance-may-13-2025.pdf",
                source: "美国商务部",
              ),
            ],
          ),
          TimelineEvent(
            date: "2025年5月13日",
            content: "美国商务部废除拜登政府人工智能扩散规则，出台三项政策加强AI芯片出口管制，对中国先进计算集成电路适用通用禁令10（GP10）的指导意见。",
            sources: [
              Source(
                title: "美国商务部关于可能适用于高级计算集成电路和其他用于训练AI模型的商品的管制政策声明",
                url: "https://www.bis.gov/media/documents/ai-policy-statement-training-ai-models-may-13-2025",
                source: "美国商务部",
              ),
            ],
          ),
        ],
        riskFactors: [
          RiskFactor(
            type: "tech-supply-risk",
            title: "技术供应链风险",
            level: "very-high",
            details: [
              RiskFactorDetail(
                title: "芯片断供风险",
                description: "美国全面限制向华为供应芯片，包括使用美国技术、设备生产的第三方芯片，导致华为无法获得先进制程芯片。",
              ),
              RiskFactorDetail(
                title: "操作系统依赖",
                description: "Android系统授权被撤销，迫使华为加速发展自有操作系统HarmonyOS，但生态建设面临挑战。",
              ),
            ],
          ),
          RiskFactor(
            type: "market-access",
            title: "市场准入风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "5G设备禁用",
                description: "美国及其盟友（英国、澳大利亚等）禁止使用华为5G设备，导致华为在关键市场份额大幅下滑。",
              ),
              RiskFactorDetail(
                title: "终端产品销售受限",
                description: "智能手机等终端产品在欧美市场销售受阻，市场份额受到严重影响。",
              ),
            ],
          ),
        ],
        legalBasis: [
          LegalBasis(
            category: "entity-list",
            title: "实体清单限制",
            summary: "美国商务部将华为及其关联公司列入实体清单，禁止美国企业在未获许可的情况下向华为提供产品和技术。",
            details: LegalBasisDetail(
              legalFramework: "《出口管理条例》(EAR)第744部分",
              implementation: "任何含美国技术或软件的产品，如需出口给华为，均需申请许可证",
              scope: "适用于全球企业，涵盖芯片、软件、设备等多种产品",
              penalties: "违规可能导致巨额罚款、刑事处罚及出口特权丧失",
            ),
          ),
          LegalBasis(
            category: "foreign-direct-product-rule",
            title: "外国直接产品规则",
            summary: "扩大实体清单的管辖范围，禁止使用美国技术的外国厂商向华为提供产品。",
            details: LegalBasisDetail(
              legalFramework: "《出口管理条例》修订版，针对华为特别修改",
              implementation: "使用美国技术、软件设计或生产的产品，均不得向华为提供",
              scope: "特别针对芯片制造，影响全球半导体供应链",
              penalties: "违规企业可能被列入实体清单，面临同样的制裁",
            ),
          ),
        ],
        riskScore: RiskScore(
          totalScore: 425,
          riskLevel: "very-high",
          components: RiskComponents(
            externalRisk: ExternalRisk(
              score: 100,
              breakdown: RiskBreakdown(
                investigationAnnounced: 10,
                investigationOngoing: 15,
                personnelInfiltration: 10,
                personnelExtraction: 10,
                technicalAttacks: 15,
                sanctionsImplemented: 25,
                legalActions: 10,
                reputationAttacks: 0,
                decouplingPressure: 5,
                foreignInfiltration: 0,
              ),
            ),
            internalRisk: InternalRisk(
              score: 25,
              breakdown: RiskBreakdown(
                investigationAnnounced: 5,
                investigationOngoing: 5,
                personnelInfiltration: 0,
                personnelExtraction: 0,
                technicalAttacks: 5,
                sanctionsImplemented: 0,
                legalActions: 0,
                reputationAttacks: 5,
                decouplingPressure: 5,
                foreignInfiltration: 0,
              ),
            ),
            operationalImpact: '200',
            securityImpact: '100',
          ),
          trend: [
            TrendScore(month: "2024年12月", score: 420),
            TrendScore(month: "2025年1月", score: 422),
            TrendScore(month: "2025年2月", score: 420),
            TrendScore(month: "2025年3月", score: 415),
            TrendScore(month: "2025年4月", score: 418),
            TrendScore(month: "2025年5月", score: 425),
          ],
        ),
        lastUpdated: "2025-05-24T16:30:00+08:00",
      ),
      // 添加503-detail.json的数据 - 深圳市鹏芯微集成电路制造有限公司
      RiskCompanyDetail(
        companyId: "503",
        companyInfo: CompanyInfo(
          name: "深圳市鹏芯微集成电路制造有限公司",
          englishName: "Shenzhen Pengxin Micro Integrated Circuit Manufacturing Co., Ltd.",
          industry: "半导体集成电路制造",
          location: "中国广东省深圳市龙岗区",
          establishedDate: "2021年6月",
          registeredCapital: "71.28亿元人民币",
          employees: "未公开",
          website: "https://www.pengxinwei.com",
        ),
        timelineTracking: [
          TimelineEvent(
            date: "2024年12月3日",
            content: "美国商务部工业和安全局（BIS）发布新规，将鹏芯微列入实体清单，限制其获取含美国技术的半导体设备和软件。",
            sources: [
              Source(
                title: "美国商务部实体清单更新公告",
                url: "https://www.federalregister.gov/documents/2024/12/03",
                source: "美国《联邦公报》",
              ),
              Source(
                title: "鹏芯微被列入美国实体清单",
                url: "https://www.stcn.com/article/detail/1437505.html",
                source: "证券时报网",
              ),
            ],
          ),
          TimelineEvent(
            date: "2024年9月19日",
            content: "抖音视频报道称鹏芯微被推测列入美国制裁名单，其与华为的关联引发关注，被指协助华为突破5G芯片生产限制。",
            sources: [
              Source(
                title: "鹏芯微制裁风险分析视频",
                url: "https://www.iesdouyin.com/share/video/7416327451367853322/",
                source: "抖音平台",
              ),
            ],
          ),
          TimelineEvent(
            date: "2024年3月22日",
            content: "美国商务部考虑将鹏芯微关联企业鹏新旭列入制裁名单，引发市场对鹏芯微潜在风险的担忧。",
            sources: [
              Source(
                title: "鹏新旭制裁风险报道",
                url: "https://www.zaobao.com.sg/realtime/china/story20221006-1320093",
                source: "联合早报",
              ),
            ],
          ),
          TimelineEvent(
            date: "2023年7月",
            content: "鹏芯微平湖生产基地正式投产，规划产能超2万片/月，标志着公司正式进入量产阶段。",
            sources: [
              Source(
                title: "鹏芯微平湖基地投产公告",
                url: "https://www.pengxinwei.com/news/2023-07-15",
                source: "鹏芯微官网",
              ),
            ],
          ),
        ],
        riskFactors: [
          RiskFactor(
            type: "tech-dependency",
            title: "技术封锁与供应链风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "设备供应限制",
                description: "被列入实体清单后，鹏芯微难以获取美国应用材料、泛林集团等企业的先进半导体设备，且ASML、东京电子等国际供应商的设备若含美国技术超25%，需额外申请许可，可能导致产能扩张受阻。",
              ),
              RiskFactorDetail(
                title: "软件工具限制",
                description: "无法获取含美国技术的EDA设计软件和工艺软件，影响芯片设计和生产流程优化。",
              ),
            ],
          ),
          RiskFactor(
            type: "supply-chain",
            title: "与华为关联的合规风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "代工合规风险",
                description: "鹏芯微被指为华为代工芯片，若被证实直接违反美国对华为的出口限制，可能面临更严厉制裁，如全面禁运或资产冻结。",
              ),
              RiskFactorDetail(
                title: "技术转移风险",
                description: "与华为的技术合作可能被认定为技术转移，面临知识产权和合规风险。",
              ),
            ],
          ),
          RiskFactor(
            type: "market-competition",
            title: "市场竞争与技术迭代压力",
            level: "medium",
            details: [
              RiskFactorDetail(
                title: "成熟制程竞争",
                description: "全球半导体设备巨头（如台积电、三星）在成熟制程领域持续优化成本，而鹏芯微需在28nm/20nm节点与中芯国际、华虹等国内企业竞争，同时面临先进封装技术（如Chiplet）的替代风险。",
              ),
              RiskFactorDetail(
                title: "客户集中风险",
                description: "主要客户可能集中在特定领域，存在客户结构单一的风险。",
              ),
            ],
          ),
        ],
        legalBasis: [
          LegalBasis(
            category: "entity-list",
            title: "实体清单机制",
            summary: "依据美国《出口管理条例》（EAR）第744节，BIS可将损害美国国家安全或外交政策利益的实体列入清单，限制其获取美国技术及产品。",
            details: LegalBasisDetail(
              legalFramework: "《出口管理条例》（EAR）第744部分",
              implementation: "需要获得BIS许可证才能出口受管制物项，许可证申请采用推定拒绝政策",
              scope: "涵盖美国原产物项、含有超过最低限度美国成分的外国产品、使用美国技术或软件的直接产品",
              penalties: "违规可能面临刑事起诉、民事罚款、出口特权撤销等处罚",
            ),
          ),
          LegalBasis(
            category: "direct-product-rule",
            title: "外国直接产品规则（FDP）",
            summary: "针对半导体设备，若外国生产的设备含美国技术超10%（特定场景下为25%），需申请出口许可。",
            details: LegalBasisDetail(
              legalFramework: "《出口管理条例》（EAR）第734.9条",
              implementation: "针对半导体制造设备的特殊管制措施",
              scope: "扩大了美国出口管制的域外效力",
              penalties: "限制国际供应商向被制裁实体提供含美技术的设备",
            ),
          ),
        ],
        riskScore: RiskScore(
          totalScore: 290,
          riskLevel: "high",
          components: RiskComponents(
            externalRisk: ExternalRisk(
              score: 90,
              breakdown: RiskBreakdown(
                investigationAnnounced: 10,
                investigationOngoing: 20,
                personnelInfiltration: 0,
                personnelExtraction: 0,
                technicalAttacks: 10,
                sanctionsImplemented: 30,
                legalActions: 10,
                reputationAttacks: 0,
                decouplingPressure: 10,
                foreignInfiltration: 0,
              ),
            ),
            internalRisk: InternalRisk(
              score: 30,
              breakdown: RiskBreakdown(
                investigationAnnounced: 10,
                investigationOngoing: 5,
                personnelInfiltration: 5,
                personnelExtraction: 5,
                technicalAttacks: 5,
                sanctionsImplemented: 0,
                legalActions: 0,
                reputationAttacks: 10,
                decouplingPressure: 5,
                foreignInfiltration: 0,
              ),
            ),
            operationalImpact: '120',
            securityImpact: '70',
          ),
          trend: [
            TrendScore(month: "2024年7月", score: 240),
            TrendScore(month: "2024年8月", score: 250),
            TrendScore(month: "2024年9月", score: 260),
            TrendScore(month: "2024年10月", score: 270),
            TrendScore(month: "2024年11月", score: 280),
            TrendScore(month: "2024年12月", score: 290),
          ],
        ),
        lastUpdated: "2024-12-15T09:45:00+08:00",
      ),
      // 添加505-detail.json的数据 - 中国电子
      RiskCompanyDetail(
        companyId: "505",
        companyInfo: CompanyInfo(
          name: "中国电子",
          englishName: "China Electronics Corporation",
          industry: "信息技术领域，核心业务涵盖集成电路、计算产业、数据应用、网络安全等，是中国电子信息产业的核心央企之一",
          location: "广东省深圳市",
          establishedDate: "1989年",
          registeredCapital: "未公开",
          employees: "未公开",
          website: "https://www.cec.com.cn",
        ),
        timelineTracking: [
          TimelineEvent(
            date: "2025年3月26日",
            content: "美国商务部工业与安全局（BIS）宣布将54家中国实体列入出口管制实体清单，其中包括多家中电子系企业，涉及人工智能、超算等领域。虽然未直接点名中国电子信息产业集团，但行业分析认为，此次制裁是对中国电子产业链的系统性打压，旨在限制中国在先进计算和半导体领域的发展。",
            sources: [
              Source(
                title: "美国将54家中国实体列入实体清单",
                url: "https://www.c114.com.cn/news/116/a1227638.html",
                source: "C114通信网",
              ),
            ],
          ),
          TimelineEvent(
            date: "2024年12月3日",
            content: "美国将140家中国半导体相关企业列入实体清单，包括北方华创、拓荆科技等设备厂商。中国电子旗下部分半导体制造子公司可能受此影响，面临设备进口限制和技术封锁。",
            sources: [
              Source(
                title: "美国大规模制裁中国半导体企业",
                url: "https://new.qq.com/omn/20241203/20241203A088G200.html",
                source: "腾讯新闻",
              ),
            ],
          ),
          TimelineEvent(
            date: "2024年9月10日",
            content: "中国电子通过国家集成电路产业基金获得政策支持，加大自主创新投入，推进关键核心技术攻关，提升产业链供应链安全水平。",
            sources: [
              Source(
                title: "中国电子获国家产业基金支持",
                url: "https://www.cec.com.cn/news/2024-09-10",
                source: "中国电子官网",
              ),
            ],
          ),
          TimelineEvent(
            date: "2023年8月20日",
            content: "西门子EDA暂停对中国服务，美国对EDA工具的限制影响中国电子旗下企业的芯片设计流程，凸显技术自主化的重要性。",
            sources: [
              Source(
                title: "西门子EDA暂停中国服务",
                url: "https://www.eda-china.com/news/2023-08-20",
                source: "EDA中国",
              ),
            ],
          ),
        ],
        riskFactors: [
          RiskFactor(
            type: "supply-chain",
            title: "供应链中断风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "设备依赖风险",
                description: "中国电子在半导体制造环节依赖美国设备和技术（如光刻机、刻蚀机），被列入实体清单后，可能无法获取关键零部件和软件，导致生产线停滞。例如，美国对EDA工具的限制（如西门子EDA暂停中国服务）已影响芯片设计流程。",
              ),
              RiskFactorDetail(
                title: "原材料供应风险",
                description: "关键原材料和高端零部件供应可能受到国际制裁影响，影响生产连续性。",
              ),
            ],
          ),
          RiskFactor(
            type: "tech-dependency",
            title: "技术封锁与研发受限",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "先进制程限制",
                description: "美国通过实体清单限制中国电子获取先进技术（如7nm以下制程工艺），迫使其转向成熟制程研发。尽管中国在28nm及以上节点取得进展，但高端芯片（如AI芯片）仍受制于海外技术。",
              ),
              RiskFactorDetail(
                title: "关键软件限制",
                description: "EDA工具、操作系统等关键软件的获取受限，影响产品研发和生产。",
              ),
            ],
          ),
          RiskFactor(
            type: "market-access",
            title: "市场准入与营收下滑",
            level: "medium",
            details: [
              RiskFactorDetail(
                title: "海外市场限制",
                description: "被制裁后，中国电子的海外市场（如欧美）可能受限，导致通信设备、消费电子等产品出口下降。例如，瑞典等国家已禁止使用华为设备，类似政策可能扩展至中国电子旗下产品。",
              ),
              RiskFactorDetail(
                title: "国际合作受阻",
                description: "国际技术合作和标准制定参与可能受到影响。",
              ),
            ],
          ),
        ],
        legalBasis: [
          LegalBasis(
            category: "similar-cases",
            title: "华为（同行业案例）",
            summary: "华为作为中国科技企业被美国制裁的标杆案例，为中国电子提供重要参考。",
            details: LegalBasisDetail(
              legalFramework: "美国以国家安全为由，依据EAR第744部分将华为列入实体清单，禁止其采购含美技术的产品",
              implementation: "华为旗下海思芯片设计受限，最终通过自主研发（如昇腾系列）实现部分替代",
              scope: "EAR第736.2(b)(10)节（通用禁令10）、ECCN 3A090分类",
              penalties: "制裁导致华为海外市场份额大幅下滑，需加速自主替代",
            ),
          ),
          LegalBasis(
            category: "similar-cases",
            title: "中兴通讯（同供应链案例）",
            summary: "中兴通讯的制裁案例展示了美国对供应链合规性的严格审查。",
            details: LegalBasisDetail(
              legalFramework: "中兴因违反美国对伊朗的出口禁令，依据EAR第744部分被实施7年出口禁令",
              implementation: "最终支付14亿美元罚款并改组管理层",
              scope: "EAR第744部分及《出口管制改革法案》（ECRA）",
              penalties: "中兴被迫大规模重组并完全接受美方监管",
            ),
          ),
        ],
        riskScore: RiskScore(
          totalScore: 330,
          riskLevel: "high",
          components: RiskComponents(
            externalRisk: ExternalRisk(
              score: 80,
              breakdown: RiskBreakdown(
                investigationAnnounced: 15,
                investigationOngoing: 15,
                personnelInfiltration: 5,
                personnelExtraction: 5,
                technicalAttacks: 10,
                sanctionsImplemented: 15,
                legalActions: 5,
                reputationAttacks: 5,
                decouplingPressure: 5,
                foreignInfiltration: 0,
              ),
            ),
            internalRisk: InternalRisk(
              score: 50,
              breakdown: RiskBreakdown(
                investigationAnnounced: 10,
                investigationOngoing: 10,
                personnelInfiltration: 5,
                personnelExtraction: 5,
                technicalAttacks: 5,
                sanctionsImplemented: 0,
                legalActions: 0,
                reputationAttacks: 10,
                decouplingPressure: 5,
                foreignInfiltration: 0,
              ),
            ),
            operationalImpact: '120',
            securityImpact: '80',
          ),
          trend: [
            TrendScore(month: "2024年10月", score: 290),
            TrendScore(month: "2024年11月", score: 300),
            TrendScore(month: "2024年12月", score: 310),
            TrendScore(month: "2025年1月", score: 315),
            TrendScore(month: "2025年2月", score: 320),
            TrendScore(month: "2025年3月", score: 330),
          ],
        ),
        lastUpdated: "2025-04-05T14:30:00+08:00",
      ),
      // 添加504-detail.json的数据 - 中兴通讯
      RiskCompanyDetail(
        companyId: "504",
        companyInfo: CompanyInfo(
          name: "中兴通讯股份有限公司",
          englishName: "ZTE Corporation",
          industry: "通信设备制造、信息技术服务，核心业务包括5G基站、光通信、芯片设计、云计算等",
          location: "总部位于中国广东省深圳市，在全球设有分支机构",
          establishedDate: "1985年",
          registeredCapital: "约人民币47亿元",
          employees: "约7万人",
          website: "https://www.zte.com.cn",
        ),
        timelineTracking: [
          TimelineEvent(
            date: "2025年5月23日",
            content: "美国联邦通讯委员会（FCC）宣布调查包括中兴通讯在内的9家中国通信企业，指控其威胁美国国家安全，并拟禁止关联中国实验室为美国市场提供检测认证服务。若新规通过，中兴通讯的产品可能因无法获得FCC认证而退出美国市场。",
            sources: [
              Source(
                title: "FCC宣布调查中国通信企业",
                url: "https://www.fcc.gov/document/fcc-investigates-china-telecom-companies-security-threat",
                source: "美国联邦通讯委员会官网",
              ),
              Source(
                title: "中兴等9家中国企业受FCC调查",
                url: "https://www.douyin.com/video/7367890123456789012",
                source: "抖音视频",
              ),
            ],
          ),
          TimelineEvent(
            date: "2025年4月22日",
            content: "抖音平台报道称，美国要求中兴通讯采购美国芯片占比需超过35%，并强制更换全部董事会及高管，派驻合规监督组长期入驻。此消息与2022年缓刑结束的判决存在矛盾，需进一步核实。",
            sources: [
              Source(
                title: "美国对中兴新要求报道",
                url: "https://www.douyin.com/video/7356789012345678901",
                source: "抖音视频",
              ),
            ],
          ),
          TimelineEvent(
            date: "2022年3月23日",
            content: "美国法院裁定中兴通讯结束2017年以来的5年缓刑期，无附加处罚，监察官任期结束。此判决标志着中兴通讯正式摆脱美国制裁框架。",
            sources: [
              Source(
                title: "中兴通讯缓刑期结束",
                url: "https://overseas.chinanews.com/2022/03-23/9717234.shtml",
                source: "海外网",
              ),
              Source(
                title: "中兴制裁框架解除",
                url: "https://www.douyin.com/video/7078901234567890123",
                source: "抖音视频",
              ),
            ],
          ),
          TimelineEvent(
            date: "2018年6月7日",
            content: "美国商务部与中兴通讯达成和解协议，撤销封杀禁令，但要求其支付10亿美元罚款并设立4亿美元保证金。此前，中兴因违反美国对伊朗出口管制被激活七年拒绝令，导致供应链中断。",
            sources: [
              Source(
                title: "中兴通讯和解协议",
                url: "https://www.caixin.com/2018-06-07/101267890.html",
                source: "财新网",
              ),
            ],
          ),
        ],
        riskFactors: [
          RiskFactor(
            type: "international-relations",
            title: "国际关系与政策风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "中美科技博弈",
                description: "中美科技博弈持续升级，美国以国家安全为由频繁对中国科技企业实施出口管制。中兴通讯作为通信设备龙头，可能再次被列入实体清单或面临更严格的采购限制。例如，2025年FCC对中兴的调查已显示美国政策进一步收紧。",
              ),
              RiskFactorDetail(
                title: "市场准入限制",
                description: "美国及其盟友国家可能进一步限制中兴通讯产品的市场准入，影响海外业务拓展。",
              ),
            ],
          ),
          RiskFactor(
            type: "supply-chain",
            title: "供应链依赖风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "核心芯片依赖",
                description: "中兴通讯的核心芯片（如基站处理器、FPGA）依赖美国供应商（如高通、英特尔）。若美国再次限制出口，可能导致生产中断。2018年制裁期间，中兴因无法采购美国元器件一度停摆。",
              ),
              RiskFactorDetail(
                title: "关键技术依赖",
                description: "在某些关键技术领域仍依赖国外供应商，存在供应链中断风险。",
              ),
            ],
          ),
          RiskFactor(
            type: "legal-compliance",
            title: "合规与法律风险",
            level: "medium",
            details: [
              RiskFactorDetail(
                title: "出口管制合规",
                description: "美国要求中兴通讯持续遵守出口管制合规要求，包括定期接受审计和派驻监督组。若违规可能面临罚款、重启拒绝令等后果。2024年财报显示，中兴因海外市场合规成本增加导致净利润下降9.66%。",
              ),
              RiskFactorDetail(
                title: "监管合规成本",
                description: "持续的合规要求增加了运营成本，影响盈利能力。",
              ),
            ],
          ),
        ],
        legalBasis: [
          LegalBasis(
            category: "entity-list",
            title: "中兴通讯自身案例",
            summary: "中兴通讯是美国制裁中国科技企业的重要先例，为理解美国制裁机制提供直接参考。",
            details: LegalBasisDetail(
              legalFramework: "《国际紧急经济权力法》（IEEPA）、《出口管理条例》（EAR）第744部分",
              implementation: "指控中兴向伊朗出口含美国技术的设备，违反美国对伊制裁；因未完全执行和解协议（如未处罚涉事员工），被激活七年拒绝令",
              scope: "禁止美国企业与中兴通讯进行业务往来，切断供应链",
              penalties: "支付14.6亿美元罚款，更换管理层，接受长期合规监督",
            ),
          ),
          LegalBasis(
            category: "similar-cases",
            title: "同行业类似案例",
            summary: "华为、海康威视、海能达等企业的制裁案例为中兴提供参考。",
            details: LegalBasisDetail(
              legalFramework: "EAR第744.11条（实体清单机制）、第744.21条（对华为的特别许可限制）",
              implementation: "限制美国企业与被制裁实体的业务往来",
              scope: "适用于所有涉及美国技术的产品和服务",
              penalties: "违规可能导致巨额罚款、刑事处罚及商业限制",
            ),
          ),
        ],
        riskScore: RiskScore(
          totalScore: 350,
          riskLevel: "high",
          components: RiskComponents(
            externalRisk: ExternalRisk(
              score: 80,
              breakdown: RiskBreakdown(
                investigationAnnounced: 15,
                investigationOngoing: 10,
                personnelInfiltration: 0,
                personnelExtraction: 0,
                technicalAttacks: 10,
                sanctionsImplemented: 20,
                legalActions: 15,
                reputationAttacks: 5,
                decouplingPressure: 5,
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
                technicalAttacks: 5,
                sanctionsImplemented: 0,
                legalActions: 0,
                reputationAttacks: 10,
                decouplingPressure: 5,
                foreignInfiltration: 0,
              ),
            ),
            operationalImpact: '150',
            securityImpact: '100',
          ),
          trend: [
            TrendScore(month: "2024年12月", score: 310),
            TrendScore(month: "2025年1月", score: 320),
            TrendScore(month: "2025年2月", score: 325),
            TrendScore(month: "2025年3月", score: 330),
            TrendScore(month: "2025年4月", score: 340),
            TrendScore(month: "2025年5月", score: 350),
          ],
        ),
        lastUpdated: "2025-05-24T10:15:00+08:00",
      ),
      // 添加506-detail.json的数据 - 大疆创新
      RiskCompanyDetail(
        companyId: "506",
        companyInfo: CompanyInfo(
          name: "深圳市大疆创新科技有限公司",
          englishName: "DJI (DJ-Innovations)",
          industry: "无人机制造与智能硬件",
          location: "广东省深圳市",
          establishedDate: "2006年",
          registeredCapital: "未公开",
          employees: "超过1.4万人",
          website: "https://www.dji.com",
        ),
        timelineTracking: [
          TimelineEvent(
            date: "2024年10月18日",
            content: "大疆起诉美国国防部，要求撤销其被列入'中国军事企业清单'的决定，称该认定缺乏事实依据且损害了公司声誉和商业利益。大疆在起诉书中强调其为民用无人机制造商，与军事活动无关。",
            sources: [
              Source(
                title: "大疆起诉美国国防部要求撤销军事企业认定",
                url: "https://www.caixin.com/2024-10-18/102244356.html",
                source: "财新网",
              ),
              Source(
                title: "DJI sues Pentagon to remove it from Chinese military company list",
                url: "https://www.reuters.com/business/aerospace-defense/dji-sues-pentagon-remove-it-chinese-military-company-list-2024-10-18/",
                source: "路透社",
              ),
            ],
          ),
          TimelineEvent(
            date: "2024年8月5日",
            content: "中国宣布自9月1日起限制无人机出口，反制美国制裁。这一措施被视为对美国限制中国无人机企业的直接回应，可能影响全球无人机供应链。",
            sources: [
              Source(
                title: "中国限制无人机出口新规正式实施",
                url: "https://www.163.com/news/article/J5K8QG5N0001899O.html",
                source: "网易新闻",
              ),
              Source(
                title: "商务部等部门发布关于无人驾驶航空器出口管制措施的公告",
                url: "http://www.mofcom.gov.cn/article/zwgk/zcfb/202408/20240803477063.shtml",
                source: "中国商务部",
              ),
            ],
          ),
          TimelineEvent(
            date: "2024年6月17日",
            content: "美国众议院通过《反制中国无人机法案》，禁止大疆无人机未来在美销售，但参议院未通过该条款。该法案试图全面禁止大疆产品在美国市场的销售，但立法进程尚未完成。",
            sources: [
              Source(
                title: "美众议院通过反制中国无人机法案",
                url: "https://www.reuters.com/technology/us-house-passes-bill-that-could-ban-dji-drones-2024-06-17/",
                source: "路透社",
              ),
              Source(
                title: "House passes bill that could ban DJI drones in the US",
                url: "https://www.theverge.com/2024/6/17/24179842/house-passes-bill-ban-dji-drones-us",
                source: "The Verge",
              ),
            ],
          ),
          TimelineEvent(
            date: "2020年12月18日",
            content: "美国商务部将大疆列入'实体清单'，禁止美国企业向其出口技术。这标志着美国对大疆制裁的正式开始，严重影响了大疆获取美国技术和组件的能力。",
            sources: [
              Source(
                title: "美国商务部将大疆等中国企业列入实体清单",
                url: "https://finance.sina.com.cn/tech/2020-12-19/doc-iiznezxs896234.shtml",
                source: "新浪财经",
              ),
              Source(
                title: "Commerce Department adds DJI to Entity List",
                url: "https://www.reuters.com/technology/us-adds-chinese-drone-maker-dji-entity-list-2020-12-18/",
                source: "路透社",
              ),
            ],
          ),
        ],
        riskFactors: [
          RiskFactor(
            type: "supply-chain",
            title: "供应链依赖风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "芯片依赖",
                description: "大疆无人机80%的芯片依赖进口，其中美国企业供应占比较高，可能因制裁导致核心零部件断供。",
              ),
              RiskFactorDetail(
                title: "技术获取限制",
                description: "被列入实体清单后，大疆获取美国高端技术和组件的渠道受阻，可能影响产品迭代和性能提升。",
              ),
            ],
          ),
          RiskFactor(
            type: "legal-compliance",
            title: "法律诉讼风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "专利纠纷",
                description: "美国以专利侵权为由多次起诉大疆，如2023年Textron案赔偿2.79亿美元，且可能通过'实体清单'限制技术获取。",
              ),
              RiskFactorDetail(
                title: "数据安全合规",
                description: "美国指控大疆产品存在数据安全风险，可能向中国政府传输敏感数据，这增加了产品合规和市场准入的难度。",
              ),
            ],
          ),
          RiskFactor(
            type: "market-access",
            title: "市场准入风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "全面禁售风险",
                description: "美国通过立法禁止政府机构采购大疆产品，并试图全面禁售，可能导致其在美市场份额下滑。《反制中国无人机法案》已在众议院通过，虽然参议院未通过，但立法趋势明显。",
              ),
              RiskFactorDetail(
                title: "国际市场连锁反应",
                description: "美国的限制措施可能导致其盟友国家跟进，形成连锁反应，进一步缩小大疆的国际市场空间。",
              ),
            ],
          ),
        ],
        legalBasis: [
          LegalBasis(
            category: "entity-list",
            title: "实体清单机制",
            summary: "美国商务部以'危害国家安全'为由将大疆列入清单，限制技术出口。",
            details: LegalBasisDetail(
              legalFramework: "《出口管理条例》第744节",
              implementation: "限制美国企业向大疆出口技术和组件，需要特别许可证",
              scope: "涵盖所有含美国技术或知识产权的产品和服务",
              penalties: "违规企业可能面临巨额罚款和刑事处罚",
            ),
          ),
          LegalBasis(
            category: "similar-cases",
            title: "投资黑名单",
            summary: "美国国防部将大疆列入'中国军事企业清单'，限制美国主体投资。",
            details: LegalBasisDetail(
              legalFramework: "《2021财年国防授权法案》第1260H条",
              implementation: "禁止美国人投资大疆，限制其资本市场融资渠道",
              scope: "适用于所有美国个人和实体的投资行为",
              penalties: "违规可能导致资产冻结和法律处罚",
            ),
          ),
        ],
        riskScore: RiskScore(
          totalScore: 170,
          riskLevel: "medium",
          components: RiskComponents(
            externalRisk: ExternalRisk(
              score: 95,
              breakdown: RiskBreakdown(
                investigationAnnounced: 10,
                investigationOngoing: 20,
                personnelInfiltration: 0,
                personnelExtraction: 0,
                technicalAttacks: 10,
                sanctionsImplemented: 30,
                legalActions: 0,
                reputationAttacks: 5,
                decouplingPressure: 20,
                foreignInfiltration: 0,
              ),
            ),
            internalRisk: InternalRisk(
              score: 25,
              breakdown: RiskBreakdown(
                investigationAnnounced: 5,
                investigationOngoing: 0,
                personnelInfiltration: 0,
                personnelExtraction: 0,
                technicalAttacks: 10,
                sanctionsImplemented: 0,
                legalActions: 0,
                reputationAttacks: 10,
                decouplingPressure: 0,
                foreignInfiltration: 0,
              ),
            ),
            operationalImpact: '30',
            securityImpact: '20',
          ),
          trend: [
            TrendScore(month: "2024年5月", score: 140),
            TrendScore(month: "2024年6月", score: 145),
            TrendScore(month: "2024年7月", score: 150),
            TrendScore(month: "2024年8月", score: 155),
            TrendScore(month: "2024年9月", score: 160),
            TrendScore(month: "2024年10月", score: 170),
          ],
        ),
        lastUpdated: "2024-10-20T16:30:00+08:00",
      ),
      // 添加507-detail.json的数据 - 华大基因
      RiskCompanyDetail(
        companyId: "507",
        companyInfo: CompanyInfo(
          name: "深圳华大基因股份有限公司",
          englishName: "BGI Genomics Co., Ltd.",
          industry: "生物科技/基因测序",
          location: "中国广东省深圳市盐田区",
          establishedDate: "2010年",
          registeredCapital: "未公开",
          employees: "未公开",
          website: "https://www.bgi.com",
        ),
        timelineTracking: [
          TimelineEvent(
            date: "2024年9月9日",
            content: "美国众议院通过《生物安全法案》（H.R.8333号法案），点名华大基因集团等中国生物技术公司，旨在限制其从美国联邦资助机构获取基因数据，并削减在美市场份额。该法案后续需提交参议院审议，立法进程走向尚不明确。",
            sources: [
              Source(
                title: "美国众议院通过《生物安全法案》",
                url: "https://www.voachinese.com/a/house-vote-on-biosecure-act-20240909/7777625.html",
                source: "美国之音",
              ),
              Source(
                title: "美众议院通过《生物安全法》草案 对中国药企'出海'影响几何？",
                url: "https://finance.sina.com.cn/chanjing/cyxw/2024-09-10/doc-incntkri789234.shtml",
                source: "21世纪经济报道",
              ),
            ],
          ),
          TimelineEvent(
            date: "2024年1月25日",
            content: "美国参众两院拟出台针对华大集团的'生物安全法案'，以'保护基因数据和国家安全'为由，限制其在美业务。法案在两党获得支持，对华大集团等企业预设性指控，解释法案通过后的潜在执行机制。",
            sources: [
              Source(
                title: "美众议院通过《生物安全法》草案 对中国药企'出海'影响几何？",
                url: "https://finance.sina.com.cn/chanjing/cyxw/2024-01-25/doc-incntkri789456.shtml",
                source: "21世纪经济报道",
              ),
              Source(
                title: "美国参众两院生物安全法案立法背景分析",
                url: "https://www.congress.gov/bill/118th-congress/house-bill/8333",
                source: "美国国会官网",
              ),
            ],
          ),
          TimelineEvent(
            date: "2022年9月9日",
            content: "华大智造成功登陆科创板上市，发行价87.18元，发行前市值突破360亿元，加速国产基因测序设备替代进程，间接回应美国技术压制。这是汪建继华大基因后的第二单IPO。",
            sources: [
              Source(
                title: "汪建第二单IPO来了：华大智造即将登陆科创板 发行前市值突破360亿",
                url: "https://finance.sina.com.cn/stock/relnews/cn/2022-09-09/doc-imqqsmrp234567.shtml",
                source: "21世纪经济报道",
              ),
              Source(
                title: "华大智造科创板上市公告",
                url: "https://www.sse.com.cn/disclosure/listedinfo/announcement/",
                source: "上海证券交易所",
              ),
            ],
          ),
        ],
        riskFactors: [
          RiskFactor(
            type: "international-relations",
            title: "国际政治与技术封锁风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "法案限制",
                description: "美国以'国家安全'为由，通过立法限制华大基因获取美国技术及市场准入，可能导致关键设备进口受限、国际合作受阻。",
              ),
              RiskFactorDetail(
                title: "技术封锁",
                description: "美国可能将华大基因列入实体清单，限制其获取关键技术和设备，影响研发和生产能力。",
              ),
            ],
          ),
          RiskFactor(
            type: "supply-chain",
            title: "供应链中断风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "设备依赖",
                description: "基因测序设备核心零部件依赖进口（如光学元件、芯片），若美国扩大制裁范围，可能影响生产连续性。",
              ),
              RiskFactorDetail(
                title: "原材料风险",
                description: "测序试剂和耗材部分依赖进口，可能面临供应链不稳定风险。",
              ),
            ],
          ),
          RiskFactor(
            type: "legal-compliance",
            title: "法律诉讼与合规风险",
            level: "medium",
            details: [
              RiskFactorDetail(
                title: "专利纠纷",
                description: "美国企业（如因美纳）曾以专利侵权为由对华大智造提起诉讼，未来可能面临更多知识产权纠纷。",
              ),
              RiskFactorDetail(
                title: "数据安全合规",
                description: "美国指控华大基因可能收集美国公民基因数据并与中国政府共享，增加数据合规风险。",
              ),
            ],
          ),
        ],
        legalBasis: [
          LegalBasis(
            category: "similar-cases",
            title: "同行业制裁案例",
            summary: "药明康德、商汤科技等案例为华大基因提供参考。",
            details: LegalBasisDetail(
              legalFramework: "美国《出口管理条例》（EAR）第744部分实体清单机制",
              implementation: "限制被列名企业获取美国技术及产品",
              scope: "涵盖基因测序设备、软件及相关技术",
              penalties: "违规可能导致巨额罚款及市场准入限制",
            ),
          ),
          LegalBasis(
            category: "entity-list",
            title: "美国《生物安全法案》",
            summary: "专门针对中国生物技术公司的立法，限制其从美国联邦机构获取基因数据。",
            details: LegalBasisDetail(
              legalFramework: "《国家安全法》及《对外贸易法》",
              implementation: "限制中国生物技术公司参与美国政府资助项目",
              scope: "覆盖基因数据收集、使用及设备采购",
              penalties: "违规可能导致行政处罚及市场限制",
            ),
          ),
        ],
        riskScore: RiskScore(
          totalScore: 210,
          riskLevel: "high",
          components: RiskComponents(
            externalRisk: ExternalRisk(
              score: 75,
              breakdown: RiskBreakdown(
                investigationAnnounced: 10,
                investigationOngoing: 20,
                personnelInfiltration: 0,
                personnelExtraction: 0,
                technicalAttacks: 10,
                sanctionsImplemented: 30,
                legalActions: 0,
                reputationAttacks: 5,
                decouplingPressure: 0,
                foreignInfiltration: 0,
              ),
            ),
            internalRisk: InternalRisk(
              score: 25,
              breakdown: RiskBreakdown(
                investigationAnnounced: 10,
                investigationOngoing: 10,
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
            operationalImpact: '70',
            securityImpact: '40',
          ),
          trend: [
            TrendScore(month: "2024年5月", score: 0),
            TrendScore(month: "2024年6月", score: 150),
            TrendScore(month: "2024年7月", score: 190),
            TrendScore(month: "2025年5月", score: 210),
          ],
        ),
        lastUpdated: "2025-05-10T09:30:00+08:00",
      ),
      // 添加508-detail.json的数据 - 比亚迪
      RiskCompanyDetail(
        companyId: "508",
        companyInfo: CompanyInfo(
          name: "比亚迪股份有限公司",
          englishName: "BYD Company Limited",
          industry: "新能源汽车制造、动力电池研发与生产、电子制造",
          location: "广东省深圳市",
          establishedDate: "1995年",
          registeredCapital: "未公开",
          employees: "超过70万人",
          website: "https://www.byd.com",
        ),
        timelineTracking: [
          TimelineEvent(
            date: "2024年9月20日",
            content: "美国商务部对中国电动汽车及电池相关产品展开贸易调查，比亚迪等中国企业成为重点关注对象。此举被视为美国进一步限制中国新能源汽车产业发展的措施。",
            sources: [
              Source(
                title: "美商务部调查中国电动汽车产业",
                url: "https://www.reuters.com/business/autos-transportation/us-commerce-dept-investigate-chinese-ev-industry-2024-09-20/",
                source: "路透社",
              ),
              Source(
                title: "美国对华新能源汽车贸易调查分析",
                url: "https://www.xinhuanet.com/auto/2024-09/20/c_1131026754.htm",
                source: "新华网",
              ),
            ],
          ),
          TimelineEvent(
            date: "2023年12月22日",
            content: "美国《2024财年国防授权法案》生效，禁止国防部从比亚迪采购电池，自2027年10月起实施。法案第805条以'国家安全'为由限制中国电池企业，比亚迪在美军事及政府相关领域的电池供应被切断。",
            sources: [
              Source(
                title: "美国2024财年国防授权法案全文",
                url: "https://www.congress.gov/bill/118th-congress/house-bill/2670",
                source: "美国国会官网",
              ),
              Source(
                title: "美国防授权法案禁止采购中国电池",
                url: "https://www.thepaper.cn/newsDetail_forward_25776345",
                source: "澎湃新闻",
              ),
            ],
          ),
        ],
        riskFactors: [
          RiskFactor(
            type: "international-relations",
            title: "国际贸易政策风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "贸易壁垒",
                description: "美国通过反补贴税、采购禁令等措施限制比亚迪电池及汽车产品进入美国市场，可能引发其他国家效仿，导致全球市场准入门槛提高。",
              ),
              RiskFactorDetail(
                title: "政策限制",
                description: "《国防授权法案》和《与依赖外国对手电池脱钩法案》等对比亚迪在美国政府相关市场形成系统性限制。",
              ),
            ],
          ),
          RiskFactor(
            type: "supply-chain",
            title: "供应链中断风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "零部件风险",
                description: "美国制裁可能导致比亚迪在美采购关键零部件受阻，如半导体、材料等，影响生产效率和成本控制。",
              ),
              RiskFactorDetail(
                title: "技术获取限制",
                description: "美国可能限制比亚迪获取先进芯片和软件，影响智能驾驶等关键技术的发展。",
              ),
            ],
          ),
          RiskFactor(
            type: "legal-compliance",
            title: "法律与合规风险",
            level: "medium",
            details: [
              RiskFactorDetail(
                title: "调查风险",
                description: "美国国会及政府机构对比亚迪展开调查（如2025年5月国土安全委员会要求提交文件），可能引发法律诉讼或声誉损害。",
              ),
              RiskFactorDetail(
                title: "合规成本",
                description: "应对美国及全球各种监管要求，合规成本不断增加，影响经营效率。",
              ),
            ],
          ),
        ],
        legalBasis: [
          LegalBasis(
            category: "similar-cases",
            title: "同行业制裁案例",
            summary: "宁德时代、国轩高科等案例为比亚迪提供参考。",
            details: LegalBasisDetail(
              legalFramework: "《国防授权法案》第1260H条",
              implementation: "将中国企业列入'中国军事公司'（CMC）清单，限制投资和采购",
              scope: "覆盖电池制造和电动汽车产业",
              penalties: "被限制参与美国政府采购，影响市场准入",
            ),
          ),
          LegalBasis(
            category: "entity-list",
            title: "美国贸易法规",
            summary: "《出口管理条例》和《反补贴税法》是美国限制比亚迪的主要法律工具。",
            details: LegalBasisDetail(
              legalFramework: "《出口管理条例》（EAR）、《反补贴税法》",
              implementation: "限制技术出口，加征关税",
              scope: "覆盖电池、电动汽车及相关零部件",
              penalties: "可能面临高额关税和市场准入限制",
            ),
          ),
        ],
        riskScore: RiskScore(
          totalScore: 235,
          riskLevel: "high",
          components: RiskComponents(
            externalRisk: ExternalRisk(
              score: 45,
              breakdown: RiskBreakdown(
                investigationAnnounced: 10,
                investigationOngoing: 20,
                personnelInfiltration: 0,
                personnelExtraction: 0,
                technicalAttacks: 10,
                sanctionsImplemented: 0,
                legalActions: 0,
                reputationAttacks: 5,
                decouplingPressure: 0,
                foreignInfiltration: 0,
              ),
            ),
            internalRisk: InternalRisk(
              score: 40,
              breakdown: RiskBreakdown(
                investigationAnnounced: 10,
                investigationOngoing: 10,
                personnelInfiltration: 0,
                personnelExtraction: 0,
                technicalAttacks: 0,
                sanctionsImplemented: 0,
                legalActions: 0,
                reputationAttacks: 5,
                decouplingPressure: 5,
                foreignInfiltration: 10,
              ),
            ),
            operationalImpact: '100',
            securityImpact: '50',
          ),
          trend: [
            TrendScore(month: "2024年9月", score: 0),
            TrendScore(month: "2025年6月", score: 235),
          ],
        ),
        lastUpdated: "2025-06-10T11:15:00+08:00",
      ),
      
      // 添加509-detail.json的数据 - 工业和信息化部电子第五研究所
      RiskCompanyDetail(
        companyId: "509",
        companyInfo: CompanyInfo(
          name: "工业和信息化部电子第五研究所",
          englishName: "China Electronic Product Reliability and Environmental Testing Research Institute (CEPREI)",
          industry: "电子信息产业中的检测认证、可靠性研究及标准化服务",
          location: "总部位于中国广东省广州市",
          establishedDate: "1955年",
          registeredCapital: "未公开",
          employees: "未公开",
          website: "https://www.ceprei.org",
        ),
        timelineTracking: [
          TimelineEvent(
            date: "2025年5月22日",
            content: "美国联邦通信委员会（FCC）全票通过新规，禁止被认定为'国家安全风险'的中国实验室参与测试出口到美国的电子设备。此举可能影响包括电子五所在内的中国权威检测机构的国际认证业务。",
            sources: [
              Source(
                title: "FCC新规则：禁止被认定受中国政府控制的'不良实验室'测试在美国销售的电子产品",
                url: "https://www.voachinese.com/a/fcc-adopted-new-rules-to-block-chinese-government-ability-to-assert-control-over-wireless-equipment-authorization-process-20250523/8032264.html",
                source: "美国之音",
              ),
              Source(
                title: "美机构禁被指存在安全风险的中国实验室测试销美电子产品",
                url: "https://www.rfi.fr/cn/%E5%9B%BD%E9%99%85/20250523-%E7%BE%8E%E6%9C%BA%E6%9E%84%E7%A6%81%E8%A2%AB%E6%8C%87%E5%AD%98%E5%AE%89%E5%85%A8%E9%A3%8E%E9%99%A9%E7%9A%84%E4%B8%AD%E5%9B%BD%E5%AE%9E%E9%AA%8C%E5%AE%A4%E6%B5%8B%E8%AF%95%E9%94%80%E7%BE%8E%E7%94%B5%E5%AD%90%E4%BA%A7%E5%93%81",
                source: "法国国际广播电台",
              ),
            ],
          ),
          TimelineEvent(
            date: "2024年10月",
            content: "美国商务部更新出口管制政策，进一步加强对华技术限制。作为中国电子产品检测领域的权威机构，电子五所可能面临获取先进测试设备和技术的限制。",
            sources: [
              Source(
                title: "美国出口管制政策对中国科技产业的影响分析",
                url: "https://www.bis.doc.gov/index.php/policy-guidance",
                source: "美国商务部工业与安全局",
              ),
            ],
          ),
          TimelineEvent(
            date: "2022年11月",
            content: "美国FCC禁止华为、中兴通讯等中国企业的电信设备进入美国市场。作为这些企业的重要合作伙伴，电子五所的相关检测认证业务受到影响。",
            sources: [
              Source(
                title: "FCC禁止华为中兴设备进入美国市场",
                url: "https://www.fcc.gov/document/fcc-prohibits-authorization-equipment-poses-national-security-risk",
                source: "美国联邦通信委员会",
              ),
            ],
          ),
        ],
        riskFactors: [
          RiskFactor(
            type: "tech-dependency",
            title: "技术封锁与供应链中断风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "设备获取困难",
                description: "美国对华科技制裁可能导致电子五所无法获取先进检测设备、软件工具及关键零部件，影响其技术研发和检测能力。",
              ),
              RiskFactorDetail(
                title: "技术更新受限",
                description: "测试认证领域的关键技术和标准更新可能受阻，降低国际竞争力。",
              ),
            ],
          ),
          RiskFactor(
            type: "international-relations",
            title: "国际合作受限风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "国际认可度降低",
                description: "被纳入实体清单或遭受其他制裁后，电子五所可能被排除在国际标准化组织的合作之外，削弱其在全球技术标准制定中的话语权。",
              ),
              RiskFactorDetail(
                title: "国际业务萎缩",
                description: "FCC新规直接禁止中国实验室参与美国市场电子产品认证，导致国际业务大幅萎缩。",
              ),
            ],
          ),
          RiskFactor(
            type: "legal-compliance",
            title: "业务合规风险",
            level: "medium",
            details: [
              RiskFactorDetail(
                title: "业务审查风险",
                description: "美国可能以'军民融合'或'支持军事应用'为由，对电子五所的检测项目进行追溯审查，要求其披露客户信息或停止特定领域服务。",
              ),
              RiskFactorDetail(
                title: "合规成本增加",
                description: "为应对美国及其盟友的限制措施，需增加合规审查环节，提高业务成本。",
              ),
            ],
          ),
        ],
        legalBasis: [
          LegalBasis(
            category: "similar-cases",
            title: "同行业制裁案例",
            summary: "华为、中兴通讯等案例为电子五所提供参考。",
            details: LegalBasisDetail(
              legalFramework: "出口管理条例第744节",
              implementation: "限制被列名实体获取美国技术和设备",
              scope: "涵盖测试设备、软件及相关技术",
              penalties: "违规可能导致巨额罚款及国际业务限制",
            ),
          ),
          LegalBasis(
            category: "entity-list",
            title: "FCC认证限制",
            summary: "美国FCC可以禁止中国实验室参与输美电子设备测试。",
            details: LegalBasisDetail(
              legalFramework: "美国通信法第303节",
              implementation: "FCC可禁止'国家安全风险'实验室参与认证",
              scope: "覆盖电子设备检测认证业务",
              penalties: "认证结果不被美国市场接受，导致业务受损",
            ),
          ),
        ],
        riskScore: RiskScore(
          totalScore: 10,
          riskLevel: "low",
          components: RiskComponents(
            externalRisk: ExternalRisk(
              score: 10,
              breakdown: RiskBreakdown(
                investigationAnnounced: 0,
                investigationOngoing: 0,
                personnelInfiltration: 0,
                personnelExtraction: 10,
                technicalAttacks: 0,
                sanctionsImplemented: 0,
                legalActions: 0,
                reputationAttacks: 0,
                decouplingPressure: 0,
                foreignInfiltration: 0,
              ),
            ),
            internalRisk: InternalRisk(
              score: 0,
              breakdown: RiskBreakdown(
                investigationAnnounced: 0,
                investigationOngoing: 0,
                personnelInfiltration: 0,
                personnelExtraction: 0,
                technicalAttacks: 0,
                sanctionsImplemented: 0,
                legalActions: 0,
                reputationAttacks: 0,
                decouplingPressure: 0,
                foreignInfiltration: 0,
              ),
            ),
            operationalImpact: '0',
            securityImpact: '0',
          ),
          trend: [
            TrendScore(month: "2024年9月", score: 0),
            TrendScore(month: "2025年6月", score: 10),
          ],
        ),
        lastUpdated: "2025-06-06T16:00:00+08:00",
      ),
      
      // 添加510-detail.json的数据 - 国家超级计算深圳中心
      RiskCompanyDetail(
        companyId: "510",
        companyInfo: CompanyInfo(
          name: "国家超级计算深圳中心",
          englishName: "National Supercomputing Centre in Shenzhen (NSCS)",
          industry: "信息技术/高性能计算",
          location: "中国广东省深圳市南山区",
          establishedDate: "2011年",
          registeredCapital: "未公开",
          employees: "未公开",
          website: "https://www.nsccsz.cn",
        ),
        timelineTracking: [
          TimelineEvent(
            date: "2019年6月21日",
            content: "美国商务部将中科曙光、无锡江南计算技术研究所等5家中国超算机构列入'实体清单'，指控其参与中国军方超级计算机开发。虽然深圳中心未直接被列入，但作为使用曙光设备的机构，其技术升级和设备采购可能受到间接影响。",
            sources: [
              Source(
                title: "美国将中科曙光等五家中国超算机构列入'实体清单'",
                url: "https://m.21jingji.com/article/20190622/herald/58a314463f5d6d0b308bde9be9c544be.html",
                source: "21世纪经济报道",
              ),
              Source(
                title: "遏制中国超算发展美国制裁中科曙光等5家中企",
                url: "https://companies.caixin.com/2019-06-22/101430332.html",
                source: "财新网",
              ),
            ],
          ),
          TimelineEvent(
            date: "2018年6月8日",
            content: "美国Summit超级计算机正式落成并投入使用，超越中国'神威·太湖之光'成为全球最快超算，标志着中美超算竞争的激烈化。此举对包括深圳中心在内的中国超算机构形成技术压力。",
            sources: [
              Source(
                title: "为超越神威·太湖之光而生：美国超级计算机顶点（Summit）",
                url: "https://www.chaosuanwiki.com/lingxianchaosuanpinpai/wei-chao-yue-shen-wei-tai-hu-zhi-guang-er-sheng-mei-guo-chao-ji-ji-suan-ji-ding-dian-Summit.html",
                source: "超算百科",
              ),
            ],
          ),
          TimelineEvent(
            date: "2015年2月18日",
            content: "美国将国家超级计算长沙中心、广州中心、天津中心、国防科学技术大学四家实体列入出口管制'实体清单'，开创了对中国超算中心制裁的先例，为后续对华超算制裁奠定了基础。",
            sources: [
              Source(
                title: "美国制裁中国超算产业链历史回顾",
                url: "https://www.scmp.com/tech/science-research/article/3015858/what-you-need-know-about-chinese-supercomputer-firms-added-us",
                source: "南华早报",
              ),
            ],
          ),
        ],
        riskFactors: [
          RiskFactor(
            type: "tech-dependency",
            title: "技术封锁与供应链中断风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "芯片获取受限",
                description: "美国对华科技制裁可能导致深圳中心难以获取先进的高性能芯片、计算组件及相关技术，影响现有超算系统升级和未来E级机研发进度。",
              ),
              RiskFactorDetail(
                title: "技术更新受阻",
                description: "超算系统的升级和新一代系统研发可能受到限制，拉大与国际先进水平的差距。",
              ),
            ],
          ),
          RiskFactor(
            type: "international-relations",
            title: "国际合作受限风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "学术交流障碍",
                description: "制裁可能削弱深圳中心与国际科研机构的合作，影响其参与全球超算项目、学术交流及技术共享。",
              ),
              RiskFactorDetail(
                title: "国际项目限制",
                description: "可能被排除在国际大科学计划之外，失去全球顶尖技术交流机会。",
              ),
            ],
          ),
          RiskFactor(
            type: "supply-chain",
            title: "设备更新替代压力",
            level: "medium",
            details: [
              RiskFactorDetail(
                title: "零部件断供风险",
                description: "现有曙光6000系统可能面临零部件供应困难，需要加速国产化替代，但短期内可能面临技术成熟度不足的挑战。",
              ),
              RiskFactorDetail(
                title: "替代技术成本高",
                description: "寻找替代解决方案将增加研发和采购成本，影响运营效率。",
              ),
            ],
          ),
        ],
        legalBasis: [
          LegalBasis(
            category: "similar-cases",
            title: "同行业制裁案例",
            summary: "中科曙光、无锡江南计算技术研究所等案例为深圳中心提供参考。",
            details: LegalBasisDetail(
              legalFramework: "出口管理条例第744节",
              implementation: "以'参与中国军方超级计算机开发'为由限制技术获取",
              scope: "覆盖超算芯片、设备及相关技术",
              penalties: "无法获取美国技术和产品，影响系统升级",
            ),
          ),
          LegalBasis(
            category: "entity-list",
            title: "先进计算直接产品规则",
            summary: "针对超级计算机相关技术的特殊出口管制。",
            details: LegalBasisDetail(
              legalFramework: "出口管理条例FDP规则",
              implementation: "要求包含美国技术的外国产品出口需额外许可",
              scope: "覆盖高性能计算芯片和软件",
              penalties: "违规可能导致供应商被列入实体清单",
            ),
          ),
        ],
        riskScore: RiskScore(
          totalScore: 50,
          riskLevel: "low",
          components: RiskComponents(
            externalRisk: ExternalRisk(
              score: 0,
              breakdown: RiskBreakdown(
                investigationAnnounced: 0,
                investigationOngoing: 0,
                personnelInfiltration: 0,
                personnelExtraction: 0,
                technicalAttacks: 0,
                sanctionsImplemented: 0,
                legalActions: 0,
                reputationAttacks: 0,
                decouplingPressure: 0,
                foreignInfiltration: 0,
              ),
            ),
            internalRisk: InternalRisk(
              score: 0,
              breakdown: RiskBreakdown(
                investigationAnnounced: 0,
                investigationOngoing: 0,
                personnelInfiltration: 0,
                personnelExtraction: 0,
                technicalAttacks: 0,
                sanctionsImplemented: 0,
                legalActions: 0,
                reputationAttacks: 0,
                decouplingPressure: 0,
                foreignInfiltration: 0,
              ),
            ),
            operationalImpact: '20',
            securityImpact: '30',
          ),
          trend: [
            TrendScore(month: "2024年9月", score: 0),
            TrendScore(month: "2025年6月", score: 50),
          ],
        ),
        lastUpdated: "2025-06-06T16:00:00+08:00",
      ),
      
      // 添加511-detail.json的数据 - 中芯国际（深圳）
      RiskCompanyDetail(
        companyId: "511",
        companyInfo: CompanyInfo(
          name: "中芯国际（深圳）",
          englishName: "SMIC (Shenzhen) Co., Ltd.",
          industry: "半导体制造业",
          location: "中国广东省深圳市",
          establishedDate: "2008年",
          registeredCapital: "未公开",
          employees: "未公开",
          website: "https://www.smics.com",
        ),
        timelineTracking: [
          TimelineEvent(
            date: "2020年12月18日",
            content: "美国商务部将中芯国际正式列入'实体清单'，以'防范军事最终用途风险'为由，要求美企向中芯国际出口特定技术需申请许可。深圳子公司作为集团成员，其设备进口和技术合作首次受到系统性限制。",
            sources: [
              Source(
                title: "美国将中芯国际列入实体清单",
                url: "https://www.bis.doc.gov/index.php/documents/about-bis/newsroom/press-releases/2695-2020-12-18-bis-press-release-entity-list-additions/file",
                source: "美国商务部",
              ),
              Source(
                title: "中芯国际回应被列入实体清单：与中国军方无关",
                url: "https://finance.sina.com.cn/tech/2020-12-19/doc-iiznezxs896234.shtml",
                source: "新浪财经",
              ),
            ],
          ),
          TimelineEvent(
            date: "2020年9月25日",
            content: "美国商务部初步将中芯国际列入出口管制观察名单，要求美国企业向中芯国际出口特定技术需要申请许可证。这是美国首次对中芯国际实施技术限制措施。",
            sources: [
              Source(
                title: "美国限制对中芯国际出口技术",
                url: "https://www.reuters.com/technology/us-restricts-tech-exports-chinas-smic-2020-09-25/",
                source: "路透社",
              ),
            ],
          ),
          TimelineEvent(
            date: "2022年10月7日",
            content: "美国商务部进一步收紧对华半导体出口管制，禁止14纳米及以下先进制程设备出口，中芯国际的先进制程研发受到严重影响。",
            sources: [
              Source(
                title: "美国升级半导体出口管制",
                url: "https://www.bis.doc.gov/index.php/policy-guidance/country-guidance/semiconductor-manufacturing-controls",
                source: "美国商务部工业与安全局",
              ),
            ],
          ),
        ],
        riskFactors: [
          RiskFactor(
            type: "supply-chain",
            title: "供应链依赖风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "设备依赖",
                description: "关键设备和材料高度依赖进口，其中美国供应商占比超过40%，制裁可能导致设备维护中断、材料供应短缺。",
              ),
              RiskFactorDetail(
                title: "零部件断供",
                description: "美国制裁导致光刻机、刻蚀机等关键设备的零部件难以获取，影响生产连续性。",
              ),
            ],
          ),
          RiskFactor(
            type: "tech-dependency",
            title: "技术封锁风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "先进制程受限",
                description: "美国限制EUV光刻机出口，导致无法升级至7nm以下先进制程，EDA工具禁令进一步制约芯片设计能力。",
              ),
              RiskFactorDetail(
                title: "技术断代风险",
                description: "无法获取最新制程技术，可能导致中芯国际在全球半导体市场竞争力下降。",
              ),
            ],
          ),
          RiskFactor(
            type: "market-access",
            title: "市场准入风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "客户流失",
                description: "可能失去部分国际客户订单，无法参与全球先进制程供应链竞争，市场份额面临台积电、三星挤压。",
              ),
              RiskFactorDetail(
                title: "国际市场萎缩",
                description: "美国及其盟友可能禁止采购中芯国际产品，导致国际市场份额下降。",
              ),
            ],
          ),
        ],
        legalBasis: [
          LegalBasis(
            category: "entity-list",
            title: "实体清单机制",
            summary: "美国以'军事最终用途风险'为由限制对中芯国际的技术出口。",
            details: LegalBasisDetail(
              legalFramework: "出口管理条例第744节",
              implementation: "对列入实体清单的企业出口需特别许可",
              scope: "覆盖半导体制造设备、材料及相关技术",
              penalties: "违规可能导致高额罚款及刑事处罚",
            ),
          ),
          LegalBasis(
            category: "similar-cases",
            title: "直接产品规则",
            summary: "限制外国企业使用美国技术生产的产品对华出口。",
            details: LegalBasisDetail(
              legalFramework: "出口管理条例第744.21节",
              implementation: "含美国技术的产品需额外许可才能出口给中芯国际",
              scope: "扩大美国出口管制的域外效力",
              penalties: "违规供应商可能被列入实体清单",
            ),
          ),
        ],
        riskScore: RiskScore(
          totalScore: 290,
          riskLevel: "high",
          components: RiskComponents(
            externalRisk: ExternalRisk(
              score: 75,
              breakdown: RiskBreakdown(
                investigationAnnounced: 10,
                investigationOngoing: 20,
                personnelInfiltration: 0,
                personnelExtraction: 0,
                technicalAttacks: 10,
                sanctionsImplemented: 30,
                legalActions: 0,
                reputationAttacks: 5,
                decouplingPressure: 0,
                foreignInfiltration: 0,
              ),
            ),
            internalRisk: InternalRisk(
              score: 25,
              breakdown: RiskBreakdown(
                investigationAnnounced: 10,
                investigationOngoing: 10,
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
            operationalImpact: '120',
            securityImpact: '70',
          ),
          trend: [
            TrendScore(month: "2024年9月", score: 0),
            TrendScore(month: "2025年6月", score: 245),
          ],
        ),
        lastUpdated: "2025-05-08T16:00:00+08:00",
      ),
      
      // 添加512-detail.json的数据 - 深圳光启尖端技术有限责任公司
      RiskCompanyDetail(
        companyId: "512",
        companyInfo: CompanyInfo(
          name: "深圳光启尖端技术有限责任公司",
          englishName: "Shenzhen Kuang-Chi Advanced Technology Co., Ltd.",
          industry: "铁路、船舶、航空航天和其他运输设备制造业",
          location: "中国广东省深圳市南山区",
          establishedDate: "2011年11月21日",
          registeredCapital: "10000万人民币",
          employees: "未公开",
          website: "https://www.kuang-chi.com",
        ),
        timelineTracking: [
          TimelineEvent(
            date: "2020年12月19日",
            content: "美国商务部将光启技术（包括子公司光启尖端）列入'实体清单'，限制其获取美国技术和产品。这是美国首次对光启实施技术封锁措施，主要因其业务涉及航空航天等国防领域。",
            sources: [
              Source(
                title: "美国商务部将光启列入实体清单",
                url: "https://www.bis.doc.gov/index.php/documents/about-bis/newsroom/press-releases/2020/2693-2020-12-18-bis-press-release-entity-list-military-end-user-additions/file",
                source: "美国商务部",
              ),
              Source(
                title: "光启技术回应被列入实体清单",
                url: "https://finance.sina.com.cn/stock/relnews/cn/2020-12-19/doc-iiznezxs896789.shtml",
                source: "新浪财经",
              ),
            ],
          ),
          TimelineEvent(
            date: "2018年4月",
            content: "光启技术成功研发多款电磁超材料产品，在航空航天领域取得重大技术突破，引起国际关注。",
            sources: [
              Source(
                title: "光启技术电磁超材料技术突破",
                url: "https://tech.sina.com.cn/it/2018-04-15/doc-ifyzeyqc123456.shtml",
                source: "科技日报",
              ),
            ],
          ),
        ],
        riskFactors: [
          RiskFactor(
            type: "tech-dependency",
            title: "技术封锁风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "技术获取受限",
                description: "被列入实体清单后，难以获取美国先进技术和设备，可能影响电磁超材料技术的进一步发展。",
              ),
              RiskFactorDetail(
                title: "研发受阻",
                description: "关键软件工具和材料获取受限，可能延缓新产品研发进度。",
              ),
            ],
          ),
          RiskFactor(
            type: "market-competition",
            title: "市场竞争风险",
            level: "medium",
            details: [
              RiskFactorDetail(
                title: "市场份额压力",
                description: "超材料市场发展潜力大，会吸引更多企业进入，公司面临市场份额被蚕食风险。",
              ),
              RiskFactorDetail(
                title: "技术迭代压力",
                description: "超材料技术更新迭代快，持续研发投入压力大。",
              ),
            ],
          ),
          RiskFactor(
            type: "business-dependency",
            title: "行业依赖风险",
            level: "medium",
            details: [
              RiskFactorDetail(
                title: "客户集中",
                description: "产品主要应用于军工等特定行业，对特定行业依赖度较高，政策变化可能对业绩产生较大影响。",
              ),
              RiskFactorDetail(
                title: "国际业务萎缩",
                description: "被列入实体清单后，国际合作伙伴减少，影响市场拓展。",
              ),
            ],
          ),
        ],
        legalBasis: [
          LegalBasis(
            category: "entity-list",
            title: "实体清单机制",
            summary: "美国以业务涉及航空航天等国防领域为由，认定威胁美国国家安全。",
            details: LegalBasisDetail(
              legalFramework: "出口管理条例第744节",
              implementation: "对列入实体清单的企业出口需特别许可",
              scope: "覆盖超材料技术相关设备、材料及软件",
              penalties: "违规可能导致高额罚款及刑事处罚",
            ),
          ),
          LegalBasis(
            category: "similar-cases",
            title: "军事最终用户清单",
            summary: "限制向被认定为军事最终用户的实体出口受管制物项。",
            details: LegalBasisDetail(
              legalFramework: "出口管理条例第744.21节",
              implementation: "以'最终军事用途'为由限制技术获取",
              scope: "涵盖可能用于军事用途的技术和产品",
              penalties: "违规供应商可能被列入实体清单",
            ),
          ),
        ],
        riskScore: RiskScore(
          totalScore: 380,
          riskLevel: "high",
          components: RiskComponents(
            externalRisk: ExternalRisk(
              score: 120,
              breakdown: RiskBreakdown(
                investigationAnnounced: 10,
                investigationOngoing: 20,
                personnelInfiltration: 0,
                personnelExtraction: 0,
                technicalAttacks: 10,
                sanctionsImplemented: 30,
                legalActions: 25,
                reputationAttacks: 5,
                decouplingPressure: 20,
                foreignInfiltration: 0,
              ),
            ),
            internalRisk: InternalRisk(
              score: 60,
              breakdown: RiskBreakdown(
                investigationAnnounced: 10,
                investigationOngoing: 10,
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
            operationalImpact: '120',
            securityImpact: '80',
          ),
          trend: [
            TrendScore(month: "2024年9月", score: 0),
            TrendScore(month: "2025年6月", score: 205),
          ],
        ),
        lastUpdated: "2025-06-08T16:00:00+08:00",
      ),
      
      // 添加513-detail.json的数据 - 国家超级计算广州中心
      RiskCompanyDetail(
        companyId: "513",
        companyInfo: CompanyInfo(
          name: "国家超级计算广州中心",
          englishName: "National Supercomputing Center in Guangzhou (NSCC Guangzhou)",
          industry: "高性能计算、信息技术服务业",
          location: "中国广东省广州市",
          establishedDate: "2012年",
          registeredCapital: "未公开",
          employees: "未公开",
          website: "https://www.nscc-gz.cn",
        ),
        timelineTracking: [
          TimelineEvent(
            date: "2025年5月31日",
            content: "美国商务部将飞腾、申威等7家中国实体列入'实体清单'，指控其参与中国军队超级计算机建设。尽管未明确提及广州中心，但其关联企业（如使用飞腾CPU的超算中心）可能受到间接影响。",
            sources: [
              Source(
                title: "美国制裁中国超算产业链",
                url: "https://www.reuters.com/technology/us-adds-chinese-ai-chip-firms-entity-list-2025-05-31/",
                source: "路透社",
              ),
              Source(
                title: "美商务部新增中国实体清单企业",
                url: "https://www.commerce.gov/news/press-releases/2025/05/bis-adds-entities-entity-list",
                source: "美国商务部",
              ),
            ],
          ),
          TimelineEvent(
            date: "2021年4月8日",
            content: "美国商务部将国家超级计算济南中心、深圳中心、无锡中心、郑州中心等7家实体列入'实体清单'，指控其支持中国军事现代化。广州中心虽未直接上榜，但其技术路径（如'天河二号'使用类似架构）与被制裁实体存在共性，为后续制裁埋下伏笔。",
            sources: [
              Source(
                title: "美国将7家中国超算实体列入制裁清单",
                url: "https://www.commerce.gov/news/press-releases/2021/04/commerce-adds-seven-chinese-supercomputing-entities-entity-list-their",
                source: "美国商务部",
              ),
              Source(
                title: "美国制裁中国七家超级计算机实体",
                url: "https://www.bbc.com/zhongwen/simp/world-56689334",
                source: "BBC中文",
              ),
            ],
          ),
          TimelineEvent(
            date: "2019年6月21日",
            content: "美国商务部将中科曙光等超算企业列入'实体清单'，标志着美国开始大规模制裁中国超算产业。这一先例为后续针对更多超算中心的制裁奠定了基础。",
            sources: [
              Source(
                title: "美国制裁中科曙光等中国超算企业",
                url: "https://www.commerce.gov/news/press-releases/2019/06/commerce-department-adds-five-chinese-entities-entity-list",
                source: "美国商务部",
              ),
              Source(
                title: "中美科技竞争升级",
                url: "https://www.reuters.com/article/us-usa-china-tech-idUSKCN1TM2B5",
                source: "路透社",
              ),
            ],
          ),
        ],
        riskFactors: [
          RiskFactor(
            type: "tech-dependency",
            title: "技术供应链中断风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "高端芯片依赖",
                description: "广州中心可能无法直接采购美国生产的高性能CPU、GPU芯片（如英特尔至强、英伟达A100），导致现有系统升级受阻，算力扩容能力受限。",
              ),
              RiskFactorDetail(
                title: "关键组件断供",
                description: "'天河星逸'系统的核心组件如高速互联设备、存储系统等可能受到美国出口管制影响。",
              ),
              RiskFactorDetail(
                title: "软件工具限制",
                description: "高性能计算所需的编译器、调试工具、优化软件等可能面临获取困难。",
              ),
            ],
          ),
          RiskFactor(
            type: "international-relations",
            title: "国际合作与学术交流受限",
            level: "medium",
            details: [
              RiskFactorDetail(
                title: "科研项目终止",
                description: "制裁可能导致广州中心与国际科研机构的合作项目（如气候模拟、天体物理研究）被迫终止，影响其在全球超算领域的学术影响力。",
              ),
              RiskFactorDetail(
                title: "人员交流限制",
                description: "研究人员参与国际会议、合作研究可能受到限制。",
              ),
            ],
          ),
          RiskFactor(
            type: "geopolitical",
            title: "地缘政治博弈风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "制裁升级风险",
                description: "美国将超算视为'军事现代化关键领域'，可能进一步升级制裁措施，将广州中心列入'军事最终用户清单'（MEU）。",
              ),
              RiskFactorDetail(
                title: "第三方压力",
                description: "国际合作伙伴可能因担心受到美国次级制裁而减少与广州中心的合作。",
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
              implementation: "需要获得BIS许可证才能出口受管制物项，许可证申请采用推定拒绝政策",
              scope: "涵盖美国原产物项、含有超过最低限度美国成分的外国产品、使用美国技术或软件的直接产品",
              penalties: "违规可能面临刑事起诉、民事罚款、出口特权撤销等处罚",
            ),
          ),
        ],
        riskScore: RiskScore(
          totalScore: 60,
          riskLevel: "low",
          components: RiskComponents(
            externalRisk: ExternalRisk(
              score: 10,
              breakdown: RiskBreakdown(
                investigationAnnounced: 0,
                investigationOngoing: 10,
                personnelInfiltration: 0,
                personnelExtraction: 0,
                technicalAttacks: 0,
                sanctionsImplemented: 0,
                legalActions: 0,
                reputationAttacks: 0,
                decouplingPressure: 0,
                foreignInfiltration: 0,
              ),
            ),
            internalRisk: InternalRisk(
              score: 0,
              breakdown: RiskBreakdown(
                investigationAnnounced: 0,
                investigationOngoing: 0,
                personnelInfiltration: 0,
                personnelExtraction: 0,
                technicalAttacks: 0,
                sanctionsImplemented: 0,
                legalActions: 0,
                reputationAttacks: 0,
                decouplingPressure: 0,
                foreignInfiltration: 0,
              ),
            ),
            operationalImpact: '20',
            securityImpact: '30',
          ),
          trend: [
            TrendScore(month: "2025年4月", score: 0),
            TrendScore(month: "2025年5月", score: 60),
          ],
        ),
        lastUpdated: "2025-05-30T16:30:00+08:00",
      ),
      
      // 添加514-detail.json的数据 - 中国南方电网有限责任公司
      RiskCompanyDetail(
        companyId: "514",
        companyInfo: CompanyInfo(
          name: "中国南方电网有限责任公司",
          englishName: "China Southern Power Grid Company Limited",
          industry: "电力供应与传输行业",
          location: "中国广东省广州市",
          establishedDate: "2004年",
          registeredCapital: "未公开",
          employees: "未公开",
          website: "https://www.csg.cn",
        ),
        timelineTracking: [
          TimelineEvent(
            date: "2023年5月18日",
            content: "菲律宾总统马科斯宣布暂停中国参与的电网项目，理由是国家安全担忧。菲律宾政府担心中国企业参与关键基础设施可能影响国家能源安全，这直接影响了南方电网的海外业务拓展。",
            sources: [
              Source(
                title: "菲律宾暂停中国电网项目引发能源安全担忧",
                url: "https://www.rappler.com/nation/marcos-suspends-china-power-grid-projects-security-concerns/",
                source: "Rappler",
              ),
              Source(
                title: "Philippines suspends China power grid projects over security concerns",
                url: "https://www.reuters.com/world/asia-pacific/philippines-suspends-china-power-grid-projects-security-concerns-2023-05-18/",
                source: "路透社",
              ),
            ],
          ),
          TimelineEvent(
            date: "2022年7月15日",
            content: "中国南方电网与老挝国家电力公司签署电力合作协议，参与老挝电网建设与运营，加强中老电力互联互通。这标志着南方电网在'一带一路'倡议下积极拓展海外市场。",
            sources: [
              Source(
                title: "中国南方电网与老挝深化电力合作",
                url: "https://www.xinhuanet.com/english/asiapacific/2022-07/15/c_1310646789.htm",
                source: "新华社",
              ),
              Source(
                title: "南方电网公司与老挝国家电力公司签署合作协议",
                url: "https://www.csg.cn/xwzx/2022/202207/t20220715_365421.html",
                source: "南方电网官网",
              ),
            ],
          ),
          TimelineEvent(
            date: "2018年10月11日",
            content: "美国政府在对华贸易战期间，开始审查中国国有企业在海外的投资项目，包括电网等关键基础设施领域，南方电网的海外项目面临更严格的审查。",
            sources: [
              Source(
                title: "US scrutinizes Chinese state-owned enterprises' overseas investments",
                url: "https://www.scmp.com/economy/china-economy/article/2168147/us-scrutinizes-chinese-soes-overseas-investments-trade-war",
                source: "南华早报",
              ),
              Source(
                title: "Trade war intensifies scrutiny of Chinese infrastructure investments",
                url: "https://www.ft.com/content/8b4e2d5a-cd65-11e8-b276-b9069bde0956",
                source: "金融时报",
              ),
            ],
          ),
        ],
        riskFactors: [
          RiskFactor(
            type: "geopolitical-risk",
            title: "地缘政治风险",
            level: "medium",
            details: [
              RiskFactorDetail(
                title: "海外项目安全审查",
                description: "菲律宾等国以国家安全为由暂停或审查中国电网企业参与的项目，影响南方电网海外业务拓展。",
              ),
              RiskFactorDetail(
                title: "中美关系影响",
                description: "中美贸易摩擦和科技竞争可能影响南方电网在第三国的项目合作和技术交流。",
              ),
              RiskFactorDetail(
                title: "关键基础设施敏感性",
                description: "电网作为国家关键基础设施，容易成为地缘政治博弈的焦点，面临政治风险。",
              ),
            ],
          ),
          RiskFactor(
            type: "technology-dependency",
            title: "技术依赖风险",
            level: "low",
            details: [
              RiskFactorDetail(
                title: "核心技术自主可控",
                description: "南方电网在特高压、柔性直流等核心电网技术方面已达到世界领先水平，技术依赖风险相对较低。",
              ),
              RiskFactorDetail(
                title: "智能电网设备",
                description: "部分高端智能电网设备和软件系统可能涉及国外技术，存在一定的技术风险。",
              ),
            ],
          ),
          RiskFactor(
            type: "market-access",
            title: "市场准入风险",
            level: "medium",
            details: [
              RiskFactorDetail(
                title: "海外市场限制",
                description: "部分国家对中国国有企业参与电网等关键基础设施项目设置限制或审查。",
              ),
              RiskFactorDetail(
                title: "投资审查加强",
                description: "各国对外资参与电网投资的审查趋严，可能影响南方电网的海外扩张。",
              ),
            ],
          ),
        ],
        legalBasis: [
          LegalBasis(
            category: "similar-cases",
            title: "外资投资审查机制",
            summary: "各国对外资参与关键基础设施投资的审查日趋严格，电网作为国家安全相关领域受到重点关注。",
            details: LegalBasisDetail(
              legalFramework: "各国外资投资法、国家安全审查法",
              implementation: "通过外国投资委员会等机构对涉及国家安全的投资进行审查",
              scope: "覆盖电网、电力等关键基础设施领域的投资和并购",
              penalties: "可能导致投资被禁止、附加条件或延期审批",
            ),
          ),
          LegalBasis(
            category: "entity-list",
            title: "关键基础设施保护法规",
            summary: "电网作为国家关键基础设施，各国都有相应的保护法规限制外资参与。",
            details: LegalBasisDetail(
              legalFramework: "国家安全法、关键基础设施保护法等",
              implementation: "限制外资在电网等关键基础设施中的参与程度和控制权",
              scope: "涵盖电网建设、运营、维护等各个环节",
              penalties: "违规可能面临投资撤销、业务限制等处罚",
            ),
          ),
        ],
        riskScore: RiskScore(
          totalScore: 60,
          riskLevel: "low",
          components: RiskComponents(
            externalRisk: ExternalRisk(
              score: 25,
              breakdown: RiskBreakdown(
                investigationAnnounced: 0,
                investigationOngoing: 10,
                personnelInfiltration: 0,
                personnelExtraction: 0,
                technicalAttacks: 10,
                sanctionsImplemented: 0,
                legalActions: 0,
                reputationAttacks: 5,
                decouplingPressure: 0,
                foreignInfiltration: 0,
              ),
            ),
            internalRisk: InternalRisk(
              score: 5,
              breakdown: RiskBreakdown(
                investigationAnnounced: 0,
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
            operationalImpact: '10',
            securityImpact: '20',
          ),
          trend: [
            TrendScore(month: "2024年12月", score: 0),
            TrendScore(month: "2025年5月", score: 60),
          ],
        ),
        lastUpdated: "2025-05-09T16:45:00+08:00",
      ),
      
      // 添加515-detail.json的数据 - 中国散裂中子源
      RiskCompanyDetail(
        companyId: "515",
        companyInfo: CompanyInfo(
          name: "中国散裂中子源",
          englishName: "China Spallation Neutron Source (CSNS)",
          industry: "科学研究与技术服务业",
          location: "中国广东省东莞市",
          establishedDate: "2018年（建成投用）",
          registeredCapital: "无（非盈利科研机构）",
          employees: "未公开",
          website: "https://www.csns.org.cn",
        ),
        timelineTracking: [
          TimelineEvent(
            date: "2024年3月22日",
            content: "彭博社报道称，美国政府正在考虑将更多中国科研机构列入制裁清单，其中可能包括散裂中子源等大科学装置相关机构，理由是担心相关技术可能被用于军事目的。",
            sources: [
              Source(
                title: "US considers expanding sanctions on Chinese research institutions",
                url: "https://www.bloomberg.com/news/articles/2024-03-22/us-considers-sanctions-chinese-research-institutions",
                source: "彭博社",
              ),
              Source(
                title: "美国或扩大制裁中国科研机构范围",
                url: "https://www.scmp.com/news/china/science/article/3254681/us-may-expand-sanctions-chinese-research-institutions",
                source: "南华早报",
              ),
            ],
          ),
          TimelineEvent(
            date: "2023年9月12日",
            content: "中国散裂中子源二期工程建设项目获得国家发改委批复，将新建13台中子散射谱仪，进一步提升科研能力。这标志着中国在中子散射技术领域的持续投入和发展。",
            sources: [
              Source(
                title: "中国散裂中子源二期工程获批",
                url: "https://www.cas.cn/syky/202309/t20230912_4753421.shtml",
                source: "中科院官网",
              ),
              Source(
                title: "CSNS Phase II project approved for construction",
                url: "https://english.cas.cn/newsroom/research_news/phys/202309/t20230912_318645.shtml",
                source: "中科院英文网",
              ),
            ],
          ),
          TimelineEvent(
            date: "2022年8月28日",
            content: "中国散裂中子源迎来建成投用四周年，累计为国内外400多个研究组提供实验机时超过2.2万小时，在新材料研发、工业检测等领域发挥重要作用。",
            sources: [
              Source(
                title: "中国散裂中子源四周年成果丰硕",
                url: "https://www.ihep.cas.cn/xwdt/kydt/202208/t20220828_6493182.html",
                source: "中科院高能所",
              ),
              Source(
                title: "China's spallation neutron source marks 4th anniversary",
                url: "https://english.cas.cn/newsroom/research_news/202208/t20220828_311234.shtml",
                source: "中科院英文网",
              ),
            ],
          ),
          TimelineEvent(
            date: "2021年5月20日",
            content: "美国商务部更新实体清单，虽然未直接列入散裂中子源，但对相关的高能物理研究设备出口实施更严格管制，可能影响设备升级和国际合作。",
            sources: [
              Source(
                title: "美国加强高能物理设备出口管制",
                url: "https://www.scmp.com/tech/policy/article/3134267/us-tightens-export-controls-high-energy-physics-equipment",
                source: "南华早报",
              ),
              Source(
                title: "US tightens export controls on high-energy physics equipment",
                url: "https://www.nature.com/articles/d41586-021-01234-z",
                source: "自然杂志",
              ),
            ],
          ),
          TimelineEvent(
            date: "2018年8月23日",
            content: "中国散裂中子源正式投入运行，习近平主席发来贺信。这标志着中国在大科学装置建设方面取得重大突破，成为发展中国家首个拥有散裂中子源的国家。",
            sources: [
              Source(
                title: "习近平致信祝贺中国散裂中子源投入运行",
                url: "http://www.xinhuanet.com/politics/leaders/2018-08/23/c_1123315567.htm",
                source: "新华网",
              ),
              Source(
                title: "China's first spallation neutron source officially commissioned",
                url: "https://english.cas.cn/newsroom/news/201808/t20180823_196789.shtml",
                source: "中科院英文网",
              ),
            ],
          ),
        ],
        riskFactors: [
          RiskFactor(
            type: "technology-security",
            title: "技术安全风险",
            level: "medium",
            details: [
              RiskFactorDetail(
                title: "军民两用技术敏感性",
                description: "散裂中子源技术涉及高能粒子加速器，可能被认为具有军民两用性质，面临技术管制风险",
              ),
              RiskFactorDetail(
                title: "国际合作限制",
                description: "美国等国可能限制与中国在高能物理领域的合作，影响技术交流和设备采购",
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
                description: "散裂中子源的部分关键设备和精密仪器可能依赖进口，存在供应链中断风险",
              ),
              RiskFactorDetail(
                title: "技术更新限制",
                description: "制裁可能影响设备升级和技术更新，影响科研效率",
              ),
            ],
          ),
          RiskFactor(
            type: "international-cooperation",
            title: "国际合作风险",
            level: "low",
            details: [
              RiskFactorDetail(
                title: "科研合作受限",
                description: "与国际同类机构的合作可能受到政治因素影响",
              ),
              RiskFactorDetail(
                title: "人员交流限制",
                description: "科研人员的国际交流可能面临签证和合作限制",
              ),
            ],
          ),
        ],
        legalBasis: [
          LegalBasis(
            category: "dual-use-technology",
            title: "军民两用技术管制",
            summary: "散裂中子源涉及的高能粒子加速器技术被认为具有军民两用性质，可能面临出口管制。",
            details: LegalBasisDetail(
              legalFramework: "《出口管理条例》、《瓦森纳安排》等国际军民两用技术管制机制",
              implementation: "限制相关技术和设备的出口，需要获得出口许可",
              scope: "涵盖加速器技术、中子源技术、精密测量设备等",
              penalties: "违规可能导致供应商被列入实体清单",
            ),
          ),
          LegalBasis(
            category: "research-institution-sanctions",
            title: "科研机构制裁机制",
            summary: "美国等国可能将中国科研机构列入制裁清单，限制技术获取和国际合作。",
            details: LegalBasisDetail(
              legalFramework: "实体清单、军工复合体企业清单等",
              implementation: "禁止或限制与被制裁机构的技术合作和设备出口",
              scope: "涵盖高能物理、核技术等敏感科研领域",
              penalties: "违规可能面临刑事起诉和民事处罚",
            ),
          ),
        ],
        riskScore: RiskScore(
          totalScore: 50,
          riskLevel: "low",
          components: RiskComponents(
            externalRisk: ExternalRisk(
              score: 10,
              breakdown: RiskBreakdown(
                investigationAnnounced: 0,
                investigationOngoing: 0,
                personnelInfiltration: 0,
                personnelExtraction: 0,
                technicalAttacks: 10,
                sanctionsImplemented: 0,
                legalActions: 0,
                reputationAttacks: 0,
                decouplingPressure: 0,
                foreignInfiltration: 0,
              ),
            ),
            internalRisk: InternalRisk(
              score: 0,
              breakdown: RiskBreakdown(
                investigationAnnounced: 0,
                investigationOngoing: 0,
                personnelInfiltration: 0,
                personnelExtraction: 0,
                technicalAttacks: 0,
                sanctionsImplemented: 0,
                legalActions: 0,
                reputationAttacks: 0,
                decouplingPressure: 0,
                foreignInfiltration: 0,
              ),
            ),
            operationalImpact: '20',
            securityImpact: '20',
          ),
          trend: [
            TrendScore(month: "2024年4月", score: 0),
            TrendScore(month: "2025年5月", score: 50),
          ],
        ),
        lastUpdated: "2025-05-09T17:00:00+08:00",
      ),
      
      // 添加516-detail.json的数据 - 中广核研究院有限公司
      RiskCompanyDetail(
        companyId: "516",
        companyInfo: CompanyInfo(
          name: "中广核研究院有限公司",
          englishName: "China Nuclear Power Technology Research Institute Co., Ltd.",
          industry: "核能技术研发与工程设计",
          location: "中国广东省深圳市",
          establishedDate: "2010年",
          registeredCapital: "未公开",
          employees: "未公开",
          website: "https://www.cgnpc.com.cn",
        ),
        timelineTracking: [
          TimelineEvent(
            date: "2019年8月19日",
            content: "美国商务部将中广核集团及其下属4家企业（包括中广核研究院）列入实体清单，指控其获取或试图获取美国技术用于中国军事核项目。这是美国首次将中国大型核能企业列入制裁清单。",
            sources: [
              Source(
                title: "美国商务部将中广核列入实体清单",
                url: "https://www.commerce.gov/news/press-releases/2019/08/commerce-department-adds-chinese-nuclear-companies-entity-list",
                source: "美国商务部",
              ),
              Source(
                title: "US adds Chinese nuclear companies to trade blacklist",
                url: "https://www.reuters.com/article/us-usa-china-nuclear-idUSKCN1V908P",
                source: "路透社",
              ),
            ],
          ),
          TimelineEvent(
            date: "2021年3月15日",
            content: "中广核研究院发布华龙一号全球首堆福清5号机组正式商运的技术成果，标志着中国自主三代核电技术正式走向世界。这是在美国制裁背景下中国核电技术的重大突破。",
            sources: [
              Source(
                title: "华龙一号全球首堆商运 中国核电技术走向世界",
                url: "https://www.cnnc.com.cn/xwzx/mtjj/202103/t20210315_445362.html",
                source: "中核集团官网",
              ),
              Source(
                title: "China's Hualong One reactor enters commercial operation",
                url: "https://www.world-nuclear-news.org/Articles/Fuqing-5-first-Hualong-One-enters-commercial-oper",
                source: "世界核工业新闻网",
              ),
            ],
          ),
          TimelineEvent(
            date: "2020年9月2日",
            content: "中广核研究院在小堆技术领域取得突破，ACPR50S海上浮动核电站关键技术通过国际原子能机构评审，展现了中国在核能创新技术方面的实力。",
            sources: [
              Source(
                title: "中广核海上浮动核电站技术获国际认可",
                url: "https://www.cgnpc.com.cn/xwzx/jtxw/202009/t20200902_437658.html",
                source: "中广核官网",
              ),
              Source(
                title: "IAEA reviews CGN's floating nuclear power plant technology",
                url: "https://www.world-nuclear-news.org/Articles/IAEA-reviews-CGNs-floating-nuclear-power-plant-tec",
                source: "世界核工业新闻网",
              ),
            ],
          ),
          TimelineEvent(
            date: "2018年10月17日",
            content: "英国政府批准中广核参与英国布拉德韦尔B核电项目，使用华龙一号技术。这是中国自主核电技术首次获得西方发达国家认可，但后因中英关系变化面临不确定性。",
            sources: [
              Source(
                title: "英国批准中广核参与布拉德韦尔B核电项目",
                url: "https://www.gov.uk/government/news/bradwell-b-nuclear-power-station-project-approved",
                source: "英国政府官网",
              ),
              Source(
                title: "UK approves Chinese nuclear project using Hualong One technology",
                url: "https://www.ft.com/content/0c2e5d8a-d221-11e8-a9f2-7574db66bcd5",
                source: "金融时报",
              ),
            ],
          ),
          TimelineEvent(
            date: "2017年5月25日",
            content: "华龙一号示范工程福清5号机组开始首次装料，标志着中国自主三代核电技术迈向产业化的重要里程碑。这一技术突破为中广核应对后续制裁奠定了基础。",
            sources: [
              Source(
                title: "华龙一号示范工程首次装料",
                url: "https://www.cgnpc.com.cn/xwzx/jtxw/202105/t20210525_471234.html",
                source: "中广核官网",
              ),
              Source(
                title: "China loads fuel into first Hualong One reactor",
                url: "https://www.world-nuclear-news.org/Articles/China-loads-fuel-into-first-Hualong-One-reactor",
                source: "世界核工业新闻网",
              ),
            ],
          ),
        ],
        riskFactors: [
          RiskFactor(
            type: "sanctions-impact",
            title: "制裁影响风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "技术获取限制",
                description: "被列入美国实体清单，限制获取美国核技术、设备和材料，影响技术升级和国际合作",
              ),
              RiskFactorDetail(
                title: "国际项目受阻",
                description: "制裁影响中广核在英国等西方国家的核电项目推进，国际化战略受挫",
              ),
              RiskFactorDetail(
                title: "供应链中断",
                description: "关键核级设备和材料的进口受限，可能影响核电项目建设进度",
              ),
            ],
          ),
          RiskFactor(
            type: "technology-security",
            title: "技术安全风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "核技术敏感性",
                description: "核能技术具有军民两用性质，容易成为国际制裁和技术封锁的目标",
              ),
              RiskFactorDetail(
                title: "知识产权风险",
                description: "在技术引进受限的情况下，需要避免潜在的知识产权纠纷和技术泄露风险",
              ),
            ],
          ),
          RiskFactor(
            type: "market-access",
            title: "市场准入风险",
            level: "medium",
            details: [
              RiskFactorDetail(
                title: "海外市场限制",
                description: "美国制裁可能影响中广核在第三国的核电项目竞标和合作",
              ),
              RiskFactorDetail(
                title: "金融合作受限",
                description: "国际金融机构可能因制裁风险而减少对相关项目的资金支持",
              ),
            ],
          ),
        ],
        legalBasis: [
          LegalBasis(
            category: "entity-list-sanctions",
            title: "实体清单制裁机制",
            summary: "中广核及其下属企业被美国列入实体清单，限制美国企业向其出口技术和产品。",
            details: LegalBasisDetail(
              legalFramework: "《出口管理条例》第744.11条",
              implementation: "禁止美国企业在未获得许可的情况下向被制裁实体出口受管制物项",
              scope: "涵盖核技术、核设备、核材料等敏感领域",
              penalties: "违规可能面临刑事起诉、民事罚款等严厉处罚",
            ),
          ),
          LegalBasis(
            category: "similar-cases",
            title: "核技术出口管制",
            summary: "核技术作为高度敏感技术，受到国际核供应国集团等多边管制机制严格控制。",
            details: LegalBasisDetail(
              legalFramework: "核供应国集团(NSG)准则、《不扩散核武器条约》等",
              implementation: "限制核技术和设备的国际转让，需要获得多方许可",
              scope: "涵盖核反应堆技术、核燃料循环技术、核材料等",
              penalties: "违规可能导致供应商被列入实体清单",
            ),
          ),
        ],
        riskScore: RiskScore(
          totalScore: 155,
          riskLevel: "medium",
          components: RiskComponents(
            externalRisk: ExternalRisk(
              score: 35,
              breakdown: RiskBreakdown(
                investigationAnnounced: 0,
                investigationOngoing: 10,
                personnelInfiltration: 0,
                personnelExtraction: 0,
                technicalAttacks: 10,
                sanctionsImplemented: 15,
                legalActions: 0,
                reputationAttacks: 0,
                decouplingPressure: 0,
                foreignInfiltration: 0,
              ),
            ),
            internalRisk: InternalRisk(
              score: 20,
              breakdown: RiskBreakdown(
                investigationAnnounced: 10,
                investigationOngoing: 10,
                personnelInfiltration: 0,
                personnelExtraction: 0,
                technicalAttacks: 0,
                sanctionsImplemented: 0,
                legalActions: 0,
                reputationAttacks: 0,
                decouplingPressure: 0,
                foreignInfiltration: 0,
              ),
            ),
            operationalImpact: '0',
            securityImpact: '100',
          ),
          trend: [
            TrendScore(month: "2024年12月", score: 0),
            TrendScore(month: "2025年5月", score: 155),
          ],
        ),
        lastUpdated: "2025-01-09T17:15:00+08:00",
      ),
      
      // 添加517-detail.json的数据 - 鹏城实验室
      RiskCompanyDetail(
        companyId: "517",
        companyInfo: CompanyInfo(
          name: "鹏城实验室",
          englishName: "Peng Cheng Laboratory",
          industry: "网络通信技术研发",
          location: "中国广东省深圳市",
          establishedDate: "2018年",
          registeredCapital: "未公开",
          employees: "未公开",
          website: "https://www.szpclab.com",
        ),
        timelineTracking: [
          TimelineEvent(
            date: "2025年1月3日",
            content: "美国商务部将鹏城实验室列入实体清单，指控其参与开发可能威胁美国国家安全的技术。这是美国首次将中国国家级科研实验室列入制裁清单，标志着科技制裁升级。",
            sources: [
              Source(
                title: "美国商务部将鹏城实验室等中国机构列入实体清单",
                url: "https://www.commerce.gov/news/press-releases/2025/01/commerce-adds-entities-entity-list",
                source: "美国商务部",
              ),
              Source(
                title: "US adds Peng Cheng Laboratory to Entity List",
                url: "https://www.reuters.com/technology/us-adds-peng-cheng-laboratory-entity-list-2025-01-03/",
                source: "路透社",
              ),
            ],
          ),
          TimelineEvent(
            date: "2024年11月15日",
            content: "鹏城实验室'鹏城云脑Ⅲ'大科学装置正式启用，算力性能达到每秒千万亿次级别，成为全球领先的AI计算平台。该装置为深圳乃至粤港澳大湾区的AI产业发展提供强大算力支撑。",
            sources: [
              Source(
                title: "鹏城云脑Ⅲ正式启用 算力达千万亿次级别",
                url: "https://www.szpclab.com/news/detail/1234567890",
                source: "鹏城实验室官网",
              ),
              Source(
                title: "Peng Cheng Cloud Brain III officially launched",
                url: "https://english.szpclab.com/news/detail/1234567890",
                source: "鹏城实验室英文网",
              ),
            ],
          ),
          TimelineEvent(
            date: "2023年8月20日",
            content: "鹏城实验室在6G无线通信技术方面取得重大突破，成功实现太赫兹频段100Gbps无线传输实验，为6G技术标准制定奠定基础。这一成果引起国际通信界广泛关注。",
            sources: [
              Source(
                title: "鹏城实验室实现6G太赫兹100Gbps传输突破",
                url: "https://www.cas.cn/syky/202308/t20230820_4792345.shtml",
                source: "中科院官网",
              ),
              Source(
                title: "Peng Cheng Lab achieves 6G terahertz transmission breakthrough",
                url: "https://english.cas.cn/newsroom/research_news/202308/t20230820_323456.shtml",
                source: "中科院英文网",
              ),
            ],
          ),
          TimelineEvent(
            date: "2022年5月12日",
            content: "鹏城实验室与华为、腾讯等企业联合发布'数字城市操作系统'，该系统整合了城市各类数据资源，为智慧城市建设提供底层技术支撑，展现了产学研融合创新能力。",
            sources: [
              Source(
                title: "鹏城实验室联合发布数字城市操作系统",
                url: "https://www.szpclab.com/news/detail/20220512",
                source: "鹏城实验室官网",
              ),
              Source(
                title: "Digital City OS unveiled by Peng Cheng Laboratory",
                url: "https://www.scmp.com/tech/innovation/article/3177234/digital-city-os-unveiled-peng-cheng-lab",
                source: "南华早报",
              ),
            ],
          ),
          TimelineEvent(
            date: "2020年9月25日",
            content: "鹏城实验室'鹏城云脑Ⅱ'正式发布，成为当时亚洲算力最强的AI计算平台，支撑了深圳乃至全国的人工智能研究和产业发展，为后续技术突破奠定基础。",
            sources: [
              Source(
                title: "鹏城云脑Ⅱ发布 成亚洲最强AI算力平台",
                url: "https://www.szpclab.com/news/detail/20200925",
                source: "鹏城实验室官网",
              ),
              Source(
                title: "Peng Cheng Cloud Brain II becomes Asia's most powerful AI platform",
                url: "https://www.chinadaily.com.cn/a/202009/25/WS5f6dd892a310675bc6c567fe.html",
                source: "中国日报",
              ),
            ],
          ),
        ],
        riskFactors: [
          RiskFactor(
            type: "sanctions-impact",
            title: "制裁影响风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "技术获取限制",
                description: "被列入美国实体清单，限制获取美国先进芯片、软件和技术，严重影响科研能力提升",
              ),
              RiskFactorDetail(
                title: "国际合作受阻",
                description: "制裁可能导致与国际科研机构的合作项目中断，影响国际学术交流",
              ),
              RiskFactorDetail(
                title: "设备采购困难",
                description: "高端科研设备和计算硬件的采购受限，可能影响大科学装置的升级和维护",
              ),
            ],
          ),
          RiskFactor(
            type: "technology-security",
            title: "技术安全风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "网络技术敏感性",
                description: "网络通信和网络安全技术具有高度敏感性，容易成为技术管制和制裁的目标",
              ),
              RiskFactorDetail(
                title: "数据安全风险",
                description: "实验室承担的数字城市和AI平台项目涉及大量数据，面临数据安全和隐私保护压力",
              ),
            ],
          ),
          RiskFactor(
            type: "research-collaboration",
            title: "科研合作风险",
            level: "medium",
            details: [
              RiskFactorDetail(
                title: "学术交流限制",
                description: "制裁可能影响与国际顶尖学者和机构的合作，限制人才引进和培养",
              ),
              RiskFactorDetail(
                title: "标准制定参与",
                description: "在6G等前沿技术标准制定中的参与可能受到限制，影响话语权",
              ),
            ],
          ),
        ],
        legalBasis: [
          LegalBasis(
            category: "entity-list-sanctions",
            title: "实体清单制裁机制",
            summary: "鹏城实验室被美国列入实体清单，限制美国企业向其出口技术和产品。",
            details: LegalBasisDetail(
              legalFramework: "《出口管理条例》第744.11条",
              implementation: "禁止美国企业在未获得许可的情况下向被制裁实体出口受管制物项",
              scope: "涵盖网络通信技术、AI芯片、高性能计算设备等",
              penalties: "违规可能面临刑事起诉、民事罚款等严厉处罚",
            ),
          ),
          LegalBasis(
            category: "research-institution-targeting",
            title: "科研机构制裁趋势",
            summary: "美国加强对中国科研机构的制裁，将国家级实验室列为重点目标。",
            details: LegalBasisDetail(
              legalFramework: "国家安全相关法律、出口管制法规等",
              implementation: "以国家安全为由限制技术转让和学术合作",
              scope: "覆盖网络通信、人工智能、量子计算等前沿科技领域",
              penalties: "严重影响中国科研机构的国际合作和技术获取能力",
            ),
          ),
        ],
        riskScore: RiskScore(
          totalScore: 165,
          riskLevel: "medium",
          components: RiskComponents(
            externalRisk: ExternalRisk(
              score: 40,
              breakdown: RiskBreakdown(
                investigationAnnounced: 0,
                investigationOngoing: 10,
                personnelInfiltration: 0,
                personnelExtraction: 0,
                technicalAttacks: 10,
                sanctionsImplemented: 15,
                legalActions: 0,
                reputationAttacks: 5,
                decouplingPressure: 0,
                foreignInfiltration: 0,
              ),
            ),
            internalRisk: InternalRisk(
              score: 5,
              breakdown: RiskBreakdown(
                investigationAnnounced: 0,
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
            operationalImpact: '40',
            securityImpact: '80',
          ),
          trend: [
            TrendScore(month: "2024年12月", score: 0),
            TrendScore(month: "2025年5月", score: 165),
          ],
        ),
        lastUpdated: "2025-05-09T17:30:00+08:00",
      ),
      
      // 添加518-detail.json的数据 - 深圳市昇维旭技术有限公司
      RiskCompanyDetail(
        companyId: "518",
        companyInfo: CompanyInfo(
          name: "深圳市昇维旭技术有限公司",
          englishName: "Shenzhen Shengweixu Technology Co., Ltd.",
          industry: "新型存储半导体技术",
          location: "中国广东省深圳市",
          establishedDate: "2019年",
          registeredCapital: "未公开",
          employees: "未公开",
          website: "https://www.shengweixu.com",
        ),
        timelineTracking: [
          TimelineEvent(
            date: "2024年12月2日",
            content: "美国商务部将深圳市昇维旭技术有限公司列入实体清单，指控其参与军民融合项目，存储技术可能被用于军事目的。这标志着美国对中国存储芯片产业的制裁进一步扩大。",
            sources: [
              Source(
                title: "美国商务部新增中国存储芯片企业至实体清单",
                url: "https://www.commerce.gov/news/press-releases/2024/12/commerce-adds-memory-chip-companies-entity-list",
                source: "美国商务部",
              ),
              Source(
                title: "US adds Chinese memory chip companies to trade blacklist",
                url: "https://www.reuters.com/technology/us-adds-chinese-memory-chip-companies-blacklist-2024-12-02/",
                source: "路透社",
              ),
            ],
          ),
          TimelineEvent(
            date: "2023年6月15日",
            content: "昇维旭技术在新型相变存储器技术方面取得突破，成功开发出具有自主知识产权的PCM存储器芯片，填补了国内在该技术领域的空白，为中国存储产业发展提供新方向。",
            sources: [
              Source(
                title: "昇维旭突破相变存储器技术 填补国内空白",
                url: "https://www.eet-china.com/news/article/54e1234567",
                source: "电子工程专辑",
              ),
              Source(
                title: "Shengweixu achieves breakthrough in phase-change memory technology",
                url: "https://www.semiconductor-today.com/news_items/2023/jun/shengweixu_150623.shtml",
                source: "Semiconductor Today",
              ),
            ],
          ),
          TimelineEvent(
            date: "2022年9月28日",
            content: "昇维旭技术获得深圳市政府专项资金支持，用于建设新型存储器产业化基地。该项目计划投资15亿元，建成后将具备年产50万片存储芯片的产能。",
            sources: [
              Source(
                title: "深圳支持昇维旭建设存储器产业化基地",
                url: "https://www.sz.gov.cn/szszf/xxgk/zfxxgj/tzgg/content/post_9876543.html",
                source: "深圳市政府官网",
              ),
              Source(
                title: "Shenzhen government supports Shengweixu memory chip project",
                url: "https://www.chinadaily.com.cn/a/202209/28/WS633a1234a31006754c5789ab.html",
                source: "中国日报",
              ),
            ],
          ),
          TimelineEvent(
            date: "2021年3月10日",
            content: "昇维旭技术完成A轮融资，获得多家投资机构5亿元投资，资金主要用于存储器芯片技术研发和人才引进。此轮融资为公司后续技术发展奠定了基础。",
            sources: [
              Source(
                title: "昇维旭完成5亿元A轮融资 加速存储芯片研发",
                url: "https://36kr.com/p/1234567890",
                source: "36氪",
              ),
              Source(
                title: "Shengweixu raises 500 million yuan in Series A funding",
                url: "https://technode.com/2021/03/10/shengweixu-series-a-funding/",
                source: "TechNode",
              ),
            ],
          ),
          TimelineEvent(
            date: "2019年8月20日",
            content: "深圳市昇维旭技术有限公司正式成立，注册资本1亿元人民币。公司成立时即确立了以新型存储技术为核心的发展战略，致力于打破国外存储芯片技术垄断。",
            sources: [
              Source(
                title: "昇维旭技术正式成立 专注存储芯片研发",
                url: "https://www.shengweixu.com/news/company-founded-2019",
                source: "昇维旭官网",
              ),
              Source(
                title: "New memory chip company founded in Shenzhen",
                url: "https://www.eejournal.com/article/new-memory-chip-company-founded-shenzhen/",
                source: "EE Journal",
              ),
            ],
          ),
        ],
        riskFactors: [
          RiskFactor(
            type: "sanctions-impact",
            title: "制裁影响风险",
            level: "high",
            details: [
              RiskFactorDetail(
                title: "设备采购受限",
                description: "被列入实体清单导致无法采购美国半导体制造设备，严重影响产能扩张",
              ),
              RiskFactorDetail(
                title: "技术获取困难",
                description: "限制获取美国存储器设计软件和制造技术，影响技术升级",
              ),
              RiskFactorDetail(
                title: "供应链中断",
                description: "关键原材料和零部件供应受限，可能导致生产中断",
              ),
            ],
          ),
          RiskFactor(
            type: "technology-dependency",
            title: "技术依赖风险",
            level: "medium",
            details: [
              RiskFactorDetail(
                title: "EDA工具依赖",
                description: "存储器设计依赖美国EDA软件，制裁可能影响芯片设计能力",
              ),
              RiskFactorDetail(
                title: "制造设备依赖",
                description: "高端存储器制造设备主要来自美国和日本，面临供应链风险",
              ),
            ],
          ),
          RiskFactor(
            type: "market-competition",
            title: "市场竞争风险",
            level: "medium",
            details: [
              RiskFactorDetail(
                title: "国际巨头竞争",
                description: "面临三星、SK海力士、美光等国际存储巨头的激烈竞争",
              ),
              RiskFactorDetail(
                title: "技术差距",
                description: "在先进制程和产品性能方面与国际领先企业存在差距",
              ),
            ],
          ),
        ],
        legalBasis: [
          LegalBasis(
            category: "entity-list-sanctions",
            title: "实体清单制裁机制",
            summary: "昇维旭技术被美国列入实体清单，限制美国企业向其出口技术和设备。",
            details: LegalBasisDetail(
              legalFramework: "《出口管理条例》第744.11条",
              implementation: "禁止美国企业在未获得许可的情况下向被制裁实体出口受管制物项",
              scope: "涵盖半导体设计软件、制造设备、关键材料等",
              penalties: "违规可能面临刑事起诉、民事罚款等严厉处罚",
            ),
          ),
          LegalBasis(
            category: "semiconductor-controls",
            title: "半导体出口管制",
            summary: "美国对中国半导体产业实施全面管制，存储芯片企业是重点目标。",
            details: LegalBasisDetail(
              legalFramework: "《芯片与科学法案》、半导体出口管制规则等",
              implementation: "限制先进制程设备和技术向中国出口",
              scope: "覆盖存储器设计、制造、封测等全产业链",
              penalties: "严重制约中国存储芯片产业发展",
            ),
          ),
        ],
        riskScore: RiskScore(
          totalScore: 290,
          riskLevel: "high",
          components: RiskComponents(
            externalRisk: ExternalRisk(
              score: 95,
              breakdown: RiskBreakdown(
                investigationAnnounced: 10,
                investigationOngoing: 20,
                personnelInfiltration: 0,
                personnelExtraction: 0,
                technicalAttacks: 10,
                sanctionsImplemented: 30,
                legalActions: 0,
                reputationAttacks: 5,
                decouplingPressure: 20,
                foreignInfiltration: 0,
              ),
            ),
            internalRisk: InternalRisk(
              score: 5,
              breakdown: RiskBreakdown(
                investigationAnnounced: 0,
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
            operationalImpact: '120',
            securityImpact: '70',
          ),
          trend: [
            TrendScore(month: "2024年12月", score: 0),
            TrendScore(month: "2025年5月", score: 290),
          ],
        ),
        lastUpdated: "2025-05-09T17:45:00+08:00",
      ),
    ];
    return mockList;
  }
}

class CompanyInfo {
  String name;
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
      // 处理 'cases' 字段或 'details' 字段
      final casesData = json.containsKey('cases') ? json['cases'] : json['details'];
      details = (casesData as List)
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
    // 处理 operational_impact 和 security_impact 可能是对象或直接数值的情况
    String operationalImpact;
    String securityImpact;
    
    if (json['operational_impact'] is Map) {
      operationalImpact = (json['operational_impact']['score'] ?? 0).toString();
    } else {
      operationalImpact = json['operational_impact']?.toString() ?? '0';
    }
    
    if (json['security_impact'] is Map) {
      securityImpact = (json['security_impact']['score'] ?? 0).toString();
    } else {
      securityImpact = json['security_impact']?.toString() ?? '0';
    }
    
    return RiskComponents(
      externalRisk: ExternalRisk.fromJson(json['external_risk']),
      internalRisk: InternalRisk.fromJson(json['internal_risk']),
      operationalImpact: operationalImpact,
      securityImpact: securityImpact,
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

  // 安全获取整数值的辅助方法
  static int _safeIntValue(Map<String, dynamic> json, String key, [List<String> alternativeKeys = const []]) {
    if (json.containsKey(key)) {
      return json[key] as int? ?? 0;
    }
    
    // 尝试替代键
    for (final altKey in alternativeKeys) {
      if (json.containsKey(altKey)) {
        return json[altKey] as int? ?? 0;
      }
    }
    
    return 0;
  }

  factory RiskBreakdown.fromJson(Map<String, dynamic> json) {
    return RiskBreakdown(
      investigationAnnounced: _safeIntValue(json, 'investigation_announced'),
      investigationOngoing: _safeIntValue(json, 'investigation_ongoing'),
      personnelInfiltration: _safeIntValue(json, 'personnel_infiltration'),
      personnelExtraction: _safeIntValue(json, 'personnel_extraction'),
      technicalAttacks: _safeIntValue(json, 'technical_attacks'),
      sanctionsImplemented: _safeIntValue(json, 'sanctions_implemented'),
      legalActions: _safeIntValue(json, 'legal_actions'),
      reputationAttacks: _safeIntValue(json, 'reputation_attacks', ['negative_publicity']),
      decouplingPressure: _safeIntValue(json, 'decoupling_pressure'),
      foreignInfiltration: _safeIntValue(json, 'foreign_infiltration'),
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