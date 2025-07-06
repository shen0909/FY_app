import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/main.dart';
import 'dart:async';

// 导出状态枚举
enum ExportStatus {
  generating,
  success,
  failed,
}

class AiQusState {
  // 对话消息列表
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  
  // 消息输入控制器
  final TextEditingController messageController = TextEditingController();

  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  
  // 消息列表滚动控制器
  final ScrollController scrollController = ScrollController();
  
  // 当前会话ID
  String? currentConversationId;
  
  // 当前服务端会话UUID
  String? currentServerSessionUuid;
  
  // 聊天历史
  final RxList<Map<String, dynamic>> chatHistory = <Map<String, dynamic>>[].obs;
  
  // 提示词模板
  final RxList<Map<String, dynamic>> promptTemplates = <Map<String, dynamic>>[].obs;
  
  // 是否正在加载
  final RxBool isLoading = false.obs;
  
  // 当前选择的模型
  final RxString selectedModel = "Hunyuan".obs;

  final RxBool isBatchCheck = false.obs;
  final RxBool showTemplateForm = false.obs; // 自定义提示词模版弹窗是否关闭

  // 批量选择模式下选中的消息索引
  final RxList<int> selectedMessageIndexes = <int>[].obs;

  // 导出相关状态
  final RxBool isExporting = false.obs;
  final Rx<ExportStatus> exportStatus = ExportStatus.generating.obs;
  final RxMap<String, dynamic> exportInfo = <String, dynamic>{}.obs;

  // 模型选择相关
  final modelOverlayEntry = Rx<OverlayEntry?>(null);
  final modelList = [
    {
      'name': 'Perplexity',
      'description': '境外舆情信息检索融合',
      'isSelected': false.obs,
    },
    {
      'name': 'Deepseek',
      'description': '中文深度思考',
      'isSelected': false.obs,
    },
    {
      'name': 'Hunyuan',
      'description': '大数据分析处理',
      'isSelected': false.obs,
    },
  ].obs;

  // ===== AI对话相关状态 =====
  
  // 当前对话UUID（用于轮询获取回复）
  String? currentChatUuid;
  
  // 对话历史记录（用于上下文）
  final RxList<Map<String, dynamic>> conversationHistory = <Map<String, dynamic>>[].obs;
  
  // 流式回复状态
  final RxBool isStreamingReply = false.obs;
  
  // 当前正在接收的AI回复内容
  final RxString currentAiReply = "".obs;
  
  // 轮询计数器（用于检测超时）
  int pollCount = 0;
  final int maxPollCount = 50; // 最大轮询次数（约10秒）
  
  // 连续空内容计数器（用于等待式轮询）
  int? emptyContentCount;
  
  // 登录状态
  final RxBool isLoggedIn = false.obs;

  // 输入框动态高度相关
  final RxDouble inputBoxHeight = 60.w.obs; // 输入框默认高度
  final GlobalKey inputBoxKey = GlobalKey(); // 用于获取输入框实际高度
  
  // 性能优化相关
  Timer? heightUpdateTimer; // 防抖定时器
  double lastKnownHeight = 60.0; // 缓存上次的高度值
  
  // 预设位置方案（可选）- 极致性能
  final RxInt inputLines = 1.obs; // 当前输入行数
  
  // 是否正在加载历史消息
  final RxBool isLoadingHistory = false.obs;
  
  // 是否正在初始化页面数据
  final RxBool isInitializing = false.obs;
  
  // 预设的按钮位置（基于行数）
  double getButtonBottomByLines(int lines) {
    switch (lines) {
      case 1: return 80.w;
      case 2: return 100.w;
      case 3: return 120.w;
      case 4: return 140.w;
      default: return 140.w;
    }
  }

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
  }
  
  // ===== AI对话相关方法 =====
  
  /// 添加消息到对话历史（用于API调用）
  void addToConversationHistory(String role, String content) {
    conversationHistory.add({
      'role': role, // 'user' 或 'assistant'
      'content': content,
    });
    
    // 限制历史记录长度，避免token过多
    if (conversationHistory.length > 20) {
      conversationHistory.removeRange(0, conversationHistory.length - 20);
    }
  }
  
  /// 清空对话历史
  void clearConversationHistory() {
    conversationHistory.clear();
  }
  
  /// 重置流式回复状态
  void resetStreamingState() {
    currentChatUuid = null;
    isStreamingReply.value = false;
    currentAiReply.value = "";
    pollCount = 0;
    emptyContentCount = null;
  }
}
