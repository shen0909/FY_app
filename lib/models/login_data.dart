class LoginData {
  final String token;
  final String userid;
  final String username;
  final String region; //地区码
  final int user_role;
  final String nickname;
  final String lastLoginAt;

  LoginData({
    required this.token,
    required this.userid,
    required this.username,
    required this.region,
    required this.user_role,
    required this.nickname,
    required this.lastLoginAt,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'],
      userid: json['userid'],
      username: json['username'],
      region: json['region'],
      user_role: json['user_role'],
      nickname: json['nickname'] ?? json['username'],
      lastLoginAt: json['last_login_at'] ?? '',
    );
  }
}
