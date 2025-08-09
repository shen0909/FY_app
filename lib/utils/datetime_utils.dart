import 'package:flutter/foundation.dart';

/// 统一的时间格式化工具类
/// 用于解决时间显示中的ISO 8601格式问题（去除T分隔符）
class DateTimeUtils {
  /// 统一中文日期时间格式：yyyy年MM月dd日HH时mm分
  static String _formatChinese(DateTime dt) {
    return '${dt.year}年'
        '${dt.month.toString().padLeft(2, '0')}月'
        '${dt.day.toString().padLeft(2, '0')}日'
        '${dt.hour.toString().padLeft(2, '0')}时'
        '${dt.minute.toString().padLeft(2, '0')}分';
  }

  /// 安全解析多种时间字符串
  static DateTime _parseDateTime(String timeString) {
    if (timeString.contains('T')) {
      return DateTime.parse(timeString);
    } else if (timeString.contains(' ')) {
      return DateTime.parse(timeString.replaceAll(' ', 'T'));
    }
    return DateTime.parse(timeString);
  }
  
  /// 格式化更新时间显示
  /// 将 "2025-07-26T14:13:55" 格式化为友好的显示格式
  static String formatUpdateTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return '未知时间';
    }
    
    try {
      final dateTime = _parseDateTime(timeString);
      return _formatChinese(dateTime);
    } catch (e) {
      if (kDebugMode) {
        print('时间格式化失败: $timeString, 错误: $e');
      }
      return timeString.replaceAll('T', ' ');
    }
  }
  
  /// 格式化发布时间显示（用于新闻等）
  /// 更加简洁的显示方式
  static String formatPublishTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return '未知时间';
    }
    
    try {
      final dateTime = _parseDateTime(timeString);
      return _formatChinese(dateTime);
    } catch (e) {
      if (kDebugMode) {
        print('发布时间格式化失败: $timeString, 错误: $e');
      }
      return timeString.replaceAll('T', ' ');
    }
  }
  
  /// 格式化详情页时间显示
  /// 用于详情页面的时间显示，包含完整的日期时间信息
  static String formatDetailTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return '未知时间';
    }
    
    try {
      final dateTime = _parseDateTime(timeString);
      return _formatChinese(dateTime);
    } catch (e) {
      if (kDebugMode) {
        print('详情时间格式化失败: $timeString, 错误: $e');
      }
      return timeString.replaceAll('T', ' ');
    }
  }
  
  /// 简单格式化时间（仅去除T分隔符）
  /// 用于快速修复现有显示
  static String formatSimple(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return '';
    }
    
    try {
      final dateTime = _parseDateTime(timeString);
      return _formatChinese(dateTime);
    } catch (e) {
      if (kDebugMode) {
        print('简单时间格式化失败: $timeString, 错误: $e');
      }
      return timeString.replaceAll('T', ' ');
    }
  }
  
  /// 内部方法：格式化时间为 HH:mm
  static String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  /// 获取相对时间描述
  /// 例如：刚刚、5分钟前、2小时前、3天前等
  static String getRelativeTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return '未知时间';
    }
    
    try {
      final dateTime = _parseDateTime(timeString);
      return _formatChinese(dateTime);
    } catch (e) {
      if (kDebugMode) {
        print('相对时间格式化失败: $timeString, 错误: $e');
      }
      return timeString.replaceAll('T', ' ');
    }
  }
}