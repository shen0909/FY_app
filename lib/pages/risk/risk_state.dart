import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';

class RiskState {
  // 当前选择的单位类型 0-烽云一号 1-烽云二号 2-星云
  RxInt chooseUint = 0.obs;
  
  // 地区
  RxString location = "广东省广州市".obs;

  // 城市选择相关
  final RxString selectedCity = "全部".obs;
  final List<String> priorityCities = ["全部", "广州市", "深圳市", "珠海市"];
  final List<String> otherCities = [
    "汕头市", "佛山市", "韶关市", "湛江市", "肇庆市", 
    "江门市", "茂名市", "惠州市", "梅州市", "汕尾市", 
    "河源市", "阳江市", "清远市", "东莞市", "中山市", 
    "潮州市", "揭阳市", "云浮市"
  ];

  // 烽云一号数据
  final Map<String, dynamic> type1Data = {
    'high': {'title': '高风险', 'count': 12, 'change': 0, 'color': 0xFFFF2A08},
    'medium': {'title': '中风险', 'count': 7, 'change': 0, 'color': 0xFFFF9900},
    'low': {'title': '低风险', 'count': 31, 'change': 0, 'color': 0xFF07CC89},
    'total': {'count': 50, 'color': 0xFF1A1A1A},
  }.obs;

  // 烽云二号数据
  final Map<String, dynamic> type2Data = {
    'high': {'title': '高风险', 'count': 18, 'change': 0, 'color': 0xFFFF2A08},
    'medium': {'title': '中风险', 'count': 10, 'change': 1, 'color': 0xFFFF9900},
    'low': {'title': '低风险', 'count': 22, 'change': 1, 'color': 0xFF07CC89},
    'total': {'count': 50, 'color': 0xFF1A1A1A},
  }.obs;

  // 星云数据
  final Map<String, dynamic> type3Data = {
    'high': {'title': '重点关注', 'count': 100, 'change': 3, 'color': 0xFFFF2A08},
    'medium': {'title': '一般关注', 'count': 50, 'change': 2, 'color': 0xFF07CC89},
    'total': {'count': 150, 'color': 0xFF1A1A1A},
  }.obs;

  // 获取当前单位类型的数据
  Map<String, dynamic> get currentUnitData {
    switch (chooseUint.value) {
      case 0:
        return type1Data;
      case 1:
        return type2Data;
      case 2:
        return type3Data;
      default:
        return type1Data;
    }
  }

  // 风险列表数据
  final RxList<Map<String, dynamic>> type1List = <Map<String, dynamic>>[
    {
      'id': '104',
      'name': '中船黄埔文冲船舶有限公司',
      'englishName': 'CSSC Huangpu Wenchong Shipbuilding Company Limited',
      'description': '中船集团旗下大型造船企业，专注于各类船舶建造与海工装备',
      'riskLevel': '中风险',
      'riskColor': 0xFFFF9900,
      'borderColor': 0xFFFFE7CC,
      'updateTime': '2025-01-09',
      'unreadCount': 5,
      'isRead': false,
    },
    {
      'id': '101',
      'name': '广船国际有限公司',
      'englishName': 'Guangzhou Shipyard International Company Limited',
      'description': '市值为 8448.59 万元 | 股价为 3.30 元人民币',
      'riskLevel': '低风险',
      'riskColor': 0xFF07CC89,
      'borderColor': 0xFFCEFFEE,
      'updateTime': '2025-05-14',
      'unreadCount': 3,
      'isRead': false,
    },
    {
      'id': '102',
      'name': '广州实验室',
      'englishName': 'Guangzhou Laboratory',
      'description': '国家级科研机构，专注于生物医学与健康科学研究',
      'riskLevel': '低风险',
      'riskColor': 0xFF07CC89,
      'borderColor': 0xFFCEFFEE,
      'updateTime': '2025-04-18',
      'unreadCount': 2,
      'isRead': false,
    },
    {
      'id': '103',
      'name': '华南理工大学',
      'englishName': 'South China University of Technology',
      'description': '国家"双一流"建设高校，教育部直属全国重点大学',
      'riskLevel': '低风险',
      'riskColor': 0xFF07CC89,
      'borderColor': 0xFFCEFFEE,
      'updateTime': '2025-04-19',
      'unreadCount': 1,
      'isRead': false,
    },
  ].obs;

  final RxList<Map<String, dynamic>> type2List = <Map<String, dynamic>>[
    {
      'id': '305',
      'name': '中国科学院香港创新研究院',
      'englishName': 'Hong Kong Institute of Science & Innovation, CAS',
      'description': '专注于人工智能、生物医药和材料科学领域的前沿研究',
      'riskLevel': '高风险',
      'riskColor': 0xFFFF2A08,
      'borderColor': 0xFFFFD8D2,
      'updateTime': '2025-04-22',
      'unreadCount': 3,
      'isRead': false,
    },
    {
      'id': '302',
      'name': '云从科技集团股份有限公司',
      'englishName': 'CloudWalk Technology Co., Ltd.',
      'description': '人工智能领域独角兽企业，专注于计算机视觉技术',
      'riskLevel': '中风险',
      'riskColor': 0xFFFF9900,
      'borderColor': 0xFFFFE7CC,
      'updateTime': '2025-01-06',
      'unreadCount': 3,
      'isRead': false,
    },
    {
      'id': '303',
      'name': '金发科技股份有限公司',
      'englishName': 'Kingfa Science & Technology Co., Ltd.',
      'description': '市值：198.6亿元 | 股价：7.32元（收市）',
      'riskLevel': '低风险',
      'riskColor': 0xFF07CC89,
      'borderColor': 0xFFCEFFEE,
      'updateTime': '2025-01-06',
      'unreadCount': 2,
      'isRead': false,
    },
  ].obs;

  final RxList<Map<String, dynamic>> type3List = <Map<String, dynamic>>[
    {
      'id': '204',
      'name': '中芯国际集成电路制造有限公司',
      'englishName': 'Semiconductor Manufacturing International Corporation',
      'description': 'A股总市值：6624.19亿元人民币|收盘价为82.16元人民币',
      'riskLevel': '高风险',
      'riskColor': 0xFFFF2A08,
      'borderColor': 0xFFFFD8D2,
      'updateTime': '2025-05-28',
      'unreadCount': 3,
      'isRead': false,
    },
    {
      'id': '205',
      'name': '广东一知安全科技有限公司',
      'englishName': 'Guangdong Yizhi Security Technology Co., Ltd.',
      'description': '专注于网络安全与数据保护的高新技术企业',
      'riskLevel': '高风险',
      'riskColor': 0xFFFF2A08,
      'borderColor': 0xFFFFD8D2,
      'updateTime': '2025-05-16',
      'unreadCount': 2,
      'isRead': false,
    },
    {
      'id': '202',
      'name': '佳都科技集团股份有限公司',
      'englishName': 'PCI Technology Group Co., Ltd.',
      'description': '市值：102.3亿元 | 股价：5.84元（收市）',
      'riskLevel': '高风险',
      'riskColor': 0xFFFF2A08,
      'borderColor': 0xFFFFD8D2,
      'updateTime': '2025-01-06',
      'unreadCount': 4,
      'isRead': false,
    },
    {
      'id': '201',
      'name': '广州云蝶科技有限公司',
      'englishName': 'Guangzhou Yundie Technology Co., Ltd.',
      'description': '专注于人工智能和大数据分析技术开发的科技企业',
      'riskLevel': '中风险',
      'riskColor': 0xFFFF9900,
      'borderColor': 0xFFFFE7CC,
      'updateTime': '2025-01-06',
      'unreadCount': 2,
      'isRead': false,
    },
    {
      'id': '203',
      'name': '广州致景信息科技有限公司',
      'englishName': 'Guangzhou Zhijing Information Technology Co., Ltd.',
      'description': '专注于信息安全与软件服务的高新技术企业',
      'riskLevel': '低风险',
      'riskColor': 0xFF07CC89,
      'borderColor': 0xFFCEFFEE,
      'updateTime': '2025-01-06',
      'unreadCount': 1,
      'isRead': false,
    },
  ].obs;

  // 获取当前风险列表
  List<Map<String, dynamic>> get currentRiskList {
    switch (chooseUint.value) {
      case 0:
        return type1List;
      case 1:
        return type2List;
      case 2:
        return type3List;
      default:
        return type1List;
    }
  }

  // 未读消息列表
  final RxList<Map<String, dynamic>> unreadMessages = <Map<String, dynamic>>[
    {
      'title': '美国商务部将中船黄埔列入出口管制实体清单',
      'date': '2025-04-15',
      'company': '中船黄埔文冲船舶有限公司',
      'isRead': false,
    },
    {
      'title': '中船黄埔签订5艘大型集装箱船订单',
      'date': '2025-04-15',
      'company': '中船黄埔文冲船舶有限公司',
      'isRead': false,
    },
    {
      'title': '欧盟调查中国船厂获政府补贴情况',
      'date': '2025-04-15',
      'company': '中船黄埔文冲船舶有限公司',
      'isRead': false,
    },
  ].obs;
}
