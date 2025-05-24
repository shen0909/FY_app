import 'package:safe_app/https/api_service.dart';
import 'package:safe_app/models/login_data.dart';

class LoginApi {
  // 登录接口
  static Future<LoginData?> login(String username, String password) async {
    try {
      // 调用登录接口
      var result = await ApiService().login(
        username: username,
        password: password,
      );
      
      if (result['code'] == 10010) {
        // 登录成功，返回用户数据
        return LoginData(
          token: result['data']['token'] ?? '',
          userid: result['data']['userid'] ?? '',
          username: result['data']['username'] ?? '',
          province: result['data']['province'] ?? '',
          city: result['data']['city'] ?? '',
          county_level_city: result['data']['county_level_city'] ?? '',
          user_role: result['data']['user_role'] ?? 0,
          nickname: result['data']['nickname'] ?? '',
        );
      } else {
        // 登录失败
        return null;
      }
    } catch (e) {
      print('登录接口异常: $e');
      return null;
    }
  }
} 