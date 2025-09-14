// To parse this JSON data, do
//
//     final userList = userListFromJson(jsonString);

import 'dart:convert';

UserList userListFromJson(String str) => UserList.fromJson(json.decode(str));

String userListToJson(UserList data) => json.encode(data.toJson());

class UserList {
  int allCount;
  List<UserListElement> list;

  UserList({
    required this.allCount,
    required this.list,
  });

  factory UserList.fromJson(Map<String, dynamic> json) => UserList(
    allCount: json["all_count"],
    list: List<UserListElement>.from(json["list"].map((x) => UserListElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "all_count": allCount,
    "list": List<dynamic>.from(list.map((x) => x.toJson())),
  };
}

class UserListElement {
  String? createdAt;

  ///昵称
  String? nickname;

  ///地区代码
  String region;

  ///角色
  int? role;

  ///用户名
  String? username;

  ///用户UUID
  String? uuid;

  /// 用户状态
  String status = "在线";

  UserListElement({
    this.createdAt,
    this.nickname,
    required this.region,
    this.role,
    this.username,
    this.uuid,
  });

  factory UserListElement.fromJson(Map<String, dynamic> json) => UserListElement(
    createdAt: json["created_at"],
    nickname: json["nickname"],
    region: json["region"],
    role: json["role"],
    username: json["username"],
    uuid: json["uuid"],
  );

  Map<String, dynamic> toJson() => {
    "created_at": createdAt,
    "nickname": nickname,
    "region": region,
    "role": role,
    "username": username,
    "uuid": uuid,
  };
}