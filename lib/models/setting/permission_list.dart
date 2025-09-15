import 'dart:convert';

import 'package:intl/intl.dart';

PermissionList permissionListFromMap(String str) => PermissionList.fromMap(json.decode(str));


class PermissionList {
  int allCount;
  List<PermissionListElement> list;

  PermissionList({
    required this.allCount,
    required this.list,
  });

  factory PermissionList.fromMap(Map<String, dynamic> json) => PermissionList(
    allCount: json["all_count"],
    list: List<PermissionListElement>.from(json["list"].map((x) => PermissionListElement.fromMap(x))),
  );
}

class PermissionListElement {

  ///申请人信息
  Applicant applicant;

  ///被申请信息，被申请对应用户的信息
  ApplicationContent applicationContent;

  ///申请原因
  String applicationReason;

  ///审核人信息
  Auditor? auditor;

  ///创建时间
  String createdAt;

  ///处理时间
  String? processAt;

  ///审核原因
  String? processReason;

  ///申请状态
  int status;

  ///申请类型
  int type;

  ///申请UUID
  String uuid;

  PermissionListElement({
    required this.applicant,
    required this.applicationContent,
    required this.applicationReason,
    required this.auditor,
    required this.createdAt,
    required this.processAt,
    required this.processReason,
    required this.status,
    required this.type,
    required this.uuid,
  });

  factory PermissionListElement.fromMap(Map<String, dynamic> json) => PermissionListElement(
    applicant: Applicant.fromMap(json["applicant"]),
    applicationContent: ApplicationContent.fromMap(json["application_content"]),
    applicationReason: json["application_reason"],
    auditor: json["auditor"] != null ? Auditor.fromMap(json["auditor"]) : null,
    createdAt: formatDate(json["created_at"])!,
    processAt: formatDate(json["process_at"]),
    processReason: json["process_reason"] != null ? json["process_reason"] : null,
    status: json["status"],
    type: json["type"],
    uuid: json["uuid"],
  );
}

String? formatDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return null;
  }
  return DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(dateString));
}

///申请人信息
class Applicant {

  ///忽略此字段
  String createdAt;

  ///申请人昵称
  String nickname;

  ///申请人角色，这里的角色都是管理员
  int role;

  ///申请人用户名
  String username;

  ///申请人UUID
  String uuid;

  Applicant({
    required this.createdAt,
    required this.nickname,
    required this.role,
    required this.username,
    required this.uuid,
  });

  factory Applicant.fromMap(Map<String, dynamic> json) => Applicant(
    createdAt: json["created_at"],
    nickname: json["nickname"],
    role: json["role"],
    username: json["username"],
    uuid: json["uuid"],
  );

  Map<String, dynamic> toMap() => {
    "created_at": createdAt,
    "nickname": nickname,
    "role": role,
    "username": username,
    "uuid": uuid,
  };
}


///被申请信息，被申请对应用户的信息
class ApplicationContent {

  ///忽略此字段
  String createdAt;

  ///被申请用户昵称
  String nickname;

  ///被申请用户角色
  int role;

  ///被申请用户用户名
  String username;

  ///被申请用户UUID，如果申请的是新建用户则忽略此字段
  String uuid;

  ApplicationContent({
    required this.createdAt,
    required this.nickname,
    required this.role,
    required this.username,
    required this.uuid,
  });

  factory ApplicationContent.fromMap(Map<String, dynamic> json) => ApplicationContent(
    createdAt: json["created_at"],
    nickname: json["nickname"],
    role: json["role"],
    username: json["username"],
    uuid: json["uuid"],
  );

  Map<String, dynamic> toMap() => {
    "created_at": createdAt,
    "nickname": nickname,
    "role": role,
    "username": username,
    "uuid": uuid,
  };
}


///审核人信息
class Auditor {

  ///忽略此字段
  String createdAt;

  ///审核人昵称
  String nickname;

  ///审核人角色，这里的角色都是审核员
  int role;

  ///审核人用户名
  String username;

  ///审核人UUID
  String uuid;

  Auditor({
    required this.createdAt,
    required this.nickname,
    required this.role,
    required this.username,
    required this.uuid,
  });

  factory Auditor.fromMap(Map<String, dynamic> json) => Auditor(
    createdAt: json["created_at"],
    nickname: json["nickname"],
    role: json["role"],
    username: json["username"],
    uuid: json["uuid"],
  );

  Map<String, dynamic> toMap() => {
    "created_at": createdAt,
    "nickname": nickname,
    "role": role,
    "username": username,
    "uuid": uuid,
  };
}