import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 导出状态枚举
enum ExportStatus {
  generating,
  success,
}

class AiQusState {
  // 对话消息列表
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  
  // 消息输入控制器
  final TextEditingController messageController = TextEditingController();

  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  // 当前会话ID
  String? currentConversationId;
  
  // 聊天历史
  final RxList<Map<String, dynamic>> chatHistory = <Map<String, dynamic>>[].obs;
  
  // 提示词模板
  final RxList<Map<String, dynamic>> promptTemplates = <Map<String, dynamic>>[].obs;
  
  // 是否正在加载
  final RxBool isLoading = false.obs;
  
  // 当前选择的模型
  final RxString selectedModel = "Perplexity +".obs;

  final RxBool isBatchCheck = false.obs;
  
  // 批量选择模式下选中的消息索引
  final RxList<int> selectedMessageIndexes = <int>[].obs;

  // 导出相关状态
  final RxBool isExporting = false.obs;
  final Rx<ExportStatus> exportStatus = ExportStatus.generating.obs;
  final RxMap<String, dynamic> exportInfo = <String, dynamic>{}.obs;

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
    
    // 添加默认提示词模板
    promptTemplates.clear(); // 清空旧数据
    promptTemplates.addAll([
      {
        'title': '贸易战',
        'content': '分析【XX国】【202X年XX月】对华加征关税，对我出口企业贸易的冲击影响和对策建议，并罗列【XX省XX市】哪些企业受影响最为严重。'
      },
      {
        'title': '制裁打压',
        'content': '请分析【XX国】对【XX实体】制裁的原因，对其上下游产业链、海外资金安全等的影响，并提供【XX实体】在应对制裁的对策建议和反制策略。'
      }
    ]);
  }
}
