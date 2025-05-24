import 'dart:convert';
import 'package:safe_app/https/api_service.dart';
import 'package:safe_app/utils/shared_prefer.dart';

class TokenUtil {
  // 验证token是否有效
  static Future<bool> isTokenValid() async {
    try {
      String? token = await SharedPreference.getToken();
      if (token == null || token.isEmpty) return false;
      
      // 解析JWT token获取过期时间
      final parts = token.split('.');
      if (parts.length != 3) return false;
      
      // 解码payload部分
      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      final payloadMap = json.decode(decoded);
      
      // 获取过期时间（exp字段，单位为秒）
      final expiry = payloadMap['exp'];
      if (expiry == null) return false;
      
      // 比较当前时间和过期时间
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiry * 1000);
      return DateTime.now().isBefore(expiryDate);
    } catch (e) {
      print('Token验证错误: $e');
      return false;
    }
  }

  // 如果token即将过期，尝试刷新
  static Future<bool> refreshTokenIfNeeded() async {
    try {
      String? token = await SharedPreference.getToken();
      if (token == null || token.isEmpty) return false;
      
      // 解析token获取过期时间
      final parts = token.split('.');
      if (parts.length != 3) return false;
      
      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      final payloadMap = json.decode(decoded);
      
      final expiry = payloadMap['exp'];
      if (expiry == null) return false;
      
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiry * 1000);
      final now = DateTime.now();
      
      // 如果token还有不到1小时过期，尝试刷新
      if (expiryDate.difference(now).inHours < 1) {
        // 调用刷新token接口
        String? newToken = await ApiService().refreshToken();
        return newToken != null;
      }
      
      return true;
    } catch (e) {
      print('刷新Token错误: $e');
      return false;
    }
  }
} 