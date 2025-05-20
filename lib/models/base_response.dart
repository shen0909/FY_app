// 响应model
class BaseResponse<T> {
  final int code;
  final String msg;
  final T data;

  BaseResponse({
    required this.code,
    required this.msg,
    required this.data,
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return BaseResponse(
      code: json['code'],
      msg: json['msg'],
      data: fromJsonT(json['data']),
    );
  }
}