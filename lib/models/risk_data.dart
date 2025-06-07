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
      companies: (json['companies'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(
          key,
          (value as List).map((e) => Company.fromJson(e)).toList(),
        ),
      ),
      unreadMessages: (json['unread_messages'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(
          key,
          (value as List).map((e) => UnreadMessage.fromJson(e)).toList(),
        ),
      ),
      riskCategories: (json['risk_categories'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(
          key,
          RiskCategory.fromJson(value),
        ),
      ),
      severityLevels: (json['severity_levels'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(
          key,
          SeverityLevel.fromJson(value),
        ),
      ),
      riskLevels: (json['risk_levels'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(
          key,
          RiskLevel.fromJson(value),
        ),
      ),
      attentionLevels: (json['attention_levels'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(
          key,
          AttentionLevel.fromJson(value),
        ),
      ),
    );
  }

  factory RiskyData.mock() => RiskyData(
    metadata: Metadata(
      lastUpdated: "2025-01-09",
      version: "1.0.0",
      description: "风险预警系统完整数据 - 基于alerts.html页面数据整理",
      totalCompanies: 249,
      totalMessages: 168,
    ),
    statistics: Statistics(
      fengyun1: FengyunStats(
        name: "烽云一号",
        description: "第一代风险监控系统",
        stats: Stats(
          highRisk: 12,
          mediumRisk: 7,
          lowRisk: 31,
          total: 50,
          dailyChange: DailyChange(highRisk: 0, mediumRisk: 0, lowRisk: 0),
        ),
      ),
      fengyun2: FengyunStats(
        name: "烽云二号",
        description: "第二代风险监控系统",
        stats: Stats(
          highRisk: 18,
          mediumRisk: 10,
          lowRisk: 21,
          total: 49,
          dailyChange: DailyChange(highRisk: 0, mediumRisk: 1, lowRisk: -1),
        ),
      ),
      xingyun: XingyunStats(
        name: "星云",
        description: "星云关注度监控系统",
        stats: XingyunStatsData(
          keyFocus: 100,
          generalFocus: 50,
          total: 150,
          dailyChange: XingyunDailyChange(keyFocus: 3, generalFocus: -2),
        ),
      ),
    ),
    location: Location(
      province: "广东省",
      cities: [
        City(code: "all", name: "全部"),
        City(code: "guangzhou", name: "广州市"),
        City(code: "shenzhen", name: "深圳市"),
        City(code: "zhuhai", name: "珠海市"),
        City(code: "foshan", name: "佛山市"),
        City(code: "dongguan", name: "东莞市"),
        City(code: "zhongshan", name: "中山市"),
        City(code: "jiangmen", name: "江门市"),
        City(code: "huizhou", name: "惠州市"),
        City(code: "shantou", name: "汕头市"),
        City(code: "chaozhou", name: "潮州市"),
      ],
    ),
    companies: {
      'fengyun_1': [
        Company(
          id: "104",
          name: "中船黄埔文冲船舶有限公司",
          englishName: "CSSC Huangpu Wenchong Shipbuilding Company Limited",
          description: "中船集团旗下大型造船企业，专注于各类船舶建造与海工装备",
          riskLevel: "medium",
          riskLevelText: "中风险",
          city: "guangzhou",
          updateDate: "2025-01-09",
          unreadCount: 5,
          detailPage: "cssc-huangpu-detail.html",
          industry: "船舶制造",
          marketCap: null,
          stockPrice: null,
          tags: ["中船集团", "大型造船", "海工装备"],
          attentionLevel: null,
          attentionLevelText: null,
        ),
        Company(
          id: "101",
          name: "广船国际有限公司",
          englishName: "CSSC Guangzhou Longxue Shipbuilding Co.,Ltd.",
          description: "市值为 8448.59 万元 | 股价为 3.30 元人民币",
          riskLevel: "low",
          riskLevelText: "低风险",
          city: "guangzhou",
          updateDate: "2025-05-14",
          unreadCount: 3,
          detailPage: "gsi-detail.html",
          industry: "船舶制造",
          marketCap: "8448.59万元",
          stockPrice: "3.30元",
          tags: ["造船", "股票上市", "国企"],
          attentionLevel: null,
          attentionLevelText: null,
        ),
        Company(
          id: "102",
          name: "广州实验室",
          englishName: "Guangzhou Laboratory",
          description: "国家级科研机构，专注于生物医学与健康科学研究",
          riskLevel: "low",
          riskLevelText: "低风险",
          city: "guangzhou",
          updateDate: "2025-04-18",
          unreadCount: 2,
          detailPage: "gzlab-detail.html",
          industry: "科研机构",
          marketCap: null,
          stockPrice: null,
          tags: ["国家级", "生物医学", "科研"],
          attentionLevel: null,
          attentionLevelText: null,
        ),
        Company(
          id: "103",
          name: "华南理工大学",
          englishName: "South China University of Technology",
          description: "国家\"双一流\"建设高校，教育部直属全国重点大学",
          riskLevel: "low",
          riskLevelText: "低风险",
          city: "guangzhou",
          updateDate: "2025-04-19",
          unreadCount: 1,
          detailPage: "scut-detail.html",
          industry: "教育",
          marketCap: null,
          stockPrice: null,
          tags: ["双一流", "教育部直属", "重点大学"],
          attentionLevel: null,
          attentionLevelText: null,
        ),
        Company(
          id: "401",
          name: "华为技术有限公司",
          englishName: "Huawei Technologies Co., Ltd.",
          description: "全球领先的ICT基础设施和智能终端提供商",
          riskLevel: "high",
          riskLevelText: "高风险",
          city: "shenzhen",
          updateDate: "2025-05-14",
          unreadCount: 5,
          detailPage: "huawei-detail.html",
          industry: "通信技术",
          marketCap: null,
          stockPrice: null,
          tags: ["ICT", "智能终端", "全球领先"],
          attentionLevel: null,
          attentionLevelText: null,
        ),
        Company(
          id: "402",
          name: "中兴通讯股份有限公司",
          englishName: "ZTE Corporation",
          description: "市值：1245.8亿元 | 股价：28.45元（收市）",
          riskLevel: "high",
          riskLevelText: "高风险",
          city: "shenzhen",
          updateDate: "2025-05-14",
          unreadCount: 3,
          detailPage: "zte-detail.html",
          industry: "通信设备",
          marketCap: "1245.8亿元",
          stockPrice: "28.45元",
          tags: ["通信设备", "股票上市", "5G技术"],
          attentionLevel: null,
          attentionLevelText: null,
        ),
        Company(
          id: "403",
          name: "比亚迪股份有限公司",
          englishName: "BYD Company Limited",
          description: "市值：6982.5亿元 | 股价：237.52元（收市）",
          riskLevel: "high",
          riskLevelText: "高风险",
          city: "shenzhen",
          updateDate: "2025-05-14",
          unreadCount: 2,
          detailPage: "byd-detail.html",
          industry: "新能源汽车",
          marketCap: "6982.5亿元",
          stockPrice: "237.52元",
          tags: ["电动车", "新能源", "股票上市"],
          attentionLevel: null,
          attentionLevelText: null,
        ),
        Company(
          id: "501",
          name: "深圳市医学科学院",
          englishName: "Shenzhen Academy of Medical Sciences",
          description: "深圳市重要的医学科研机构，专注于转化医学研究",
          riskLevel: "high",
          riskLevelText: "高风险",
          city: "shenzhen",
          updateDate: "2025-01-06",
          unreadCount: 2,
          detailPage: "sams-detail.html",
          industry: "医学科研",
          marketCap: null,
          stockPrice: null,
          tags: ["医学科研", "转化医学", "深圳市"],
          attentionLevel: null,
          attentionLevelText: null,
        ),
        Company(
          id: "502",
          name: "中芯国际（深圳）",
          englishName: "SMIC (Shenzhen)",
          description: "中国大型集成电路制造企业，专注于先进芯片工艺",
          riskLevel: "high",
          riskLevelText: "高风险",
          city: "shenzhen",
          updateDate: "2025-05-20",
          unreadCount: 4,
          detailPage: "smic-shenzhen-detail.html",
          industry: "半导体",
          marketCap: null,
          stockPrice: null,
          tags: ["集成电路", "芯片制造", "先进工艺"],
          attentionLevel: null,
          attentionLevelText: null,
        ),
      ],
      'fengyun_2': [
        Company(
          id: "305",
          name: "中国科学院香港创新研究院",
          englishName: "Hong Kong Institute of Science & Innovation, CAS",
          description: "专注于人工智能、生物医药和材料科学领域的前沿研究",
          riskLevel: "high",
          riskLevelText: "高风险",
          city: "guangzhou",
          updateDate: "2025-04-22",
          unreadCount: 3,
          detailPage: "hkist-detail.html",
          industry: "科研机构",
          marketCap: null,
          stockPrice: null,
          tags: ["中科院", "人工智能", "生物医药", "材料科学"],
          attentionLevel: null,
          attentionLevelText: null,
        ),
        Company(
          id: "302",
          name: "云从科技集团股份有限公司",
          englishName: "CloudWalk Technology Co., Ltd.",
          description: "人工智能领域独角兽企业，专注于计算机视觉技术",
          riskLevel: "medium",
          riskLevelText: "中风险",
          city: "guangzhou",
          updateDate: "2025-01-06",
          unreadCount: 3,
          detailPage: "cloudwalk-detail.html",
          industry: "人工智能",
          marketCap: null,
          stockPrice: null,
          tags: ["独角兽", "计算机视觉", "AI技术"],
          attentionLevel: null,
          attentionLevelText: null,
        ),
        Company(
          id: "303",
          name: "金发科技股份有限公司",
          englishName: "Kingfa Science & Technology Co., Ltd.",
          description: "市值：198.6亿元 | 股价：7.32元（收市）",
          riskLevel: "low",
          riskLevelText: "低风险",
          city: "guangzhou",
          updateDate: "2025-01-06",
          unreadCount: 2,
          detailPage: "kingfa-detail.html",
          industry: "新材料",
          marketCap: "198.6亿元",
          stockPrice: "7.32元",
          tags: ["化工材料", "股票上市", "高分子"],
          attentionLevel: null,
          attentionLevelText: null,
        ),
      ],
      'xingyun': [
        Company(
          id: "204",
          name: "中芯国际集成电路制造有限公司",
          englishName: "Semiconductor Manufacturing International Corporation",
          description: "A股总市值：6624.19亿元人民币|收盘价为82.16元人民币",
          riskLevel: "high",
          riskLevelText: "高风险",
          city: "guangzhou",
          updateDate: "2025-05-28",
          unreadCount: 3,
          detailPage: "smic-detail.html",
          industry: "半导体",
          marketCap: "6624.19亿元",
          stockPrice: "82.16元",
          tags: ["集成电路", "芯片制造", "A股上市"],
          attentionLevel: "key_focus",
          attentionLevelText: "重点关注",
        ),
        Company(
          id: "205",
          name: "广东一知安全科技有限公司",
          englishName: "Guangdong Yizhi Security Technology Co., Ltd.",
          description: "专注于网络安全与数据保护的高新技术企业",
          riskLevel: "high",
          riskLevelText: "高风险",
          city: "guangzhou",
          updateDate: "2025-05-16",
          unreadCount: 2,
          detailPage: "yizhi-detail.html",
          industry: "网络安全",
          marketCap: null,
          stockPrice: null,
          tags: ["网络安全", "数据保护", "高新技术"],
          attentionLevel: "key_focus",
          attentionLevelText: "重点关注",
        ),
        Company(
          id: "202",
          name: "佳都科技集团股份有限公司",
          englishName: "PCI Technology Group Co., Ltd.",
          description: "市值：102.3亿元 | 股价：5.84元（收市）",
          riskLevel: "high",
          riskLevelText: "高风险",
          city: "guangzhou",
          updateDate: "2025-01-06",
          unreadCount: 4,
          detailPage: "pcitech-detail.html",
          industry: "智能科技",
          marketCap: "102.3亿元",
          stockPrice: "5.84元",
          tags: ["人工智能", "轨道交通", "股票上市"],
          attentionLevel: "key_focus",
          attentionLevelText: "重点关注",
        ),
        Company(
          id: "201",
          name: "广州云蝶科技有限公司",
          englishName: "Guangzhou Yundie Technology Co., Ltd.",
          description: "专注于人工智能和大数据分析技术开发的科技企业",
          riskLevel: "low",
          riskLevelText: "低风险",
          city: "guangzhou",
          updateDate: "2025-01-06",
          unreadCount: 2,
          detailPage: "yundie-detail.html",
          industry: "人工智能",
          marketCap: null,
          stockPrice: null,
          tags: ["人工智能", "大数据", "科技企业"],
          attentionLevel: "general_focus",
          attentionLevelText: "一般关注",
        ),
        Company(
          id: "203",
          name: "广州致景信息科技有限公司",
          englishName: "Guangzhou Zhijing Information Technology Co., Ltd.",
          description: "专注于信息安全与软件服务的高新技术企业",
          riskLevel: "low",
          riskLevelText: "低风险",
          city: "guangzhou",
          updateDate: "2025-01-06",
          unreadCount: 1,
          detailPage: "zhijing-detail.html",
          industry: "信息安全",
          marketCap: null,
          stockPrice: null,
          tags: ["信息安全", "软件服务", "高新技术"],
          attentionLevel: "general_focus",
          attentionLevelText: "一般关注",
        ),
      ],
    },
    unreadMessages: {
      '104': [
        UnreadMessage(
          id: "104-1",
          title: "美国国防部进一步解释CMC清单目的与影响",
          content: "美国国防部发布新的指导意见，对列入CMC清单企业的影响范围进行进一步说明",
          date: "2025-01-09",
          source: "https://www.defense.gov/News/Releases/2025-01-09",
          sourceName: "美国国防部",
          read: false,
          category: "政策风险",
          severity: "high",
          tags: ["政策变化", "制裁清单", "影响评估"],
        ),
        UnreadMessage(
          id: "104-2",
          title: "中船黄埔文冲被列入美国最新版\"中国涉军企业\"清单",
          content: "美国财政部更新中国涉军企业清单，中船黄埔文冲船舶有限公司被正式列入",
          date: "2025-01-06",
          source: "https://www.federalregister.gov/documents/2025/01/06",
          sourceName: "美国联邦公报",
          read: false,
          category: "制裁风险",
          severity: "high",
          tags: ["制裁清单", "涉军企业", "投资限制"],
        ),
        UnreadMessage(
          id: "104-3",
          title: "蓬莱巨涛因参与俄罗斯项目被美国列入SDN清单",
          content: "美国财政部将蓬莱巨涛海洋工程重工有限公司列入SDN清单，原因是其参与俄罗斯相关项目",
          date: "2024-06-19",
          source: "https://www.worldoe.com/html/2024/Shipyards_0618/204002.html",
          sourceName: "世界海事新闻",
          read: false,
          category: "制裁风险",
          severity: "high",
          tags: ["SDN清单", "俄罗斯项目", "制裁措施"],
        ),
        UnreadMessage(
          id: "104-4",
          title: "美国对航运及船舶行业制裁范围扩大",
          content: "美国财政部宣布扩大对航运及船舶制造行业的制裁范围，涉及多家中国企业",
          date: "2024-03-28",
          source: "https://www.treasury.gov/press-releases/2024-03-28",
          sourceName: "美国财政部",
          read: false,
          category: "行业风险",
          severity: "medium",
          tags: ["行业制裁", "航运业", "制裁扩大"],
        ),
        UnreadMessage(
          id: "104-5",
          title: "中国船舶集团下属25家机构被列入实体清单",
          content: "美国商务部将中国船舶集团下属25家机构列入实体清单，限制技术出口",
          date: "2020-12-20",
          source: "https://www.commerce.gov/news/2020-12-20",
          sourceName: "美国商务部",
          read: false,
          category: "制裁风险",
          severity: "high",
          tags: ["实体清单", "技术限制", "船舶集团"],
        ),
      ],
      '101': [
        UnreadMessage(
          id: "101-1",
          title: "美国国防部更新中国涉军企业清单",
          content: "美国国防部发布2025年最新版中国涉军企业清单，新增多家企业",
          date: "2025-01-06",
          source: "https://www.defense.gov/",
          sourceName: "美国国防部",
          read: false,
          category: "政策风险",
          severity: "high",
          tags: ["涉军清单", "政策更新", "投资限制"],
        ),
        UnreadMessage(
          id: "101-2",
          title: "蓬莱巨涛因涉俄项目被美国列入SDN清单",
          content: "蓬莱巨涛海洋工程重工有限公司因参与俄罗斯Arctic LNG 2项目被列入SDN清单",
          date: "2024-06-19",
          source: "https://www.worldoe.com/html/2024/Shipyards_0618/204002.html",
          sourceName: "世界海事新闻",
          read: false,
          category: "制裁风险",
          severity: "medium",
          tags: ["SDN清单", "俄罗斯项目", "海洋工程"],
        ),
        UnreadMessage(
          id: "101-3",
          title: "商船三井退出Arctic LNG 2项目租船合同",
          content: "日本商船三井宣布退出Arctic LNG 2项目的租船合同，受制裁影响",
          date: "2024-02-08",
          source: "http://m.toutiao.com/group/7333107879946043938/?upstream_biz=doubao",
          sourceName: "航运界",
          read: false,
          category: "业务风险",
          severity: "low",
          tags: ["项目退出", "租船合同", "制裁影响"],
        ),
      ],
      '102': [
        UnreadMessage(
          id: "102-1",
          title: "广州实验室在生物医学领域取得重大突破",
          content: "广州实验室在干细胞治疗和基因编辑技术方面取得重要进展",
          date: "2025-01-06",
          source: "https://www.gzlab.ac.cn/news/2025-01-06",
          sourceName: "广州实验室官网",
          read: false,
          category: "科研进展",
          severity: "low",
          tags: ["科研突破", "生物医学", "技术进展"],
        ),
        UnreadMessage(
          id: "102-2",
          title: "国际合作项目面临新的监管要求",
          content: "国家相关部门对生物医学领域国际合作项目提出新的数据安全和合规要求",
          date: "2025-01-06",
          source: "https://www.gzlab.ac.cn/news/2025-01-06",
          sourceName: "广州实验室官网",
          read: false,
          category: "合规风险",
          severity: "medium",
          tags: ["国际合作", "监管要求", "数据安全"],
        ),
      ],
      '103': [
        UnreadMessage(
          id: "103-1",
          title: "华南理工大学与美国高校合作项目调整",
          content: "华南理工大学宣布调整与部分美国高校的合作项目，以符合最新的国际合作规定",
          date: "2025-01-06",
          source: "https://www.scut.edu.cn/news/2025-01-06",
          sourceName: "华南理工大学官网",
          read: false,
          category: "合作风险",
          severity: "medium",
          tags: ["国际合作", "高校合作", "项目调整"],
        ),
      ],
      '305': [
        UnreadMessage(
          id: "305-1",
          title: "中科院香港创新研究院纳入美国关注监控名单",
          content: "美国相关部门将中科院香港创新研究院纳入重点关注监控名单",
          date: "2025-04-22",
          source: "https://www.hkisi.cas.cn/news/2025-04-22",
          sourceName: "中科院香港创新研究院",
          read: false,
          category: "监管风险",
          severity: "high",
          tags: ["监控名单", "科研机构", "国际关注"],
        ),
        UnreadMessage(
          id: "305-2",
          title: "中科院香港创新研究院暂停与麻省理工学院合作计划",
          content: "受国际形势影响，暂停与麻省理工学院的部分合作研究计划",
          date: "2025-03-15",
          source: "https://www.hkisi.cas.cn/news/2025-03-15",
          sourceName: "中科院香港创新研究院",
          read: false,
          category: "合作风险",
          severity: "medium",
          tags: ["合作暂停", "国际合作", "研究计划"],
        ),
        UnreadMessage(
          id: "305-3",
          title: "香港创新研究院AI技术进入国家战略审查范围",
          content: "研究院的人工智能技术被纳入国家战略技术审查范围",
          date: "2025-02-28",
          source: "https://www.hkisi.cas.cn/news/2025-02-28",
          sourceName: "中科院香港创新研究院",
          read: false,
          category: "政策风险",
          severity: "high",
          tags: ["战略审查", "AI技术", "国家政策"],
        ),
      ],
      '302': [
        UnreadMessage(
          id: "302-1",
          title: "云从科技AI技术被纳入出口管制清单",
          content: "云从科技的人脸识别和计算机视觉技术被列入技术出口管制清单",
          date: "2025-01-06",
          source: "https://www.cloudwalk.com/news/2025-01-06",
          sourceName: "云从科技官网",
          read: false,
          category: "贸易风险",
          severity: "high",
          tags: ["出口管制", "AI技术", "人脸识别"],
        ),
        UnreadMessage(
          id: "302-2",
          title: "云从科技获得新一轮战略投资",
          content: "云从科技完成新一轮战略投资，投资方包括多家知名机构",
          date: "2025-01-06",
          source: "https://www.cloudwalk.com/news/2025-01-06",
          sourceName: "云从科技官网",
          read: false,
          category: "融资动态",
          severity: "low",
          tags: ["战略投资", "融资", "机构投资"],
        ),
        UnreadMessage(
          id: "302-3",
          title: "欧盟审查中国AI企业数据处理合规性",
          content: "欧盟启动对中国AI企业在欧洲数据处理合规性的专项审查",
          date: "2025-01-06",
          source: "https://ec.europa.eu/digital/2025-01-06",
          sourceName: "欧盟委员会",
          read: false,
          category: "合规风险",
          severity: "medium",
          tags: ["欧盟审查", "数据合规", "AI企业"],
        ),
      ],
      '303': [
        UnreadMessage(
          id: "303-1",
          title: "金发科技被指在欧洲倾销高性能塑料产品",
          content: "欧盟对金发科技的高性能塑料产品启动反倾销调查",
          date: "2025-01-06",
          source: "https://www.reuters.com/business/2025-01-06",
          sourceName: "路透社",
          read: false,
          category: "贸易争端",
          severity: "medium",
          tags: ["反倾销", "贸易争端", "高性能塑料"],
        ),
        UnreadMessage(
          id: "303-2",
          title: "金发科技新型环保材料获国家科技进步奖",
          content: "金发科技研发的新型可降解材料获得国家科技进步奖二等奖",
          date: "2025-01-06",
          source: "https://www.kingfa.com/news/2025-01-06",
          sourceName: "金发科技官网",
          read: false,
          category: "科技成果",
          severity: "low",
          tags: ["科技奖项", "环保材料", "技术创新"],
        ),
      ],
      '204': [
        UnreadMessage(
          id: "204-1",
          title: "美国商务部将中芯国际列入实体清单",
          content: "美国商务部正式将中芯国际列入实体清单，限制其获得美国技术",
          date: "2020-12-18",
          source: "https://www.commerce.gov/news/press-releases/2020/12/commerce-adds-china-national-offshore-oil-corporation-and-subsidiaries",
          sourceName: "美国商务部",
          read: false,
          category: "制裁风险",
          severity: "high",
          tags: ["实体清单", "技术限制", "半导体"],
        ),
        UnreadMessage(
          id: "204-2",
          title: "中芯国际14纳米工艺技术获得突破",
          content: "中芯国际在14纳米FinFET工艺技术方面取得重要突破",
          date: "2024-08-15",
          source: "https://www.smic.com/news/2024-08-15",
          sourceName: "中芯国际官网",
          read: false,
          category: "技术突破",
          severity: "low",
          tags: ["工艺突破", "14纳米", "FinFET"],
        ),
        UnreadMessage(
          id: "204-3",
          title: "荷兰政府限制对华半导体设备出口",
          content: "荷兰政府宣布对华实施半导体制造设备出口限制措施",
          date: "2023-06-30",
          source: "https://www.government.nl/latest/news/2023/06/30/export-restrictions-semiconductor-manufacturing-equipment",
          sourceName: "荷兰政府",
          read: false,
          category: "供应链风险",
          severity: "high",
          tags: ["出口限制", "半导体设备", "供应链"],
        ),
      ],
      '205': [
        UnreadMessage(
          id: "205-1",
          title: "美国商务部将广东一知安全科技列入实体清单",
          content: "美国商务部将广东一知安全科技有限公司列入实体清单",
          date: "2025-05-16",
          source: "https://www.commerce.gov/news/2025-05-16",
          sourceName: "美国商务部",
          read: false,
          category: "制裁风险",
          severity: "high",
          tags: ["实体清单", "网络安全", "制裁措施"],
        ),
        UnreadMessage(
          id: "205-2",
          title: "广东一知安全科技获国家网络安全重点实验室认证",
          content: "公司获得国家网络安全重点实验室认证，技术实力得到认可",
          date: "2025-03-20",
          source: "https://www.yizhi-security.com/news/2025-03-20",
          sourceName: "一知安全官网",
          read: false,
          category: "资质认证",
          severity: "low",
          tags: ["实验室认证", "技术认可", "网络安全"],
        ),
      ],
      '202': [
        UnreadMessage(
          id: "202-1",
          title: "佳都科技中标广州地铁智能安防项目",
          content: "佳都科技成功中标广州地铁新线路智能安防系统建设项目",
          date: "2025-01-06",
          source: "https://www.pcitech.com/news/2025-01-06",
          sourceName: "佳都科技官网",
          read: false,
          category: "业务进展",
          severity: "low",
          tags: ["项目中标", "智能安防", "地铁系统"],
        ),
        UnreadMessage(
          id: "202-2",
          title: "佳都科技AI芯片研发取得突破",
          content: "公司自主研发的AI芯片在性能测试中取得重要突破",
          date: "2025-01-06",
          source: "https://www.pcitech.com/news/2025-01-06",
          sourceName: "佳都科技官网",
          read: false,
          category: "技术突破",
          severity: "low",
          tags: ["AI芯片", "技术突破", "自主研发"],
        ),
        UnreadMessage(
          id: "202-3",
          title: "分析师下调佳都科技评级至\"中性\"",
          content: "多家证券机构分析师下调佳都科技投资评级至\"中性\"",
          date: "2025-01-06",
          source: "https://finance.eastmoney.com/news/2025-01-06",
          sourceName: "东方财富",
          read: false,
          category: "市场风险",
          severity: "medium",
          tags: ["评级下调", "投资评级", "市场表现"],
        ),
        UnreadMessage(
          id: "202-4",
          title: "佳都科技董事长增持公司股份500万股",
          content: "公司董事长通过二级市场增持公司股份500万股",
          date: "2025-01-06",
          source: "https://www.cnstock.com/company/2025-01-06",
          sourceName: "中国证券网",
          read: false,
          category: "股权变动",
          severity: "low",
          tags: ["董事长增持", "股权变动", "股份增持"],
        ),
      ],
      '201': [
        UnreadMessage(
          id: "201-1",
          title: "广州云蝶获得5000万美元B轮融资",
          content: "广州云蝶科技完成5000万美元B轮融资，投资方包括多家知名VC",
          date: "2025-01-06",
          source: "https://www.yundie.com/news/2025-01-06",
          sourceName: "云蝶科技官网",
          read: false,
          category: "融资动态",
          severity: "low",
          tags: ["B轮融资", "投资", "5000万美元"],
        ),
        UnreadMessage(
          id: "201-2",
          title: "云蝶AI模型被指存在数据隐私风险",
          content: "有报告指出云蝶科技的AI模型在数据处理方面存在隐私风险",
          date: "2025-01-06",
          source: "https://tech.sina.com.cn/2025-01-06",
          sourceName: "新浪科技",
          read: false,
          category: "隐私风险",
          severity: "medium",
          tags: ["数据隐私", "AI模型", "风险评估"],
        ),
      ],
      '203': [
        UnreadMessage(
          id: "203-1",
          title: "广州致景获评省级网络安全技术创新中心",
          content: "广州致景信息科技被评为广东省网络安全技术创新中心",
          date: "2025-01-06",
          source: "https://www.gzzhijing.com/news/2025-01-06",
          sourceName: "致景科技官网",
          read: false,
          category: "荣誉认证",
          severity: "low",
          tags: ["技术中心", "网络安全", "省级认证"],
        ),
      ],
    },
    riskCategories: {
      "政策风险": RiskCategory(
        color: "#ef4444",
        priority: 1,
        description: "政府政策变化带来的风险",
      ),
      "制裁风险": RiskCategory(
        color: "#dc2626",
        priority: 1,
        description: "国际制裁措施的影响",
      ),
      "贸易风险": RiskCategory(
        color: "#f59e0b",
        priority: 2,
        description: "国际贸易争端和限制",
      ),
      "合规风险": RiskCategory(
        color: "#f59e0b",
        priority: 2,
        description: "法规合规要求变化",
      ),
      "供应链风险": RiskCategory(
        color: "#f59e0b",
        priority: 2,
        description: "供应链中断或限制",
      ),
      "业务风险": RiskCategory(
        color: "#10b981",
        priority: 3,
        description: "业务运营相关风险",
      ),
      "技术风险": RiskCategory(
        color: "#10b981",
        priority: 3,
        description: "技术发展相关风险",
      ),
      "市场风险": RiskCategory(
        color: "#10b981",
        priority: 3,
        description: "市场表现和竞争风险",
      ),
    },
    severityLevels: {
      "high": SeverityLevel(
        label: "高",
        color: "#ef4444",
        description: "需要立即关注和处理",
      ),
      "medium": SeverityLevel(
        label: "中",
        color: "#f59e0b",
        description: "需要密切关注",
      ),
      "low": SeverityLevel(
        label: "低",
        color: "#10b981",
        description: "常规监控即可",
      ),
    },
    riskLevels: {
      "high": RiskLevel(
        label: "高风险",
        color: "#ef4444",
        bgColor: "rgba(254, 226, 226, 0.6)",
        borderColor: "rgba(248, 113, 113, 0.4)",
      ),
      "medium": RiskLevel(
        label: "中风险",
        color: "#f59e0b",
        bgColor: "rgba(254, 243, 199, 0.6)",
        borderColor: "rgba(251, 191, 36, 0.4)",
      ),
      "low": RiskLevel(
        label: "低风险",
        color: "#10b981",
        bgColor: "rgba(209, 250, 229, 0.6)",
        borderColor: "rgba(52, 211, 153, 0.4)",
      ),
    },
    attentionLevels: {
      "key_focus": AttentionLevel(
        label: "重点关注",
        color: "#ef4444",
        bgColor: "rgba(254, 226, 226, 0.6)",
        borderColor: "rgba(248, 113, 113, 0.4)",
      ),
      "general_focus": AttentionLevel(
        label: "一般关注",
        color: "#10b981",
        bgColor: "rgba(255, 255, 255, 0.9)",
        borderColor: "rgba(203, 213, 225, 0.8)",
      ),
    },
  );
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
      lastUpdated: json['lastUpdated'] as String,
      version: json['version'] as String,
      description: json['description'] as String,
      totalCompanies: json['totalCompanies'] as int,
      totalMessages: json['totalMessages'] as int,
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
      fengyun1: FengyunStats.fromJson(json['fengyun_1']),
      fengyun2: FengyunStats.fromJson(json['fengyun_2']),
      xingyun: XingyunStats.fromJson(json['xingyun']),
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
      name: json['name'] as String,
      description: json['description'] as String,
      stats: Stats.fromJson(json['stats']),
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
      highRisk: json['high_risk'] as int,
      mediumRisk: json['medium_risk'] as int,
      lowRisk: json['low_risk'] as int,
      total: json['total'] as int,
      dailyChange: DailyChange.fromJson(json['daily_change']),
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
      highRisk: json['high_risk'] as int,
      mediumRisk: json['medium_risk'] as int,
      lowRisk: json['low_risk'] as int,
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
      name: json['name'] as String,
      description: json['description'] as String,
      stats: XingyunStatsData.fromJson(json['stats']),
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
      keyFocus: json['key_focus'] as int,
      generalFocus: json['general_focus'] as int,
      total: json['total'] as int,
      dailyChange: XingyunDailyChange.fromJson(json['daily_change']),
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
      keyFocus: json['key_focus'] as int,
      generalFocus: json['general_focus'] as int,
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
      province: json['province'] as String,
      cities: (json['cities'] as List).map((e) => City.fromJson(e)).toList(),
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
      code: json['code'] as String,
      name: json['name'] as String,
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
      id: json['id'] as String,
      name: json['name'] as String,
      englishName: json['english_name'] as String,
      description: json['description'] as String,
      riskLevel: json['risk_level'] as String,
      riskLevelText: json['risk_level_text'] as String,
      attentionLevel: json['attention_level'] as String?,
      attentionLevelText: json['attention_level_text'] as String?,
      city: json['city'] as String,
      updateDate: json['update_date'] as String,
      unreadCount: json['unread_count'] as int,
      detailPage: json['detail_page'] as String,
      industry: json['industry'] as String,
      marketCap: json['market_cap'] as String?,
      stockPrice: json['stock_price'] as String?,
      tags: (json['tags'] as List).map((e) => e as String).toList(),
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
      read: json['read'] as bool,
      category: json['category'] as String,
      severity: json['severity'] as String,
      tags: (json['tags'] as List).map((e) => e as String).toList(),
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
      color: json['color'] as String,
      priority: json['priority'] as int,
      description: json['description'] as String,
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
      label: json['label'] as String,
      color: json['color'] as String,
      description: json['description'] as String,
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
      label: json['label'] as String,
      color: json['color'] as String,
      bgColor: json['bg_color'] as String,
      borderColor: json['border_color'] as String,
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
      label: json['label'] as String,
      color: json['color'] as String,
      bgColor: json['bg_color'] as String,
      borderColor: json['border_color'] as String,
    );
  }
}