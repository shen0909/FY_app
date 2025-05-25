import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PatternLockUtil {
  static const String PATTERN_KEY = 'pattern_lock';
  static const String PATTERN_ENABLED_KEY = 'pattern_enabled';
  static const String PATTERN_FAILED_ATTEMPTS = 'pattern_failed_attempts';
  static const String PATTERN_LOCK_TIME = 'pattern_lock_time';
  static const int MAX_FAILED_ATTEMPTS = 5;
  static const int LOCK_DURATION_MINUTES = 30;

  // 保存图案
  static Future<bool> savePattern(List<int> pattern) async {
    if (pattern.length < 4) {
      return false; // 图案太短，不安全
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(PATTERN_KEY, jsonEncode(pattern));
  }

  // 启用图案锁屏
  static Future<bool> enablePatternLock(bool enabled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(PATTERN_ENABLED_KEY, enabled);
  }

  // 是否启用了图案锁屏
  static Future<bool> isPatternEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(PATTERN_ENABLED_KEY) ?? false;
  }

  // 获取保存的图案
  static Future<List<int>?> getPattern() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? patternString = prefs.getString(PATTERN_KEY);
    if (patternString == null) {
      return null;
    }

    List<dynamic> decoded = jsonDecode(patternString);
    return decoded.map<int>((e) => e as int).toList();
  }

  // 验证图案
  static Future<bool> verifyPattern(List<int> inputPattern) async {
    List<int>? savedPattern = await getPattern();
    if (savedPattern == null) {
      return false;
    }

    if (savedPattern.length != inputPattern.length) {
      return false;
    }

    for (int i = 0; i < savedPattern.length; i++) {
      if (savedPattern[i] != inputPattern[i]) {
        return false;
      }
    }

    return true;
  }

  // 记录失败尝试
  static Future<int> recordFailedAttempt() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int attempts = prefs.getInt(PATTERN_FAILED_ATTEMPTS) ?? 0;
    attempts++;
    await prefs.setInt(PATTERN_FAILED_ATTEMPTS, attempts);

    // 如果达到最大尝试次数，设置锁定时间
    if (attempts >= MAX_FAILED_ATTEMPTS) {
      int lockTime = DateTime.now().millisecondsSinceEpoch +
          (LOCK_DURATION_MINUTES * 60 * 1000);
      await prefs.setInt(PATTERN_LOCK_TIME, lockTime);
    }

    return attempts;
  }

  // 重置失败尝试次数
  static Future<void> resetFailedAttempts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(PATTERN_FAILED_ATTEMPTS);
    await prefs.remove(PATTERN_LOCK_TIME);
  }

  // 检查是否被锁定
  static Future<bool> isLocked() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? lockTime = prefs.getInt(PATTERN_LOCK_TIME);
    int attempts = prefs.getInt(PATTERN_FAILED_ATTEMPTS) ?? 0;

    if (lockTime != null && attempts >= MAX_FAILED_ATTEMPTS) {
      if (DateTime.now().millisecondsSinceEpoch < lockTime) {
        return true;
      } else {
        // 锁定时间已过，重置失败次数
        await resetFailedAttempts();
        return false;
      }
    }

    return false;
  }

  // 获取剩余锁定时间（分钟）
  static Future<int> getRemainingLockTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? lockTime = prefs.getInt(PATTERN_LOCK_TIME);

    if (lockTime == null) {
      return 0;
    }

    int remainingMs = lockTime - DateTime.now().millisecondsSinceEpoch;
    if (remainingMs <= 0) {
      return 0;
    }

    return (remainingMs / (60 * 1000)).ceil(); // 转换为分钟并向上取整
  }

  // 获取剩余允许尝试次数
  static Future<int> getRemainingAttempts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int attempts = prefs.getInt(PATTERN_FAILED_ATTEMPTS) ?? 0;
    return MAX_FAILED_ATTEMPTS - attempts;
  }

  // 清除图案锁屏设置
  static Future<void> clearPatternLock() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(PATTERN_KEY);
    await prefs.remove(PATTERN_ENABLED_KEY);
    await resetFailedAttempts();
  }
}
