import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AiQusState {
  // 对话消息列表
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  
  // 消息输入控制器
  final TextEditingController messageController = TextEditingController();
  
  // 当前会话ID
  String? currentConversationId;
  
  // 聊天历史
  final RxList<Map<String, dynamic>> chatHistory = <Map<String, dynamic>>[].obs;
  
  // 提示词模板
  final RxList<Map<String, dynamic>> promptTemplates = <Map<String, dynamic>>[].obs;
  
  // 是否正在加载
  final RxBool isLoading = false.obs;
  
  // 当前选择的模型
  final RxString selectedModel = "DeepSeek".obs;

  final RxBool isBatchCheck = false.obs;

  AiQusState() {
    ///Initialize variables
    _initDemoData();
  }
  
  // 初始化演示数据
  void _initDemoData() {
    // 添加示例消息
    messages.add({
      'isUser': false,
      'content': 'Hi~ 我是您身边的智能助手，可以为您答疑解惑、精读文档、尽情创作，让科技助你轻松工作，多点生活',
    });
    
    // 添加示例聊天历史
    chatHistory.addAll([
      {'title': '模拟腾讯元宇宙的对话', 'time': '今天 14:30'},
      {'title': '数据合规分析', 'time': '昨天 10:15'},
      {'title': '行业分析报告', 'time': '3天前'},
    ]);
    
    // 添加示例提示词模板
    promptTemplates.add({'title': '哈哈哈', 'content': '哈哈哈'});
  }
}
