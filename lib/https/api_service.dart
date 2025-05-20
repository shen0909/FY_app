import 'package:dio/dio.dart';
import 'package:safe_app/utils/shared_prefer.dart';
import '../models/login_data.dart';
import 'http_service.dart';
import 'package:flutter/foundation.dart';

/// API服务路径
class ServicePath {
  static const String login = '/api/login';
  static const String logout = '/api/logout';
  static const String refreshToken = '/api/refreshToken';
  static const String getRegion = '/api/sh_news/region_args';
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  static const String _tag = 'ApiService';

  factory ApiService() => _instance;

  ApiService._internal();

  /// 底层POST封装，统一处理请求和错误
  Future<dynamic> _post(String path,
      {Map<String, dynamic>? data,
      bool isForm = false,
      Options? options}) async {
    dynamic response;
    await HttpService().post(path, data: data, options: options, isForm: isForm,
        successCallback: (data) {
      response = data;
    }, errorCallback: (error) {
      response = {'code': 0, 'msg': error.toString()};
    });
    return response;
  }

  /// 底层GET封装，统一处理请求和错误
  Future<dynamic> _get(String path,
      {Map<String, dynamic>? params, Options? options}) async {
    dynamic response;
    await HttpService().get(path, params: params, options: options,
        successCallback: (data) {
      response = data;
    }, errorCallback: (error) {
      response = {'code': 0, 'msg': error.toString()};
    });
    return response;
  }

  /// 底层DELETE封装，统一处理请求和错误
  Future<dynamic> _delete(String path,
      {Map<String, dynamic>? params, Options? options}) async {
    dynamic response;
    await HttpService().delete(path, params: params, options: options,
        successCallback: (data) {
      response = data;
    }, errorCallback: (error) {
      response = {'code': 0, 'msg': error.toString()};
    });
    return response;
  }

  /// 登录接口
  Future<dynamic> login(
      {required String username, required String password}) async {
    var data = {
      'username': username,
      'password': password,
    };

    dynamic result = await _post(ServicePath.login, data: data, isForm: true);

    if (result['code'] == 10010 && result['data'] != null) {
      // 保存登录数据
      LoginData loginData = LoginData.fromJson(result['data']);
      await SharedPreference.saveLoginData(loginData);
      await SharedPreference.saveToken(loginData.token);
      await SharedPreference.saveUserInfo(
          userId: loginData.userid,
          userName: loginData.username,
          userRole: loginData.user_role);
    } else if (kDebugMode) {
      print('$_tag 登录失败，业务错误码: ${result['code']}, ${result['msg']}');
    }
    return result;
  }

  /// 获取地区参数
  Future<dynamic> getRegion() async {
    return await _get(ServicePath.getRegion);
  }

  /// 退出登录
  Future<bool> logout() async {
    dynamic result = await _post(ServicePath.logout);
    if (result['code'] == 10010) {
      await SharedPreference.clearLoginData();
      return true;
    }
    return false;
  }

  /// 刷新令牌
  Future<String?> refreshToken() async {
    // 获取当前token
    String? currentToken = await SharedPreference.getToken();
    if (currentToken == null || currentToken.isEmpty) {
      return null;
    }
    Options options = Options(
      headers: {'Authorization': 'Bearer $currentToken'},
    );

    dynamic result = await _post(ServicePath.refreshToken, options: options);

    if (result['code'] == 10010 && result['data'] != null) {
      String newToken = result['data']['token'];
      // 保存新token
      await SharedPreference.saveToken(newToken);
      return newToken;
    }
    return null;
  }
}
