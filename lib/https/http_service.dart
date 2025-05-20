import 'package:dio/dio.dart';
import 'package:safe_app/utils/shared_prefer.dart';

class HttpService {
  static final HttpService _instance = HttpService._internal();

  factory HttpService() => _instance;
  late Dio dio;
  static const String baseUrl = 'http://180.97.221.196:2032';

  HttpService._internal() {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    );
    dio = Dio(options);
    dio.interceptors.add(LogInterceptor(responseBody: true));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await SharedPreference.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        return handler.next(e);
      },
    ));
  }

  Future<Response<T>> post<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.get<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
