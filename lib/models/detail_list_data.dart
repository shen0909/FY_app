/// 实体清单数据
class SanctionListResponse {
  final bool success;
  final int statusCode;
  final String message;
  final SanctionListData? data;
  final String? recordUuid;
  final int? timestamp;

  SanctionListResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
    this.recordUuid,
    this.timestamp,
  });

  factory SanctionListResponse.fromJson(Map<String, dynamic> json) {
    return SanctionListResponse(
      success: json['执行结果'],
      statusCode: json['状态码'],
      message: json['返回消息'],
      data: json['返回数据'] != null ? SanctionListData.fromJson(json['返回数据']) : null,
      recordUuid: json['记录UUID'],
      timestamp: json['时间戳'],
    );
  }
}

class SanctionListData {
  final int allCount;
  final int allPage;
  final List<SanctionEntity> entities;

  SanctionListData({
    required this.allCount,
    required this.allPage,
    required this.entities,
  });

  factory SanctionListData.fromJson(Map<String, dynamic> json) {
    List<SanctionEntity> entities = [];
    if (json['data'] != null) {
      json['data'].forEach((v) {
        entities.add(SanctionEntity.fromJson(v));
      });
    }

    return SanctionListData(
      allCount: json['all_count'],
      allPage: json['all_page'],
      entities: entities,
    );
  }
}

class SanctionEntity {
  final String id;
  final String uuid;
  final String zhName;
  final String enName;
  final String province;
  final String city;
  final String sanctionType;
  final String sanctionDate;
  final String removeDate;
  final String createdAt;
  final String updateAt;

  SanctionEntity({
    required this.id,
    required this.uuid,
    required this.zhName,
    required this.enName,
    required this.province,
    required this.city,
    required this.sanctionType,
    required this.sanctionDate,
    required this.removeDate,
    required this.createdAt,
    required this.updateAt,
  });

  factory SanctionEntity.fromJson(Map<String, dynamic> json) {
    return SanctionEntity(
      id: json['id'],
      uuid: json['uuid'],
      zhName: json['zh_name'],
      enName: json['en_name'],
      province: json['province'],
      city: json['city'],
      sanctionType: json['sanction_type'],
      sanctionDate: json['sanction_date'],
      removeDate: json['remove_date'] ?? '',
      createdAt: json['created_at'],
      updateAt: json['update_at'],
    );
  }
}