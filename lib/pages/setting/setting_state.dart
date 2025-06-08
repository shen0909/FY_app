import 'package:get/get.dart';
import 'package:safe_app/utils/shared_prefer.dart';

class SettingState {
  // 用户信息
  final RxMap<String, dynamic> userInfo = <String, dynamic>{}.obs;
  
  // 功能开关
  final RxBool isLockEnabled = false.obs;
  final RxBool isFingerprintEnabled = false.obs;
  
  // 消息推送设置
  final RxBool isRiskAlertEnabled = true.obs;
  final RxBool isSubscriptionEnabled = true.obs;
  
  // 角色信息
  final RxString currentRole = '管理员'.obs;
  
  // 统计数据
  final RxMap<String, dynamic> statistics = <String, dynamic>{}.obs;
  
  // 权限申请
  final RxInt permissionRequestCount = 3.obs;
  
  // 用户列表
  final RxList<Map<String, dynamic>> userList = <Map<String, dynamic>>[].obs;
  
  SettingState() {
    ///Initialize variables
    _initDemoData();
  }
  
  // 初始化演示数据
  Future<void> _initDemoData() async {
    userInfo.addAll({
      'username': 'ZQP001',
      'name': '刘晓龙',
      'role': '管理员',
      'version': 'v2.5.1',
      'department': '广东省深圳市',
      'avatar': 'assets/images/default_avatar.png'
    });
    
    statistics.addAll({
      'todayVisits': 1156,
      'visitTrend': 12,
      'predictionCount': 56,
      'predictionTrend': -8,
      'subscriptionCount': 1156,
      'subscriptionTrend': 12,
      'region': '广东省'
    });
    
    userList.addAll([
      {
        'name': '张三',
        'id': 'ZQP001',
        'role': '管理员',
        'status': '在线',
        'lastLoginTime': '2023-05-10 09:40'
      },
      {
        'name': '李四',
        'id': 'ZQP002',
        'role': '审核员',
        'status': '在线',
        'lastLoginTime': '2023-05-10 16:21'
      },
      {
        'name': '王五',
        'id': 'ZQP003',
        'role': '普通用户',
        'status': '申请中',
        'lastLoginTime': '2023-05-10 10:15'
      }
    ]);
  }
}
