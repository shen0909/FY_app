import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:safe_app/routers/routers.dart';
import 'package:safe_app/utils/shared_prefer.dart';
import 'package:safe_app/https/api_service.dart';
import 'package:flutter/foundation.dart';

/// Token拦截器
/// 用于处理token过期和刷新
class TokenInterceptor extends Interceptor {
  static final TokenInterceptor _instance = TokenInterceptor._internal();
  factory TokenInterceptor() => _instance;
  
  TokenInterceptor._internal();
  
  final String _tag = 'TokenInterceptor';
  
  // 是否正在刷新token
  bool _isRefreshing = false;
  
  // 等待token刷新的请求队列
  final List<RequestOptions> _pendingRequests = [];
  
  // 重试请求的Dio实例
  late Dio _dio;
  
  void setDio(Dio dio) {
    _dio = dio;
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 检查是否是token过期错误
    if (_isTokenExpiredError(err)) {
      if (kDebugMode) {
        print('$_tag Token过期，准备刷新');
      }
      
      // 保存原始请求
      RequestOptions options = err.requestOptions;
      
      // 如果已经在刷新过程中，将请求加入队列
      if (_isRefreshing) {
        if (kDebugMode) {
          print('$_tag 已经在刷新Token，将请求加入队列: ${options.path}');
        }
        _pendingRequests.add(options);
        return;
      }
      
      _isRefreshing = true;
      
      try {
        // 刷新token
        String? newToken = await ApiService().refreshToken();
        
        if (newToken != null && newToken.isNotEmpty) {
          if (kDebugMode) {
            print('$_tag Token刷新成功，处理队列中的请求');
          }
          
          // 使用新token重试当前请求
          options.headers["Authorization"] = "Bearer $newToken";
          
          // 处理之前加入队列的请求
          for (RequestOptions request in _pendingRequests) {
            request.headers["Authorization"] = "Bearer $newToken";
            _dio.fetch(request);
          }
          _pendingRequests.clear();
          
          // 重试当前请求
          final response = await _dio.fetch(options);
          handler.resolve(response);
        } else {
          // 刷新失败，需要重新登录
          if (kDebugMode) {
            print('$_tag Token刷新失败，需要重新登录');
          }
          _pendingRequests.clear();
          _navigateToLogin();
          handler.next(err);
        }
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 刷新Token出错: $e');
        }
        // 处理刷新异常
        _pendingRequests.clear();
        _navigateToLogin();
        handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }
  
  // 判断是否是token过期错误
  bool _isTokenExpiredError(DioException err) {
    // 这里根据实际后端返回的错误码判断
    // 通常有以下几种情况:
    // 1. HTTP状态码 401
    // 2. 后端自定义错误码，如 {"code": 401, "message": "token过期"}
    
    if (err.response?.statusCode == 401) {
      return true;
    }
    
    // 判断后端自定义错误码
    if (err.response?.data is Map) {
      final data = err.response?.data as Map;
      if (data.containsKey('code') && (data['code'] == 401 || data['code'] == 10011)) {
        return true;
      }
    }
    
    return false;
  }
  
  // 跳转到登录页
  void _navigateToLogin() {
    // 清除登录数据
    SharedPreference.clearLoginData();
    
    // 延迟跳转，避免在拦截器中直接调用Get.offAllNamed可能导致的问题
    Future.delayed(const Duration(milliseconds: 100), () {
      Get.offAllNamed(Routers.login);
    });
  }
} 