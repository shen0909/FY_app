import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safe_app/models/login_data.dart';

class SharedPreference {
  static const String TOKEN_KEY = 'token';
  static const String USER_ID_KEY = 'user_id';
  static const String USER_NAME_KEY = 'user_name';
  static const String USER_ROLE_KEY = 'user_role';
  static const String USER_DATA_KEY = 'user_data';
  static const String USE_PASSWORD_LOGIN_KEY = 'use_password_login';
  static const String FINGERPRINT_ENABLED_KEY = 'fingerprint_enabled';
  static const String PATTERN_LOCK_FAILED_ATTEMPTS = 'pattern_lock_failed_attempts';
  static const String PATTERN_LOCK_TIMESTAMP = 'pattern_lock_timestamp';
  static const String PATTERN_LOCK_ENABLED = 'pattern_lock_enabled';
  static const String IS_FIRST_LOGIN = 'is_first_login';

  // 保存完整的LoginData对象
  static Future<bool> saveLoginData(LoginData loginData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // 将LoginData对象转为JSON字符串
    String userData = jsonEncode({
      'token': loginData.token,
      'userid': loginData.userid,
      'username': loginData.username,
      'province': loginData.province,
      'city': loginData.city,
      'county_level_city': loginData.county_level_city,
      'user_role': loginData.user_role,
      'nickname': loginData.nickname,
    });

    // 同时存储token便于快速访问
    await prefs.setString(TOKEN_KEY, loginData.token);
    return prefs.setString(USER_DATA_KEY, userData);
  }

  // 获取完整的LoginData对象
  static Future<LoginData?> getLoginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString(USER_DATA_KEY);
    if (userData == null) {
      return null;
    }

    Map<String, dynamic> jsonData = jsonDecode(userData);
    return LoginData.fromJson(jsonData);
  }

  // 保存token
  static Future<bool> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(TOKEN_KEY, token);
  }

  // 获取token
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(TOKEN_KEY);
  }

  // 清除token
  static Future<bool> removeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(TOKEN_KEY);
  }

  // 保存用户信息
  static Future<bool> saveUserInfo({
    required String userId,
    required String userName,
    required int userRole,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_ID_KEY, userId);
    await prefs.setString(USER_NAME_KEY, userName);
    return prefs.setInt(USER_ROLE_KEY, userRole);
  }

  // 获取用户ID
  static Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(USER_ID_KEY);
  }

  // 获取用户名
  static Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(USER_NAME_KEY);
  }

  // 获取用户角色
  static Future<int?> getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(USER_ROLE_KEY);
  }

  // 清除登录数据
  static Future<bool> clearLoginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(TOKEN_KEY);
    await prefs.remove(USER_ID_KEY);
    await prefs.remove(USER_NAME_KEY);
    await prefs.remove(USER_ROLE_KEY);
    return prefs.remove(USER_DATA_KEY);
  }

  // 清除所有数据
  static Future<bool> clearAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }

  // 设置使用密码登录标记
  static Future<bool> setUsePasswordLogin(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(USE_PASSWORD_LOGIN_KEY, value);
  }

  // 获取使用密码登录标记
  static Future<bool> getUsePasswordLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(USE_PASSWORD_LOGIN_KEY) ?? false;
  }

  // 移除使用密码登录标记
  static Future<bool> removeUsePasswordLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(USE_PASSWORD_LOGIN_KEY);
  }

  // 设置指纹登录启用状态
  static Future<bool> setFingerprintEnabled(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(FINGERPRINT_ENABLED_KEY, value);
  }

  // 获取指纹登录启用状态
  static Future<bool> getFingerprintEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(FINGERPRINT_ENABLED_KEY) ?? false;
  }

  // 获取图案锁失败次数
  static Future<int> getPatternLockFailedAttempts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(PATTERN_LOCK_FAILED_ATTEMPTS) ?? 0;
  }

  // 设置图案锁失败次数
  static Future<bool> setPatternLockFailedAttempts(int attempts) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(PATTERN_LOCK_FAILED_ATTEMPTS, attempts);
  }

  // 重置图案锁失败次数
  static Future<bool> resetPatternLockFailedAttempts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(PATTERN_LOCK_FAILED_ATTEMPTS, 0);
  }

  // 设置图案锁锁定时间戳
  static Future<bool> setPatternLockTimestamp(int timestamp) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setInt(PATTERN_LOCK_TIMESTAMP, timestamp);
  }

  // 获取图案锁锁定时间戳
  static Future<int?> getPatternLockTimestamp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(PATTERN_LOCK_TIMESTAMP);
  }

  // 设置图案锁启用状态
  static Future<bool> setPatternLockEnabled(bool enabled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(PATTERN_LOCK_ENABLED, enabled);
  }

  // 获取图案锁启用状态
  static Future<bool> getPatternLockEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PATTERN_LOCK_ENABLED) ?? false;
  }

  // 检查是否是首次登录
  static Future<bool> isFirstLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(IS_FIRST_LOGIN) ?? true;
  }

  // 设置非首次登录
  static Future<bool> setNotFirstLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(IS_FIRST_LOGIN, false);
  }
}
