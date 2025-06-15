import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:safe_app/models/login_response.dart';
import 'package:safe_app/utils/shared_prefer.dart';
import '../models/detail_list_data.dart';
import '../models/risk_company_details.dart';
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
  static const String outerLogin = '/login';
  static const String outerRefreshToken = '/refresh_token';
  static const String sendChannelEvent = '/send_channel_event';
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

  /// 底层应用内统一请求封装
  Future<dynamic> _sendChannelEvent({required Map<String, dynamic> paramData, Options? options}) async {
    dynamic response;
    // 统一接口请求参数
    Map<String, dynamic> requestData = {
      "marker": "",
      "param_string": jsonEncode(paramData),
      "service_category": "comb_business_listen_plate",
      "service_name": "comb_business_listen_channel",
      "target_hall_name": "",
      "timeout_milliseconds": 100000,
      "wait_return": true
    };
    await HttpService().sendChannelEvent(requestData, options: options,
        successCallback: (data) {
      response = data;
    }, errorCallback: (error) {
      response = {'is_success': false, 'error_message': error.toString()};
    });
    return response;
  }

  /// 外层登录接口
  Future<OuterLoginResponse?> outerLogin(
      {required String username, required String password}) async {
    var data = {'uid': username, 'password': password, 'validate_code': '123'};

    dynamic result = await _post(ServicePath.outerLogin, data: data, isForm: true);

    if (result != null) {
      try {
        OuterLoginResponse response = OuterLoginResponse.fromJson(result);

        if (response.isSuccess) {
          // 保存外层token
          await FYSharedPreferenceUtils.saveOuterAccessToken(response.accessToken);
          await FYSharedPreferenceUtils.saveOuterRefreshToken(response.refreshToken);
        }
        return response;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析外层登录响应失败: $e');
        }
      }
    }

    return null;
  }
  
  /// 应用内登录接口
  Future<InnerLoginResponse?> innerLogin({
    required String username,
    required String password,
  }) async {
    String username = 'user0611';
    // 将密码转为base64
    var bytes = utf8.encode('fNj12CT1TA');
    String passBase64 = base64.encode(bytes);
    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "用户操作-登录",
      "当前请求用户UUID": "",
      "命令具体内容": {
        "用户名": username,
        "PassBase64": passBase64
      }
    };
    dynamic result = await _sendChannelEvent(paramData: paramData);
    
    if (result != null && result['is_success'] == true && result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        InnerLoginResponse response = InnerLoginResponse.fromJson(resultData);
        
        if (response.success && response.statusCode == 10010 && response.data != null) {
          // 保存内层token
          String innerToken = response.data!['access_token'];
          await FYSharedPreferenceUtils.saveInnerAccessToken(innerToken);
        }
        
        return response;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析应用内登录响应失败: $e');
        }
      }
    }
    
    return null;
  }
  
  /// 两层登录流程
  Future<dynamic> login({
    required String username,
    required String password,
  }) async {
    // 外层登录
    OuterLoginResponse? outerResponse = await outerLogin(
      username: username,
      password: password,
    );
    if (outerResponse == null || !outerResponse.isSuccess) {
      return {
        'code': 0,
        'msg': outerResponse?.errorMessage ?? '外层登录失败',
      };
    }
    // 应用内登录
    InnerLoginResponse? innerResponse = await innerLogin(username: username, password: password);
    if (innerResponse == null || !innerResponse.success || innerResponse.statusCode != 10010) {
      return {
        'code': 0,
        'msg': innerResponse?.message ?? '应用内登录失败',
      };
    }
    
    // 3. 构造统一的登录成功响应
    return {
      'code': 10010,
      'msg': '登录成功',
      'data': {
        'token': innerResponse.data!['access_token'],
        'userid': username,
        'username': username,
        'province': '',
        'city': '',
        'county_level_city': '',
        'user_role': 1,
        'nickname': username,
      }
    };
  }
  
  /// 刷新外层令牌
  Future<String?> refreshOuterToken() async {
    // 获取当前外层刷新token
    String? refreshToken = await FYSharedPreferenceUtils.getOuterRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }
    
    var data = {'refresh_token': refreshToken};
    
    dynamic result = await _post(ServicePath.outerRefreshToken, data: data);
    
    if (result != null) {
      try {
        RefreshTokenResponse response = RefreshTokenResponse.fromJson(result);
        
        if (response.isSuccess) {
          // 保存新的访问令牌
          await FYSharedPreferenceUtils.saveOuterAccessToken(response.accessToken);
          return response.accessToken;
        }
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析外层刷新令牌响应失败: $e');
        }
      }
    }
    
    return null;
  }
  
  /// 重新登录应用内系统
  Future<bool> reLoginInnerApp() async {
    // 获取用户名
    String? username = await FYSharedPreferenceUtils.getUserName();
    if (username == null || username.isEmpty) {
      return false;
    }
    // 这里假设密码加密已经在之前登录时存储，实际项目中可能需要用户重新输入密码
    // 简化处理，使用固定密码重新登录
    InnerLoginResponse? response = await innerLogin(
      username: username,
      password: 'fNj12CT1TA', // 使用接口文档中的示例密码
    );
    
    return response != null && response.success && response.statusCode == 10010;
  }

  /// 获取制裁清单
  Future<SanctionListResponse?> getSanctionList({
    int currentPage = 1,
    int pageSize = 1,
    String sanctionType = "全部",
    String province = "全部",
    String city = "全部",
    String search = "",
  }) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 获取制裁清单失败：内层token为空');
      }
      return null;
    }
    
    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "实体清单_分页获取列表",
      "当前请求用户UUID": token,
      "命令具体内容": {
        "current_page": currentPage,
        "page_size": pageSize,
        "sanction_type": sanctionType,
        "province": province,
        "city": city,
        "search": search,
      }
    };
    
    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true && result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return SanctionListResponse.fromJson(resultData);
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析制裁清单响应失败: $e');
        }
      }
    }
    
    return null;
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
      await FYSharedPreferenceUtils.clearLoginData();
      return true;
    }
    return false;
  }

  /// 刷新令牌 (兼容旧接口)
  Future<String?> refreshToken() async {
    // 获取当前token
    String? currentToken = await FYSharedPreferenceUtils.getToken();
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
      await FYSharedPreferenceUtils.saveToken(newToken);
      return newToken;
    }
    return null;
  }

  /// 根据公司ID获取公司详情
  Future<RiskCompanyDetail?> getCompanyDetail(String companyId) async {
    try {
      // 加载对应的JSON文件
      final String jsonString = await rootBundle.loadString('assets/company-details/$companyId-detail.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // 转换为RiskCompanyDetail对象
      return RiskCompanyDetail.fromJson(jsonData);
    } catch (e) {
      print('加载公司详情失败: $e');
      return null;
    }
  }
}
