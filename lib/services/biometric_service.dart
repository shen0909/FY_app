import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  
  // 检查设备是否支持生物识别
  static Future<bool> isBiometricAvailable() async {
    bool canCheckBiometrics = false;
    try {
      canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } on PlatformException catch (e) {
      print('生物识别检查失败: ${e.message}');
      return false;
    }
  }
  
  // 获取可用的生物识别类型
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('获取可用生物识别类型失败: ${e.message}');
      return [];
    }
  }
  
  // 验证指纹
  static Future<bool> authenticateWithBiometrics({required String reason}) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        print('生物识别认证失败: 设备不支持或未启用生物识别');
        return false;
      }
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          sensitiveTransaction: true,
        ),
      );
    } on PlatformException catch (e) {
      print('生物识别认证失败: ${e.message}, 错误代码: ${e.code}');
      
      // 企业级错误处理
      switch (e.code) {
        case auth_error.notAvailable:
          throw Exception('设备不支持指纹登录');
        case auth_error.notEnrolled:
          throw Exception('设备未设置指纹，请先在系统设置中添加指纹');
        case auth_error.lockedOut:
          throw Exception('指纹验证次数过多，请稍后再试');
        case auth_error.permanentlyLockedOut:
          throw Exception('指纹功能已被锁定，请使用其他认证方式');
        default:
          throw Exception('指纹验证失败: ${e.message}');
      }
    } catch (e) {
      print('生物识别认证异常: $e');
      throw Exception('生物识别认证服务异常，请联系技术支持');
    }
  }
  
  // 保存用户选择使用生物识别登录的状态
  Future<void> saveBiometricEnabled(String username, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_$username', enabled);
    
    // 如果关闭指纹登录则清除凭证
    if (!enabled) {
      await clearUserCredentials();
    }
  }
  
  // 检查用户是否开启了生物识别登录
  Future<bool> isBiometricEnabled(String username) async {
    if (username.isEmpty) return false;
    
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_$username') ?? false;
  }
  
  // 保存账号信息（仅用于演示，实际应用中应使用更安全的存储方式）
  Future<void> saveUserCredentials(String username, String password) async {
    if (username.isEmpty || password.isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bio_username', username);
    await prefs.setString('bio_password', password);
    print('保存了用户凭证：$username');
  }
  
  // 获取保存的账号信息
  Future<Map<String, String?>> getUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('bio_username');
    final password = prefs.getString('bio_password');
    
    print('读取用户凭证：$username');
    return {
      'username': username,
      'password': password,
    };
  }
  
  // 判断是否存在保存的用户凭证
  Future<bool> hasUserCredentials() async {
    final credentials = await getUserCredentials();
    return credentials['username'] != null && 
           credentials['username']!.isNotEmpty &&
           credentials['password'] != null &&
           credentials['password']!.isNotEmpty;
  }
  
  // 清除用户凭证
  Future<void> clearUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bio_username');
    await prefs.remove('bio_password');
    print('清除了用户凭证');
  }
  
  // 清除生物识别登录相关信息
  Future<void> clearBiometricLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('bio_username');
    if (username != null && username.isNotEmpty) {
      await prefs.remove('biometric_$username');
    }
    await clearUserCredentials();
  }
} 