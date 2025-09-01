import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/image_resource.dart';
import 'package:safe_app/utils/diolag_utils.dart';
import 'package:safe_app/utils/toast_util.dart';
import 'package:safe_app/widgets/widgets.dart';
import 'package:side_sheet/side_sheet.dart';
import 'dart:async';
import 'ai_qus_state.dart';
import '../../https/api_service.dart';
import '../../services/realm_service.dart';
import '../../services/permission_service.dart';
import 'package:safe_app/utils/dialog_utils.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';

class AiQusLogic extends GetxController {
  final AiQusState state = AiQusState();
  Timer? _pollTimer;
  final RealmService _realmService = RealmService();

  final TextEditingController editTitleController = TextEditingController();
  final TextEditingController editContentController = TextEditingController();

  @override
  void onReady() {
    super.onReady();
    // 设置初始化状态
    state.isInitializing.value = true;
    // 加载数据
    _initializeData();
  }

  // 新增初始化数据的方法
  Future<void> _initializeData() async {
    try {
      // 并行加载会话列表和提示词模板
      await Future.wait([
        loadConversations(),
        loadPromptTemplates(),
      ]);
    } catch (e) {
      print('初始化数据失败: $e');
    } finally {
      state.isInitializing.value = false;
    }
  }

  @override
  void onClose() {
    // 释放资源
    state.messageController.dispose();
    state.titleController.dispose();
    state.contentController.dispose();
    state.scrollController.dispose();
    // 编辑模板控制器释放
    editTitleController.dispose();
    editContentController.dispose();
    // 确保在页面销毁前清理浮层
    _safeHideModelSelection();
    // 清理定时器
    _pollTimer?.cancel();
    super.onClose();
  }

  /// 自动滚动到底部
  void _scrollToBottom({bool animated = true}) {
    if (state.scrollController.hasClients) {
      if (animated) {
        state.scrollController.animateTo(
          state.scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        state.scrollController.jumpTo(
          state.scrollController.position.maxScrollExtent,
        );
      }
    }
  }

  /// 延迟滚动到底部（用于等待UI更新）
  Future<void> _scrollToBottomDelayed(
      {bool animated = true, int delayMs = 100}) async {
    await Future.delayed(Duration(milliseconds: delayMs));
    _scrollToBottom(animated: animated);
  }

  // 发送消息
  Future<void> sendMessage() async {
    final text = state.messageController.text.trim();
    if (text.isEmpty) return;
    // 防止重复发送：如果已有消息正在发送中，则直接返回
    if (state.isSendingMessage.value) {
      print('🚫 消息正在发送中，请等待当前消息处理完毕');
      return;
    }
    // 设置发送状态
    state.isSendingMessage.value = true;

    // 发送时固化当前选择的机器人/模型，写入每条消息，避免中途切换导致来源显示不一致
    final String robotAtSend = state.selectedModel.value;

    // 添加用户消息
    final userMessage = {
      'isUser': true,
      'content': text,
      'timestamp': DateTime.now().toIso8601String(),
      'isSynced': false, // 标记新用户消息需要同步
      'aiSource': robotAtSend, // 记录当次对话的目标机器人，便于追溯
    };
    state.messages.add(userMessage);

    // 滚动到底部显示用户消息
    _scrollToBottomDelayed();

    // 清空输入框
    state.messageController.clear();

    // 立即创建或更新聊天记录到数据库
    await _createOrUpdateChatSession(text);

    // 设置加载状态
    state.isLoading.value = true;
    state.resetStreamingState();

    // 立即添加AI消息占位符，显示loading状态
    final aiMessageIndex = state.messages.length;
    state.messages.add({
      'isUser': false,
      'content': '',
      'isStreaming': true,
      'isLoading': true, // 添加loading标识
      'timestamp': DateTime.now().toIso8601String(),
      'isSynced': false, // 标记新AI消息需要同步
      'aiSource': robotAtSend, // 固化当前机器人来源
    });

    // 滚动到底部显示AI消息占位符
    _scrollToBottomDelayed(delayMs: 150);

    try {
      // 准备历史对话数据（转换为新格式）
      final historyForAPI = _prepareHistoryForAPI();

      // 发送AI对话请求
      final chatUuid = await ApiService()
          .sendAIChat(text, historyForAPI, state.selectedModel.value);

      // 添加到对话历史
      state.addToConversationHistory('user', text);
      if (chatUuid != null) {
        state.currentChatUuid = chatUuid;
        state.isStreamingReply.value = true;

        // 更新AI消息，移除loading状态
        state.messages[aiMessageIndex] = {
          'isUser': false,
          'content': '',
          'isStreaming': true,
          'isLoading': false,
          'timestamp': DateTime.now().toIso8601String(),
          'isSynced': false, // 保持未同步状态
          'aiSource': robotAtSend, // 保持来源一致
        };

        // 开始轮询获取回复
        _startPollingForReply(aiMessageIndex);
      } else {
        state.isLoading.value = false;
        // 清除发送状态
        state.isSendingMessage.value = false;
        // 更新AI消息为错误状态
        state.messages[aiMessageIndex] = {
          'isUser': false,
          'content': "发送消息失败，请重试",
          'isError': true,
          'isStreaming': false,
          'timestamp': DateTime.now().toIso8601String(),
          'isSynced': true, // 错误消息不需要同步
        };
        // 错误消息也需要滚动到底部
        _scrollToBottomDelayed();
      }
    } catch (e) {
      state.isLoading.value = false;
      // 清除发送状态
      state.isSendingMessage.value = false;
      print('发送AI消息失败: $e');
      // 更新AI消息为错误状态
      state.messages[aiMessageIndex] = {
        'isUser': false,
        'content': "发送消息时出现错误: $e",
        'isError': true,
        'isStreaming': false,
        'timestamp': DateTime.now().toIso8601String(),
        'isSynced': true, // 错误消息不需要同步
      };
      // 错误消息也需要滚动到底部
      _scrollToBottomDelayed();
    }
  }

    /// 创建或更新聊天会话
  Future<void> _createOrUpdateChatSession(String userMessage) async {
    try {
      if (state.currentServerSessionUuid == null) {
        // 创建新的聊天会话
        String title = userMessage.length > 20
            ? userMessage.substring(0, 20) + "..."
            : userMessage;

        // 先尝试在服务端创建会话
        String? serverSessionUuid;
        try {
          final serverResponse = await ApiService().createChatSession(sessionName: title);
          if (serverResponse != null &&
              // serverResponse['执行结果'] == true &&
              serverResponse['返回数据'] != null) {
            serverSessionUuid = serverResponse['返回数据']['session_uuid'];
            print('✅ 服务端会话创建成功: $serverSessionUuid');
          }
        } catch (e) {
          print('⚠️ 服务端会话创建失败: $e');
        }
        state.currentServerSessionUuid = serverSessionUuid;
        state.currentChatUuid = serverSessionUuid ?? state.currentChatUuid;
        state.currentConversationId = null;
        // 刷新聊天历史列表
        await loadConversations();
        print('✅ 创建新聊天会话: $title (仅服务端)');
      } else {
        // 如果有服务端会话UUID，尝试同步到服务端
        if (state.currentServerSessionUuid != null) {
          try {
            await _syncChatRecordsToServer();
          } catch (e) {
            print('⚠️ 同步聊天记录到服务端失败: $e');
          }
        }
        
        print('✅ 更新聊天会话: 仅服务端同步');
      }
    } catch (e) {
      print('创建/更新聊天会话失败: $e');
    }
  }

  /// 同步聊天记录到服务端
  Future<void> _syncChatRecordsToServer() async {
    if (state.currentServerSessionUuid == null || state.messages.isEmpty) {
      return;
    }

    try {
      // ✅ 改进：只同步未同步过的消息
      final unsyncedMessages = state.messages.where((msg) => 
        msg['isError'] != true && 
        msg['isSystem'] != true &&
        msg['isTemporary'] != true && // 排除临时错误消息
        msg['content']?.toString().isNotEmpty == true &&
        msg['isSynced'] != true // 添加同步标记检查
      ).toList();

      if (unsyncedMessages.isEmpty) {
        print('🔄 没有需要同步的新消息');
        return;
      }

      print('🚀 开始同步 ${unsyncedMessages.length} 条新消息到服务端');
      int successCount = 0;

      for (int i = 0; i < unsyncedMessages.length; i++) {
        final message = unsyncedMessages[i];
        try {
          final role = message['isUser'] == true ? 'user' : 'assistant';
          final content = message['content']?.toString() ?? '';
          
          if (content.isNotEmpty) {
            final response = await ApiService().addChatRecord(
              sessionUuid: state.currentServerSessionUuid!,
              role: role,
              content: content,
              factoryName: "OpenAI",
              model: state.selectedModel.value,
              tokenCount: 0,
            );

            // ✅ 同步成功后标记消息
            if (response != null && response['执行结果'] == true) {
              // 在原messages数组中找到对应消息并标记
              for (int j = 0; j < state.messages.length; j++) {
                if (state.messages[j] == message) {
                  state.messages[j]['isSynced'] = true;
                  break;
                }
              }
              successCount++;
              print('✅ 消息 ${i+1}/${unsyncedMessages.length} 同步成功');
            } else {
              print('⚠️ 消息 ${i+1}/${unsyncedMessages.length} 同步失败: ${response?['返回消息'] ?? '未知错误'}');
            }
          }
        } catch (e) {
          print('❌ 同步消息 ${i+1}/${unsyncedMessages.length} 异常: $e');
          // 继续同步其他记录，不因单条失败而中断
        }
      }
      
      print('✅ 聊天记录同步完成: $successCount/${unsyncedMessages.length} 条成功');
    } catch (e) {
      print('同步聊天记录到服务端失败: $e');
    }
  }

  /// 准备发送给API的历史对话数据
  /// 根据后端要求：首次发送消息时传空列表，后续按一问一答形式传递历史
  List<Map<String, dynamic>> _prepareHistoryForAPI() {
    List<Map<String, dynamic>> apiHistory = [];

    // 获取所有有效的非流式消息（排除当前正在发送的消息）
    List<Map<String, dynamic>> validMessages = [];
    
    for (var message in state.messages) {
      // 跳过错误消息、系统消息、临时消息和当前正在流式传输的消息
      if (message['isError'] == true ||
          message['isSystem'] == true ||
          message['isTemporary'] == true || // 排除临时错误消息
          message['isStreaming'] == true ||
          message['isLoading'] == true) {
        continue;
      }

      String content = message['content']?.toString() ?? '';
      if (content.isNotEmpty) {
        validMessages.add(message);
      }
    }

    // 🚀 关键逻辑：判断是否为新会话的首次消息
    // 如果有效消息只有1条（当前用户刚发送的消息），说明是首次发送
    if (validMessages.length <= 1) {
      print('🎯 首次发送消息，历史记录为空列表');
      return []; // 返回空列表
    }

    // 🔄 构建严格一问一答格式的历史记录
    // 排除最后一条消息（当前正在发送的用户消息）
    List<Map<String, dynamic>> historyMessages = validMessages.sublist(0, validMessages.length - 1);
    
    // 🚀 关键修复：确保严格的一问一答交替顺序
    List<Map<String, dynamic>> validPairs = [];
    
    for (int i = 0; i < historyMessages.length; i++) {
      var message = historyMessages[i];
      String role = message['isUser'] == true ? 'user' : 'assistant';
      String content = message['content']?.toString() ?? '';
      
      if (content.isEmpty) continue; // 跳过空内容消息
      
      // 确保交替顺序：user -> assistant -> user -> assistant
      if (validPairs.isEmpty) {
        // 第一条消息必须是用户消息
        if (role == 'user') {
          validPairs.add({
            'role': role,
            'content': content,
          });
        }
      } else {
        String lastRole = validPairs.last['role'];
        // 确保角色交替：上一条是user，这一条必须是assistant；反之亦然
        if ((lastRole == 'user' && role == 'assistant') || 
            (lastRole == 'assistant' && role == 'user')) {
          validPairs.add({
            'role': role,
            'content': content,
          });
        } else {
          // 如果顺序不对，跳过这条消息，保持交替顺序
          print('⚠️ 跳过顺序不正确的消息: $role (期望: ${lastRole == 'user' ? 'assistant' : 'user'})');
        }
      }
    }
    
    // 🛡️ 最终检查：确保历史记录格式正确
    // 历史记录应该包含完整的用户-助手对话对
    // 如果最后一条是孤立的用户消息（没有对应的助手回复），才移除它
    if (validPairs.isNotEmpty && validPairs.last['role'] == 'user') {
      // 检查这是否是一个孤立的用户消息（前面没有assistant回复）
      if (validPairs.length == 1) {
        // 只有一条用户消息，没有回复，移除它避免发送不完整对话
        validPairs.removeLast();
        print('🔧 移除孤立的用户消息，避免发送不完整对话');
      }
      // 如果有多条消息且最后是user，说明是完整的对话历史，保持不变
    }

    print('📝 构建严格交替历史记录，共 ${validPairs.length} 条消息');
    
    // 🔍 调试信息：打印历史记录的角色顺序
    if (validPairs.isNotEmpty) {
      String roleSequence = validPairs.map((msg) => msg['role']).join(' -> ');
      print('📋 历史记录角色顺序: $roleSequence');
    }
    
    return validPairs;
  }

  /// 开始轮询获取AI回复 - 等待式轮询（正确实现）
  void _startPollingForReply(int messageIndex) {
    state.pollCount = 0;
    state.currentAiReply.value = "";
    // 开始第一次请求
    _pollForReplyOnce(messageIndex);
  }

  /// 单次轮询请求 - 等待响应后再决定是否继续
  Future<void> _pollForReplyOnce(int messageIndex) async {
    // 检查是否应该停止轮询
    if (state.currentChatUuid == null || !state.isStreamingReply.value) {
      return;
    }

    // 轮询计数和超时检查
    state.pollCount++;
    const int maxEmptyCount = 50; // 连续空内容次数

    try {
      // 发起单次请求，等待结果
      final reply = await ApiService().getAIChatReply(state.currentChatUuid!);
      // 检查轮询状态（请求期间可能被取消）
      if (state.currentChatUuid == null || !state.isStreamingReply.value) {
        return;
      }
      if (reply != null) {
        final content = reply['content'];
        final isEmpty = reply['isEmpty'] ?? false;
        final isComplete = reply['isComplete'] ?? false;

        // 处理返回内容
        bool hasNewContent = false;
        if (content != null && content.isNotEmpty) {
          state.currentAiReply.value += content;
          hasNewContent = true;
          // 更新UI中的消息
          if (messageIndex < state.messages.length) {
            final prev = state.messages[messageIndex];
            state.messages[messageIndex] = {
              'isUser': false,
              'content': state.currentAiReply.value,
              'isStreaming': true,
              'timestamp': DateTime.now().toIso8601String(),
              'isSynced': false, // 保持流式消息的未同步状态
              'aiSource': prev['aiSource'], // 继承来源
            };

            // 流式回复时自动滚动到底部
            _scrollToBottom(animated: false);
          }
        }

        if (isComplete) {
          print('✅ AI回复完成 - 服务器返回完成状态');
          _finishStreaming(messageIndex);
          return;
        }
        // 判断是否完成 - 根据接口文档建议
        if (isEmpty || (content == null || content.isEmpty)) {
          // 如果连续多次空内容，认为完成
          if (!hasNewContent) {
            // 使用静态变量追踪连续空内容次数
            state.emptyContentCount = (state.emptyContentCount ?? 0) + 1;

            if (state.emptyContentCount! >= maxEmptyCount) {
              print('✅ AI回复完成 - 连续${maxEmptyCount}次空内容');
              _finishStreaming(messageIndex);
              return;
            }
          } else {
            // 有新内容时重置计数
            state.emptyContentCount = 0;
          }
        } else {
          state.emptyContentCount = 0;
        }
        // 计算下次请求的延迟时间
        int nextDelay =
            _calculateNextDelay(hasNewContent, state.emptyContentCount ?? 0);

        // 延迟后继续下一次请求
        Future.delayed(Duration(milliseconds: nextDelay), () {
          _pollForReplyOnce(messageIndex);
        });
      } else {
        // 请求失败，增加重试延迟
        print('⚠️ 获取AI回复失败，准备重试...');
        state.emptyContentCount = (state.emptyContentCount ?? 0) + 1;

        if (state.emptyContentCount! >= maxEmptyCount) {
          print('⚠️ 连续失败次数过多，停止轮询');
          _finishStreaming(messageIndex);
          return;
        }

        // 失败重试延迟（指数退避）
        int retryDelay = _calculateRetryDelay(state.pollCount);
        Future.delayed(Duration(milliseconds: retryDelay), () {
          _pollForReplyOnce(messageIndex);
        });
      }
    } catch (e) {
      print('轮询AI回复异常: $e');

      // 检查轮询状态
      if (state.currentChatUuid == null || !state.isStreamingReply.value) {
        return;
      }

      // 网络异常处理
      state.emptyContentCount = (state.emptyContentCount ?? 0) + 1;

      // 网络错误容忍度更低
      if (state.emptyContentCount! >= 10) {
        print('⚠️ 网络错误过多，停止轮询');
        _finishStreaming(messageIndex);
        return;
      }

      // 异常重试延迟（更保守）
      int retryDelay = _calculateRetryDelay(state.pollCount, isError: true);
      Future.delayed(Duration(milliseconds: retryDelay), () {
        _pollForReplyOnce(messageIndex);
      });
    }
  }

  int _calculateNextDelay(bool hasNewContent, int emptyCount) {
    if (hasNewContent) {
      // 有新内容时快速轮询
      return 200;
    } else if (emptyCount < 5) {
      // 开始时保持较快频率
      return 300;
    } else if (emptyCount < 20) {
      // 逐渐降低频率
      return 500;
    } else {
      // 长时间无内容时降低到最低频率
      return 1000;
    }
  }

  /// 计算重试延迟时间（指数退避）
  int _calculateRetryDelay(int pollCount, {bool isError = false}) {
    int baseDelay = isError ? 500 : 300;
    double multiplier = isError ? 2.0 : 1.5;
    int maxDelay = isError ? 5000 : 3000;

    int delay = (baseDelay * math.pow(multiplier, (pollCount / 10).floor())).toInt();
    return math.min(delay, maxDelay);
  }

  /// 完成流式回复
  void _finishStreaming(int messageIndex) {
    state.isLoading.value = false;
    state.isStreamingReply.value = false;
    // 清除发送状态，允许发送下一条消息
    state.isSendingMessage.value = false;

    // 最终更新消息
    if (messageIndex < state.messages.length) {
      final isAiReplyEmpty = state.currentAiReply.value.isEmpty;
      final finalContent = isAiReplyEmpty
          ? "抱歉，我现在无法回答您的问题，请稍后再试。"
          : state.currentAiReply.value;

      // 🚨 关键修复：如果AI回复失败，实现事务性回滚
      if (isAiReplyEmpty) {
        // AI回复失败，移除失败的对话对（用户消息 + AI错误回复）
        print('🔧 AI回复失败，执行事务性回滚，移除失败的对话对');
        
        // 移除AI错误消息（当前消息）
        if (messageIndex < state.messages.length) {
          state.messages.removeAt(messageIndex);
        }
        
        // 查找并移除对应的用户消息（最后一条用户消息）
        for (int i = state.messages.length - 1; i >= 0; i--) {
          if (state.messages[i]['isUser'] == true && state.messages[i]['isSynced'] == false) {
            print('🗑️ 移除失败的用户消息: ${state.messages[i]['content']}');
            state.messages.removeAt(i);
            break;
          }
        }
        
        // 显示临时错误提示（不保存到历史记录）
        state.messages.add({
          'isUser': false,
          'content': finalContent,
          'isError': true,
          'isTemporary': true, // 标记为临时消息，不同步
          'timestamp': DateTime.now().toIso8601String(),
          // 系统/错误提示不显示来源标题
          'isSystem': true,
        });
        
        print('💡 AI回复失败，已回滚用户消息，避免污染历史记录');
        
      } else {
        // AI回复成功，正常处理
        final prev = state.messages[messageIndex];
        state.messages[messageIndex] = {
          'isUser': false,
          'content': finalContent,
          'isStreaming': false,
          'timestamp': DateTime.now().toIso8601String(),
          'aiModel': state.selectedModel.value,
          'isSynced': false, // 标记最终AI消息需要同步
          'aiSource': prev['aiSource'], // 保持本条消息来源
        };

        // 添加到对话历史
        state.addToConversationHistory('assistant', finalContent);

        // 只有成功时才同步到数据库
        _updateChatHistoryInDB();
        print('✅ AI回复成功，消息已保存到历史记录');
      }
    }

    // 重置状态
    state.resetStreamingState();
  }

    /// 更新聊天记录中的消息
  Future<void> _updateChatHistoryInDB() async {
    try {
      if (state.currentServerSessionUuid != null) {
        // 检查是否有未同步的消息
        final hasUnsyncedMessages = state.messages.any((msg) => 
          msg['isError'] != true && 
          msg['isSystem'] != true &&
          msg['isTemporary'] != true && // 排除临时错误消息
          msg['content']?.toString().isNotEmpty == true &&
          msg['isSynced'] != true
        );

        if (hasUnsyncedMessages) {
          await _syncChatRecordsToServer();
          print('✅ 聊天记录已同步到服务端');
        } else {
          print('🔄 所有消息已同步，跳过本次同步');
        }
      }
      // 刷新聊天历史列表以更新最后消息预览
      await loadConversations();
    } catch (e) {
      print('同步聊天记录失败: $e');
    }
  }

  // 显示聊天历史
  void showChatHistory() {
    // 首先确保当前焦点被移除
    if (Get.context != null) {
      FocusScope.of(Get.context!).unfocus();
    }
    SideSheet.left(
      context: Get.context!,
      width: MediaQuery.of(Get.context!).size.width * 0.8,
      // 内容部分
      body: Obx(() {
        return SafeArea(
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头部标题栏
                Container(
                  height: 48.w,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFFEFEFEF),
                        width: 1.w,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '聊天记录',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // 关闭弹窗并确保移除焦点
                          Navigator.pop(Get.context!);
                          FocusScope.of(Get.context!).unfocus();
                        },
                        child: Container(
                          width: 24.w,
                          height: 24.w,
                          child: Icon(
                            Icons.close,
                            size: 20.w,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 聊天记录列表
                Expanded(
                  child: state.chatHistory.isEmpty
                      ? FYWidget.buildEmptyContent()
                      : ListView.separated(
                          padding: EdgeInsets.only(top: 12.w),
                          itemCount: state.chatHistory.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1.w,
                            color: const Color(0xFFEFEFEF),
                            indent: 16.w,
                            endIndent: 16.w,
                          ),
                          itemBuilder: (context, index) {
                            final history = state.chatHistory[index];
                            return ListTile(
                              leading: Image.asset(
                                FYImages.messenge_icon,
                                width: 24.w,
                                height: 24.w,
                                fit: BoxFit.contain,
                              ),
                              title: Text(
                                history['title'],
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF1A1A1A),
                                ),
                              ),
                              subtitle: Padding(
                                padding: EdgeInsets.only(top: 4.w),
                                child: Text(
                                  history['time'],
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: const Color(0xFFA6A6A6),
                                  ),
                                ),
                              ),
                              trailing: GestureDetector(
                                onTap: () {
                                  print('删除');
                                  // 显示确认对话框
                                  showDialog(
                                    context: Get.context!,
                                    builder: (context) => AlertDialog(
                                      content: Text(
                                        '确定要删除当前对话吗？',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          color: const Color(0xFF1A1A1A),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.w),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 24.w, horizontal: 16.w),
                                      actionsPadding: EdgeInsets.zero,
                                      buttonPadding: EdgeInsets.zero,
                                      actions: [
                                        // 分割线
                                        Container(
                                          height: 1.w,
                                          color: const Color(0xFFEFEFEF),
                                        ),
                                        // 按钮区域
                                        Row(
                                          children: [
                                            // 取消按钮
                                            Expanded(
                                              child: InkWell(
                                                onTap: () =>
                                                    Navigator.pop(context),
                                                child: Container(
                                                  height: 44.w,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      right: BorderSide(
                                                        color: const Color(
                                                            0xFFEFEFEF),
                                                        width: 1.w,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    '取消',
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: const Color(
                                                          0xFF1A1A1A),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // 确定按钮
                                            Expanded(
                                              child: InkWell(
                                                onTap: () async {
                                                  // 确认后删除记录
                                                  await _deleteChatRecord(
                                                      index);
                                                  Navigator.pop(context);
                                                },
                                                child: Container(
                                                  height: 44.w,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    '确定',
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: const Color(
                                                          0xFF3361FE),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Image.asset(
                                  FYImages.cancle_cion,
                                  width: 24.w,
                                  height: 24.w,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              onTap: () {
                                // 加载对话
                                state.isBatchCheck.value = false;
                                state.selectedMessageIndexes.clear();
                                state.messageController.clear();
                                loadConversation(history['title']);
                                Navigator.pop(Get.context!);
                              },
                            );
                          },
                        ),
                ),
                // 底部按钮
                state.chatHistory.isEmpty
                    ? Container()
                    : Container(
                        padding: EdgeInsets.all(16.w),
                        child: GestureDetector(
                          onTap: () {
                            // 显示确认对话框
                            showDialog(
                              context: Get.context!,
                              builder: (context) => AlertDialog(
                                content: Text(
                                  '确定要清空当前对话吗？',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: const Color(0xFF1A1A1A),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.w),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 24.w, horizontal: 16.w),
                                actionsPadding: EdgeInsets.zero,
                                buttonPadding: EdgeInsets.zero,
                                actions: [
                                  // 分割线
                                  Container(
                                    height: 1.w,
                                    color: const Color(0xFFEFEFEF),
                                  ),
                                  // 按钮区域
                                  Row(
                                    children: [
                                      // 取消按钮
                                      Expanded(
                                        child: InkWell(
                                          onTap: () => Navigator.pop(context),
                                          child: Container(
                                            height: 44.w,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                right: BorderSide(
                                                  color:
                                                      const Color(0xFFEFEFEF),
                                                  width: 1.w,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              '取消',
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                color: const Color(0xFF1A1A1A),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // 确定按钮
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            // 确认后执行操作
                                            Navigator.pop(context);
                                            Navigator.pop(Get.context!);
                                            await _clearAllChatHistory();
                                            createNewConversation();
                                          },
                                          child: Container(
                                            height: 44.w,
                                            alignment: Alignment.center,
                                            child: Text(
                                              '确定',
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                color: const Color(0xFF3361FE),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            height: 48.w,
                            decoration: BoxDecoration(
                                color: const Color(0xFFFFECE9),
                                borderRadius: BorderRadius.circular(4.w),
                                border: Border.all(
                                  color: const Color(0xFFFF6850),
                                )),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  FYImages.cancel_red,
                                  width: 24.w,
                                  height: 24.w,
                                  fit: BoxFit.contain,
                                ),
                                Text(
                                  '删除所有历史',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: const Color(0xFFFF3B30),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        );
      }),
    ).then((_) {
      // 确保在弹窗关闭后移除焦点
      if (Get.context != null) {
        FocusScope.of(Get.context!).unfocus();
      }
    });
  }

  // 显示提示词模板
  void showPromptTemplates() {
    FYDialogUtils.showBottomSheet(Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '自定义提示词模板',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('创建您自己的提示词模板，以便在对话中快速使用。'),
                SizedBox(height: 20.w),
                Container(
                  padding: EdgeInsets.all(15.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add_circle, color: Colors.blue.shade700),
                      SizedBox(width: 10.w),
                      const Text(
                        '创建新模板',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.w),
                const Text(
                  '模板标题',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.w),
                TextField(
                  decoration: InputDecoration(
                    hintText: '例如：行业分析',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.w),
                const Text(
                  '提示词内容',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.w),
                TextField(
                  decoration: InputDecoration(
                    hintText: '输入您的提示词模板内容...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text('我的模板'),
                const Icon(Icons.list),
              ],
            ),
          ),
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: state.promptTemplates.length,
                  itemBuilder: (context, index) {
                    final template = state.promptTemplates[index];
                    return GestureDetector(
                      onTap: () {
                        // 使用该模板
                        state.messageController.text = template['content'];
                        state.showTemplateForm.value = false;
                        Get.back();
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10.w),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(8.w),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    template['title'],
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ),
                                // 编辑按钮
                                GestureDetector(
                                  onTap: () {
                                    _showEditTemplateDialog(context, template);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(4.w),
                                    child: Icon(
                                      Icons.edit,
                                      size: 16.w,
                                      color: const Color(0xFF666666),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                // 删除按钮
                                GestureDetector(
                                  onTap: () {
                                    deletePromptTemplate(
                                      template['uuid'] ?? '',
                                      template['title'] ?? '',
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(4.w),
                                    child: Icon(
                                      Icons.delete,
                                      size: 16.w,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.w),
                            Text(
                              template['content'],
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFFA6A6A6),
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {
                Get.back();
              },
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Text('保存模板'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ));
  }

  // 创建新的对话
  void createNewConversation() {
    // 清理定时器
    _pollTimer?.cancel();

    // 重置所有状态
    state.resetStreamingState();
    state.clearConversationHistory();
    state.messageController.clear();

    // 清空消息列表
    state.messages.clear();

    // 添加欢迎消息
    state.messages.add({
      'isUser': false,
      'content': 'Hi~我是烽云AI助手，已接入Perplexity、DeepSeek、Hunyuan大模型，提供实时检索与本地知识库无缝融合，为用户提供精准的回答，提供常用提示词模板。',
      'isSynced': true, // ✅ 标记欢迎消息为已同步（系统消息不需要同步到服务端）
      'isSystem': true, // 标记为系统消息，不会包含在历史对话API中
    });

    state.currentConversationId = null;
    state.currentServerSessionUuid = null;
    state.isLoading.value = false;
  }

    // 加载所有历史对话
  Future<void> loadConversations() async {
    try {
      // ✅ 只从服务端加载会话列表
      List<Map<String, dynamic>> serverSessions = [];
      try {
        final serverResponse = await ApiService().getChatSessionList(
          currentPage: 1,
          pageSize: 50, // 获取较多数据
        );
        
        if (serverResponse != null && 
            serverResponse['执行结果'] == true && 
            serverResponse['返回数据'] != null &&
            serverResponse['返回数据']['list'] != null) {
          
          final List<dynamic> sessionData = serverResponse['返回数据']['list'];
          serverSessions = sessionData.map((session) => {
            'serverUuid': session['uuid'] ?? '',
            'title': session['title_name'] ?? '',
            'createdAt': session['created_at'] ?? '',
            'updatedAt': session['updated_at'] ?? '',
          }).toList();
          
          print('✅ 从服务端加载了 ${serverSessions.length} 个会话');
        }
      } catch (e) {
        print('⚠️ 从服务端加载会话失败: $e');
        state.chatHistory.clear();
        return;
      }
      state.chatHistory.clear();
      for (var serverSession in serverSessions) {
        final title = serverSession['title'] ?? '';
        if (title.isNotEmpty) {
          state.chatHistory.add({
            'id': null, // 服务端会话没有本地ID
            'title': title,
            'time': _formatServerTime(serverSession['updatedAt']),
            'createdAt': serverSession['createdAt'] ?? '',
            'messageCount': 0,
            'lastMessage': '云端会话',
            'chatUuid': serverSession['serverUuid'],
            'serverUuid': serverSession['serverUuid'],
            'source': 'server',
          });
        }
      }

      // 按时间排序
      state.chatHistory.sort((a, b) {
        final timeA = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime.now();
        final timeB = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime.now();
        return timeB.compareTo(timeA);
      });

      print('✅ 会话加载完成: 服务端${serverSessions.length}个');
    } catch (e) {
      print('加载聊天记录失败: $e');
      state.chatHistory.clear();
    }
  }

  /// 格式化服务端时间
  String _formatServerTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return '未知时间';
    }
    
    try {
      // 尝试解析服务端时间格式 "2025-06-25 17:01:59"
      final DateTime dateTime = DateTime.parse(timeString.replaceAll(' ', 'T'));
      return _formatTime(dateTime);
    } catch (e) {
      return timeString;
    }
  }

  /// 加载指定对话
  Future<void> loadConversation(String title) async {
    try {
      // 设置加载状态
      state.isLoadingHistory.value = true;
      
      final cloudSessions = state.chatHistory.where(
        (chat) => chat['title'] == title && chat['source'] == 'server'
      );
      final cloudSession = cloudSessions.isNotEmpty ? cloudSessions.first : null;

      if (cloudSession != null) {
        await _loadCloudConversation(cloudSession);
      } else {
        print('未找到聊天记录: $title，创建新对话');
        createNewConversation();
      }
    } catch (e) {
      print('加载聊天记录失败: $e');
      createNewConversation();
    } finally {
      // 完成后关闭加载状态
      state.isLoadingHistory.value = false;
    }
  }

  /// 从云端加载会话记录
  Future<void> _loadCloudConversation(Map<String, dynamic> cloudSession) async {
    try {
      final serverUuid = cloudSession['serverUuid'];
      if (serverUuid == null || serverUuid.toString().isEmpty) {
        createNewConversation();
        return;
      }
      print('🌐 正在从云端加载会话: ${cloudSession['title']}');
      // 从服务端获取聊天记录
      final serverResponse = await ApiService().getChatRecords(serverUuid.toString());
      if (serverResponse != null && 
          serverResponse['执行结果'] == true && 
          serverResponse['返回数据'] != null) {
        
        final List<dynamic> records = serverResponse['返回数据'];
        List<Map<String, dynamic>> messages = [];
        for (var record in records) {
          messages.add({
            'isUser': record['role'] == 'user',
            'content': record['content'] ?? '',
            'timestamp': record['created_at'] ?? DateTime.now().toIso8601String(),
            'aiModel': record['model'] ?? 'Unknown',
            'aiSource': record['model'] ?? 'Unknown', // 从云端记录恢复来源
            'isSynced': true, // ✅ 标记从云端加载的消息已同步
          });
        }
        
        // 如果没有消息，添加欢迎消息
        if (messages.isEmpty) {
          messages.add({
            'isUser': false,
            'content': 'Hi~我是烽云AI助手，已接入Perplexity、DeepSeek、Hunyuan大模型，提供实时检索与本地知识库无缝融合，为用户提供精准的回答，提供常用提示词模板。',
            'isSynced': true, // ✅ 欢迎消息也标记为已同步（系统消息）
            'isSystem': true, // 标记为系统消息，不会包含在历史对话API中
          });
        }

        // 更新UI状态
        state.messages.clear();
        state.messages.addAll(messages);
        
        // 重建对话历史
        state.clearConversationHistory();
        for (var message in messages) {
          if (message['isUser'] == true) {
            state.addToConversationHistory('user', message['content']?.toString() ?? '');
          } else if (message['aiModel'] != null) {
            state.addToConversationHistory('assistant', message['content']?.toString() ?? '');
          }
        }

        // 设置当前会话状态
        state.currentConversationId = null; // 云端会话暂时没有本地ID
        state.currentServerSessionUuid = serverUuid.toString();
        state.currentChatUuid = serverUuid.toString();

        // 滚动到底部
        _scrollToBottomDelayed(animated: true, delayMs: 200);

        print('✅ 云端会话加载成功: ${messages.length} 条消息');
      } else {
        print('⚠️ 云端会话记录加载失败，创建新对话');
        createNewConversation();
      }
    } catch (e) {
      print('加载云端会话失败: $e');
      createNewConversation();
    }
  }

  /// 删除单个聊天记录
  Future<void> _deleteChatRecord(int index) async {
    try {
      // 获取要删除的聊天记录
      final chatToDelete = state.chatHistory[index];
      final serverUuid = chatToDelete['serverUuid'];

      // ✅ 只删除服务端数据
      if (serverUuid != null && serverUuid.toString().isNotEmpty) {
        try {
          final serverResponse = await ApiService().deleteChatSession(serverUuid.toString());
          if (serverResponse != null && serverResponse['执行结果'] == true) {
            print('✅ 服务端会话删除成功: $serverUuid');
          } else {
            print('⚠️ 服务端会话删除失败: ${serverResponse?['返回消息'] ?? '未知错误'}');
          }
        } catch (e) {
          print('⚠️ 服务端会话删除异常: $e');
        }
      }
      // 更新UI状态
      state.chatHistory.removeAt(index);

      // 如果删除的是当前对话，则创建新对话
      // ✅ 修复：确保类型安全的字符串比较
      if (state.currentServerSessionUuid?.toString() == serverUuid?.toString()) {
        createNewConversation();
      }

      ToastUtil.showShort("删除成功");
      print('✅ 聊天记录删除完成');
    } catch (e) {
      print('删除聊天记录失败: $e');
      ToastUtil.showShort("删除聊天记录时出现错误");
    }
  }

  /// 清空所有聊天记录
  Future<void> _clearAllChatHistory() async {
    try {
      // 显示加载状态
      DialogUtils.showLoading('正在清空聊天记录...');

      // 收集所有需要删除的服务端会话UUID
      List<String> serverUuidsToDelete = [];
      for (var chat in state.chatHistory) {
        final serverUuid = chat['serverUuid'];
        if (serverUuid != null && serverUuid.toString().isNotEmpty) {
          serverUuidsToDelete.add(serverUuid.toString());
        }
      }

      // ✅ 只批量删除服务端会话
      if (serverUuidsToDelete.isNotEmpty) {
        try {
          final serverResponse = await ApiService().batchDeleteChatSessions(serverUuidsToDelete);
          if (serverResponse != null && serverResponse['执行结果'] == true) {
            print('✅ 服务端批量删除会话成功: ${serverUuidsToDelete.length}个');
          } else {
            print('⚠️ 服务端批量删除失败: ${serverResponse?['返回消息'] ?? '未知错误'}');
          }
        } catch (e) {
          print('⚠️ 服务端批量删除异常: $e');
        }
      }
      // 立即更新状态中的聊天历史
      state.chatHistory.clear();

      DialogUtils.hideLoading();
      ToastUtil.showShort("清空成功");
      print('✅ 所有聊天记录已清空完成 (仅服务端)');
    } catch (e) {
      DialogUtils.hideLoading();
      print('清空聊天记录失败: $e');
      ToastUtil.showShort("清空聊天记录时出现错误");
    }
  }

  /// 格式化时间显示
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '今天 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return '昨天 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.month}月${dateTime.day}日';
    }
  }

  // 显示AI助手
  void showAIAssistant() {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'AI助手',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.smart_toy_outlined),
              title: const Text('选择模型'),
              subtitle: Obx(() => Text(state.selectedModel.value)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // 切换模型
                if (state.selectedModel.value == 'DeepSeek') {
                  state.selectedModel.value = 'GPT-4';
                } else {
                  state.selectedModel.value = 'DeepSeek';
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('会话设置'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('帮助中心'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  /// 批量选择
  batchCheck() {
    state.isBatchCheck.value = !state.isBatchCheck.value;
    // 退出批量选择模式时清空选择
    if (!state.isBatchCheck.value) {
      state.selectedMessageIndexes.clear();
    }
  }

  /// 选择/取消选择消息
  toggleMessageSelection(int index) {
    if (state.selectedMessageIndexes.contains(index)) {
      state.selectedMessageIndexes.remove(index);
    } else {
      state.selectedMessageIndexes.add(index);
    }
  }

  /// 导出选中的消息
  exportSelectedMessages() async {
    try {
      // 获取选中的消息
      List<Map<String, dynamic>> selectedMessages = [];
      for (int index in state.selectedMessageIndexes) {
        if (index < state.messages.length) {
          selectedMessages.add(state.messages[index]);
        }
      }

      if (selectedMessages.isEmpty) {
        ToastUtil.showShort("没有选中任何消息");
        return;
      }
      
      // 先检查权限
      final hasPermission = await PermissionService.requestStoragePermission(Get.context);
      if (!hasPermission) {
        // 权限被拒绝，显示对话框让用户选择重试或取消
        if (Get.context != null) {
          final bool? retry = await showDialog<bool>(
            context: Get.context!,
            builder: (context) => AlertDialog(
              title: const Text('需要存储权限'),
              content: const Text('导出文件需要存储权限，请授予权限后重试'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
          
          if (retry == true) {
            // 用户选择重试，再次尝试导出
            exportSelectedMessages();
          }
        }
        return;
      }
      
      state.isExporting.value = true;
      state.exportStatus.value = ExportStatus.generating;

      // 格式化消息为文本
      final String formattedText = _formatMessagesToText(selectedMessages);
      
      // 生成文件名
      final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String fileName = 'AI对话_$timestamp.txt';
      
      String? filePath;
      String saveLocation = '';
      
      if (Platform.isAndroid) {
        // Android: 保存到Downloads文件夹
        try {
          // 尝试保存到外部存储的Downloads目录
          Directory? downloadsDir;
          
          // 方法1：尝试获取外部存储的Downloads目录
          if (await Permission.manageExternalStorage.isGranted) {
            downloadsDir = Directory('/storage/emulated/0/Download');
            if (!await downloadsDir.exists()) {
              downloadsDir = Directory('/storage/emulated/0/Downloads');
            }
          }
          
          // 方法2：如果上面失败，使用应用的外部存储目录
          if (downloadsDir == null || !await downloadsDir.exists()) {
            final externalDir = await getExternalStorageDirectory();
            if (externalDir != null) {
              downloadsDir = Directory('${externalDir.path}/Downloads');
              await downloadsDir.create(recursive: true);
            }
          }
          
          // 方法3：最后备选方案，使用应用文档目录
          if (downloadsDir == null || !await downloadsDir.exists()) {
            final appDocDir = await getApplicationDocumentsDirectory();
            downloadsDir = Directory('${appDocDir.path}/导出文件');
            await downloadsDir.create(recursive: true);
          }
          
          final file = File('${downloadsDir.path}/$fileName');
          await file.writeAsString(formattedText);
          filePath = file.path;
          
          // 确定保存位置描述
          if (filePath.contains('/storage/emulated/0/Download')) {
            saveLocation = '设备存储/Downloads';
          } else if (filePath.contains('/storage/emulated/0/Downloads')) {
            saveLocation = '设备存储/Downloads';
          } else if (filePath.contains('Android/data')) {
            saveLocation = '应用外部存储/Downloads';
          } else {
            saveLocation = '应用文档目录/导出文件';
          }
          
          print('✅ Android文件已保存至: $filePath');
          
        } catch (e) {
          print('❌ Android保存失败: $e');
          // 备选方案：保存到应用文档目录
          final appDocDir = await getApplicationDocumentsDirectory();
          final exportDir = Directory('${appDocDir.path}/导出文件');
          await exportDir.create(recursive: true);
          final file = File('${exportDir.path}/$fileName');
          await file.writeAsString(formattedText);
          filePath = file.path;
          saveLocation = '应用文档目录/导出文件';
          print('✅ 备选方案保存成功: $filePath');
        }
      } else {
        // iOS或其他平台：使用文档目录
        final directory = await getApplicationDocumentsDirectory();
        final exportDir = Directory('${directory.path}/导出文件');
        await exportDir.create(recursive: true);
        final file = File('${exportDir.path}/$fileName');
        await file.writeAsString(formattedText);
        filePath = file.path;
        saveLocation = '应用文档目录/导出文件';
        print('✅ 文件已保存至: $filePath');
      }
      
      if (filePath == null) {
        throw Exception('文件保存失败');
      }
      
      // 设置导出信息
      state.exportInfo.value = {
        'title': fileName,
        'date': DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
        'fileType': 'TXT文件',
        'size': await _getFileSize(filePath),
        'description': '包含${selectedMessages.length}条对话内容，已按时间顺序整理。',
        'filePath': filePath,
        'saveLocation': saveLocation,
      };
      
      state.exportStatus.value = ExportStatus.success;
      
      // 显示成功提示
      ToastUtil.showShort("文件已保存至: $saveLocation");
      
    } catch (e) {
      print('导出消息异常: $e');
      state.exportStatus.value = ExportStatus.failed;
      ToastUtil.showShort("导出过程中出现错误: ${e.toString().substring(0, math.min(50, e.toString().length))}");
      Future.delayed(Duration(seconds: 2), () {
        state.isExporting.value = false;
      });
    }
  }

  /// 格式化消息为文本
  String _formatMessagesToText(List<Map<String, dynamic>> messages) {
    StringBuffer buffer = StringBuffer();
    
    // 添加标题
    buffer.writeln('========== AI对话记录 ==========');
    buffer.writeln('导出时间: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
    buffer.writeln('=============================\n');
    
    // 按时间顺序添加消息
    for (var message in messages) {
      final bool isUser = message['isUser'] == true;
      final String role = isUser ? '用户' : 'AI助手';
      final String content = message['content']?.toString() ?? '';
      final String timestamp = message['timestamp'] != null 
          ? _formatTimestamp(message['timestamp'])
          : '';
          
      buffer.writeln('[$role] $timestamp');
      buffer.writeln(content);
      buffer.writeln('\n----------------------------\n');
    }
    
    return buffer.toString();
  }
  
  /// 格式化时间戳
  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    } catch (e) {
      return '';
    }
  }
  
  /// 获取文件大小
  Future<String> _getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.length();
      
      if (bytes < 1024) {
        return '$bytes B';
      } else if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(2)} KB';
      } else {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
      }
    } catch (e) {
      return '未知大小';
    }
  }

  // 取消批量选择
  cancelBatchSelection() {
    state.isBatchCheck.value = false;
    state.selectedMessageIndexes.clear();
  }

  // 显示提示词模板弹窗
  void showTipTemplateDialog(BuildContext context) {
    // 首先确保当前焦点被移除
    FocusScope.of(context).unfocus();
    // 更新状态UI，添加半透明蒙层
    FYDialogUtils.showBottomSheet(Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r), topRight: Radius.circular(16.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部标题栏
          Container(
            height: 48.w,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.w),
                topRight: Radius.circular(16.w),
              ),
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: const Color(0xFFEFEFEF), width: 1.w),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '自定义提示词模板',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // 关闭弹窗并确保移除焦点
                    Navigator.pop(context);
                    FocusScope.of(context).unfocus();
                  },
                  child: Container(
                    width: 24.w,
                    height: 24.w,
                    child: Icon(
                      Icons.close,
                      size: 20.w,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              print('模版:${state.showTemplateForm.value}');
              state.showTemplateForm.value = !state.showTemplateForm.value;
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
              child: Row(
                children: [
                  Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF345DFF), Color(0xFF2F89F8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        FYImages.add_tip_mock,
                        width: 24.w,
                        height: 24.w,
                        fit: BoxFit.contain,
                      )),
                  SizedBox(width: 8.w),
                  Text(
                    '创建新模板',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    state.showTemplateForm.value
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20.w,
                    color: const Color(0xFF1A1A1A),
                  )
                ],
              ),
            ),
          ),

          // 创建新模板表单
          Obx(() {
            return Visibility(
              visible: state.showTemplateForm.value,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 模板标题
                    Text(
                      '模板标题',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 8.w),
                    Container(
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(4.w),
                      ),
                      child: TextField(
                        controller: state.titleController,
                        decoration: InputDecoration(
                          hintText: '例如:行业标题',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFFA6A6A6),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.w),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12.w),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.w),
                    // 提示词内容
                    Text(
                      '提示词内容',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 8.w),
                    Container(
                      // height: 100.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(4.w),
                      ),
                      child: TextField(
                        controller: state.contentController,
                        decoration: InputDecoration(
                          hintText: '输入您的提示词模板内容',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFFA6A6A6),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.w),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 12.w),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.w),

                    // 保存按钮
                    GestureDetector(
                      onTap: () {
                        // 调用保存提示词模板的方法
                        savePromptTemplate(
                          state.titleController.text,
                          state.contentController.text,
                        );
                      },
                      child: Container(
                        height: 48.w,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF345DFF), Color(0xFF2F89F8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(4.w),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '保存模板',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.w),
                  ],
                ),
              ),
            );
          }),

          // 分割线
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            height: 1.w,
            color: const Color(0xFFD8D8D8),
          ),

          // 我的模板标题
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
            child: Row(
              children: [
                Image.asset(FYImages.my_mock,
                    width: 20.w, height: 20.w, fit: BoxFit.contain),
                SizedBox(width: 8.w),
                Text(
                  '我的模板',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),

          // 模板列表
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: state.promptTemplates.length,
                  itemBuilder: (context, index) {
                    final template = state.promptTemplates[index];
                    return GestureDetector(
                      onTap: () {
                        // 使用该模板
                        state.messageController.text = template['content'];
                        state.showTemplateForm.value = false;
                        Get.back();
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10.w),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(8.w),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    template['title'],
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ),
                                // 编辑按钮
                                Visibility(
                                  visible: !template['isDefault'],
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          _showEditTemplateDialog(context, template);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(4.w),
                                          child: Icon(
                                            Icons.edit,
                                            size: 16.w,
                                            color: const Color(0xFF666666),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      // 删除按钮
                                      GestureDetector(
                                        onTap: () {
                                          deletePromptTemplate(
                                            template['uuid'] ?? '',
                                            template['title'] ?? '',
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(4.w),
                                          child: Icon(
                                            Icons.delete,
                                            size: 16.w,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.w),
                            Text(
                              template['content'],
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFFA6A6A6),
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
          ),
        ],
      ),
    ));
  }

  // 显示模型选择弹窗
  void showModelSelectionDialog(BuildContext context, GlobalKey modelKey) {
    if (state.modelOverlayEntry.value != null) {
      hideModelSelection();
      return;
    }

    // 获取按钮的位置和大小
    final RenderBox? renderBox =
        modelKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Size size = renderBox.size;
    final Offset position = renderBox.localToGlobal(Offset.zero);

    // 获取屏幕宽度用于边界检查
    final screenWidth = MediaQuery.of(context).size.width;

    // 创建浮层
    final overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 背景遮罩，点击后关闭浮层
          Positioned.fill(
            child: GestureDetector(
              onTap: hideModelSelection,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // 下拉菜单内容
          Positioned(
            top: position.dy + size.height + 4,
            right: 1.w,
            child: Material(
              color: Colors.transparent,
              child: IntrinsicWidth(
                child: Container(
                  // 计算左侧位置，确保不超出屏幕边界
                  margin: EdgeInsets.only(
                    left: _calculateDropdownLeft(position.dx, screenWidth, context),
                    right: 16.w,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 8,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: state.modelList.map((model) {
                      return Obx(() => GestureDetector(
                            onTap: () => selectModel(model['name'].toString()),
                            child: Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: model['name'] == state.selectedModel.value
                                    ? const Color(0xFFF0F6FF)
                                    : Colors.white,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "${model['name'].toString()} +",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                    maxLines: 1,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    model['description'].toString(),
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: const Color(0xFFA6A6A6),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  if (model['name'] == state.selectedModel.value)
                                    Icon(
                                      Icons.check,
                                      size: 20.w,
                                      color: FYColors.color_3361FE,
                                    ),
                                ],
                              ),
                            ),
                          ));
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    state.modelOverlayEntry.value = overlayEntry;

    // 安全地插入浮层
    try {
      Overlay.of(context).insert(overlayEntry);
    } catch (e) {
      print('插入模型选择浮层时出现异常: $e');
      state.modelOverlayEntry.value = null;
    }
  }

  /// 计算下拉菜单的左侧位置，确保不超出屏幕边界
  double _calculateDropdownLeft(double buttonX, double screenWidth, BuildContext context) {
    // 预估弹窗宽度（可以根据实际内容调整）
    const estimatedDropdownWidth = 200.0;
    
    // 理想的左侧位置（按钮中心向左偏移一些）
    double idealLeft = buttonX - 60;
    
    // 确保不超出左边界
    if (idealLeft < 16.w) {
      idealLeft = 16.w;
    }
    
    // 确保不超出右边界
    if (idealLeft + estimatedDropdownWidth > screenWidth - 16.w) {
      idealLeft = screenWidth - estimatedDropdownWidth - 16.w;
    }
    
    return idealLeft;
  }

  // 隐藏模型选择弹窗
  void hideModelSelection() {
    _safeHideModelSelection();
  }

  // 安全地隐藏模型选择弹窗
  void _safeHideModelSelection() {
    try {
      if (state.modelOverlayEntry.value != null) {
        state.modelOverlayEntry.value?.remove();
        state.modelOverlayEntry.value = null;
      }
    } catch (e) {
      state.modelOverlayEntry.value = null;
      print('清理模型选择浮层时出现异常: $e');
    }
  }

  // 选择模型
  void selectModel(String modelName) {
    state.selectedModel.value = modelName;
    _safeHideModelSelection();
  }

  // 关闭导出弹窗
  void closeExportDialog() {
    state.isExporting.value = false;
    state.exportStatus.value = ExportStatus.generating;
    state.exportInfo.clear();
  }

  // 预览导出内容
  void previewExport() {
    // 如果没有导出信息或文件路径，则返回
    if (state.exportInfo.isEmpty || state.exportInfo['filePath'] == null) {
      ToastUtil.showShort("无法预览导出内容");
      return;
    }
    _openFileWithSystemApp();
  }
  
  /// 应用内预览
  void _showInAppPreview() {
    try {
      // 读取文件内容并显示预览
      final file = File(state.exportInfo['filePath']);
      file.readAsString().then((content) {
        Get.dialog(
          Dialog(
            child: Container(
              width: double.maxFinite,
              height: Get.height * 0.8,
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题栏
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '预览导出内容',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '文件位置: ${state.exportInfo['saveLocation'] ?? ''}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 用系统应用打开按钮
                          IconButton(
                            icon: Icon(Icons.open_in_new),
                            onPressed: () {
                              Get.back();
                              _openFileWithSystemApp();
                            },
                            tooltip: '用系统应用打开',
                          ),
                          // 关闭按钮
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Get.back(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(),
                  // 内容预览
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          content,
                          style: TextStyle(
                            fontSize: 14.sp,
                            height: 1.5,
                            fontFamily: 'monospace', // 使用等宽字体
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 底部操作按钮
                  SizedBox(height: 16.w),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 复制内容按钮
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: content));
                            ToastUtil.showShort("内容已复制到剪贴板");
                          },
                          icon: Icon(Icons.copy, size: 16.sp),
                          label: Text('复制内容'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade100,
                            foregroundColor: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // 分享文件按钮
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.back();
                            downloadExport();
                          },
                          icon: Icon(Icons.share, size: 16.sp),
                          label: Text('分享文件'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).catchError((error) {
        ToastUtil.showShort("读取文件内容失败: $error");
      });
    } catch (e) {
      ToastUtil.showShort("预览文件时出错: $e");
    }
  }
  
  /// 用系统应用打开文件
  void _openFileWithSystemApp() async {
    try {
      final filePath = state.exportInfo['filePath'];
      if (filePath == null || filePath.isEmpty) {
        ToastUtil.showShort("文件路径无效");
        return;
      }
      
      final file = File(filePath);
      if (!await file.exists()) {
        ToastUtil.showShort("文件不存在");
        return;
      }
      
      if (Platform.isAndroid) {
        // Android: 优先使用open_file插件直接打开文件
        try {
          final result = await OpenFile.open(filePath);
          
          switch (result.type) {
            case ResultType.done:
              ToastUtil.showShort("文件已打开");
              break;
            case ResultType.noAppToOpen:
              ToastUtil.showShort("没有找到可以打开此文件的应用");
              _showFileLocationInfo(filePath);
              break;
            case ResultType.fileNotFound:
              ToastUtil.showShort("文件不存在");
              break;
            case ResultType.permissionDenied:
              ToastUtil.showShort("权限被拒绝");
              _showFileLocationInfo(filePath);
              break;
            case ResultType.error:
            default:
              // 如果open_file失败，尝试使用分享功能
              print('open_file失败，尝试分享功能: ${result.message}');
              await _shareFileAsBackup(filePath);
              break;
          }
        } catch (e) {
          print('open_file异常: $e');
          // 备选方案：使用分享功能
          await _shareFileAsBackup(filePath);
        }
      } else {
        // 其他平台的处理
        ToastUtil.showShort("当前平台暂不支持直接打开文件");
        _showFileLocationInfo(filePath);
      }
    } catch (e) {
      print('打开文件异常: $e');
      ToastUtil.showShort("打开文件失败: $e");
      // 显示文件位置信息作为备选方案
      final filePath = state.exportInfo['filePath'];
      if (filePath != null) {
        _showFileLocationInfo(filePath);
      }
    }
  }
  
  /// 备选方案：使用分享功能
  Future<void> _shareFileAsBackup(String filePath) async {
    try {
      final result = await Share.shareXFiles(
        [XFile(filePath)],
        text: '查看AI对话记录',
        subject: state.exportInfo['title'] ?? 'AI对话记录',
      );
      
      if (result.status == ShareResultStatus.success) {
        ToastUtil.showShort("已调用系统应用");
      } else if (result.status == ShareResultStatus.dismissed) {
        // 用户取消了，显示文件位置信息
        _showFileLocationInfo(filePath);
      }
    } catch (e) {
      print('分享功能异常: $e');
      _showFileLocationInfo(filePath);
    }
  }
  
  /// 显示文件位置信息
  void _showFileLocationInfo(String filePath) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.folder_open, color: Colors.blue),
            SizedBox(width: 8.w),
            Text('文件位置'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('文件已保存至以下位置：'),
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '保存位置:',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    state.exportInfo['saveLocation'] ?? '',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '完整路径:',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  SelectableText(
                    filePath,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: 'monospace',
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              '💡 提示：您可以使用文件管理器找到此文件',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.blue.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: filePath));
              ToastUtil.showShort("文件路径已复制到剪贴板");
            },
            child: Text('复制路径'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  // 下载/分享导出文件
  void downloadExport() async {
    // 如果没有导出信息或文件路径，则返回
    if (state.exportInfo.isEmpty || state.exportInfo['filePath'] == null) {
      ToastUtil.showShort("无法分享导出内容");
      return;
    }
    
    try {
      final filePath = state.exportInfo['filePath'];
      final file = File(filePath);
      
      if (await file.exists()) {
        // 确保文件可以被访问
        final bytes = await file.readAsBytes();
        if (bytes.isEmpty) {
          ToastUtil.showShort("文件内容为空，无法分享");
          return;
        }
        
        // 使用分享功能让用户选择保存位置或分享
        final result = await Share.shareXFiles(
          [XFile(filePath)],
          text: '导出的AI对话记录',
          subject: '${state.exportInfo['title'] ?? "AI对话记录"}',
        );
        
        if (result.status == ShareResultStatus.success) {
          ToastUtil.showShort("文件已成功分享");
        } else if (result.status == ShareResultStatus.dismissed) {
          ToastUtil.showShort("分享已取消");
        }
        
        closeExportDialog();
      } else {
        // 如果文件不存在，尝试重新导出
        ToastUtil.showShort("文件不存在，请重新导出");
        closeExportDialog();
      }
    } catch (e) {
      print('分享文件异常: $e');
      ToastUtil.showShort("分享文件时出错，请重试");
      // 显示更详细的错误信息，帮助调试
      print('详细错误: $e');
    }
  }

  // 复制消息内容
  void copyContent(String content) {
    if (content.trim().isEmpty) return;

    Clipboard.setData(ClipboardData(text: content));
    ToastUtil.showShort("消息内容已复制到剪贴板");
  }

  canPopFunction(bool didPop) {
    if (didPop) return;

    // 如果有模型选择弹窗显示，优先关闭弹窗
    if (state.modelOverlayEntry.value != null) {
      hideModelSelection();
      return;
    }
    // 否则正常返回
    Get.back();
  }

  // 更新 输入框的高度
  void updateInputBoxHeightOptimized() {
    final RenderBox? renderBox =
        state.inputBoxKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final newHeight = renderBox.size.height;
      // 只有高度真正发生变化时才更新状态
      if ((newHeight - state.lastKnownHeight).abs() > 1.0) {
        state.lastKnownHeight = newHeight;
        state.inputBoxHeight.value = newHeight;
      }
    }
  }

  // ===== 提示词模板管理方法 =====
  
  /// 从服务端加载提示词模板列表
  Future<void> loadPromptTemplates() async {
    try {
      final response = await ApiService().getPromptTemplateList(
        currentPage: 1,
        pageSize: 100
      );

      if (response != null && 
          response['执行结果'] == true && 
          response['返回数据'] != null) {
        
        final data = response['返回数据'];
        if (data is Map && data['list'] != null) {
          // 清空当前模板
          state.promptTemplates.clear();
          // 解析服务端返回的模板数据
          final List<dynamic> templates = data['list'];
          for (var template in templates) {
            state.promptTemplates.add({
              'uuid': template['uuid'] ?? '',
              'title': template['prompt_name'] ?? '',
              'content': template['prompt_content'] ?? '',
              'isDefault': template['is_default'],
              'createdAt': template['created_at'] ?? '',
            });
          }
          
          print('✅ 成功加载 ${state.promptTemplates.length} 个提示词模板');
        }
      } else {
        print('❌ 加载提示词模板失败，使用默认模板');
        // 如果服务端加载失败，保持使用当前的默认模板
      }
    } catch (e) {
      print('❌ 加载提示词模板异常: $e');
    }
  }

  /// 保存新的提示词模板到服务端
  Future<void> savePromptTemplate(String title, String content) async {
    if (title.trim().isEmpty || content.trim().isEmpty) {
      ToastUtil.showShort('模板标题和内容不能为空');
      return;
    }

    try {
      // 显示加载状态
      DialogUtils.showLoading('正在保存模板...');

      final response = await ApiService().addPromptTemplate(
        promptName: title.trim(),
        promptContent: content.trim(),
        isDefault: false,
      );

      if (response != null && response['执行结果'] == true) {
        // 清空输入框
        state.titleController.clear();
        state.contentController.clear();
        // 关闭表单
        state.showTemplateForm.value = false;
        // 重新加载模板列表
        await loadPromptTemplates();
        // 所有操作完成后隐藏loading并显示成功提示
        DialogUtils.hideLoading();
        ToastUtil.showShort('模板保存成功');
      } else {
        DialogUtils.hideLoading();
        ToastUtil.showShort('模板保存失败: ${response?['返回消息'] ?? '未知错误'}');
      }
    } catch (e) {
      DialogUtils.hideLoading();
      ToastUtil.showShort('保存模板时出错: $e');
      print('保存提示词模板异常: $e');
    }
  }

  /// 编辑提示词模板
  Future<void> editPromptTemplate(String uuid, String title, String content) async {
    if (title.trim().isEmpty || content.trim().isEmpty) {
      ToastUtil.showShort('模板标题和内容不能为空');
      return;
    }

    try {
      // 显示加载状态
      DialogUtils.showLoading('正在更新模板...');

      final response = await ApiService().updatePromptTemplate(
        promptUuid: uuid,
        promptName: title.trim(),
        promptContent: content.trim(),
        isDefault: false,
      );

      if (response != null && response['执行结果'] == true) {
        // 重新加载模板列表
        await loadPromptTemplates();
        // 所有操作完成后隐藏loading并显示成功提示
        DialogUtils.hideLoading();
        ToastUtil.showShort('模板更新成功');
        
      } else {
        DialogUtils.hideLoading();
        ToastUtil.showShort('模板更新失败: ${response?['返回消息'] ?? '未知错误'}');
      }
    } catch (e) {
      DialogUtils.hideLoading();
      ToastUtil.showShort('更新模板时出错: $e');
      print('编辑提示词模板异常: $e');
    }
  }

  /// 删除提示词模板
  Future<void> deletePromptTemplate(String uuid, String title) async {
    // 先确认删除
    bool? confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除模板"$title"吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      // 显示加载状态
      DialogUtils.showLoading('正在删除模板...');
      final response = await ApiService().deletePromptTemplate(uuid);
      if (response != null && response['执行结果'] == true) {
        // 重新加载模板列表
        await loadPromptTemplates();
        DialogUtils.hideLoading();
        ToastUtil.showShort('模板删除成功');
      } else {
        DialogUtils.hideLoading();
        ToastUtil.showShort('模板删除失败: ${response?['返回消息'] ?? '未知错误'}');
      }
    } catch (e) {
      DialogUtils.hideLoading();
      ToastUtil.showShort('删除模板时出错: $e');
      print('删除提示词模板异常: $e');
    }
  }

  /// 批量删除提示词模板
  Future<void> batchDeletePromptTemplates(List<String> uuids) async {
    if (uuids.isEmpty) {
      ToastUtil.showShort('请选择要删除的模板');
      return;
    }

    // 先确认删除
    bool? confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认批量删除'),
        content: Text('确定要删除选中的${uuids.length}个模板吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // 显示加载状态
      DialogUtils.showLoading('正在批量删除模板...');

      final response = await ApiService().batchDeletePromptTemplates(uuids);
      if (response != null && response['执行结果'] == true) {
        // 重新加载模板列表
        await loadPromptTemplates();
        // 所有操作完成后隐藏loading并显示成功提示
        DialogUtils.hideLoading();
        ToastUtil.showShort('模板批量删除成功');
        
      } else {
        DialogUtils.hideLoading();
        ToastUtil.showShort('模板批量删除失败: ${response?['返回消息'] ?? '未知错误'}');
      }
    } catch (e) {
      DialogUtils.hideLoading();
      ToastUtil.showShort('批量删除模板时出错: $e');
      print('批量删除提示词模板异常: $e');
    }
  }

  /// 刷新提示词模板列表
  Future<void> refreshPromptTemplates() async {
    await loadPromptTemplates();
  }

  /// 显示编辑模板对话框
  void _showEditTemplateDialog(BuildContext context, Map<String, dynamic> template) {
    // 预填充当前模板的数据
    editTitleController.text = template['title'] ?? '';
    editContentController.text = template['content'] ?? '';

    Get.dialog(
      AlertDialog(
        title: const Text('编辑提示词模板'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400, // 设置固定高度避免溢出
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 模板标题
                const Text('模板标题'),
                const SizedBox(height: 8),
                TextField(
                  controller: editTitleController,
                  decoration: const InputDecoration(
                    hintText: '请输入模板标题',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 模板内容
                const Text('模板内容'),
                const SizedBox(height: 8),
                TextField(
                  controller: editContentController,
                  maxLines: 8, // 设置最大行数
                  minLines: 3, // 设置最小行数
                  decoration: const InputDecoration(
                    hintText: '请输入模板内容',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              clearEditTemplateData();
              Get.back();
            },
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = editTitleController.text.trim();
              final content = editContentController.text.trim();
              
              if (title.isEmpty || content.isEmpty) {
                ToastUtil.showShort('标题和内容不能为空');
                return;
              }

              // 关闭对话框
              Get.back();
              
              // 调用编辑API
              await editPromptTemplate(
                template['uuid'] ?? '',
                title,
                content,
              );
              
              // 清理编辑数据
              clearEditTemplateData();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  // 清理编辑模板数据
  void clearEditTemplateData() {
    editTitleController.clear();
    editContentController.clear();
  }
}
