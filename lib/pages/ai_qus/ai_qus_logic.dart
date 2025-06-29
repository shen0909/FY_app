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
import 'package:safe_app/utils/dialog_utils.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class AiQusLogic extends GetxController {
  final AiQusState state = AiQusState();
  Timer? _pollTimer;
  final RealmService _realmService = RealmService();

  @override
  void onReady() {
    super.onReady();
    // 加载数据
    loadConversations();
    // 加载提示词模板
    loadPromptTemplates();
  }

  @override
  void onClose() {
    // 释放资源
    state.messageController.dispose();
    state.titleController.dispose();
    state.contentController.dispose();
    state.scrollController.dispose();
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

    // 添加用户消息
    final userMessage = {
      'isUser': true,
      'content': text,
      'timestamp': DateTime.now().toIso8601String(),
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
        };

        // 开始轮询获取回复
        _startPollingForReply(aiMessageIndex);
      } else {
        state.isLoading.value = false;
        // 更新AI消息为错误状态
        state.messages[aiMessageIndex] = {
          'isUser': false,
          'content': "发送消息失败，请重试",
          'isError': true,
          'isStreaming': false,
          'timestamp': DateTime.now().toIso8601String(),
        };
        // 错误消息也需要滚动到底部
        _scrollToBottomDelayed();
      }
    } catch (e) {
      state.isLoading.value = false;
      print('发送AI消息失败: $e');
      // 更新AI消息为错误状态
      state.messages[aiMessageIndex] = {
        'isUser': false,
        'content': "发送消息时出现错误: $e",
        'isError': true,
        'isStreaming': false,
        'timestamp': DateTime.now().toIso8601String(),
      };
      // 错误消息也需要滚动到底部
      _scrollToBottomDelayed();
    }
  }

  /// 创建或更新聊天会话
  Future<void> _createOrUpdateChatSession(String userMessage) async {
    try {
      if (state.currentConversationId == null) {
        // 创建新的聊天会话
        String title = userMessage.length > 20
            ? userMessage.substring(0, 20) + "..."
            : userMessage;

        final chatHistory = await _realmService.saveChatHistory(
          title: title,
          messages: state.messages,
          chatUuid: state.currentChatUuid,
          modelName: state.selectedModel.value,
        );
        state.currentConversationId = chatHistory.id;

        // 刷新聊天历史列表
        await loadConversations();

        print('✅ 创建新聊天会话: $title');
      } else {
        // 更新现有聊天会话
        await _realmService.updateChatHistory(
          id: state.currentConversationId!,
          messages: state.messages,
        );
        print('✅ 更新聊天会话: ${state.currentConversationId}');
      }
    } catch (e) {
      print('创建/更新聊天会话失败: $e');
    }
  }

  /// 准备发送给API的历史对话数据
  List<Map<String, dynamic>> _prepareHistoryForAPI() {
    List<Map<String, dynamic>> apiHistory = [];

    for (var message in state.messages) {
      // 跳过错误消息、系统消息和当前正在输入的消息
      if (message['isError'] == true ||
          message['isSystem'] == true ||
          message['isStreaming'] == true) {
        continue;
      }

      String role = message['isUser'] == true ? 'user' : 'assistant';
      String content = message['content']?.toString() ?? '';

      if (content.isNotEmpty) {
        apiHistory.add({
          'role': role,
          'content': content,
        });
      }
    }

    return apiHistory;
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
    const int maxPollCount = 150; // 最大轮询次数
    const int maxEmptyCount = 50; // 连续空内容次数

    if (state.pollCount > maxPollCount) {
      print('⚠️ 达到最大轮询次数限制(${maxPollCount})，停止轮询');
      _finishStreaming(messageIndex);
      return;
    }

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

        // 处理返回内容
        bool hasNewContent = false;
        if (content != null && content.isNotEmpty) {
          state.currentAiReply.value += content;
          hasNewContent = true;
          // 更新UI中的消息
          if (messageIndex < state.messages.length) {
            state.messages[messageIndex] = {
              'isUser': false,
              'content': state.currentAiReply.value,
              'isStreaming': true,
              'timestamp': DateTime.now().toIso8601String(),
            };

            // 流式回复时自动滚动到底部
            _scrollToBottom(animated: false);
          }
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

    // 最终更新消息
    if (messageIndex < state.messages.length) {
      final finalContent = state.currentAiReply.value.isEmpty
          ? "抱歉，我现在无法回答您的问题，请稍后再试。"
          : state.currentAiReply.value;

      state.messages[messageIndex] = {
        'isUser': false,
        'content': finalContent,
        'isStreaming': false,
        'timestamp': DateTime.now().toIso8601String(),
        'aiModel': state.selectedModel.value,
      };

      // 添加到对话历史
      state.addToConversationHistory('assistant', finalContent);

      // 立即更新数据库记录
      _updateChatHistoryInDB();
    }

    // 重置状态
    state.resetStreamingState();
  }

  /// 更新数据库中的聊天记录
  Future<void> _updateChatHistoryInDB() async {
    try {
      if (state.currentConversationId != null) {
        await _realmService.updateChatHistory(
          id: state.currentConversationId!,
          messages: state.messages,
        );

        // 刷新聊天历史列表以更新最后消息预览
        await loadConversations();

        print('✅ 数据库聊天记录已更新');
      }
    } catch (e) {
      print('更新数据库聊天记录失败: $e');
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
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '自定义提示词模板',
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
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('创建您自己的提示词模板，以便在对话中快速使用。'),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add_circle, color: Colors.blue.shade700),
                      const SizedBox(width: 10),
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
                const SizedBox(height: 20),
                const Text(
                  '模板标题',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    hintText: '例如：行业分析',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '提示词内容',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    hintText: '输入您的提示词模板内容...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
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
      'content': 'Hi~ 我是您身边的智能助手，可以为您答疑解惑、精读文档、尽情创作，让科技助你轻松工作，多点生活',
    });

    state.currentConversationId = null;
    state.isLoading.value = false;
  }

  // 加载所有对话
  Future<void> loadConversations() async {
    try {
      // 从Realm数据库加载聊天记录
      final chatHistories = _realmService.getAllChatHistory();

      // 更新状态中的聊天历史
      state.chatHistory.clear();
      for (var history in chatHistories) {
        state.chatHistory.add({
          'id': history.id,
          'title': history.title,
          'time': _formatTime(history.updatedAt),
          'createdAt': history.createdAt.toIso8601String(),
          'messageCount': history.messageCount,
          'lastMessage': history.lastMessage ?? '',
          'chatUuid': history.chatUuid,
        });
      }

      print('✅ 已从Realm加载 ${chatHistories.length} 条聊天记录');
    } catch (e) {
      print('从Realm加载聊天记录失败: $e');
      // 如果Realm加载失败，保持空状态，不加载模拟数据
      state.chatHistory.clear();
    }
  }

  /// 加载指定对话
  Future<void> loadConversation(String title) async {
    try {
      // 根据title查找对应的聊天历史
      final chatHistory = _realmService.getChatHistoryByTitle(title);

      if (chatHistory != null) {
        // 加载聊天历史的所有消息
        final messages = _realmService.getChatMessages(chatHistory.id);

        state.messages.clear();
        state.messages.addAll(messages);

        // 重建对话历史（用于API调用）
        state.clearConversationHistory();
        for (var message in messages) {
          if (message['isUser'] == true) {
            state.addToConversationHistory(
                'user', message['content']?.toString() ?? '');
          } else if (message['isError'] != true &&
              message['isSystem'] != true) {
            state.addToConversationHistory(
                'assistant', message['content']?.toString() ?? '');
          }
        }

        state.currentConversationId = chatHistory.id;
        state.currentChatUuid = chatHistory.chatUuid;

        // 加载完成后自动滚动到底部
        _scrollToBottomDelayed(animated: true, delayMs: 200);

        print('✅ 已从Realm加载聊天记录: $title');
      } else {
        // 如果找不到记录，创建新对话
        print('未找到聊天记录: $title，创建新对话');
        createNewConversation();
      }
    } catch (e) {
      print('从Realm加载指定聊天记录失败: $e');
      createNewConversation();
    }
  }

  /// 删除单个聊天记录
  Future<void> _deleteChatRecord(int index) async {
    try {
      // 获取要删除的聊天记录
      final chatToDelete = state.chatHistory[index];
      final sessionId = chatToDelete['id'];

      if (sessionId != null) {
        // 从Realm数据库删除聊天记录
        final success = await _realmService.deleteChatHistory(sessionId);

        if (success) {
          // 立即更新状态中的聊天历史
          state.chatHistory.removeAt(index);

          // 如果删除的是当前对话，则创建新对话
          if (state.currentConversationId == sessionId) {
            createNewConversation();
          }

          Get.snackbar("删除成功", "聊天记录已删除");
          print('✅ 聊天记录已从Realm删除: $sessionId');
        } else {
          Get.snackbar("删除失败", "无法删除聊天记录");
        }
      }
    } catch (e) {
      print('从Realm删除聊天记录失败: $e');
      Get.snackbar("删除失败", "删除聊天记录时出现错误");
    }
  }

  /// 清空所有聊天记录
  Future<void> _clearAllChatHistory() async {
    try {
      // 从Realm数据库清空所有聊天记录
      await _realmService.clearAllChatHistory();

      // 立即更新状态中的聊天历史
      state.chatHistory.clear();

      Get.snackbar("清空成功", "所有聊天记录已清空");
      print('✅ 所有聊天记录已从Realm清空');
    } catch (e) {
      print('从Realm清空聊天记录失败: $e');
      Get.snackbar("清空失败", "清空聊天记录时出现错误");
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
  exportSelectedMessages() {
    state.isExporting.value = true;
    state.exportStatus.value = ExportStatus.generating;

    // 模拟导出过程
    Future.delayed(const Duration(seconds: 2), () {
      // 设置导出信息
      // state.exportInfo.value = {
      //   'title': '对话内容导出文件',
      //   'date': DateTime.now().toString().substring(0, 16),
      //   'fileType': 'TXT文件',
      //   'size': '1.2MB',
      //   'description': '包含${state.selectedMessageIndexes.length}条对话内容，已按时间顺序整理。',
      // };

      state.exportStatus.value = ExportStatus.success;
    });
  }

  /// 取消批量选择
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
            left: position.dx - 120,
            right: 16.w,
            child: Material(
              color: Colors.transparent,
              child: Container(
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
                                    fontSize: 11,
                                    color: const Color(0xFFA6A6A6),
                                  ),
                                ),
                                const Spacer(),
                                if (model['name'] == state.selectedModel.value)
                                  Icon(
                                    Icons.check,
                                    size: 20,
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
    // TODO: 实现预览功能
    Get.snackbar('提示', '预览功能开发中');
  }

  // 下载导出文件
  void downloadExport() {
    // TODO: 实现下载功能
    Get.snackbar('提示', '文件已开始下载');
    closeExportDialog();
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
        pageSize: 100, // 获取所有模板
      );

      if (response != null && 
          response['执行结果'] == true && 
          response['返回数据'] != null) {
        
        final data = response['返回数据'];
        if (data is Map && data['data'] != null) {
          // 清空当前模板
          state.promptTemplates.clear();
          // 解析服务端返回的模板数据
          final List<dynamic> templates = data['data'];
          for (var template in templates) {
            state.promptTemplates.add({
              'uuid': template['uuid'] ?? '',
              'title': template['prompt_name'] ?? '',
              'content': template['prompt_content'] ?? '',
              'isDefault': template['is_default'] == 1,
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

      DialogUtils.hideLoading();
      if (response != null && response['执行结果'] == true) {
        ToastUtil.showShort('模板保存成功');
        // 清空输入框
        state.titleController.clear();
        state.contentController.clear();
        // 关闭表单
        state.showTemplateForm.value = false;
        // 重新加载模板列表
        await loadPromptTemplates();
      } else {
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

      DialogUtils.hideLoading();

      if (response != null && response['执行结果'] == true) {
        ToastUtil.showShort('模板更新成功');
        
        // 重新加载模板列表
        await loadPromptTemplates();
        
      } else {
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
        ToastUtil.showShort('模板删除成功');
        
        // 重新加载模板列表
        await loadPromptTemplates();
        DialogUtils.hideLoading();

      } else {
        ToastUtil.showShort('模板删除失败: ${response?['返回消息'] ?? '未知错误'}');
        DialogUtils.hideLoading();
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

      DialogUtils.hideLoading();

      if (response != null && response['执行结果'] == true) {
        ToastUtil.showShort('模板批量删除成功');
        
        // 重新加载模板列表
        await loadPromptTemplates();
        
      } else {
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
    final titleController = TextEditingController(text: template['title'] ?? '');
    final contentController = TextEditingController(text: template['content'] ?? '');

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
                  controller: titleController,
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
                  controller: contentController,
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
              titleController.dispose();
              contentController.dispose();
              Get.back();
            },
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final content = contentController.text.trim();
              
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
              
              titleController.dispose();
              contentController.dispose();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
