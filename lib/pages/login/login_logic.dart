import 'dart:async';
import 'package:get/get.dart';
import 'package:safe_app/routers/routers.dart';
import 'package:safe_app/utils/pattern_lock_util.dart';
import 'package:safe_app/utils/shared_prefer.dart';
import 'package:safe_app/utils/toast_util.dart';
import 'package:safe_app/models/login_data.dart';
import 'package:safe_app/pages/login/api/login_api.dart';
import 'package:local_auth/local_auth.dart';

import 'login_state.dart';

class LoginLogic extends GetxController {
  final LoginState state = LoginState();
  Timer? _lockTimer;
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
  }

  @override
  void onReady() {
    super.onReady();
    _checkAuthAndNavigate();
  }

  @override
  void onClose() {
    _lockTimer?.cancel();
    state.accountController.dispose();
    state.passwordController.dispose();
    super.onClose();
  }

  // 加载用户信息
  Future<void> _loadUserInfo() async {
    try {
      final loginData = await FYSharedPreferenceUtils.getLoginData();
      if (loginData != null) {
        state.userName.value = loginData.username ?? '';
        _setGreetingMessage();
      }
    } catch (e) {
      print('加载用户信息错误: $e');
    }
  }

  // 设置问候语
  void _setGreetingMessage() {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 6) {
      greeting = '凌晨好';
    } else if (hour < 9) {
      greeting = '早上好';
    } else if (hour < 12) {
      greeting = '上午好';
    } else if (hour < 14) {
      greeting = '中午好';
    } else if (hour < 18) {
      greeting = '下午好';
    } else if (hour < 22) {
      greeting = '晚上好';
    } else {
      greeting = '夜深了';
    }

    state.greetingMessage.value = greeting;
  }

  Future<void> _checkAuthAndNavigate() async {
    state.isChecking.value = true;

    try {
      bool hasPatternLock = await PatternLockUtil.isPatternEnabled();
      bool hasFingerprintLock = await FYSharedPreferenceUtils.getFingerprintEnabled();

      if (hasFingerprintLock) {
        state.loginMethod.value = 2; // 指纹登录
        _startFingerprintAuth();
      } else if (hasPatternLock) {
        state.loginMethod.value = 1; // 划线登录
        await _checkLockStatus();
      } else {
        state.loginMethod.value = 0; // 密码登录
      }
    } catch (e) {
      print('检查认证状态错误: $e');
      state.loginMethod.value = 0; // 发生错误时默认使用密码登录
    } finally {
      state.isChecking.value = false;
    }
  }

  // 启动指纹认证
  Future<void> _startFingerprintAuth() async {
    if (state.isBiometricAuthenticating.value) return;

    try {
      state.isBiometricAuthenticating.value = true;

      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        ToastUtil.showError('设备不支持生物认证');
        state.loginMethod.value = 0;
        return;
      }

      bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: '请验证指纹以登录',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        Get.offAllNamed(Routers.home);
      } else {
        // 指纹验证失败后切换到密码登录
        state.loginMethod.value = 0;
      }
    } catch (e) {
      print('指纹认证错误: $e');
      ToastUtil.showError('指纹认证出错，请使用密码登录');
      state.loginMethod.value = 0;
    } finally {
      state.isBiometricAuthenticating.value = false;
    }
  }

  // 检查锁定状态
  Future<void> _checkLockStatus() async {
    final failedAttempts =
        await FYSharedPreferenceUtils.getPatternLockFailedAttempts();
    final timestamp = await FYSharedPreferenceUtils.getPatternLockTimestamp();

    if (failedAttempts >= 5 && timestamp != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final lockDuration = 0.3 * 60 * 1000; // 30分钟

      if (now - timestamp < lockDuration) {
        state.isLocked.value = true;
        state.lockTimeMinutes.value =
            ((lockDuration - (now - timestamp)) / (60 * 1000)).ceil();
        _startLockTimer();
        // 如果被锁定，切换到密码登录
        // state.loginMethod.value = 0;
      } else {
        await FYSharedPreferenceUtils.resetPatternLockFailedAttempts();
        state.remainingAttempts.value = 5;
        state.isLocked.value = false;
      }
    } else {
      state.remainingAttempts.value = 5 - (failedAttempts);
      state.isLocked.value = false;
    }
  }

  // 启动锁定倒计时
  void _startLockTimer() {
    _lockTimer?.cancel();
    _lockTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (state.lockTimeMinutes.value > 0) {
        state.lockTimeMinutes.value--;
        if (state.lockTimeMinutes.value <= 0) {
          timer.cancel();
          await FYSharedPreferenceUtils.resetPatternLockFailedAttempts();
          state.isLocked.value = false;
          state.remainingAttempts.value = 5;
        }
      }
    });
  }

  // 执行密码登录
  Future<void> doLogin() async {
    String account = state.accountController.text;
    String password = state.passwordController.text;
    if (account.isEmpty) {
      ToastUtil.showError('请输入账号');
      return;
    }
    if (password.isEmpty) {
      ToastUtil.showError('请输入密码');
      return;
    }
    state.isLogging.value = true;

    try {
      LoginData? loginData = await LoginApi.login(account, password);
      print("登录排查:${loginData?.token}");
      if (loginData != null) {
        await FYSharedPreferenceUtils.saveLoginData(loginData);
        state.isLogging.value = false;

        bool isFirstLogin = await FYSharedPreferenceUtils.isFirstLogin();
        if (isFirstLogin) {
          // 首次登录，需要设置安全锁屏方式
          await FYSharedPreferenceUtils.setNotFirstLogin();
          ToastUtil.showShort('首次登录需要设置安全锁屏方式');
          Get.offAllNamed(Routers.lockMethodSelection);
        } else {
          // 非首次登录，检查是否已设置锁屏方式
          bool hasSetupLockMethod = await _hasSetupLockMethod();
          if (!hasSetupLockMethod) {
            // 如果还没设置过锁屏方式，引导用户设置
            ToastUtil.showShort('请设置安全锁屏方式');
            Get.offAllNamed(Routers.lockMethodSelection);
          } else {
            Get.offAllNamed(Routers.home);
          }
        }
      } else {
        state.isLogging.value = false;
        ToastUtil.showError('登录失败，请检查账号密码');
      }
    } catch (e) {
      state.isLogging.value = false;
      ToastUtil.showError('登录失败: ${e.toString()}');
    }
  }

  // 执行划线登录
  Future<void> handlePatternLogin(List<int> pattern) async {
    if (state.isLocked.value) {
      return;
    }

    state.isLogging.value = true;
    try {
      bool isValid = await PatternLockUtil.verifyPattern(pattern);
      if (isValid) {
        await FYSharedPreferenceUtils.resetPatternLockFailedAttempts();
        state.isLogging.value = false;
        Get.offAllNamed(Routers.home);
      } else {
        final failedAttempts =
            await FYSharedPreferenceUtils.getPatternLockFailedAttempts();
        final newFailedAttempts = failedAttempts + 1;
        await FYSharedPreferenceUtils.setPatternLockFailedAttempts(newFailedAttempts);

        state.remainingAttempts.value = 5 - newFailedAttempts;
        _showError('图案不正确，还可以尝试${state.remainingAttempts.value}次');

        if (newFailedAttempts >= 5) {
          await FYSharedPreferenceUtils.setPatternLockTimestamp(DateTime.now().millisecondsSinceEpoch);
          await _checkLockStatus();
        }
      }
    } catch (e) {
      print('划线登录失败: $e');
      ToastUtil.showError('划线登录失败，请重试');
    } finally {
      state.isLogging.value = false;
    }
  }

  // 显示错误信息
  void _showError(String message) {
    state.isError.value = true;
    state.errorMessage.value = message;

    if (state.remainingAttempts.value > 0) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        state.errorMessage.value = '';
      });
    }
  }

  // 切换到密码登录
  Future<void> switchToPasswordLogin() async {
    state.loginMethod.value = 0;
    ToastUtil.showShort('请使用账号密码登录');
  }

  // 检查是否已设置过锁屏方式
  Future<bool> _hasSetupLockMethod() async {
    bool hasPatternLock = await PatternLockUtil.isPatternEnabled();
    bool hasFingerprintLock = await FYSharedPreferenceUtils.getFingerprintEnabled();
    return hasPatternLock || hasFingerprintLock;
  }
}
