import 'package:get/get.dart';
import 'package:safe_app/models/detail_list_data.dart';

// 制裁类型数据模型
class SanctionType {
  final String name;
  final String code;
  final String description;
  final int color;
  final int bgColor;

  SanctionType({
    required this.name,
    required this.code,
    required this.description,
    required this.color,
    required this.bgColor,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'description': description,
      'color': color,
      'bgColor': bgColor,
    };
  }

  factory SanctionType.fromJson(Map<String, dynamic> json) {
    return SanctionType(
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String,
      color: json['color'] as int,
      bgColor: json['bgColor'] as int,
    );
  }

  static List<SanctionType> mockSanctionType (){
    return [
      SanctionType(
        name: '全部',
        code: 'all',
        description: '全部',
        color: 0xFFFF2A08,
        bgColor: 0xFFFFECE9,
      ),
      SanctionType(
        name: '中国军工企业清单（CMC）',
        code: 'CMC',
        description: '中国军工企业清单',
        color: 0xFF07CC89,
        bgColor: 0xFFE7FEF8,
      ),
      SanctionType(
        name: '军事最终用户清单（MEU）',
        code: 'MEU',
        description: '军事最终用户清单',
        color: 0xFF1A1A1A,
        bgColor: 0xFFEDEDED,
      ),
      SanctionType(
        name: '实体清单（EL）',
        code: 'EL',
        description: '实体清单',
        color: 0xFFFF2A08,
        bgColor: 0xFFFFECE9,
      ),
      SanctionType(
        name: '未经核实清单（UVL）',
        code: 'UVL',
        description: '未经核实清单',
        color: 0xFF1A1A1A,
        bgColor: 0xFFEDEDED,
      ),
      SanctionType(
        name: '特别指定国民清单（SDN）',
        code: 'SDN',
        description: '特别指定国民清单',
        color: 0xFFFF2A08,
        bgColor: 0xFFFFECE9,
      ),
      SanctionType(
        name: '维吾尔强迫劳动预防法实体清单（UFLPA）',
        code: 'UFLPA',
        description: '维吾尔强迫劳动预防法实体清单',
        color: 0xFF33A9FE,
        bgColor: 0xFFE7F4FE,
      ),
      SanctionType(
        name: '行业制裁清单（SSI）',
        code: 'SSI',
        description: '行业制裁清单',
        color: 0xFF07CC89,
        bgColor: 0xFFE7FEF8,
      ),
      SanctionType(
        name: '被拒绝人员清单（DPL）',
        code: 'DPL',
        description: '被拒绝人员清单',
        color: 0xFFFF2A08,
        bgColor: 0xFFFFECE9,
      ),
      SanctionType(
        name: '非SDN中国军事综合体企业清单（NS-CMIC）',
        code: 'NS-CMIC',
        description: '非SDN中国军事综合体企业清单',
        color: 0xFFFFA408,
        bgColor: 0xFFFFF7E9,
      ),
    ];
  }
}

// 制裁详情数据模型
class SanctionDetail {
  final String title; // 标题，例如"定义"
  final String content; // 内容
  
  SanctionDetail({
    required this.title,
    required this.content,
  });
}

// 完整制裁类型详情
class SanctionTypeDetail {
  final SanctionType sanctionType;
  final List<Map<String, String>> details; // 包含标题和内容的详情列表
  
  SanctionTypeDetail({
    required this.sanctionType,
    required this.details,
  });
  
  // 根据制裁类型代码获取对应的详情
  static SanctionTypeDetail getDetailByCode(String code) {
    // 在实际应用中，这些数据应该从API获取
    switch (code) {
      case 'CMC':
        return SanctionTypeDetail(
          sanctionType: SanctionType.mockSanctionType().firstWhere((type) => type.code == code),
          details: [
            {
              'title': '中国军工企业清单（CMC）',
              'content': '',
            },
            {
              'title': '定义',
              'content': '由美国国防部制订，涉及"与解放军相关企业"、在军民两用领域。',
            },
            {
              'title': '限制',
              'content': '启发警示意义为主，但为其他制裁奠定基础和依据，可能伴随金融限制。',
            },
          ],
        );
      case 'MEU':
        return SanctionTypeDetail(
          sanctionType: SanctionType.mockSanctionType().firstWhere((type) => type.code == code),
          details: [
            {
              'title': '军事最终用户清单（MEU）',
              'content': '',
            },
            {
              'title': '定义',
              'content': '针对可能将美国产品用于军事目的的最终用户实体。',
            },
            {
              'title': '限制',
              'content': '出口许可要求民用最终用途证明（如商业用途、研发用途），禁止军事用途。',
            },
          ],
        );
      case 'EL':
        return SanctionTypeDetail(
          sanctionType: SanctionType.mockSanctionType().firstWhere((type) => type.code == code),
          details: [
            {
              'title': '实体清单（Entity List）',
              'content': '',
            },
            {
              'title': '定义',
              'content': '由美国商务部工业与安全局（BIS）管理，针对"威胁美国国家安全或外交利益"的实体（企业、单位、政府机构等）。',
            },
            {
              'title': '限制',
              'content': '向清单内出口/再出口美国管制物项需申请许可，且通常为"推定拒绝"原则，供应链上下游合作伙伴能被迫中断。',
            },
            {
              'title': '典型案例',
              'content': '华为、中芯国际、深圳海思等半导体企业被列入，直接影响晶片片、服务器等产业。',
            },
          ],
        );
      case 'UVL':
        return SanctionTypeDetail(
          sanctionType: SanctionType.mockSanctionType().firstWhere((type) => type.code == code),
          details: [
            {
              'title': '未经核实清单（Unverified List, UVL）',
              'content': '',
            },
            {
              'title': '定义',
              'content': '包含那些美国政府无法通过最终用户核查确认为"适格"的实体，通常是作为EL的预警。',
            },
            {
              'title': '限制',
              'content': '出口商需证实接收方是可靠的，且还是美国受管制商品，需通过专门审查程序。',
            },
          ],
        );
      case 'SDN':
        return SanctionTypeDetail(
          sanctionType: SanctionType.mockSanctionType().firstWhere((type) => type.code == code),
          details: [
            {
              'title': '特别指定国民清单（Specially Designated Nationals, SDN）',
              'content': '',
            },
            {
              'title': '定义',
              'content': '由美国财政部外国资产管制办公室（OFAC）管理，包含被制裁的个人、企业和实体。',
            },
            {
              'title': '限制',
              'content': '美国人不得与SDN清单上的实体进行任何交易，其在美资产被冻结，禁止进入美国金融系统。',
            },
            {
              'title': '特点',
              'content': '这是最严厉的制裁措施之一，涉及全面的金融和贸易限制。',
            },
          ],
        );
      case 'UFLPA':
        return SanctionTypeDetail(
          sanctionType: SanctionType.mockSanctionType().firstWhere((type) => type.code == code),
          details: [
            {
              'title': '维吾尔强迫劳动预防法实体清单（UFLPA）',
              'content': '',
            },
            {
              'title': '定义',
              'content': '根据《维吾尔强迫劳动预防法》建立，针对涉嫌使用强迫劳动的新疆地区实体。',
            },
            {
              'title': '限制',
              'content': '禁止进口来自新疆地区或与清单实体相关的商品，除非进口商能够证明未使用强迫劳动。',
            },
            {
              'title': '影响范围',
              'content': '主要涉及棉花、番茄、太阳能电池板等产业链，对相关供应链产生重大影响。',
            },
          ],
        );
      case 'SSI':
        return SanctionTypeDetail(
          sanctionType: SanctionType.mockSanctionType().firstWhere((type) => type.code == code),
          details: [
            {
              'title': '行业制裁清单（Sectoral Sanctions Identifications List, SSI）',
              'content': '',
            },
            {
              'title': '定义',
              'content': '针对特定行业（如能源、金融）的制裁，限制特定领域的贸易和金融活动。',
            },
            {
              'title': '限制',
              'content': '美国人不得为限制清单内的公司、活动提供融资或服务，并禁止特定贸易活动。',
            },
          ],
        );
      case 'DPL':
        return SanctionTypeDetail(
          sanctionType: SanctionType.mockSanctionType().firstWhere((type) => type.code == code),
          details: [
            {
              'title': '被拒绝人员清单（Denied Persons List, DPL）',
              'content': '',
            },
            {
              'title': '定义',
              'content': '可能由于违反出口管制或违反美国国家安全法规而被禁止从美国获得出口物品的实体或个人。',
            },
            {
              'title': '限制',
              'content': '全面禁止，远远强于分类管控物项，授权数量通常低于100万美元（企业）或20万美元（个人）。',
            },
          ],
        );
      case 'NS-CMIC':
        return SanctionTypeDetail(
          sanctionType: SanctionType.mockSanctionType().firstWhere((type) => type.code == code),
          details: [
            {
              'title': '非SDN中国军事综合体企业清单（NS-CMIC）',
              'content': '',
            },
            {
              'title': '定义',
              'content': '针对与中国军事工业复合体相关的企业，限制美国投资者对此类企业进行投资。',
            },
            {
              'title': '特点',
              'content': '与SDN清单不同，重点针对限制美国投资者对企业的投资。',
            },
          ],
        );
      default:
        // 返回一个通用的详情信息
        return SanctionTypeDetail(
          sanctionType: SanctionType.mockSanctionType().first,
          details: [
            {'title': '未知制裁类型', 'content': '未找到相关制裁类型的详细信息。'}
          ],
        );
    }
  }
}

class DetailListState {
  // 搜索关键词
  var searchText = ''.obs;
  
  // 筛选选项
  var typeFilter = ''.obs;
  var provinceFilter = ''.obs;
  var cityFilter = ''.obs;
  
  // 是否正在加载数据
  var isLoading = false.obs;
  
  // 企业清单数据 - 直接使用SanctionEntity
  var sanctionList = <SanctionEntity>[].obs;
  
  // 总数量
  var totalCount = 0.obs;
  var searchCount = 0.obs;
  // 移除数
  RxInt removeNum = 0.obs;
  // 是否打开移除数表格
  RxBool openRemoveTable = false.obs;

  var updateTime = "".obs;
  RxDouble totalTableWidth = 0.0.obs;
  RxDouble maxSanctionTypeWidth = 0.0.obs; // 存储制裁类型列的宽度

  // 分页相关状态
  var currentPage = 1.obs;           // 当前页码
  var pageSize = 10.obs;             // 每页数量改为10
  var isLoadingMore = false.obs;     // 是否正在加载更多
  var hasMoreData = true.obs;        // 是否还有更多数据
  var isRefreshing = false.obs;      // 是否正在刷新

  // 年度统计数据
  var yearlyStats = <YearlyStats>[].obs;

  // 实体清单趋势数据
  var trendData = <EntityTrendData>[].obs;
  var isTrendLoading = false.obs;

  // 制裁类型列表
  var sanctionTypes = <SanctionType>[].obs;
  
  DetailListState() {
    ///Initialize variables
    _initDemoData();
  }

  void _initDemoData() {
    // 初始化制裁类型列表
    sanctionTypes.addAll(SanctionType.mockSanctionType());

    // 初始化年度统计数据
    yearlyStats.addAll([
      // YearlyStats(year: '2018', newCount: 63, totalCount: 63),
      // YearlyStats(year: '2019', newCount: 151, totalCount: 214),
      // YearlyStats(year: '2020', newCount: 240, totalCount: 454),
      // YearlyStats(year: '2021', newCount: 157, totalCount: 611),
      // YearlyStats(year: '2022', newCount: 43, totalCount: 654),
      // YearlyStats(year: '2023', newCount: 73, totalCount: 727),
      // YearlyStats(year: '2024', newCount: 136, totalCount: 863),
      // YearlyStats(year: '2025(截至5月)', newCount: 54, totalCount: 917),
    ]);
  }
}

// 年度统计数据
class YearlyStats {
  final String year;
  final int newCount;
  final int totalCount;

  YearlyStats({
    required this.year,
    required this.newCount,
    required this.totalCount,
  });
}

// 实体清单趋势数据模型
class EntityTrendData {
  final int count;
  final int year;

  EntityTrendData({
    required this.count,
    required this.year,
  });

  factory EntityTrendData.fromJson(Map<String, dynamic> json) {
    return EntityTrendData(
      count: json['count'] as int? ?? 0,
      year: json['year'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'year': year,
    };
  }
}
