// To parse this JSON data, do
//
//     final riskyData = riskyDataFromJson(jsonString);

import 'dart:convert';

RiskyDataNew riskyDataFromJson(String str) => RiskyDataNew.fromJson(json.decode(str));

String riskyDataToJson(RiskyDataNew data) => json.encode(data.toJson());

class RiskyDataNew {
  int allCount;
  List<RiskListElement> list;

  RiskyDataNew({
    required this.allCount,
    required this.list,
  });

  factory RiskyDataNew.fromJson(Map<String, dynamic> json) => RiskyDataNew(
    allCount: json["all_count"] ?? 0, // 提供默认值0
    list: List<RiskListElement>.from(json["list"]?.map((x) => RiskListElement.fromJson(x)) ?? []),
  );

  Map<String, dynamic> toJson() => {
    "all_count": allCount,
    "list": List<dynamic>.from(list.map((x) => x.toJson())),
  };
}

class RiskListElement {
  String createdAt;

  ///自定义分类:
  int customClassification;

  ///企业类型
  int customEntType;

  ///企业英文名
  String enName;

  ///企业简介
  String entProfile;

  ///地区代码
  String regionCode;

  ///风险等级，1-低风险，2-中风险，3-高风险
  int riskType;

  String updatedAt;

  ///企业UUID
  String uuid;

  ///企业中文名
  String zhName;

  ///未读新闻数量（后端返回为字符串，这里统一转为int）
  int unreadNewsCount;

  RiskListElement({
    required this.createdAt,
    required this.customClassification,
    required this.customEntType,
    required this.enName,
    required this.entProfile,
    required this.regionCode,
    required this.riskType,
    required this.updatedAt,
    required this.uuid,
    required this.zhName,
    required this.unreadNewsCount,
  });

  factory RiskListElement.fromJson(Map<String, dynamic> json) => RiskListElement(
    createdAt: json["created_at"] ?? "",
    customClassification: json["custom_classification"] ?? 0, // 提供默认值0
    customEntType: json["custom_ent_type"] ?? 0, // 提供默认值0
    enName: json["en_name"] ?? "",
    entProfile: json["ent_profile"] ?? "",
    regionCode: json["region_code"] ?? "",
    riskType: json["risk_type"] ?? 1, // 提供默认值1（低风险）
    updatedAt: json["updated_at"] ?? "",
    uuid: json["uuid"] ?? "",
    zhName: json["zh_name"] ?? "",
    unreadNewsCount: int.tryParse((json["unread_news_count"] ?? '0').toString()) ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "created_at": createdAt,
    "custom_classification": customClassification,
    "custom_ent_type": customEntType,
    "en_name": enName,
    "ent_profile": entProfile,
    "region_code": regionCode,
    "risk_type": riskType,
    "updated_at": updatedAt,
    "uuid": uuid,
    "zh_name": zhName,
    "unread_news_count": unreadNewsCount,
  };
}