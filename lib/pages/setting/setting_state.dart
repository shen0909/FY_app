import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:safe_app/utils/shared_prefer.dart';
import 'package:safe_app/models/login_data.dart';

class SettingState {
  // 用户信息
  final RxMap<String, dynamic> userInfo = <String, dynamic>{}.obs;
  final Rx<PackageInfo?> packageInfo = Rx<PackageInfo?>(null);

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
  // 仪表盘 - 今日数据（完整缓存，用于传递至 user_analysis）
  final RxMap<String, dynamic> dashboardToday = <String, dynamic>{}.obs;
  
  // 权限申请
  final RxInt permissionRequestCount = 3.obs;
  
  // 用户列表
  final RxList<Map<String, dynamic>> userList = <Map<String, dynamic>>[].obs;
  RxBool hasUpdate = false.obs;
  SettingState() {
    ///Initialize variables
    _loadUserData();
  }
  
  // 从SharedPreferences加载真实的用户数据
  Future<void> _loadUserData() async {
    try {
      packageInfo.value = await PackageInfo.fromPlatform();
      print('🔄 开始加载用户数据...');
      
      // 从SharedPreferences获取登录数据
      final loginData = await FYSharedPreferenceUtils.getLoginData();
      
      if (loginData != null) {
        print('✅ 成功获取登录数据: userid=${loginData.userid}, username=${loginData.username}, role=${loginData.user_role}');
        
        // 根据角色映射显示文字
        String roleText = _mapRoleToText(loginData.user_role);
        
        // 构建用户信息
        userInfo.addAll({
          'username': loginData.userid,  // 使用userid作为显示的用户名
          'name': loginData.nickname.isNotEmpty ? loginData.nickname : loginData.username,  // 优先使用昵称
          'role': roleText,
          'version': 'v2.5.1',  // 版本号保持不变或从其他地方获取
          'department': _buildLocationText(loginData),  // 构建地区信息
          'avatar': 'assets/images/default_avatar.png'  // 默认头像路径
        });
        
        // 更新当前角色
        currentRole.value = roleText;
        
        print('✅ 用户信息已更新: $userInfo');
      } else {
        print('⚠️ 未获取到登录数据，使用默认值');
        // 如果没有登录数据，使用默认值
        _initDefaultData();
        return; // 提前返回，避免重复初始化
      }
      
      // 初始化统计数据（这些可能需要从API获取）
      _initStatisticsData();
      
      // 初始化用户列表（这些可能需要从API获取）
      _initUserListData();
      
      print('✅ 数据加载完成');
      
    } catch (e) {
      print('❌ 加载用户数据错误: $e');
      // 出错时使用默认数据
      _initDefaultData();
    }
  }
  
  // 映射角色数字到角色文字
  String _mapRoleToText(int userRole) {
    switch (userRole) {
      case 0:
        return '普通用户';
      case 1:
        return '管理员';
      case 2:
        return '审核员';
      case 3:
        return '超级管理员';
      default:
        return '用户';
    }
  }
  
  // 构建位置信息文本
  String _buildLocationText(LoginData loginData) {
    List<String> locationParts = [];
    
    if (loginData.province.isNotEmpty) {
      locationParts.add(loginData.province);
    }
    if (loginData.city.isNotEmpty && loginData.city != loginData.province) {
      locationParts.add(loginData.city);
    }
    return locationParts.isNotEmpty ? locationParts.join('') : '未知地区';
  }
  
  // 初始化默认数据
  void _initDefaultData() {
    userInfo.addAll({
      'username': 'GUEST001',
      'name': '游客用户',
      'role': '游客',
      'version': 'v2.5.1',
      'department': '未知地区',
      'avatar': 'assets/images/default_avatar.png'
    });
    
    currentRole.value = '游客';
    
    // 初始化统计数据
    _initStatisticsData();
    
    // 初始化用户列表数据
    _initUserListData();
  }
  
  // 初始化统计数据
  void _initStatisticsData() {
    // 确保先初始化统计数据，再获取地区信息
    String regionText = '未知地区';
    if (userInfo.isNotEmpty && userInfo['department'] != null) {
      regionText = userInfo['department'];
    }
    
    statistics.addAll({
      'todayVisits': 1156,
      'visitTrend': 12,
      'predictionCount': 56,
      'predictionTrend': -8,
      'subscriptionCount': 1156,
      'subscriptionTrend': 12,
      'region': regionText
    });
  }
  
  // 初始化用户列表数据（演示数据，实际应该从API获取）
  void _initUserListData() {
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
  
  // 刷新用户数据
  Future<void> refreshUserData() async {
    await _loadUserData();
  }
}
