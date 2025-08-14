import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:safe_app/routers/routers.dart';
import 'package:safe_app/utils/shared_prefer.dart';
import 'package:safe_app/https/api_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:safe_app/utils/toast_util.dart';

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
    // 检查是否是登录已过期（状态码30001），如果是则直接跳转登录页
    if (err.response?.data is Map) {
      final data = err.response?.data as Map;
      if (data.containsKey('状态码') && data['状态码'] == 30001) {
        if (kDebugMode) {
          print('$_tag onError检测到登录已过期（状态码30001），直接跳转登录页');
        }
        _navigateToLogin();
        handler.next(err);
        return;
      }
    }
    
    // 检查是否是token过期错误
    if (_isTokenExpiredError(err)) {
      _handleTokenExpiredResponse(err, handler);
    } else {
      handler.next(err);
    }
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 检查业务层面的token失效（HTTP 200但业务失败）
    if (response.statusCode == 200 && response.data is Map) {
      final data = response.data as Map;
      
      // 检查是否是token失效的业务错误
      bool isTokenExpired = false;
      
      // 外层token失效检测
      if (data.containsKey('error_code') && data['error_code'] == 401) {
        isTokenExpired = true;
        if (kDebugMode) {
          print('$_tag 响应中检测到外层token失效: ${data['error_message']}');
        }
      }
      
      // 应用内token失效检测
      if (data.containsKey('is_success') && 
          data['is_success'] == false &&
          data.containsKey('error_message') &&
          data['error_message'].toString().contains('Token已失效')) {
        isTokenExpired = true;
        if (kDebugMode) {
          print('$_tag 响应中检测到应用内token失效: ${data['error_message']}');
        }
      }
      
      // 内层token失效检测
      if (data.containsKey('is_success') && 
          data.containsKey('result_string') && 
          data['result_string'] is String) {
        try {
          Map<String, dynamic> resultData = jsonDecode(data['result_string']);
          if (resultData.containsKey('状态码') && resultData['状态码'] == 30001) {
            isTokenExpired = true;
            if (kDebugMode) {
              print('$_tag 响应中检测到内层token失效，状态码: ${resultData['状态码']}');
            }
          }
        } catch (e) {
          // 解析错误，不处理
        }
      }
      
      // 直接检测外层状态码30001（登录已过期）
      if (data.containsKey('状态码') && data['状态码'] == 30001) {
        isTokenExpired = true;
        if (kDebugMode) {
          print('$_tag 响应中检测到登录已过期，状态码: ${data['状态码']}，消息: ${data['返回消息']}');
        }
      }
      
      if (isTokenExpired) {
        // 检查是否是登录已过期（状态码30001），如果是则直接跳转登录页
        if (data.containsKey('状态码') && data['状态码'] == 30001) {
          if (kDebugMode) {
            print('$_tag 检测到登录已过期（状态码30001），直接跳转登录页');
          }
          _navigateToLogin();
          return;
        }
        
        // 创建一个DioException来触发错误处理流程
        final dioError = DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'Token expired in business response',
        );
        
        // 手动调用错误处理
        _handleTokenExpiredResponse(dioError, handler);
        return;
      }
    }
    
    // 正常响应处理
    handler.next(response);
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
      
      // 外层token过期 (401错误码)
      if (data.containsKey('error_code') && data['error_code'] == 401) {
        if (kDebugMode) {
          print('$_tag 检测到外层token失效: ${data['error_message']}');
        }
        return true;
      }
      
      // 应用内token失效检测 - 直接在外层响应中检查
      if (data.containsKey('is_success') && 
          data['is_success'] == false &&
          data.containsKey('error_message') &&
          data['error_message'].toString().contains('Token已失效')) {
        if (kDebugMode) {
          print('$_tag 检测到应用内token失效: ${data['error_message']}');
        }
        return true;
      }
      
      // 内层token过期 - 解析result_string中的状态码
      if (data.containsKey('is_success') && 
          data.containsKey('result_string') && 
          data['result_string'] is String) {
        try {
          Map<String, dynamic> resultData = jsonDecode(data['result_string']);
          if (resultData.containsKey('状态码') && resultData['状态码'] == 30001) {
            if (kDebugMode) {
              print('$_tag 检测到内层token失效，状态码: ${resultData['状态码']}');
            }
            return true;
          }
        } catch (e) {
          // 解析错误，不处理
        }
      }
      
      // 直接检测外层状态码30001（登录已过期）
      if (data.containsKey('状态码') && data['状态码'] == 30001) {
        if (kDebugMode) {
          print('$_tag 检测到登录已过期，状态码: ${data['状态码']}，消息: ${data['返回消息']}');
        }
        return true;
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
    // 重置刷新状态
    _isRefreshing = false;
    // 清除待处理的请求队列
    _pendingRequests.clear();
    // 清除登录数据
    FYSharedPreferenceUtils.clearLoginData();
    
    // 延迟跳转，避免在拦截器中直接调用Get.offAllNamed可能导致的问题
    Future.delayed(const Duration(milliseconds: 100), () {
      Get.offAllNamed(Routers.login);
    });
  }
  
  /// 处理token失效响应的统一方法
  void _handleTokenExpiredResponse(DioException err, dynamic handler) async {
    if (kDebugMode) {
      print('$_tag Token过期，准备刷新');
    }
    
    // 检查是否是登录已过期（状态码30001）
    if (err.response?.data is Map) {
      final data = err.response?.data as Map;
      
      // 检查外层状态码30001
      if (data.containsKey('状态码') && data['状态码'] == 30001) {
        if (kDebugMode) {
          print('$_tag 检测到登录已过期（状态码30001），直接跳转登录页');
        }
        _pendingRequests.clear();
        _navigateToLogin();
        if (handler is ErrorInterceptorHandler) {
          handler.next(err);
        } else if (handler is ResponseInterceptorHandler) {
          handler.reject(err);
        }
        return;
      }
      
      // 检查内层状态码30001
      if (data.containsKey('is_success') && 
          data.containsKey('result_string') && 
          data['result_string'] is String) {
        try {
          Map<String, dynamic> resultData = jsonDecode(data['result_string']);
          if (resultData.containsKey('状态码') && resultData['状态码'] == 30001) {
            // ToastUtil.showShort('token已过期，请重新登录');
            if (kDebugMode) {
              print('$_tag 检测到内层登录已过期（状态码30001），直接跳转登录页');
            }
            _pendingRequests.clear();
            _navigateToLogin();
            if (handler is ErrorInterceptorHandler) {
              handler.next(err);
            } else if (handler is ResponseInterceptorHandler) {
              handler.reject(err);
            }
            return;
          }
        } catch (e) {
          // 解析错误，继续正常的token刷新流程
        }
      }
    }
    
    // 保存原始请求
    RequestOptions options = err.requestOptions;
    
    // 如果已经在刷新过程中，将请求加入队列
    if (_isRefreshing) {
      if (kDebugMode) {
        print('$_tag 已经在刷新Token，将请求加入队列: ${options.path}');
      }
      _pendingRequests.add(options);
      
      // 等待刷新完成，然后重试请求
      while (_isRefreshing) {
        await Future.delayed(Duration(milliseconds: 100));
      }
      
      // 刷新完成后重试当前请求
      try {
        final response = await _dio.fetch(options);
        if (handler is ErrorInterceptorHandler) {
          handler.resolve(response);
        } else if (handler is ResponseInterceptorHandler) {
          handler.resolve(response);
        }
      } catch (e) {
        if (handler is ErrorInterceptorHandler) {
          handler.next(DioException(
            requestOptions: options,
            message: 'Token refresh retry failed: $e',
            type: DioExceptionType.unknown,
          ));
        } else if (handler is ResponseInterceptorHandler) {
          handler.reject(DioException(
            requestOptions: options,
            message: 'Token refresh retry failed: $e',
            type: DioExceptionType.unknown,
          ));
        }
      }
      return;
    }
    
    _isRefreshing = true;
    
    try {
      // 根据请求路径判断使用哪种刷新方式
      if (options.path == '/send_channel_event') {
        await _handleInnerTokenRefresh(options, handler);
      } else {
        await _handleOuterTokenRefresh(options, handler);
      }
    } catch (e) {
      if (kDebugMode) {
        print('$_tag 刷新Token出错: $e');
      }
      // 处理刷新异常
      _pendingRequests.clear();
      _navigateToLogin();
      if (handler is ErrorInterceptorHandler) {
        handler.next(err);
      } else if (handler is ResponseInterceptorHandler) {
        handler.reject(err);
      }
    } finally {
      _isRefreshing = false;
    }
  }
  
  /// 处理应用内token刷新
  Future<void> _handleInnerTokenRefresh(RequestOptions options, dynamic handler) async {
    if (kDebugMode) {
      print('$_tag 应用内接口token失效，开始刷新流程');
    }
    
    // 先尝试刷新外层token
    bool outerRefreshed = await _refreshOuterToken(options);
    
    if (!outerRefreshed) {
      if (kDebugMode) {
        print('$_tag 外层token刷新失败，需要重新登录');
      }
      _pendingRequests.clear();
      _navigateToLogin();
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
      return;
    }
    
    if (kDebugMode) {
      print('$_tag 应用内重新登录成功，更新请求token');
    }
    
    // 获取新的内层token
    String? innerToken = await FYSharedPreferenceUtils.getInnerAccessToken();
    
    if (innerToken == null || innerToken.isEmpty) {
      if (kDebugMode) {
        print('$_tag 获取新的内层token失败');
      }
      _pendingRequests.clear();
      _navigateToLogin();
      return;
    }
    
    // 处理之前加入队列的请求
    for (RequestOptions request in _pendingRequests) {
      await _updateRequestWithNewToken(request, innerToken);
      try {
        final response = await _dio.fetch(request);
        // 注意：队列中的请求无法直接回调到原始的handler，
        // 因为它们是在不同的上下文中发起的
        if (kDebugMode) {
          print('$_tag 队列请求重试成功: ${request.path}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 队列请求重试失败: ${request.path}, 错误: $e');
        }
      }
    }
    _pendingRequests.clear();
    
    // 更新当前请求参数中的token
    await _updateRequestWithNewToken(options, innerToken);
    
    // 重试当前请求
    try {
      final response = await _dio.fetch(options);
      if (handler is ErrorInterceptorHandler) {
        handler.resolve(response);
      } else if (handler is ResponseInterceptorHandler) {
        handler.resolve(response);
      }
    } catch (e) {
      if (kDebugMode) {
        print('$_tag 重试请求失败: $e');
      }
      _navigateToLogin();
    }
  }
  
  /// 处理外层token刷新
  Future<void> _handleOuterTokenRefresh(RequestOptions options, dynamic handler) async {
    bool refreshed = await _refreshOuterToken(options);
    
    if (refreshed) {
      // 处理之前加入队列的请求
      for (RequestOptions request in _pendingRequests) {
        try {
          final response = await _dio.fetch(request);
          if (kDebugMode) {
            print('$_tag 队列请求重试成功: ${request.path}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('$_tag 队列请求重试失败: ${request.path}, 错误: $e');
          }
        }
      }
      _pendingRequests.clear();
      
      // 重试当前请求
      try {
        final response = await _dio.fetch(options);
        if (handler is ErrorInterceptorHandler) {
          handler.resolve(response);
        } else if (handler is ResponseInterceptorHandler) {
          handler.resolve(response);
        }
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 重试外层请求失败: $e');
        }
        _navigateToLogin();
      }
    } else {
      // 刷新失败，需要重新登录
      _pendingRequests.clear();
      _navigateToLogin();
    }
  }
  
  /// 更新请求中的内层token
  Future<void> _updateRequestWithNewToken(RequestOptions request, String innerToken) async {
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
          
          if (kDebugMode) {
            print('$_tag 已更新请求的内层token');
          }
        } catch (e) {
          if (kDebugMode) {
            print('$_tag 更新请求参数中的token失败: $e');
          }
        }
      }
    }
  }
} 