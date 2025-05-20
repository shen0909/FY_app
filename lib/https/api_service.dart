import 'package:dio/dio.dart';
import 'package:safe_app/models/base_response.dart';
import 'package:safe_app/utils/shared_prefer.dart';
import '../models/login_data.dart';
import 'http_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal();

  /// 登录接口
  Future<LoginData?> login(
      {required String username, required String password}) async {
    try {
      Response response = await HttpService().post(
        '/api/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        BaseResponse<LoginData> baseResponse = BaseResponse.fromJson(
          response.data,
          (data) => LoginData.fromJson(data),
        );

        if (baseResponse.code == 10010) {
          // 方法1：保存完整的LoginData对象（推荐使用这种方式）
          await SharedPreference.saveLoginData(baseResponse.data);
          
          // 方法2：分别保存各个字段（为了兼容已有代码，暂时保留）
          // TODO: 等系统完全迁移到使用LoginData对象后，可以移除这部分代码
          await SharedPreference.saveToken(baseResponse.data.token);
          await SharedPreference.saveUserInfo(
            userId: baseResponse.data.userid,
            userName: baseResponse.data.username,
            userRole: baseResponse.data.user_role,
          );
          return baseResponse.data;
        }
      }
      return null;
    } catch (e) {
      print('登录失败: $e');
      return null;
    }
  }

  /// 获取地区参数
  Future<dynamic> getRegion() async {
    try {
      Response response = await HttpService().get(
        '/api/sh_news/region_args',
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('获取地区参数失败: $e');
      return null;
    }
  }
}
