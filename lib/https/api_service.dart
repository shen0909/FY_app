import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:safe_app/models/login_response.dart';
import 'package:safe_app/utils/shared_prefer.dart';
import '../models/detail_list_data.dart';
import '../models/risk_company_details.dart';
import '../services/realm_service.dart';
import 'http_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

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
    await HttpService().post(path, data: data,
        options: options,
        isForm: isForm,
        successCallback: (data) {
          response = data;
        },
        errorCallback: (error) {
          response = {'code': 0, 'msg': error.toString()};
        });
    return response;
  }

  Future<dynamic> _prePost(String path,
      {Map<String, dynamic>? data,
        bool isForm = false,
        Options? options}) async {
    dynamic response;
    await HttpService().prePost(path, data: data,
        options: options,
        isForm: isForm,
        successCallback: (data) {
          response = data;
        },
        errorCallback: (error) {
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

  Future<dynamic> _preGet(String path,
      {Map<String, dynamic>? params, Options? options}) async {
    dynamic response;
    await HttpService().preGet(path, params: params, options: options,
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
  Future<dynamic> _sendChannelEvent({required Map<String,
      dynamic> paramData, Options? options, CancelToken? cancelToken}) async {
    dynamic response;
    // 统一接口请求参数
    Map<String, dynamic> requestData = {
      "marker": "",
      "param_string": jsonEncode(paramData),
      "service_category": "zqclient_plate",
      "service_name": "zqclient_channel",
      "target_hall_name": "",
      "timeout_milliseconds": 100000,
      "wait_return": true
    };
    await HttpService().sendChannelEvent(
        requestData, options: options, cancelToken: cancelToken,
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

    dynamic result = await _post(
        ServicePath.outerLogin, data: data, isForm: true);

    if (result != null) {
      try {
        OuterLoginResponse response = OuterLoginResponse.fromJson(result);

        if (response.isSuccess) {
          // 保存外层token
          await FYSharedPreferenceUtils.saveOuterAccessToken(
              response.accessToken);
          await FYSharedPreferenceUtils.saveOuterRefreshToken(
              response.refreshToken);
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
    print('$_tag 开始应用内登录，用户名: $username');

    // 将密码转为base64
    var bytes = utf8.encode(password);
    String passBase64 = base64.encode(bytes);
    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "用户认证_登录",
      "当前请求用户UUID": "",
      "命令具体内容": {
        "username": username,
        "password": passBase64
      }
    };
    dynamic result = await _sendChannelEvent(paramData: paramData);

    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        InnerLoginResponse response = InnerLoginResponse.fromJson(resultData);

        if (response.success && response.statusCode == 10010 &&
            response.data != null) {
          // 保存内层token
          String innerToken = response.data!['access_token'];
          await FYSharedPreferenceUtils.saveInnerAccessToken(innerToken);

          if (kDebugMode) {
            print('$_tag 应用内登录成功，已保存内层token');
          }
        }

        return response;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析应用内登录响应失败: $e');
        }
      }
    } else {
      if (kDebugMode) {
        print('$_tag 应用内登录失败，响应: $result');
      }
    }

    return null;
  }

  /// 两层登录流程 - 按照接口文档的固定参数设计
  Future<dynamic> login({
    required String username,
    required String password,
  }) async {
    if (kDebugMode) {
      print('$_tag 开始执行两层登录流程');
    }

    OuterLoginResponse? outerResponse = await outerLogin(
      username: 'test4',
      password: 'test4',
    );

    if (outerResponse == null || !outerResponse.isSuccess) {
      if (kDebugMode) {
        print('$_tag 外层登录失败: ${outerResponse?.errorMessage}');
      }
      return {
        'code': 0,
        'msg': outerResponse?.errorMessage ?? '外层登录失败',
      };
    }

    if (kDebugMode) {
      print('$_tag 外层登录成功，开始应用内登录');
    }

    // 第二层：应用内登录 - 使用接口文档固定参数
    InnerLoginResponse? innerResponse = await innerLogin(
      username: username,
      password: password,
    );

    if (innerResponse == null || !innerResponse.success ||
        innerResponse.statusCode != 10010) {
      if (kDebugMode) {
        print('$_tag 应用内登录失败: ${innerResponse?.message}');
      }
      return {
        'code': 0,
        'msg': innerResponse?.message ?? '应用内登录失败',
      };
    }

    if (kDebugMode) {
      print('$_tag 两层登录全部成功');
    }

    // 构造统一的登录成功响应
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
          await FYSharedPreferenceUtils.saveOuterAccessToken(
              response.accessToken);
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
    if (kDebugMode) {
      print('$_tag 开始重新登录应用内系统');
    }

    try {
      // 使用接口文档中的固定用户名和密码重新登录
      InnerLoginResponse? response = await innerLogin(
        username: 'user0611', // 接口文档固定参数
        password: 'fNj12CT1TA', // 接口文档固定参数
      );

      if (response != null && response.success &&
          response.statusCode == 10010) {
        if (kDebugMode) {
          print('$_tag 应用内重新登录成功');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('$_tag 应用内重新登录失败: ${response?.message ?? '未知错误'}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('$_tag 应用内重新登录异常: $e');
      }
      return false;
    }
  }


  /// 获取制裁清单
  Future<SanctionListResponse?> getSanctionList({
    int currentPage = 1,
    int pageSize = 1,
    String sanctionType = "",
    String province = "",
    String city = "",
    String zhName = "",
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
        "zh_name": zhName,
        "sanction_type": sanctionType != '全部' ? sanctionType : '',
        "province": province != '全部' ? province : '',
        "city": city != '全部' ? city : ''
      }
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
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

  /// 发送AI对话
  Future<String?> sendAIChat(String content, List<Map<String, dynamic>> history,
      String robotUID) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 发送AI对话失败：内层token为空');
      }
      return null;
    }
    // 内容转Base64
    final contentBase64 = base64Encode(utf8.encode(content));

    // 转换历史对话为新的JSON结构
    List<Map<String, dynamic>> historyJson = history.map((item) {
      String role = item['role'] ??
          (item['isUser'] == true ? 'user' : 'assistant');
      String content = item['content']?.toString() ?? '';
      String contentBase64 = base64Encode(utf8.encode(content));

      return {
        'role': role,
        'content_base64': contentBase64,
      };
    }).toList();

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "流任务-执行机器人流对话",
      "当前请求用户UUID": token,
      "命令具体内容": {
        "对话内容Base64": contentBase64,
        "历史对话json队列": historyJson,
        "对话RobotUID": robotUID
      }
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        if (resultData['执行结果'] == true && resultData['返回数据'] != null) {
          return resultData['返回数据']['对话UUID'];
        }
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析AI对话响应失败: $e');
        }
      }
    }

    return null;
  }

  /// 获取AI对话回复内容
  Future<Map<String, dynamic>?> getAIChatReply(String chatUuid) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 获取AI回复失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "流任务-查询机器人流对话回复内容",
      "当前请求用户UUID": token,
      "命令具体内容": {
        "对话UUID": chatUuid,
        "最多等待毫秒": 200
      }
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        if (resultData['执行结果'] == true && resultData['返回数据'] != null) {
          final returnData = resultData['返回数据'];

          // Base64解码内容
          final contentBase64 = returnData['内容Base64'];
          String? content;
          if (contentBase64 != null && contentBase64.isNotEmpty) {
            try {
              content = utf8.decode(base64Decode(contentBase64));
            } catch (e) {
              if (kDebugMode) {
                print('$_tag Base64解码失败: $e');
              }
            }
          }

          return {
            'content': content,
            'isComplete': returnData['是否完成'] ?? false,
            'isEmpty': contentBase64 == null || contentBase64.isEmpty,
          };
        }
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析AI回复响应失败: $e');
        }
      }
    }

    return null;
  }

  /// 保存聊天记录到Realm数据库
  Future<bool> saveChatHistoryToRealm(String title,
      List<Map<String, dynamic>> messages, String? chatUuid) async {
    try {
      final realmService = RealmService();

      // 创建新的聊天历史记录
      await realmService.saveChatHistory(
        title: title,
        messages: messages,
        chatUuid: chatUuid,
        modelName: 'DeepSeek', // 可以从state中获取当前模型
      );

      print('✅ 聊天记录已保存到Realm数据库');
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('$_tag 保存聊天记录到Realm失败: $e');
      }
      return false;
    }
  }

  /// 从Realm获取聊天记录列表
  Future<List<Map<String, dynamic>>> getChatHistoryFromRealm() async {
    try {
      final realmService = RealmService();
      final chatHistories = realmService.getAllChatHistory();

      final historyList = <Map<String, dynamic>>[];

      for (var history in chatHistories) {
        historyList.add({
          'id': history.id,
          'title': history.title,
          'time': _formatTime(history.updatedAt),
          'createdAt': history.createdAt.toIso8601String(),
          'messageCount': history.messageCount,
          'lastMessage': history.lastMessage ?? '',
          'chatUuid': history.chatUuid,
        });
      }

      return historyList;
    } catch (e) {
      if (kDebugMode) {
        print('$_tag 从Realm获取聊天记录失败: $e');
      }
      return [];
    }
  }

  /// 从Realm获取特定会话的消息
  Future<List<Map<String, dynamic>>?> getChatMessagesFromRealm(
      String sessionId) async {
    try {
      final realmService = RealmService();
      return realmService.getChatMessages(sessionId);
    } catch (e) {
      if (kDebugMode) {
        print('$_tag 从Realm获取消息失败: $e');
      }
      return null;
    }
  }

  /// 删除Realm中的聊天记录
  Future<bool> deleteChatHistoryFromRealm(String sessionId) async {
    try {
      final realmService = RealmService();
      return await realmService.deleteChatHistory(sessionId);
    } catch (e) {
      if (kDebugMode) {
        print('$_tag 从Realm删除聊天记录失败: $e');
      }
      return false;
    }
  }

  /// 清空Realm中的所有聊天记录
  Future<bool> clearAllChatHistoryFromRealm() async {
    try {
      final realmService = RealmService();
      await realmService.clearAllChatHistory();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('$_tag 清空Realm聊天记录失败: $e');
      }
      return false;
    }
  }

  /// 获取Realm统计信息
  Future<Map<String, dynamic>> getRealmStatistics() async {
    try {
      final realmService = RealmService();
      return realmService.getStatistics();
    } catch (e) {
      if (kDebugMode) {
        print('$_tag 获取Realm统计信息失败: $e');
      }
      return {};
    }
  }

  /// 获取地区参数
  Future<dynamic> getRegion() async {
    return await _preGet(ServicePath.getRegion);
  }

  /// 添加地区参数
  Future<dynamic> addRegion({required String region}) async {
    var data = {'region': region};
    return await _post(ServicePath.getRegion, data: data);
  }

  /// 修改地区参数
  Future<dynamic> updateRegion(
      {required String id, required String region}) async {
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
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 获取新闻列表失败：内层token为空');
      }
      return {'code': 0, 'msg': '内层token为空'};
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "舆情热点_新闻_分页获取列表",
      "当前请求用户UUID": token,
      "服务类型": 0,
      "命令具体内容": {
        "current_page": currentPage,
        "page_size": pageSize,
        'news_type': newsType == "全部" ? "" : newsType,
        'region': region == "全部" ? "" : region,
        'date_filter': dateFilter == "全部" ? "" : dateFilter,
        'start_date': startDate,
        'end_date': endDate,
        'search': search,
      }
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);

    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);

        List<dynamic> newsData = resultData["返回数据"]['list'] ?? [];
        List<Map<String, dynamic>> transformedData = newsData.map((item) {
          return {
            'news_id': item['uuid'] ?? '',
            'news_title': item['title'] ?? '',
            'news_type': item['types'] ?? '舆情热点', // 新接口没有分类，使用固定值
            'news_medium': item['news_medium'] ?? '',
            'publish_time': item['publish_time'] ?? '',
            'news_summary': item['summary'] ?? '',
          };
        }).toList();

        return {
          'code': 10010,
          'data': transformedData,
          'all_count': resultData['all_count'] ?? 0,
        };
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析新闻列表响应失败: $e');
        }
        return {'code': 0, 'msg': '解析响应失败: $e'};
      }
    } else {
      if (kDebugMode) {
        print('$_tag 获取新闻列表失败: ${result?['error_message'] ??
            '未知错误'}');
      }
      return {'code': 0, 'msg': result?['error_message'] ?? '获取数据失败'};
    }
  }

  /// 获取新闻详情
  Future<dynamic> getNewsDetail({required String newsId}) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 获取新闻详情失败：内层token为空');
      }
      return {'code': 0, 'msg': '内层token为空'};
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "舆情热点_新闻_获取新闻详细",
      "当前请求用户UUID": token,
      "服务类型": 0,
      "命令具体内容": {
        "uuid": newsId,
      }
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);

    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        Map<String, dynamic> resultString = jsonDecode(result['result_string']);
        Map<String, dynamic> resultData = resultString["返回数据"] ?? [];

        Map<String, dynamic> transformedData = {
          'news_id': resultData['news_id'] ?? newsId,
          'news_title': resultData['news_title'] ?? '',
          'news_type': resultData['news_type'] ?? '舆情热点',
          'news_medium': resultData['news_medium'] ?? '',
          'google_keyword': resultData['google_keyword'] ?? '',
          'publish_time': resultData['publish_time'] ?? '',
          'news_summary': resultData['news_summary'] ?? '',
          'region': resultData['region'] ?? '',
          'risk_analysis': resultData['risk_analysis'] ?? '',
          'news_source_url': resultData['news_source_url'] ?? '',
          'origin_context': resultData['origin_context'] ?? '',
          'translated_context': resultData['translated_context'] ?? '', // 使用摘要作为译文
          'publish_authors': resultData['publish_authors'] ?? '',
          'future_progression': resultData['future_progression'] ?? '',
          'relevant_news': resultData['relevant_news'] ?? '',
          'decision_suggestion': resultData['decision_suggestion'] ?? '',
          'effect': resultData['effect'] ?? '',
          'risk_measure': resultData['risk_measure'] ?? '',
        };

        return {
          'code': 10010,
          'data': transformedData,
        };
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析新闻详情响应失败: $e');
        }
        return {'code': 0, 'msg': '解析响应失败: $e'};
      }
    } else {
      if (kDebugMode) {
        print('$_tag 获取新闻详情失败: ${result?['error_message'] ??
            '未知错误'}');
      }
      return {'code': 0, 'msg': result?['error_message'] ?? '获取数据失败'};
    }
  }

  /// 导出新闻报告
  Future<Response?> getNewsReport({required String newsId}) async {
    try {
      Options options = Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
        receiveTimeout: const Duration(minutes: 2),
      );
      return await HttpService().preDio.get(
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
      final String jsonString = await rootBundle.loadString(
          'assets/company-details/$companyId-detail.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // 转换为RiskCompanyDetail对象
      return RiskCompanyDetail.fromJson(jsonData);
    } catch (e) {
      print('加载公司详情失败: $e');
      return null;
    }
  }

  /// 格式化时间显示
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '今天 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute
          .toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return '昨天 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute
          .toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.month}月${dateTime.day}日';
    }
  }

  /// 检查App版本更新
  Future<Map<String, dynamic>?> checkAppVersion() async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 检查版本更新失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "app热更新_检查版本",
      "当前请求用户UUID": token,
      "命令具体内容": {}
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        if (resultData['执行结果'] == true && resultData['返回数据'] != null) {
          return resultData['返回数据'];
        }
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析版本更新响应失败: $e');
        }
      }
    }

    return null;
  }

  // ===== 提示词模板管理 API =====
  /// 新增提示词模板
  Future<Map<String, dynamic>?> addPromptTemplate({
    required String promptName,
    required String promptContent,
    bool isDefault = false,
  }) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 新增提示词模板失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "ai聊天提示词模板_新增模板",
      "当前请求用户UUID": token,
      "命令具体内容": {
        "prompt_name": promptName,
        "prompt_content": promptContent,
        "is_default": isDefault ? 1 : 0
      }
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析新增提示词模板响应失败: $e');
        }
      }
    }

    return null;
  }

  /// 获取提示词模板列表
  Future<Map<String, dynamic>?> getPromptTemplateList({
    int currentPage = 1,
    int pageSize = 10,
  }) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 获取提示词模板列表失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "ai聊天提示词模板_获取模板列表",
      "当前请求用户UUID": token,
      "命令具体内容": {
        "current_page": currentPage,
        "page_size": pageSize
      }
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析获取提示词模板列表响应失败: $e');
        }
      }
    }

    return null;
  }

  /// 修改提示词模板
  Future<Map<String, dynamic>?> updatePromptTemplate({
    required String promptUuid,
    required String promptName,
    required String promptContent,
    bool isDefault = false,
  }) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 修改提示词模板失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "ai聊天提示词模板_修改模板",
      "当前请求用户UUID": token,
      "命令具体内容": {
        "prompt_uuid": promptUuid,
        "prompt_name": promptName,
        "prompt_content": promptContent,
        "is_default": isDefault ? 1 : 0
      }
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析修改提示词模板响应失败: $e');
        }
      }
    }

    return null;
  }

  /// 删除提示词模板
  Future<Map<String, dynamic>?> deletePromptTemplate(String promptUuid) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 删除提示词模板失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "ai聊天提示词模板_删除模板",
      "当前请求用户UUID": token,
      "命令具体内容": {
        "prompt_uuid": promptUuid
      }
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析删除提示词模板响应失败: $e');
        }
      }
    }

    return null;
  }

  /// 批量删除提示词模板
  Future<Map<String, dynamic>?> batchDeletePromptTemplates(
      List<String> promptUuids) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 批量删除提示词模板失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "ai聊天提示词模板_批量删除模板",
      "当前请求用户UUID": token,
      "命令具体内容": {
        "prompt_uuids": promptUuids
      }
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析批量删除提示词模板响应失败: $e');
        }
      }
    }

    return null;
  }

  // ===== 聊天会话管理 API =====

  /// 新建聊天会话
  Future<Map<String, dynamic>?> createChatSession({
    required String sessionName,
  }) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 新建聊天会话失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "ai聊天会话_新建会话",
      "当前请求用户UUID": token,
      "命令具体内容": {
        "session_name": sessionName
      }
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析新建聊天会话响应失败: $e');
        }
      }
    }

    return null;
  }

  /// 获取聊天会话列表
  Future<Map<String, dynamic>?> getChatSessionList({
    int currentPage = 1,
    int pageSize = 10,
  }) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 获取聊天会话列表失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "ai聊天会话_获取会话列表",
      "当前请求用户UUID": token,
      "命令具体内容": {
        "current_page": currentPage,
        "page_size": pageSize
      }
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析获取聊天会话列表响应失败: $e');
        }
      }
    }

    return null;
  }

  /// 修改聊天会话
  Future<Map<String, dynamic>?> updateChatSession({
    required String sessionUuid,
    required String sessionName,
  }) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 修改聊天会话失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "ai聊天会话_修改会话",
      "当前请求用户UUID": token,
      "命令具体内容": {
        "session_uuid": sessionUuid,
        "session_name": sessionName
      }
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析修改聊天会话响应失败: $e');
        }
      }
    }

    return null;
  }

  /// 删除聊天会话
  Future<Map<String, dynamic>?> deleteChatSession(String sessionUuid) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 删除聊天会话失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "ai聊天会话_删除会话",
      "当前请求用户UUID": token,
      "命令具体内容": {
        "session_uuid": sessionUuid
      }
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析删除聊天会话响应失败: $e');
        }
      }
    }

    return null;
  }

  /// 批量删除聊天会话
  Future<Map<String, dynamic>?> batchDeleteChatSessions(
      List<String> sessionUuids) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 批量删除聊天会话失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "ai聊天会话_批量删除会话",
      "当前请求用户UUID": token,
      "命令具体内容": {
        "session_uuids": sessionUuids
      }
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析批量删除聊天会话响应失败: $e');
        }
      }
    }

    return null;
  }

  // ===== 聊天记录管理 API =====

  /// 新增聊天记录
  Future<Map<String, dynamic>?> addChatRecord({
    required String sessionUuid,
    required String role,
    required String content,
    String factoryName = "OpenAI",
    String model = "ChatGPT4",
    int tokenCount = 0,
  }) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 新增聊天记录失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "ai聊天记录_新增记录",
      "当前请求用户UUID": token,
      "命令具体内容": {
        "session_uuid": sessionUuid,
        "role": role,
        "content": content,
        "factory_name": factoryName,
        "model": model,
        "token_count": tokenCount
      }
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析新增聊天记录响应失败: $e');
        }
      }
    }

    return null;
  }

  /// 获取聊天记录
  Future<Map<String, dynamic>?> getChatRecords(String sessionUuid) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 获取聊天记录失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "ai聊天记录_获取记录",
      "当前请求用户UUID": token,
      "命令具体内容": {
        "session_uuid": sessionUuid
      }
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析获取聊天记录响应失败: $e');
        }
      }
    }

    return null;
  }

  /// 下载更新文件块
  Future<Map<String, dynamic>?> downloadUpdateFile(String fileUuid,
      int fileIndex, {CancelToken? cancelToken}) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 下载更新文件失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "app热更新_下载文件",
      "当前请求用户UUID": token,
      "命令具体内容": {
        "file_uuid": fileUuid,
        "file_index": fileIndex
      }
    };

    dynamic result = await _sendChannelEvent(
        paramData: paramData, cancelToken: cancelToken);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        if (resultData['执行结果'] == true && resultData['返回数据'] != null) {
          return resultData['返回数据'];
        }
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析下载文件响应失败: $e');
        }
      }
    }

    return null;
  }

  /// Token保活ping接口 - 每分钟调用一次以刷新token时效
  Future<bool> pingTokenKeepAlive() async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag Token保活失败：内层token为空');
      }
      return false;
    }
    Map<String, dynamic> paramData = {
      "消息类型": "ping",
      "当前请求用户UUID": token,
      "命令具体内容": {}
    };
    try {
      dynamic result = await _sendChannelEvent(paramData: paramData);
      if (result != null && result['is_success'] == true) {
        if (kDebugMode) {
          print('$_tag Token保活ping成功');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('$_tag Token保活ping失败: $result');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('$_tag Token保活ping异常: $e');
      }
      return false;
    }
  }

  // ===== 专题订阅管理 API =====

  /// 新增专题订阅
  Future<Map<String, dynamic>?> toggleTopicSubscription({
    required String subjectUuid,
    required bool isFollow
  }) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 新增专题订阅失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "舆情热点_专题_修改专题订阅状态",
      "当前请求用户UUID": token,
      "命令具体内容": {
        "subject_uuid": subjectUuid,
        "is_follow": isFollow,
      }
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析新增专题订阅响应失败: $e');
        }
      }
    }

    return null;
  }

  /// 获取专题订阅列表
  Future<Map<String, dynamic>?> getTopicSubscriptionList() async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 获取专题订阅列表失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "舆情热点_专题_获取专题列表",
      "当前请求用户UUID": token,
      "命令具体内容": {}
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析获取专题订阅列表响应失败: $e');
        }
      }
    }

    return null;
  }

  // ===== 事件订阅管理 API =====

  /// 新增事件订阅
  Future<Map<String, dynamic>?> toggleEventSubscription({
    required String subjectUuid,
    required bool isFollow
  }) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 新增专题订阅失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "舆情热点_事件_修改事件订阅状态",
      "当前请求用户UUID": token,
      "命令具体内容": {
        "event_uuid": subjectUuid,
        "is_follow": isFollow,
      }
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析新增专题订阅响应失败: $e');
        }
      }
    }

    return null;
  }

  /// 获取专题订阅内容
  Future<Map<String, dynamic>?> getTopicSubscriptionContent({
    required String topicUuid,
    int currentPage = 1,
    int pageSize = 10,
    String? startDate,
    String? endDate,
  }) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 获取专题订阅内容失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "专题订阅_获取订阅内容",
      "当前请求用户UUID": token,
      "命令具体内容": {
        "topic_uuid": topicUuid,
        "current_page": currentPage,
        "page_size": pageSize,
        "start_date": startDate ?? "",
        "end_date": endDate ?? ""
      }
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析获取专题订阅内容响应失败: $e');
        }
      }
    }

    return null;
  }

  /// 获取事件订阅内容
  Future<Map<String, dynamic>?> getEventSubscriptionContent({
    required String eventUuid,
    int currentPage = 1,
    int pageSize = 10,
    String? startDate,
    String? endDate,
  }) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 获取事件订阅内容失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "事件订阅_获取订阅内容",
      "当前请求用户UUID": token,
      "命令具体内容": {
        "event_uuid": eventUuid,
        "current_page": currentPage,
        "page_size": pageSize,
        "start_date": startDate ?? "",
        "end_date": endDate ?? ""
      }
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析获取事件订阅内容响应失败: $e');
        }
      }
    }

    return null;
  }

  /// 获取订阅的专题uuid
  Future<Map<String, dynamic>?> getSubscriptionTopic() async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 获取我的订阅汇总失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "舆情热点_专题_获取关注专题UUID",
      "当前请求用户UUID": token,
      "命令具体内容": {}
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析获取订阅汇总响应失败: $e');
        }
      }
    }
    return null;
  }

  /// 获取订阅的事件uuid
  Future<Map<String, dynamic>?> getSubscriptionEvent() async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 获取我的订阅汇总失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "舆情热点_事件_获取关注事件UUID",
      "当前请求用户UUID": token,
      "命令具体内容": {}
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析获取订阅汇总响应失败: $e');
        }
      }
    }
    return null;
  }

  /// 获取我的订阅汇总
  Future<Map<String, dynamic>?> getMySubscriptionSummary() async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 获取我的订阅汇总失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "舆情热点_专题_获取关注专题列表",
      "当前请求用户UUID": token,
      "命令具体内容": {}
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析获取订阅汇总响应失败: $e');
        }
      }
    }
    return null;
  }

  /// 获取热门事件列表
  Future<Map<String, dynamic>?> getHotEventsList(
      {int currentPage = 1, int pageSize = 10}) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 获取热门事件列表失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "舆情热点_事件_获取事件列表",
      "当前请求用户UUID": token,
      "命令具体内容": {}
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析获取热门事件列表响应失败: $e');
        }
      }
    }

    return null;
  }

  /// 获取事件详情
  Future<Map<String, dynamic>?> getEventDetail({
    required String eventUuid,
  }) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 获取事件详情失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "事件管理_获取事件详情",
      "当前请求用户UUID": token,
      "命令具体内容": {
        "event_uuid": eventUuid
      }
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析获取事件详情响应失败: $e');
        }
      }
    }

    return null;
  }

  /// 获取事件最新动态
  Future<Map<String, dynamic>?> getEventLatestUpdates({
    required String eventUuid,
    int currentPage = 1,
    int pageSize = 1,
  }) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 获取事件最新动态失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "舆情热点_事件_获取相关新闻列表",
      "当前请求用户UUID": token,
      "命令具体内容": {
        "uuid": eventUuid,
        "current_page": currentPage,
        "page_size": pageSize
      }
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析获取事件最新动态响应失败: $e');
        }
      }
    }

    return null;
  }

  /// 获取专题相关新闻
  Future<Map<String, dynamic>?> getTopicLatestUpdates({
    required String eventUuid,
    int currentPage = 1,
    int pageSize = 1,
  }) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 获取事件最新动态失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "舆情热点_专题_获取相关新闻列表",
      "当前请求用户UUID": token,
      "命令具体内容": {
        "uuid": eventUuid,
        "current_page": currentPage,
        "page_size": pageSize
      }
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析获取事件最新动态响应失败: $e');
        }
      }
    }

    return null;
  }

  /// 获取风险预警列表
  Future<Map<String, dynamic>?> getRiskLists({
    int currentPage = 1,
    int page = 50,
    String? zhName,
    String? regionCode,
    int? classification, // 自定义分类
    int? entType, // 自定义企业类型
  }) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 获取事件最新动态失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "预警企业_获取企业列表",
      "当前请求用户UUID": token,
      "命令具体内容": {
        "current_page": currentPage,
        "page_size": 10,
        'zh_name': zhName,
        'region_code': regionCode,
        'custom_classification': classification, // 使用传入的参数而不是硬编码
        'custom_ent_type': entType,
      }
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析获取事件最新动态响应失败: $e');
        }
      }
    }

    return null;
  }

  /// 获取风险预警详情
  Future<Map<String, dynamic>?> getRiskDetails(String uuid) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 获取事件最新动态失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "预警企业_获取企业详细",
      "当前请求用户UUID": token,
      "命令具体内容": {"uuid": uuid}
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析获取事件最新动态响应失败: $e');
        }
      }
    }

    return null;
  }

  /// 获取企业评分详细
  Future<Map<String, dynamic>?> getEnterpriseScoreDetails(String entUuid) async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 获取企业评分详细失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "预警企业_评分_获取企业评分详细",
      "当前请求用户UUID": token,
      "命令具体内容": {"ent_uuid": entUuid}
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true &&
        result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析获取企业评分详细响应失败: $e');
        }
      }
    }

    return null;
  }

  /// 获取轮播图
  Future<Map<String, dynamic>?> getBannerLists() async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 获取事件最新动态失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "轮播图_获取轮播图",
      "当前请求用户UUID": token,
      "命令具体内容": {}
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true && result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析获取事件最新动态响应失败: $e');
        }
      }
    }

    return null;
  }

  /// 获取首页数据（轮播图+风险预警+实体清单）
  Future<Map<String, dynamic>?> getHomePageData() async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 获取首页数据失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "首页_获取首页数据",
      "当前请求用户UUID": token,
      "命令具体内容": {}
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true && result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析获取首页数据响应失败: $e');
        }
      }
    }

    return null;
  }

  /// 获取风险评分等级数量（保留旧接口作为备用）
  Future<Map<String, dynamic>?> getRiskScoreCount() async {
    // 获取内层token
    String? token = await FYSharedPreferenceUtils.getInnerAccessToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        print('$_tag 获取事件最新动态失败：内层token为空');
      }
      return null;
    }

    // 构造请求参数
    Map<String, dynamic> paramData = {
      "消息类型": "预警企业_评分_获取评分等级数量",
      "当前请求用户UUID": token,
      "命令具体内容": {}
    };

    dynamic result = await _sendChannelEvent(paramData: paramData);
    if (result != null && result['is_success'] == true && result['result_string'] != null) {
      try {
        // 解析result_string
        Map<String, dynamic> resultData = jsonDecode(result['result_string']);
        return resultData;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag 解析获取事件最新动态响应失败: $e');
        }
      }
    }

    return null;
  }
}
