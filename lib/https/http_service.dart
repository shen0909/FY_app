import 'package:dio/dio.dart';
import 'package:safe_app/utils/shared_prefer.dart';
import 'package:flutter/foundation.dart';

class HttpService {
  static final HttpService _instance = HttpService._internal();
  static const String _tag = 'FYHttp';
  static const String baseUrl = 'http://180.97.221.196:2032';
  
  factory HttpService() => _instance;
  late Dio dio;

  /// 基础请求头
  static Map<String, dynamic> _baseHeaders() {
    return <String, dynamic>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  HttpService._internal() {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      headers: _baseHeaders(),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
      responseType: ResponseType.json,
    );
    
    dio = Dio(options);
    
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await SharedPreference.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
         
        if (kDebugMode) {
          print('$_tag 请求: ${options.uri}');
          print('$_tag 请求头: ${options.headers}');
          print('$_tag 请求参数: ${options.data}');
        }
         
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('$_tag 响应: ${response.statusCode}');
          print('$_tag 响应数据: ${response.data}');
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (kDebugMode) {
          print('$_tag 错误: ${formatError(e)}');
        }
        return handler.next(e);
      },
    ));
  }

  /// 格式化错误信息
  String formatError(DioException e) {
    return 'uri: ${e.requestOptions.uri}, ${e.toString()}';
  }

  /// 统一错误处理
  static void _handleError(Function? errorCallback, String errorMsg) {
    if (kDebugMode) {
      print('$_tag 错误原因: $errorMsg');
    }
    if (errorCallback != null) {
      errorCallback(errorMsg);
    }
  }

  /// POST请求
  Future post<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    Function? successCallback,
    Function? errorCallback,
    bool isForm = false,
  }) async {
    try {
      Response response;
      if (isForm) {
        // 如果是表单提交
        response = await dio.post(
          path,
          data: data,
          options: options,
          cancelToken: cancelToken,
        );
      } else {
        // 默认是URL参数提交
        response = await dio.post(
          path,
          queryParameters: data ?? queryParameters,
          options: options,
          cancelToken: cancelToken,
        );
      }
      
      if (response.statusCode != 200) {
        _handleError(errorCallback, '网络请求错误,状态码:${response.statusCode}');
        return;
      }

      // 返回结果处理
      if (successCallback != null) {
        if (response.data != null) {
          successCallback(response.data);
        } else {
          _handleError(errorCallback, '$path, 数据请求失败');
        }
      }
    } on DioException catch (e) {
      _handleError(errorCallback, formatError(e));
    }
  }

  /// GET请求
  Future get<T>(
    String path, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    Function? successCallback,
    Function? errorCallback,
  }) async {
    try {
      if (kDebugMode) {
        print('$_tag 发起GET请求: $path');
      }
      
      Response response = await dio.get(
        path,
        queryParameters: params,
        options: options,
        cancelToken: cancelToken,
      );
      
      if (successCallback != null) {
        if (response.data != null) {
          if (kDebugMode) {
            print('$_tag $path, GET请求结果: $response');
          }
          successCallback(response.data);
        } else {
          _handleError(errorCallback, '$path, GET数据请求失败');
        }
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('$_tag GET请求失败: ${formatError(e)}');
      }
      _handleError(errorCallback, formatError(e));
    }
  }

  /// DELETE请求
  Future delete<T>(
    String path, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    Function? successCallback,
    Function? errorCallback,
  }) async {
    try {
      if (kDebugMode) {
        print('$_tag 发起DELETE请求: $path');
      }
      
      Response response = await dio.delete(
        path,
        queryParameters: params,
        options: options,
        cancelToken: cancelToken,
      );
      
      if (successCallback != null) {
        if (response.data != null) {
          if (kDebugMode) {
            print('$_tag $path, DELETE请求结果: $response');
          }
          successCallback(response.data);
        } else {
          _handleError(errorCallback, '$path, DELETE数据请求失败');
        }
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('$_tag DELETE请求失败: ${formatError(e)}');
      }
      _handleError(errorCallback, formatError(e));
    }
  }
  
  /// 取消请求
  void cancelRequests(CancelToken token) {
    token.cancel("请求已取消");
  }
}
