
import 'dart:convert';

import 'package:safe_app/models/risk_company_details.dart';
import 'package:safe_app/models/risk_factor_new.dart';

class RiskCompanyNew {

  ///注册地址
  String address;

  ///地区
  String area;

  ///业务领域
  String businessArea;

  ///经营范围
  String businessScope;

  ///城市，忽略这个字段，不要使用这个字段来显示城市名
  String city;

  ///创建时间
  String createdAt;

  ///法定代统一社会信用代码人
  String creditCode;

  ///自定义分类，1-FY一号，2-FY二号，3-星云
  int customClassification;

  ///自定义企业类型，1-民营重器，2-其他重器
  int customEntType;

  ///数据来源
  String dataSource;

  ///企业英文名
  String enName;

  ///企业描述(介绍)
  String entDescribe;

  ///企业简介
  String entProfile;

  ///企业类型（公司类型）
  String enterpriseType;

  ///成立时间
  String establishmentDate;

  ///曾用名
  String formerName;

  ///所属行业（所处行业）
  String industry;

  ///法定代表人
  String legalRepresentative;

  ///市值
  String marketValue;

  ///组织机构代码
  String organizationCode;

  ///母公司
  String parentEnt;

  ///省份，忽略这个字段，不要使用这个字段来显示省份名
  String province;

  ///区域代码，使用这个来匹配省份和城市
  String regionCode;

  ///注册资本（万元）
  String registeredCapital;

  ///工商注册号
  String registrationNumber;

  ///股价
  String stockPrice;

  ///纳税人识别号
  String taxpayerId;

  ///纳税人资质
  String taxpayerType;

  ///修改时间
  String updatedAt;
  String uuid;

  ///企业中文名
  String zhName;


  List<RiskFactorNew> riskFactors;
  List<LegalBasis> legalBasis = [];
  RiskScore riskScore = RiskScore(totalScore: 100,riskLevel: "高风险");
  List<TimelineEvent> timelineTracking = [];

  RiskCompanyNew({
    required this.address,
    required this.area,
    required this.businessArea,
    required this.businessScope,
    required this.city,
    required this.createdAt,
    required this.creditCode,
    required this.customClassification,
    required this.customEntType,
    required this.dataSource,
    required this.enName,
    required this.entDescribe,
    required this.entProfile,
    required this.enterpriseType,
    required this.establishmentDate,
    required this.formerName,
    required this.industry,
    required this.legalRepresentative,
    required this.marketValue,
    required this.organizationCode,
    required this.parentEnt,
    required this.province,
    required this.regionCode,
    required this.registeredCapital,
    required this.registrationNumber,
    required this.stockPrice,
    required this.taxpayerId,
    required this.taxpayerType,
    required this.updatedAt,
    required this.uuid,
    required this.zhName,
    required this.riskFactors
  });

  factory RiskCompanyNew.fromJson(Map<String, dynamic> json) => RiskCompanyNew(
      address: json["address"],
      area: json["area"],
      businessArea: json["business_area"],
      businessScope: json["business_scope"],
      city: json["city"],
      createdAt: json["created_at"],
      creditCode: json["credit_code"],
      customClassification: json["custom_classification"],
      customEntType: json["custom_ent_type"],
      dataSource: json["data_source"],
      enName: json["en_name"],
      entDescribe: json["ent_describe"],
      entProfile: json["ent_profile"],
      enterpriseType: json["enterprise_type"],
      establishmentDate: json["establishment_date"],
      formerName: json["former_name"],
      industry: json["industry"],
      legalRepresentative: json["legal_representative"],
      marketValue: json["market_value"],
      organizationCode: json["organization_code"],
      parentEnt: json["parent_ent"],
      province: json["province"],
      regionCode: json["region_code"],
      registeredCapital: json["registered_capital"],
      registrationNumber: json["registration_number"],
      stockPrice: json["stock_price"],
      taxpayerId: json["taxpayer_id"],
      taxpayerType: json["taxpayer_type"],
      updatedAt: json["updated_at"],
      uuid: json["uuid"],
      zhName: json["zh_name"],
      riskFactors: RiskFactorParser.parseRiskFactor(json['risk_factor']))
    ..legalBasis = _parsePrecedentToLegalBasis(json['precedent']);

  /// 解析接口新增字段 precedent 为 UI 可用的 LegalBasis 列表
  static List<LegalBasis> _parsePrecedentToLegalBasis(dynamic precedentRaw) {
    final List<LegalBasis> result = [];
    if (precedentRaw == null) return result;

    try {
      dynamic decoded;
      if (precedentRaw is String) {
        final trimmed = precedentRaw.trim();
        if (trimmed.isEmpty) return result; // ""
        decoded = jsonDecode(trimmed); // 可能是 "[]" 或 "[ {...} ]"
      } else {
        decoded = precedentRaw; // 容错：后端若直接返回数组
      }
      if (decoded is List) {
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final String title = (item['precedent_name'] ?? '').toString();
            final List<dynamic> items = (item['precedent_item'] is List)
                ? (item['precedent_item'] as List)
                : const [];

            // 将子项拼接为一段 summary 文本
            final List<String> parts = [];
            for (final sub in items) {
              if (sub is Map<String, dynamic>) {
                final name = (sub['precedent_item_name'] ?? '').toString();
                final content = (sub['precedent_item_content'] ?? '').toString();
                if (name.isNotEmpty || content.isNotEmpty) {
                  parts.add(name.isNotEmpty ? '$name：$content' : content);
                }
              }
            }
            final String summary = parts.isNotEmpty ? parts.join('；') : title;

            result.add(LegalBasis(
              category: 'precedent',
              title: title.isNotEmpty ? title : null,
              summary: summary.isNotEmpty ? summary : '',
              details: null,
            ));
          }
        }
      }
    } catch (_) {
      // 忽略解析异常，保持空列表以避免 UI 崩溃
      return result;
    }

    return result;
  }

  Map<String, dynamic> toJson() => {
    "address": address,
    "area": area,
    "business_area": businessArea,
    "business_scope": businessScope,
    "city": city,
    "created_at": createdAt,
    "credit_code": creditCode,
    "custom_classification": customClassification,
    "custom_ent_type": customEntType,
    "data_source": dataSource,
    "en_name": enName,
    "ent_describe": entDescribe,
    "ent_profile": entProfile,
    "enterprise_type": enterpriseType,
    "establishment_date": establishmentDate,
    "former_name": formerName,
    "industry": industry,
    "legal_representative": legalRepresentative,
    "market_value": marketValue,
    "organization_code": organizationCode,
    "parent_ent": parentEnt,
    "province": province,
    "region_code": regionCode,
    "registered_capital": registeredCapital,
    "registration_number": registrationNumber,
    "stock_price": stockPrice,
    "taxpayer_id": taxpayerId,
    "taxpayer_type": taxpayerType,
    "updated_at": updatedAt,
    "uuid": uuid,
    "zh_name": zhName,
    'risk_factor': riskFactors.map((factor) => factor.toJson()).toList()
  };
}