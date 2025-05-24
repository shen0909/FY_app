import 'package:get/get.dart';
import 'package:safe_app/routers/routers.dart';
import 'package:safe_app/utils/pattern_lock_util.dart';
import 'package:safe_app/utils/shared_prefer.dart';
import 'package:safe_app/utils/token_util.dart';
import 'package:safe_app/utils/toast_util.dart';
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
      // 检查token是否有效
      bool isTokenValid = await TokenUtil.isTokenValid();
      
      if (isTokenValid) {
        // token有效，检查是否设置了生物认证
        bool hasPatternLock = await PatternLockUtil.isPatternEnabled();
        bool hasFingerprintLock = await _isFingerprintEnabled();
        
        if (hasPatternLock) {
          // 有图案锁，进入图案锁验证页面
          Get.offAllNamed(Routers.patternLock);
        } else if (hasFingerprintLock) {
          // 有指纹锁，进入指纹验证页面
          Get.offAllNamed(Routers.fingerprintAuth);
        } else {
          // 未设置生物认证，进入登录页
          Get.offAllNamed(Routers.login);
        }
      } else {
        // token无效，尝试刷新
        bool refreshed = await TokenUtil.refreshTokenIfNeeded();
        
        if (refreshed) {
          // 刷新成功，重新检查生物认证
          _checkAuthAndNavigate();
        } else {
          // 刷新失败或无法刷新，进入登录页
          ToastUtil.showError('登录已过期，请重新登录');
          Get.offAllNamed(Routers.login);
        }
      }
    } catch (e) {
      // 发生错误，进入登录页
      print('启动页检查错误: $e');
      Get.offAllNamed(Routers.login);
    }
  }

  // 检查是否启用了指纹锁
  Future<bool> _isFingerprintEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('fingerprint_enabled') ?? false;
  }
} 