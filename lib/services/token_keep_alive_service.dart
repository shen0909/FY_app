import 'dart:async';
import 'package:flutter/foundation.dart';
import '../https/api_service.dart';

/// Token保活服务
/// 用于定时ping服务器以维持token时效
class TokenKeepAliveService {
  static final TokenKeepAliveService _instance = TokenKeepAliveService._internal();
  static const String _tag = 'TokenKeepAliveService';
  
  factory TokenKeepAliveService() => _instance;
  
  TokenKeepAliveService._internal();
  
  Timer? _pingTimer;
  bool _isRunning = false;
  
  /// 启动Token保活服务
  /// 每1分钟ping一次服务器
  void startKeepAlive() {
    if (_isRunning) {
      if (kDebugMode) {
        print('$_tag Token保活服务已在运行中');
      }
      return;
    }
    
    if (kDebugMode) {
      print('$_tag 启动Token保活服务，每1分钟ping一次');
    }
    
    _isRunning = true;
    
    // 立即执行一次ping
    _performPing();
    
    // 创建定时器，每1分钟执行一次
    _pingTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _performPing();
    });
  }
  
  /// 停止Token保活服务
  void stopKeepAlive() {
    if (!_isRunning) {
      if (kDebugMode) {
        print('$_tag Token保活服务未在运行');
      }
      return;
    }
    
    if (kDebugMode) {
      print('$_tag 停止Token保活服务');
    }
    
    _pingTimer?.cancel();
    _pingTimer = null;
    _isRunning = false;
  }
  
  /// 执行ping操作
  Future<void> _performPing() async {
    try {
      bool success = await ApiService().pingTokenKeepAlive();
      if (kDebugMode) {
        if (success) {
          print('$_tag Token保活ping成功 - ${DateTime.now().toString()}');
        } else {
          print('$_tag Token保活ping失败 - ${DateTime.now().toString()}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('$_tag Token保活ping异常: $e');
      }
    }
  }
  
  /// 检查服务是否正在运行
  bool get isRunning => _isRunning;
  
  /// 重启服务（先停止再启动）
  void restartKeepAlive() {
    stopKeepAlive();
    startKeepAlive();
  }
} 