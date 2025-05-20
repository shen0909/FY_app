import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safe_app/models/login_data.dart';

class SharedPreference {
  static const String TOKEN_KEY = 'token';
  static const String USER_ID_KEY = 'user_id';
  static const String USER_NAME_KEY = 'user_name';
  static const String USER_ROLE_KEY = 'user_role';
  static const String USER_DATA_KEY = 'user_data';

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

  // 清除所有数据
  static Future<bool> clearAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}
