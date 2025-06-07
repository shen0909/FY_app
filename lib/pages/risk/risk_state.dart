import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';

import '../../models/risk_data.dart';

class RiskState {
  // 当前选择的单位类型 0-烽云一号 1-烽云二号 2-星云
  RxInt chooseUint = 0.obs;
  final Rx<UnreadMessage?> unreadMessageList = Rx<UnreadMessage?>(null); // 未读消息
  final Rx<RiskyData?> riskyData = Rx<RiskyData?>(null); // 风险预警消息
  final Rx<Map<String, dynamic>> currentUnitData = Rx<Map<String, dynamic>>({}); // 当前单位数据
  final RxList<Map<String, dynamic>> currentRiskList = RxList<Map<String, dynamic>>([]); // 当前风险列表

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
