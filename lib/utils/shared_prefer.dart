import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safe_app/models/login_data.dart';

late SharedPreferences prefs;

class FYSharedPreferenceUtils {

  // get String.
  static String getString(String key, {String defValue = ''}) {
    return prefs.getString(key) ?? defValue;
  }

  // set String.
  static Future<bool> setString(String key, String value) {
    return prefs.setString(key, value);
  }

  // get Bool.
  static bool getBool(String key, {bool defValue = false}) {
    return prefs.getBool(key) ?? defValue;
  }

  // set Bool.
  static Future<bool> setBool(String key, bool value) {
    return prefs.setBool(key, value);
  }

  // get Int.
  static int getInt(String key, {int defValue = 0}) {
    return prefs.getInt(key) ?? defValue;
  }

  // set Int.
  static Future<bool> setInt(String key, int value) {
    return prefs.setInt(key, value);
  }

  // remove key
  static Future<bool> remove(String key) {
    return prefs.remove(key);
  }

  static const String user_device = 'user_device'; // 用户设备
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

  // 初始化sp
  static Future initSP() async {
    prefs = await SharedPreferences.getInstance();
  }

  // 保存用户设备
  static Future<bool> saveUserDevice(String token) async {
    return setString(user_device, token);
  }

  // 获取用户设备
  static Future<String?> getUserDevice() async {
    return getString(user_device,defValue: 'phone');
  }

  // 保存完整的LoginData对象
  static Future<bool> saveLoginData(LoginData loginData) async {
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
    await setString(TOKEN_KEY, loginData.token);
    return setString(USER_DATA_KEY, userData);
  }

  // 获取完整的LoginData对象
  static Future<LoginData?> getLoginData() async {
    String? userData = getString(USER_DATA_KEY);
    if (userData.isEmpty) {
      return null;
    }

    Map<String, dynamic> jsonData = jsonDecode(userData);
    return LoginData.fromJson(jsonData);
  }

  // 保存token
  static Future<bool> saveToken(String token) async {
    return setString(TOKEN_KEY, token);
  }

  // 获取token
  static Future<String?> getToken() async {
    return getString(TOKEN_KEY);
  }

  // 清除token
  static Future<bool> removeToken() async {
    return remove(TOKEN_KEY);
  }

  // 保存用户信息
  static Future<bool> saveUserInfo({
    required String userId,
    required String userName,
    required int userRole,
  }) async {
    await setString(USER_ID_KEY, userId);
    await setString(USER_NAME_KEY, userName);
    return setInt(USER_ROLE_KEY, userRole);
  }

  // 获取用户ID
  static Future<String?> getUserId() async {
    return getString(USER_ID_KEY);
  }

  // 获取用户名
  static Future<String?> getUserName() async {
    return getString(USER_NAME_KEY);
  }

  // 获取用户角色
  static Future<int?> getUserRole() async {
    return getInt(USER_ROLE_KEY);
  }

  // 清除登录数据
  static Future<bool> clearLoginData() async {
    await remove(TOKEN_KEY);
    await remove(USER_ID_KEY);
    await remove(USER_NAME_KEY);
    await remove(USER_ROLE_KEY);
    return remove(USER_DATA_KEY);
  }

  // 清除所有数据
  static Future<bool> clearAll() async {
    return prefs.clear();
  }

  // 设置使用密码登录标记
  static Future<bool> setUsePasswordLogin(bool value) async {
    return setBool(USE_PASSWORD_LOGIN_KEY, value);
  }

  // 获取使用密码登录标记
  static Future<bool> getUsePasswordLogin() async {
    return getBool(USE_PASSWORD_LOGIN_KEY,defValue: false);
  }

  // 移除使用密码登录标记
  static Future<bool> removeUsePasswordLogin() async {
    return remove(USE_PASSWORD_LOGIN_KEY);
  }

  // 设置指纹登录启用状态
  static Future<bool> setFingerprintEnabled(bool value) async {
    return setBool(FINGERPRINT_ENABLED_KEY, value);
  }

  // 获取指纹登录启用状态
  static Future<bool> getFingerprintEnabled() async {
    return getBool(FINGERPRINT_ENABLED_KEY,defValue: false);
  }

  // 获取图案锁失败次数
  static Future<int> getPatternLockFailedAttempts() async {
    return getInt(PATTERN_LOCK_FAILED_ATTEMPTS,defValue: 0);
  }

  // 设置图案锁失败次数
  static Future<bool> setPatternLockFailedAttempts(int attempts) async {
    return setInt(PATTERN_LOCK_FAILED_ATTEMPTS, attempts);
  }

  // 重置图案锁失败次数
  static Future<bool> resetPatternLockFailedAttempts() async {
    return setInt(PATTERN_LOCK_FAILED_ATTEMPTS, 0);
  }

  // 设置图案锁锁定时间戳
  static Future<bool> setPatternLockTimestamp(int timestamp) async {
    return setInt(PATTERN_LOCK_TIMESTAMP, timestamp);
  }

  // 获取图案锁锁定时间戳
  static Future<int?> getPatternLockTimestamp() async {
    return getInt(PATTERN_LOCK_TIMESTAMP);
  }

  // 设置图案锁启用状态
  static Future<bool> setPatternLockEnabled(bool enabled) async {
    return setBool(PATTERN_LOCK_ENABLED, enabled);
  }

  // 获取图案锁启用状态
  static Future<bool> getPatternLockEnabled() async {
    return getBool(PATTERN_LOCK_ENABLED,defValue: false);
  }

  // 检查是否是首次登录
  static Future<bool> isFirstLogin() async {
    return getBool(IS_FIRST_LOGIN,defValue: true);
  }

  // 设置非首次登录
  static Future<bool> setNotFirstLogin() async {
    return setBool(IS_FIRST_LOGIN, false);
  }
}
