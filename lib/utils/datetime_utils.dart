import 'package:flutter/foundation.dart';

/// 统一的时间格式化工具类
/// 用于解决时间显示中的ISO 8601格式问题（去除T分隔符）
class DateTimeUtils {
  
  /// 格式化更新时间显示
  /// 将 "2025-07-26T14:13:55" 格式化为友好的显示格式
  static String formatUpdateTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return '暂无更新时间';
    }
    
    try {
      // 处理 ISO 8601 格式的时间字符串
      DateTime dateTime;
      if (timeString.contains('T')) {
        // 如果包含T分隔符，直接解析
        dateTime = DateTime.parse(timeString);
      } else if (timeString.contains(' ')) {
        // 如果包含空格分隔符，替换为T后解析
        dateTime = DateTime.parse(timeString.replaceAll(' ', 'T'));
      } else {
        // 其他格式，尝试直接解析
        dateTime = DateTime.parse(timeString);
      }
      
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      // 今天
      if (difference.inDays == 0) {
        return '今天 ${_formatTime(dateTime)}';
      }
      // 昨天
      else if (difference.inDays == 1) {
        return '昨天 ${_formatTime(dateTime)}';
      }
      // 一周内
      else if (difference.inDays < 7) {
        return '${difference.inDays}天前';
      }
      // 今年内
      else if (dateTime.year == now.year) {
        return '${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${_formatTime(dateTime)}';
      }
      // 跨年
      else {
        return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${_formatTime(dateTime)}';
      }
    } catch (e) {
      if (kDebugMode) {
        print('时间格式化失败: $timeString, 错误: $e');
      }
      // 格式化失败时，尝试去除T分隔符
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
      // 处理时间字符串
      DateTime dateTime;
      if (timeString.contains('T')) {
        dateTime = DateTime.parse(timeString);
      } else if (timeString.contains(' ')) {
        dateTime = DateTime.parse(timeString.replaceAll(' ', 'T'));
      } else {
        dateTime = DateTime.parse(timeString);
      }
      
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      // 1小时内
      if (difference.inMinutes < 60) {
        if (difference.inMinutes < 1) {
          return '刚刚';
        }
        return '${difference.inMinutes}分钟前';
      }
      // 今天
      else if (difference.inDays == 0) {
        return '今天 ${_formatTime(dateTime)}';
      }
      // 昨天
      else if (difference.inDays == 1) {
        return '昨天 ${_formatTime(dateTime)}';
      }
      // 一周内
      else if (difference.inDays < 7) {
        return '${difference.inDays}天前';
      }
      // 今年内
      else if (dateTime.year == now.year) {
        return '${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
      }
      // 跨年
      else {
        return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      if (kDebugMode) {
        print('发布时间格式化失败: $timeString, 错误: $e');
      }
      // 格式化失败时，尝试去除T分隔符
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
      DateTime dateTime;
      if (timeString.contains('T')) {
        dateTime = DateTime.parse(timeString);
      } else if (timeString.contains(' ')) {
        dateTime = DateTime.parse(timeString.replaceAll(' ', 'T'));
      } else {
        dateTime = DateTime.parse(timeString);
      }
      
      // 详情页显示完整的日期时间
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${_formatTime(dateTime)}';
    } catch (e) {
      if (kDebugMode) {
        print('详情时间格式化失败: $timeString, 错误: $e');
      }
      // 格式化失败时，尝试去除T分隔符
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
      DateTime dateTime;
      if (timeString.contains('T')) {
        dateTime = DateTime.parse(timeString);
      } else if (timeString.contains(' ')) {
        dateTime = DateTime.parse(timeString.replaceAll(' ', 'T'));
      } else {
        dateTime = DateTime.parse(timeString);
      }
      
      // 返回 YYYY-MM-DD HH:mm:ss 格式
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${_formatTime(dateTime)}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      if (kDebugMode) {
        print('简单时间格式化失败: $timeString, 错误: $e');
      }
      // 格式化失败时，仅去除T分隔符
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
      DateTime dateTime;
      if (timeString.contains('T')) {
        dateTime = DateTime.parse(timeString);
      } else if (timeString.contains(' ')) {
        dateTime = DateTime.parse(timeString.replaceAll(' ', 'T'));
      } else {
        dateTime = DateTime.parse(timeString);
      }
      
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 1) {
        return '刚刚';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}分钟前';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}小时前';
      } else if (difference.inDays < 30) {
        return '${difference.inDays}天前';
      } else if (difference.inDays < 365) {
        return '${(difference.inDays / 30).floor()}个月前';
      } else {
        return '${(difference.inDays / 365).floor()}年前';
      }
    } catch (e) {
      if (kDebugMode) {
        print('相对时间格式化失败: $timeString, 错误: $e');
      }
      return timeString.replaceAll('T', ' ');
    }
  }
}