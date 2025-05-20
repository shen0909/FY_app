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
  static const String getNewsList = '/api/sh_news/list';
  static const String getNewsDetail = '/api/sh_news/detail_fetch';
  static const String getNewsReport = '/api/sh_news/detail_report';
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

  /// 底层PUT封装，统一处理请求和错误
  Future<dynamic> _put(String path,
      {Map<String, dynamic>? data, Options? options}) async {
    dynamic response;
    await HttpService().put(path, data: data, options: options,
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

  /// 添加地区参数
  Future<dynamic> addRegion({required String region}) async {
    var data = {'region': region};
    return await _post(ServicePath.getRegion, data: data);
  }

  /// 修改地区参数
  Future<dynamic> updateRegion({required String id, required String region}) async {
    var data = {'id': id, 'region': region};
    return await _put(ServicePath.getRegion, data: data);
  }

  /// 删除地区参数
  Future<dynamic> deleteRegion({required String id}) async {
    return await _delete(ServicePath.getRegion, params: {'id': id});
  }

  /// 获取新闻列表
  Future<dynamic> getNewsList({
    required int currentPage,
    required int pageSize,
    required String newsType,
    required String region,
    String? dateFilter,
    String? startDate,
    String? endDate,
    String? search,
  }) async {
    var data = {
      'current_page': currentPage,
      'page_size': pageSize,
      'news_type': newsType,
      'region': region,
    };

    if (dateFilter != null && dateFilter.isNotEmpty) {
      data['date_filter'] = dateFilter;
    }
    if (startDate != null && startDate.isNotEmpty) {
      data['start_date'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      data['end_date'] = endDate;
    }
    if (search != null && search.isNotEmpty) {
      data['search'] = search;
    }

    return await _post(ServicePath.getNewsList, data: data,isForm: true);
  }

  /// 获取新闻详情
  Future<dynamic> getNewsDetail({required String newsId}) async {
    return await _get(ServicePath.getNewsDetail, params: {'news_id': newsId});
  }

  /// 导出新闻报告
  Future<Response?> getNewsReport({required String newsId}) async {
    try {
      Options options = Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
        receiveTimeout: const Duration(minutes: 2),
      );
      return await HttpService().dio.get(
        ServicePath.getNewsReport,
        queryParameters: {'news_id': newsId},
        options: options,
      );
    } catch (e) {
      if (kDebugMode) {
        print('$_tag 导出报告失败: $e');
      }
      return null;
    }
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
