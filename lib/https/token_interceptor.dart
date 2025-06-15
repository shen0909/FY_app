import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:safe_app/routers/routers.dart';
import 'package:safe_app/utils/shared_prefer.dart';
import 'package:safe_app/https/api_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

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
        // 根据请求路径判断使用哪种刷新方式
        if (options.path == '/send_channel_event') {
          // 应用内接口可能需要重新登录应用
          // 先尝试刷新外层token
          bool refreshed = await _refreshOuterToken(options);
          
          if (!refreshed) {
            // 如果外层token刷新失败，需要重新登录
            if (kDebugMode) {
              print('$_tag 应用内接口刷新Token失败，需要重新登录');
            }
            _pendingRequests.clear();
            _navigateToLogin();
            handler.next(err);
            return;
          }
          
          // 重新尝试应用内登录
          bool innerLoginSuccess = await ApiService().reLoginInnerApp();
          
          if (!innerLoginSuccess) {
            if (kDebugMode) {
              print('$_tag 应用内重新登录失败，需要重新登录');
            }
            _pendingRequests.clear();
            _navigateToLogin();
            handler.next(err);
            return;
          }
          
          // 获取新的内层token
          String? innerToken = await FYSharedPreferenceUtils.getInnerAccessToken();
          
          // 处理之前加入队列的请求
          for (RequestOptions request in _pendingRequests) {
            // 更新应用内请求参数中的token
            if (request.path == '/send_channel_event' && request.data is Map) {
              Map<String, dynamic> data = Map<String, dynamic>.from(request.data);
              if (data.containsKey('param_string')) {
                try {
                  Map<String, dynamic> paramData = Map<String, dynamic>.from(
                    data['param_string'] is String 
                        ? jsonDecode(data['param_string']) 
                        : data['param_string']
                  );
                  paramData['当前请求用户UUID'] = innerToken;
                  data['param_string'] = jsonEncode(paramData);
                  request.data = data;
                } catch (e) {
                  if (kDebugMode) {
                    print('$_tag 更新请求参数中的token失败: $e');
                  }
                }
              }
            }
            _dio.fetch(request);
          }
          _pendingRequests.clear();
          
          // 更新当前请求参数中的token
          if (options.data is Map) {
            Map<String, dynamic> data = Map<String, dynamic>.from(options.data);
            if (data.containsKey('param_string')) {
              try {
                Map<String, dynamic> paramData = Map<String, dynamic>.from(
                  data['param_string'] is String 
                      ? jsonDecode(data['param_string']) 
                      : data['param_string']
                );
                paramData['当前请求用户UUID'] = innerToken;
                data['param_string'] = jsonEncode(paramData);
                options.data = data;
              } catch (e) {
                if (kDebugMode) {
                  print('$_tag 更新请求参数中的token失败: $e');
                }
              }
            }
          }
          
          // 重试当前请求
          final response = await _dio.fetch(options);
          handler.resolve(response);
        } else {
          // 外层接口，刷新外层token
          bool refreshed = await _refreshOuterToken(options);
          
          if (refreshed) {
            // 处理之前加入队列的请求
            for (RequestOptions request in _pendingRequests) {
              _dio.fetch(request);
            }
            _pendingRequests.clear();
            
            // 重试当前请求
            final response = await _dio.fetch(options);
            handler.resolve(response);
          } else {
            // 刷新失败，需要重新登录
            _pendingRequests.clear();
            _navigateToLogin();
            handler.next(err);
          }
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
  
  /// 刷新外层token
  Future<bool> _refreshOuterToken(RequestOptions options) async {
    String? newToken = await ApiService().refreshOuterToken();
    
    if (newToken != null && newToken.isNotEmpty) {
      if (kDebugMode) {
        print('$_tag 外层Token刷新成功');
      }
      
      // 更新请求头
      options.headers["Authorization"] = "Bearer $newToken";
      return true;
    }
    return false;
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
      // 外层token过期
      if (data.containsKey('error_code') && data['error_code'] == 401) {
        return true;
      }
      
      // 内层token过期
      if (data.containsKey('is_success') && 
          data.containsKey('result_string') && 
          data['result_string'] is String) {
        try {
          Map<String, dynamic> resultData = jsonDecode(data['result_string']);
          if (resultData.containsKey('状态码') && resultData['状态码'] == 30001) {
            return true;
          }
        } catch (e) {
          // 解析错误，不处理
        }
      }
      
      // 兼容旧接口
      if (data.containsKey('code') && (data['code'] == 401 || data['code'] == 10011)) {
        return true;
      }
    }
    
    return false;
  }
  
  // 跳转到登录页
  void _navigateToLogin() {
    // 清除登录数据
    FYSharedPreferenceUtils.clearLoginData();
    
    // 延迟跳转，避免在拦截器中直接调用Get.offAllNamed可能导致的问题
    Future.delayed(const Duration(milliseconds: 100), () {
      Get.offAllNamed(Routers.login);
    });
  }
} 