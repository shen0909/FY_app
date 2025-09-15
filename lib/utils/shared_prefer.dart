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
  static const String USER_DATA_KEY = 'user_data';
  static const String FINGERPRINT_ENABLED_KEY = 'fingerprint_enabled';
  static const String PATTERN_LOCK_FAILED_ATTEMPTS = 'pattern_lock_failed_attempts';
  static const String PATTERN_LOCK_TIMESTAMP = 'pattern_lock_timestamp';
  static const String PATTERN_LOCK_ENABLED = 'pattern_lock_enabled';
  static const String IS_FIRST_LOGIN = 'is_first_login';
  
  // 新增外层和内层token相关的key
  static const String OUTER_ACCESS_TOKEN_KEY = 'outer_access_token';
  static const String OUTER_REFRESH_TOKEN_KEY = 'outer_refresh_token';
  static const String INNER_ACCESS_TOKEN_KEY = 'inner_access_token';
  // 新增：用户凭据安全存储相关的key
  static const String STORED_USERNAME_KEY = 'stored_username';
  static const String STORED_PASSWORD_KEY = 'stored_password_encoded';

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
      'region': loginData.region,
      'user_role': loginData.user_role,
      'nickname': loginData.nickname,
      'lastLoginAt': loginData.lastLoginAt,
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
  
  // 保存外层访问令牌
  static Future<bool> saveOuterAccessToken(String token) async {
    return setString(OUTER_ACCESS_TOKEN_KEY, token);
  }
  
  // 获取外层访问令牌
  static Future<String?> getOuterAccessToken() async {
    return getString(OUTER_ACCESS_TOKEN_KEY);
  }
  
  // 保存外层刷新令牌
  static Future<bool> saveOuterRefreshToken(String token) async {
    return setString(OUTER_REFRESH_TOKEN_KEY, token);
  }
  
  // 获取外层刷新令牌
  static Future<String?> getOuterRefreshToken() async {
    return getString(OUTER_REFRESH_TOKEN_KEY);
  }
  
  // 保存内层访问令牌
  static Future<bool> saveInnerAccessToken(String token) async {
    // 同时保存到旧的TOKEN_KEY，保持兼容性
    await setString(TOKEN_KEY, token);
    return setString(INNER_ACCESS_TOKEN_KEY, token);
  }
  
  // 获取内层访问令牌
  static Future<String?> getInnerAccessToken() async {
    return getString(INNER_ACCESS_TOKEN_KEY);
  }

  // 清除登录数据
  static Future<bool> clearLoginData() async {
    await remove(TOKEN_KEY);
    await remove(USER_DATA_KEY);
    await remove(OUTER_ACCESS_TOKEN_KEY);
    await remove(OUTER_REFRESH_TOKEN_KEY);
    return remove(INNER_ACCESS_TOKEN_KEY);
  }

  // 清除所有数据
  static Future<bool> clearAll() async {
    await remove(user_device);
    await remove(TOKEN_KEY);
    await remove(USER_DATA_KEY);
    await remove(FINGERPRINT_ENABLED_KEY);
    await remove(PATTERN_LOCK_FAILED_ATTEMPTS);
    await remove(PATTERN_LOCK_TIMESTAMP);
    await remove(PATTERN_LOCK_ENABLED);
    await remove(IS_FIRST_LOGIN);
    await remove(OUTER_ACCESS_TOKEN_KEY);
    await remove(OUTER_REFRESH_TOKEN_KEY);
    await remove(INNER_ACCESS_TOKEN_KEY);
    return true;
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

  /// 安全存储用户登录凭据（用于生物识别登录）
  /// [username] 用户名
  /// [password] 密码（将被编码存储）
  static Future<bool> saveUserCredentials(String username, String password) async {
    // 使用Base64编码密码以提供基本保护
    String encodedPassword = base64Encode(utf8.encode(password));
    
    await setString(STORED_USERNAME_KEY, username);
    return setString(STORED_PASSWORD_KEY, encodedPassword);
  }

  /// 获取已存储的用户凭据
  /// 返回Map包含username和password，如果没有存储则返回null
  static Future<Map<String, String>?> getUserCredentials() async {
    String? username = getString(STORED_USERNAME_KEY);
    String? encodedPassword = getString(STORED_PASSWORD_KEY);
    
    if (username.isEmpty || encodedPassword.isEmpty) {
      return null;
    }
    
    try {
      // 解码密码
      String password = utf8.decode(base64Decode(encodedPassword));
      return {
        'username': username,
        'password': password,
      };
    } catch (e) {
      print('解码用户凭据失败: $e');
      return null;
    }
  }

  /// 清除存储的用户凭据
  static Future<bool> clearUserCredentials() async {
    await remove(STORED_USERNAME_KEY);
    return remove(STORED_PASSWORD_KEY);
  }

  /// 检查是否已存储用户凭据
  static Future<bool> hasUserCredentials() async {
    String? username = getString(STORED_USERNAME_KEY);
    String? encodedPassword = getString(STORED_PASSWORD_KEY);
    return username.isNotEmpty && encodedPassword.isNotEmpty;
  }
}
