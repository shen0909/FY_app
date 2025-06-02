import 'package:get/get.dart';

class RiskDetailsState {
  // 基本信息
  final companyName = '华为技术有限公司'.obs;
  final companyNameEn = 'Huawei Technologies Co., Ltd.'.obs;
  final riskScore = 335.obs;
  final location = '总部位于中国广东省深圳市龙岗区'.obs;
  final industry = '全球领先的信息与通信技术（ICT）基础设施和智能终端提供商'.obs;
  final businessAreas = '运营商网络、企业解决方案、智能终端、云计算、汽车终端、人工智能、5G技术'.obs;
  final companyType = '民营企业，员工持股制度'.obs;
  final marketValue = '未公开上市，估值受制裁影响但仍保持全球科技企业前列'.obs;
  final stockPrice = '未公开上市，无股价信息'.obs;
  final companyIntro = '华为创立于1987年，由任正非创立，致力于构建万物互联的智能世界。其业务遍及170多个国家和地区，服务全球30多亿人口。华为在5G、人工智能、云计算等领域处于全球领先地位，拥有超过15万件有效授权专利。近年来，华为持续加大研发投入，2024年研发费用支出达人民币1,797亿元，占全年收入的20.8%。'.obs;

  // 风险评分详情
  final externalRiskScore = 120.obs;
  final externalRiskDetails = [
    {'name': '宣布调查', 'score': 10},
    {'name': '实施调查', 'score': 20},
    {'name': '技术攻击', 'score': 10},
    {'name': '实施制裁', 'score': 30},
    {'name': '司法诉讼', 'score': 25},
    {'name': '攻击抹黑', 'score': 5},
    {'name': '脱钩断链', 'score': 20}
  ].obs;

  final internalRiskScore = 25.obs;
  final internalRiskDetails = [
    {'name': '失密泄密', 'score': 10},
    {'name': '人员失管', 'score': 10},
    {'name': '负面舆情', 'score': 5}
  ].obs;

  final operationalRiskScore = 120.obs;
  final securityRiskScore = 70.obs;

  // 风险因素列表及详情
  final riskFactors = [
    '技术依赖风险',
    '供应链风险',
    '市场准入风险',
    '国际关系风险',
    '法律合规风险'
  ].obs;

  final riskFactorDetails = {
    '技术依赖风险': [
      {'title': '芯片设计工具依赖', 'description': '华为海思半导体依赖美国EDA（电子设计自动化）工具进行芯片设计，如Cadence、Synopsys和Mentor Graphics等公司的软件。'},
      {'title': '高端芯片制造依赖', 'description': '华为自研的麒麟芯片需要台积电等代工厂使用美国设备（如应用材料、科磊、泛林集团等公司的设备）进行生产。'},
      {'title': '操作系统依赖', 'description': '华为智能手机原本依赖谷歌的Android操作系统及GMS（Google Mobile Services）。'},
      {'title': '关键组件依赖', 'description': '华为产品中的许多关键组件，如高端射频器件、光学元件等，来自美国供应商或使用美国技术的非美国供应商。'},
      {'title': '知识产权依赖', 'description': '华为需要支付大量专利费用给高通等美国公司，以获取关键通信技术的授权。'}
    ],
    '供应链风险': [
      {'title': '供应链断裂', 'description': '美国"实体清单"和"直接产品原则"的扩大适用，导致华为无法从全球供应商处获取关键组件，包括芯片、光学元件、射频模块等。'},
      {'title': '替代供应商有限', 'description': '全球半导体产业高度集中，美国企业在多个关键环节占据主导地位，华为难以找到完全不受美国技术影响的替代供应商。'},
      {'title': '库存压力', 'description': '制裁初期，华为通过大量囤积芯片等关键组件来应对供应中断风险，但这增加了库存成本和资金压力。'},
      {'title': '供应链重构成本高', 'description': '重建不依赖美国技术的供应链需要巨大投资和长时间积累，短期内难以实现完全自主可控。'},
      {'title': '第三方风险', 'description': '即使是非美国供应商，也因担心受到美国的次级制裁而减少或终止与华为的合作，进一步加剧了供应链风险。'}
    ],
    '市场准入风险': [
      {'title': '美国市场封锁', 'description': '华为电信设备和智能手机被全面排除出美国市场。'},
      {'title': '盟友市场受限', 'description': '美国政府向盟友施压，多个国家（如英国、澳大利亚、日本等）宣布禁止或限制华为参与其5G网络建设。'},
      {'title': '消费者业务受挫', 'description': '由于无法使用谷歌GMS服务，华为智能手机在海外市场的吸引力大幅下降，全球市场份额从巅峰时期的第二位大幅下滑。'},
      {'title': '运营商业务阻力', 'description': '全球电信运营商担心使用华为设备可能面临美国制裁或政治压力，减少了对华为产品的采购。'},
      {'title': '国际标准参与受限', 'description': '华为在国际标准组织中的参与和影响力受到限制，可能影响其在未来技术标准制定中的话语权。'}
    ],
    '国际关系风险': [
      {'title': '中美科技冷战', 'description': '华为成为中美科技竞争的焦点，其命运与中美关系紧密相连。'},
      {'title': '国际阵营分化', 'description': '各国在是否使用华为设备的问题上立场不同，形成了以美国为首的限制派和以中国为首的支持派。'},
      {'title': '全球化逆转风险', 'description': '华为案例可能加速全球科技产业链的分裂，推动"去全球化"趋势。'},
      {'title': '外交关系复杂化', 'description': '各国对华为的态度成为其与中国和美国关系的晴雨表，增加了外交关系的复杂性。'},
      {'title': '国际规则挑战', 'description': '美国对华为的单边制裁引发了对国际贸易规则和全球治理体系的质疑和挑战。'}
    ],
    '法律合规风险': [
      {'title': '美国出口管制合规', 'description': '华为需要确保其全球业务不违反美国的出口管制法规，包括EAR等。'},
      {'title': '长臂管辖风险', 'description': '美国法律的域外适用使华为即使在美国境外的业务也面临法律风险。'},
      {'title': '知识产权风险', 'description': '在无法获取美国技术授权的情况下，华为需要避免潜在的知识产权侵权风险。'},
      {'title': '国际诉讼风险', 'description': '华为在多个国家面临法律诉讼，包括技术窃取、违反制裁等指控。'},
      {'title': '合规成本增加', 'description': '为应对复杂的法律环境，华为需要投入更多资源进行合规管理，增加了运营成本。'}
    ]
  }.obs;

  // 时序跟踪数据
  final timelineEvents = [].obs;

  // 判例依据
  final legalCases = [
    {
      'title': '实体清单机制',
      'summary': '美国依据《出口管理条例》（EAR）第744章第11条，将华为及其152家关联实体列入实体清单，限制其获取美国技术和产品。'
    },
    {
      'title': '直接产品原则',
      'summary': '美国商务部扩大直接产品原则适用范围，限制华为获取使用美国技术和软件的半导体产品。'
    },
    {
      'title': '类似案例',
      'summary': '中芯国际、中兴通讯、东芝事件、阿尔斯通案例、小米诉美国案等相关案例分析。'
    }
  ].obs;

  // 风险趋势数据
  final riskTrends = [
    {'date': '2024-03', 'score': 335.0},
    {'date': '2024-02', 'score': 328.0},
    {'date': '2024-01', 'score': 315.0},
    {'date': '2023-12', 'score': 320.0},
    {'date': '2023-11', 'score': 310.0},
    {'date': '2023-10', 'score': 305.0},
  ].obs;

  // 是否显示风险评分详情对话框
  final RxBool showRiskScoreDialog = false.obs;
  final RxBool isExpandTimeLine = false.obs; // 是否展开时序跟踪

  // 是否展开过往判例依据
  final RxBool isExpandCases = false.obs;

  // 新闻资源详情
  final newsResources = {
    '2025年5月15-22日': [
      {
        'title': '中国商务部发言人就美方制裁措施发表谈话',
        'source': '中国商务部官网',
        'date': '2025-05-15',
        'url': 'http://www.mofcom.gov.cn'
      },
      {
        'title': '外交部：美方行为严重违反国际经贸规则',
        'source': '外交部官网',
        'date': '2025-05-16',
        'url': 'http://www.fmprc.gov.cn'
      },
      {
        'title': '商务部：坚决反对美方滥用出口管制措施',
        'source': '新华网',
        'date': '2025-05-17',
        'url': 'http://www.xinhuanet.com'
      }
    ],
    '2025年5月14日': [
      {
        'title': '美商务部发布华为AI芯片管制新规',
        'source': '路透社',
        'date': '2025-05-14',
        'url': 'http://www.reuters.com'
      },
      {
        'title': '华为回应：美方行为不会阻碍技术创新',
        'source': '华为官网',
        'date': '2025-05-14',
        'url': 'http://www.huawei.com'
      }
    ],
    '2025年5月13日': [
      {
        'title': '美国收紧AI芯片出口管制政策详解',
        'source': '彭博社',
        'date': '2025-05-13',
        'url': 'http://www.bloomberg.com'
      },
      {
        'title': '三项新政策将如何影响全球AI产业',
        'source': '华尔街日报',
        'date': '2025-05-13',
        'url': 'http://www.wsj.com'
      }
    ]
  }.obs;

  RiskDetailsState() {
    // 初始化时序跟踪数据
    timelineEvents.value = [
      {
        'date': '2025年5月15-22日',
        'content': '中国商务部和外交部先后五次对美国制裁措施表态，称美方措施是典型的单边霸凌行为，严重违反市场经济原则和国际经贸规则。'
      },
      {
        'date': '2025年5月14日',
        'content': '美国商务部发布指导意见称，在世界上任何地方使用华为的昇腾人工智能（AI）芯片都会违反出口管制规定。'
      },
      {
        'date': '2025年5月13日',
        'content': '美国商务部废除拜登政府人工智能扩散规则，出台三项政策加强AI芯片出口管制。'
      },
      {
        'date': '2025年2月',
        'content': '华为推出最新款的AI功能手机，引发美国政府关注。'
      },
      {
        'date': '2024年5月',
        'content': '美国政府撤销多个美国公司向华为供货的许可证，切断了华为与包括英特尔和高通在内的芯片巨头的重要业务联系。'
      },
      {
        'date': '2023年8月',
        'content': '美国商务部进一步收紧对华为的出口管制，限制其获取先进芯片技术。'
      },
      {
        'date': '2023年1月',
        'content': '美国政府继续向盟友施压，要求限制华为设备在其5G网络中的使用。'
      }
    ];
  }
}
