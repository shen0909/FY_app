import 'package:realm/realm.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/chat_models.dart';

class RealmService {
  static final RealmService _instance = RealmService._internal();
  static const String _tag = 'RealmService';
  
  factory RealmService() => _instance;
  RealmService._internal();
  
  Realm? _realm;
  bool _isInitialized = false;
  
  /// 初始化Realm数据库
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final config = Configuration.local([
        ChatHistory.schema,
      ]);
      
      _realm = Realm(config);
      _isInitialized = true;
      
      if (kDebugMode) {
        print('$_tag Realm数据库初始化成功');
      }
    } catch (e) {
      if (kDebugMode) {
        print('$_tag Realm初始化失败: $e');
      }
      rethrow;
    }
  }
  
  /// 确保数据库已初始化
  void _ensureInitialized() {
    if (!_isInitialized || _realm == null) {
      throw Exception('Realm数据库未初始化，请先调用initialize()');
    }
  }
  
  // =================== 聊天历史管理 ===================
  
  /// 保存聊天历史
  Future<ChatHistory> saveChatHistory({
    required String title,
    required List<Map<String, dynamic>> messages,
    String? chatUuid,
    String? modelName,
  }) async {
    _ensureInitialized();
    
    final now = DateTime.now();
    final messagesJson = jsonEncode(messages);
    
    // 生成最后一条消息预览
    String? lastMessage;
    if (messages.isNotEmpty) {
      final lastMsg = messages.last['content']?.toString() ?? '';
      lastMessage = lastMsg.length > 50 ? '${lastMsg.substring(0, 50)}...' : lastMsg;
    }
    
    final chatHistory = ChatHistory(
      now.millisecondsSinceEpoch.toString(),
      title,
      now,
      now,
      messagesJson,
      chatUuid: chatUuid,
      modelName: modelName ?? 'DeepSeek',
      messageCount: messages.length,
      lastMessage: lastMessage,
    );
    
    _realm!.write(() {
      _realm!.add(chatHistory);
    });
    
    if (kDebugMode) {
      print('$_tag 保存聊天历史: $title, ${messages.length}条消息');
    }
    
    return chatHistory;
  }
  
  /// 更新聊天历史
  Future<void> updateChatHistory({
    required String id,
    required List<Map<String, dynamic>> messages,
    String? title,
  }) async {
    _ensureInitialized();
    
    final chatHistory = _realm!.find<ChatHistory>(id);
    if (chatHistory == null) return;
    
    final messagesJson = jsonEncode(messages);
    
    // 生成最后一条消息预览
    String? lastMessage;
    if (messages.isNotEmpty) {
      final lastMsg = messages.last['content']?.toString() ?? '';
      lastMessage = lastMsg.length > 50 ? '${lastMsg.substring(0, 50)}...' : lastMsg;
    }
    
    _realm!.write(() {
      if (title != null) chatHistory.title = title;
      chatHistory.messagesJson = messagesJson;
      chatHistory.messageCount = messages.length;
      chatHistory.lastMessage = lastMessage;
      chatHistory.updatedAt = DateTime.now();
    });
    
    if (kDebugMode) {
      print('$_tag 更新聊天历史: ${chatHistory.title}');
    }
  }
  
  /// 获取所有聊天历史（按时间倒序）
  RealmResults<ChatHistory> getAllChatHistory({int? limit}) {
    _ensureInitialized();
    
    var query = _realm!.all<ChatHistory>().query('TRUEPREDICATE SORT(updatedAt DESC)');
    
    return query;
  }
  
  /// 根据ID获取聊天历史
  ChatHistory? getChatHistoryById(String id) {
    _ensureInitialized();
    return _realm!.find<ChatHistory>(id);
  }
  
  /// 获取聊天历史的消息列表
  List<Map<String, dynamic>> getChatMessages(String id) {
    _ensureInitialized();
    
    final chatHistory = _realm!.find<ChatHistory>(id);
    if (chatHistory == null) return [];
    
    try {
      final List<dynamic> messages = jsonDecode(chatHistory.messagesJson);
      return messages.cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) {
        print('$_tag 解析消息JSON失败: $e');
      }
      return [];
    }
  }
  
  /// 根据标题查找聊天历史
  ChatHistory? getChatHistoryByTitle(String title) {
    _ensureInitialized();
    
    final results = _realm!.all<ChatHistory>().query('title == \$0', [title]);
    return results.isNotEmpty ? results.first : null;
  }
  
  /// 删除聊天历史
  Future<bool> deleteChatHistory(String id) async {
    _ensureInitialized();
    
    try {
      final chatHistory = _realm!.find<ChatHistory>(id);
      if (chatHistory == null) return false;
      
      _realm!.write(() {
        _realm!.delete(chatHistory);
      });
      
      if (kDebugMode) {
        print('$_tag 删除聊天历史: $id');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('$_tag 删除聊天历史失败: $e');
      }
      return false;
    }
  }
  
  /// 清空所有聊天历史
  Future<void> clearAllChatHistory() async {
    _ensureInitialized();
    
    _realm!.write(() {
      _realm!.deleteAll<ChatHistory>();
    });
    
    if (kDebugMode) {
      print('$_tag 已清空所有聊天历史');
    }
  }
  
  /// 搜索聊天历史
  RealmResults<ChatHistory> searchChatHistory(String keyword) {
    _ensureInitialized();
    
    return _realm!.all<ChatHistory>().query(
      'title CONTAINS[c] \$0 OR messagesJson CONTAINS[c] \$0 SORT(updatedAt DESC)', 
      [keyword]
    );
  }
  
  /// 获取统计信息
  Map<String, dynamic> getStatistics() {
    _ensureInitialized();
    
    final totalChats = _realm!.all<ChatHistory>().length;
    int totalMessages = 0;
    
    for (var chat in _realm!.all<ChatHistory>()) {
      totalMessages += chat.messageCount;
    }
    
    // 估算存储大小
    final avgChatSize = 1024; // 平均每个对话1KB
    final estimatedSizeKB = (totalChats * avgChatSize / 1024).round();
    
    return {
      'totalChats': totalChats,
      'totalMessages': totalMessages,
      'estimatedSizeKB': estimatedSizeKB,
      'lastUpdateTime': DateTime.now().toIso8601String(),
    };
  }
  
  /// 关闭数据库
  void dispose() {
    _realm?.close();
    _realm = null;
    _isInitialized = false;
  }
} 