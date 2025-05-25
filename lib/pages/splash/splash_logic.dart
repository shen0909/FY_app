import 'package:get/get.dart';
import 'package:safe_app/routers/routers.dart';
import 'package:safe_app/utils/pattern_lock_util.dart';
import 'package:safe_app/utils/shared_prefer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashLogic extends GetxController {
  @override
  void onReady() {
    super.onReady();
    // 延迟一秒，展示启动页
    Future.delayed(const Duration(seconds: 1), () {
      _checkAuthAndNavigate();
    });
  }

  // 检查认证状态并导航
  Future<void> _checkAuthAndNavigate() async {
    try {
      // 检查是否有登录数据
      bool hasLoginData = await _hasLoginData();
      
      if (hasLoginData) {
        // 有登录数据，检查生物认证状态
        bool hasPatternLock = await PatternLockUtil.isPatternEnabled();
        bool hasFingerprintLock = await _isFingerprintEnabled();
        
        if (hasPatternLock) {
          // 有图案锁，进入图案锁验证页面
          Get.offAllNamed(Routers.patternLock);
        } else if (hasFingerprintLock) {
          // 有指纹锁，进入指纹验证页面
          Get.offAllNamed(Routers.fingerprintAuth);
        } else {
          // 未设置生物认证，进入主页
          Get.offAllNamed(Routers.home);
        }
      } else {
        // 无登录数据，直接进入登录页
        Get.offAllNamed(Routers.login);
      }
    } catch (e) {
      // 发生错误，进入登录页
      print('启动页检查错误: $e');
      Get.offAllNamed(Routers.login);
    }
  }
  
  // 检查是否有登录数据
  Future<bool> _hasLoginData() async {
    String? token = await SharedPreference.getToken();
    return token != null && token.isNotEmpty;
  }

  // 检查是否启用了指纹锁
  Future<bool> _isFingerprintEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('fingerprint_enabled') ?? false;
  }
} 