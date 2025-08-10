import 'package:get/get.dart';
import '../../models/risk_data_new.dart';
import '../../models/region_data.dart';

class RiskState {
  // 当前选择的单位类型 0-烽云一号 1-烽云二号 2-星云
  RxInt chooseUint = 0.obs;
  final Rx<List?> unreadMessageList = Rx<List?>(null); // 未读消息
  final Rx<Map<String, dynamic>> currentUnitData = Rx<Map<String, dynamic>>({}); // 当前单位数据
  final RxList<Map<String, dynamic>> currentRiskList = RxList<Map<String, dynamic>>([]); // 当前风险列表
  final RxList<Map<String, dynamic>> currentUnreadMessages = RxList<Map<String, dynamic>>([]); // 当前未读消息列表

  // 地区
  RxString location = "广东省全部".obs;

  // 城市选择相关
  final RxString selectedCity = "全部".obs;
  final RxList<String> priorityCities = RxList<String>(["全部"]); // 优先显示的城市
  final RxList<String> otherCities = RxList<String>([]); // 其他城市

  // 新接口
  final RxList<RiskListElement> fengyun1List = <RiskListElement>[].obs;
  final RxList<RiskListElement> fengyun2List = <RiskListElement>[].obs;
  final RxList<RiskListElement> xingyunList = <RiskListElement>[].obs;

  // 地区筛选相关
  final RxList<RegionData> allRegions = <RegionData>[].obs; // 所有地区数据
  final Rx<RegionData?> selectedProvince = Rx<RegionData?>(null); // 选择的省份
  final Rx<RegionData?> selectedRegion = Rx<RegionData?>(null); // 选择的具体地区（市/区）
  final RxString searchKeyword = "".obs; // 搜索关键词
  final RxString selectedRegionCode = "".obs; // 当前选择的地区代码（用于筛选）
  final RxString selectedRegionName = "全部".obs; // 当前选择的地区名称（用于显示）

  // 分页相关状态
  final RxInt currentPage = 1.obs; // 当前页数
  final RxBool isLoading = false.obs; // 是否正在加载
  final RxBool hasMoreData = true.obs; // 是否还有更多数据
  final RxBool isLoadingMore = false.obs; // 是否正在加载更多（用于显示底部加载指示器）
  final RxBool isRefreshing = false.obs; // 是否正在下拉刷新

  // 风险评分数量（来自新接口）
  final RxInt highRiskCount = 0.obs;
  final RxInt mediumRiskCount = 0.obs;
  final RxInt lowRiskCount = 0.obs;
}
