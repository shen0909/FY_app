import 'package:safe_app/pages/detail_list/detail_list_state.dart';

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
      success: json['执行结果'] ?? false,
      statusCode: json['状态码'] ?? 0,
      message: json['返回消息'] ?? '',
      data: json['返回数据'] != null ? SanctionListData.fromJson(json['返回数据']) : null,
      recordUuid: json['记录UUID'],
      timestamp: json['时间戳'],
    );
  }
}

class SanctionListData {
  final int allCount;
  final int allPage;
  final int search_all_num;
  final String update_time;
  final List<SanctionEntity> entities;

  SanctionListData({
    required this.allCount,
    required this.allPage,
    required this.search_all_num,
    required this.update_time,
    required this.entities,
  });

  factory SanctionListData.fromJson(Map<String, dynamic> json) {
    List<SanctionEntity> entities = [];
    if (json['list'] != null && json['list'] is List) {
      entities = (json['list'] as List)
          .map((v) => SanctionEntity.fromJson(v as Map<String, dynamic>))
          .toList();
    }

    return SanctionListData(
      allCount: json['all_count'] ?? 0,
      allPage: json['all_page'] ?? 0,
      search_all_num: json['search_all_num'] ?? 0,
      update_time: json['update_time'] ?? "",
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
  final String updatedAt;

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
    required this.updatedAt,
  });

  factory SanctionEntity.fromJson(Map<String, dynamic> json) {
    return SanctionEntity(
      id: json['id']?.toString() ?? '',
      uuid: json['uuid']?.toString() ?? '',
      zhName: json['zh_name']?.toString() ?? '',
      enName: json['en_name']?.toString() ?? '',
      province: json['province']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      sanctionType: json['sanction_type']?.toString() ?? '',
      sanctionDate: json['sanction_date']?.toString() ?? '',
      removeDate: json['remove_date']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  // 获取显示名称（优先中文，无中文则显示英文）
  String get displayName => zhName.isNotEmpty ? zhName : enName;

  // 获取格式化的地区信息
  String get displayRegion {
    if (province.isNotEmpty && city.isNotEmpty && province != city) {
      return '$province $city';
    } else if (province.isNotEmpty) {
      return province;
    } else if (city.isNotEmpty) {
      return city;
    }
    return '';
  }

  // 获取格式化的制裁时间
  String get displaySanctionTime => _formatDateTime(sanctionDate);

  // 获取格式化的移除时间
  String get displayRemoveTime => removeDate.isNotEmpty ? _formatDateTime(removeDate) : '-';

  // 根据制裁类型名称匹配SanctionType对象
  SanctionType getSanctionType(List<SanctionType> sanctionTypes) {
    try {
      // 优先完全匹配
      return sanctionTypes.firstWhere((type) => type.name == sanctionType);
    } catch (e) {
      try {
        // 其次尝试包含匹配
        String extractedCode = _extractSanctionTypeCode(sanctionType);
        return sanctionTypes.firstWhere(
          (type) => type.code == extractedCode ||
                    type.name.contains(extractedCode) ||
                    _normalizeSanctionTypeName(type.name).contains(_normalizeSanctionTypeName(sanctionType)),
        );
      } catch (e2) {
        // 如果找不到匹配的类型，创建一个默认的
        return SanctionType(
          name: sanctionType,
          code: _extractSanctionTypeCode(sanctionType),
          description: sanctionType,
          color: 0xFF1A1A1A,
          bgColor: 0xFFEDEDED,
        );
      }
    }
  }

  // 标准化制裁类型名称，用于模糊匹配
  String _normalizeSanctionTypeName(String name) {
    return name.toLowerCase()
        .replaceAll('（', '(')
        .replaceAll('）', ')')
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('_', '');
  }

  // 提取制裁类型代码的辅助方法
  String _extractSanctionTypeCode(String sanctionTypeName) {
    String normalizedName = _normalizeSanctionTypeName(sanctionTypeName);
    
    if (normalizedName.contains('实体清单') || normalizedName.contains('entitylist') || normalizedName.contains('el')) {
      return 'EL';
    } else if (normalizedName.contains('行业制裁') || normalizedName.contains('ssi')) {
      return 'SSI';
    } else if (normalizedName.contains('军工企业清单') || normalizedName.contains('cmc')) {
      return 'CMC';
    } else if (normalizedName.contains('维吾尔') || normalizedName.contains('uflpa')) {
      return 'UFLPA';
    } else if (normalizedName.contains('未经核实') || normalizedName.contains('uvl')) {
      return 'UVL';
    } else if (normalizedName.contains('被拒绝') || normalizedName.contains('dpl')) {
      return 'DPL';
    } else if (normalizedName.contains('nscmic') || normalizedName.contains('军工复合体')) {
      return 'NS-CMIC';
    } else if (normalizedName.contains('nonsdncmic') || normalizedName.contains('非sdn')) {
      return 'Non-SDN CMIC';
    } else if (normalizedName.contains('meu') || normalizedName.contains('军事最终用户')) {
      return 'MEU';
    } else if (normalizedName.contains('meul') || normalizedName.contains('最终军事用户')) {
      return 'MEUL';
    }
    return 'UNKNOWN';
  }

  // 格式化日期时间的辅助方法
  String _formatDateTime(String dateTimeStr) {
    if (dateTimeStr.isEmpty) return '';
    
    try {
      DateTime dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}';
    } catch (e) {
      // 如果解析失败，尝试其他格式或返回原始字符串
      if (dateTimeStr.length >= 7) {
        return dateTimeStr.substring(0, 7).replaceAll('-', '.');
      }
      return dateTimeStr;
    }
  }
}