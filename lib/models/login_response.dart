class OuterLoginResponse {
  final bool isSuccess;
  final String errorMessage;
  final int errorCode;
  final String accessToken;
  final String refreshToken;
  final UserInfo user;

  OuterLoginResponse({
    required this.isSuccess,
    required this.errorMessage,
    required this.errorCode,
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory OuterLoginResponse.fromJson(Map<String, dynamic> json) {
    return OuterLoginResponse(
      isSuccess: json['is_success'],
      errorMessage: json['error_message'],
      errorCode: json['error_code'],
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      user: UserInfo.fromJson(json['user']),
    );
  }
}

class UserInfo {
  final int id;
  final String uid;
  final int regType;
  final int accType;
  final String createTime;

  UserInfo({
    required this.id,
    required this.uid,
    required this.regType,
    required this.accType,
    required this.createTime,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'],
      uid: json['uid'],
      regType: json['reg_type'],
      accType: json['acc_type'],
      createTime: json['create_time'],
    );
  }
}

class InnerLoginResponse {
  final bool success;
  final int statusCode;
  final String message;
  final Map<String, dynamic>? data;
  final String? recordUuid;
  final int? timestamp;

  InnerLoginResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
    this.recordUuid,
    this.timestamp,
  });

  factory InnerLoginResponse.fromJson(Map<String, dynamic> json) {
    return InnerLoginResponse(
      success: json['执行结果'],
      statusCode: json['状态码'],
      message: json['返回消息'],
      data: json['返回数据'],
      recordUuid: json['记录UUID'],
      timestamp: json['时间戳'],
    );
  }
}

class RefreshTokenResponse {
  final bool isSuccess;
  final String errorMessage;
  final int errorCode;
  final String accessToken;

  RefreshTokenResponse({
    required this.isSuccess,
    required this.errorMessage,
    required this.errorCode,
    required this.accessToken,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      isSuccess: json['is_success'],
      errorMessage: json['error_message'],
      errorCode: json['error_code'],
      accessToken: json['access_token'],
    );
  }
}