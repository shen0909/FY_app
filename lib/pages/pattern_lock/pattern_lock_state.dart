import 'package:get/get.dart';

class PatternLockState {
  // 错误消息
  final RxString errorMessage = ''.obs;
  
  // 是否显示错误
  final RxBool isError = false.obs;
  
  // 剩余尝试次数
  final RxInt remainingAttempts = 5.obs;
  
  // 是否被锁定
  final RxBool isLocked = false.obs;
  
  // 锁定时间（分钟）
  final RxInt lockTimeMinutes = 0.obs;
  
  // 用户名
  final RxString userName = ''.obs;
  
  // 问候语
  final RxString greetingMessage = ''.obs;
  
  PatternLockState() {
    // 初始化操作
  }
} 