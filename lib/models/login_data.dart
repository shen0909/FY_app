class LoginData {
  final String token;
  final String userid;
  final String username;
  final String province;
  final String city;
  final String county_level_city;
  final int user_role;
  final String nickname;

  LoginData({
    required this.token,
    required this.userid,
    required this.username,
    required this.province,
    required this.city,
    required this.county_level_city,
    required this.user_role,
    required this.nickname,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'],
      userid: json['userid'],
      username: json['username'],
      province: json['province'],
      city: json['city'],
      county_level_city: json['county_level_city'] ?? '',
      user_role: json['user_role'],
      nickname: json['nickname'] ?? json['username'],
    );
  }
}
