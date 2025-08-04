// To parse this JSON data, do
//
//     final loginLogList = loginLogListFromJson(jsonString);

import 'dart:convert';

LoginLogList loginLogListFromJson(String str) => LoginLogList.fromJson(json.decode(str));

String loginLogListToJson(LoginLogList data) => json.encode(data.toJson());


///日志数量
class LoginLogList {
  int allCount;
  List<ListElement> list;

  LoginLogList({
    required this.allCount,
    required this.list,
  });

  factory LoginLogList.fromJson(Map<String, dynamic> json) => LoginLogList(
    allCount: json["all_count"],
    list: List<ListElement>.from(json["list"].map((x) => ListElement.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "all_count": allCount,
    "list": List<dynamic>.from(list.map((x) => x.toJson())),
  };
}

class ListElement {

  ///登录时间
  String createdAt;

  ///是否登录成功
  bool success;

  ///用户所属区域代码，请忽略
  String userRegion;

  ///用户UUID
  String userUuid;

  ///记录UUID
  String uuid;

  ListElement({
    required this.createdAt,
    required this.success,
    required this.userRegion,
    required this.userUuid,
    required this.uuid,
  });

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
    createdAt: json["created_at"],
    success: json["success"],
    userRegion: json["user_region"],
    userUuid: json["user_uuid"],
    uuid: json["uuid"],
  );

  Map<String, dynamic> toJson() => {
    "created_at": createdAt,
    "success": success,
    "user_region": userRegion,
    "user_uuid": userUuid,
    "uuid": uuid,
  };
}