import 'package:safe_app/models/login_data.dart';
import 'package:safe_app/utils/shared_prefer.dart';

/// 用户信息工具类
class UserUtils {
  /// 获取当前登录用户信息
  static Future<LoginData?> getCurrentUser() async {
    return await FYSharedPreferenceUtils.getLoginData();
  }
  
  /// 判断用户是否已登录
  static Future<bool> isLoggedIn() async {
    final token = await FYSharedPreferenceUtils.getToken();
    return token != null && token.isNotEmpty;
  }
  
  /// 获取用户ID
  static Future<String?> getUserId() async {
    final userData = await getCurrentUser();
    return userData?.userid;
  }
  
  /// 获取用户名
  static Future<String?> getUserName() async {
    final userData = await getCurrentUser();
    return userData?.username;
  }
  
  /// 获取用户角色
  static Future<int?> getUserRole() async {
    final userData = await getCurrentUser();
    return userData?.user_role;
  }
  
  /// 获取用户昵称
  static Future<String?> getNickname() async {
    final userData = await getCurrentUser();
    return userData?.nickname;
  }
  
  /// 获取用户所在省份
  static Future<String?> getProvince() async {
    final userData = await getCurrentUser();
    return userData?.province;
  }
  
  /// 获取用户所在城市
  static Future<String?> getCity() async {
    final userData = await getCurrentUser();
    return userData?.city;
  }
  
  /// 用户退出登录
  static Future<bool> logout() async {
    return await FYSharedPreferenceUtils.clearAll();
  }
} 