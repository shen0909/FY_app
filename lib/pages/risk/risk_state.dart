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
  final RxList<Map<String, dynamic>> currentUnreadMessages = RxList<Map<String, dynamic>>([]); // 当前未读消息列表

  // 地区
  RxString location = "广东省全部".obs;

  // 城市选择相关
  final RxString selectedCity = "全部".obs;
  final RxList<String> priorityCities = RxList<String>(["全部"]); // 优先显示的城市
  final RxList<String> otherCities = RxList<String>([]); // 其他城市
}
