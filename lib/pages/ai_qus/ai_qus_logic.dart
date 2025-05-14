import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ai_qus_state.dart';

class AiQusLogic extends GetxController {
  final AiQusState state = AiQusState();

  @override
  void onReady() {
    super.onReady();
    // 加载数据
    loadConversations();
  }

  @override
  void onClose() {
    // 释放资源
    state.messageController.dispose();
    super.onClose();
  }
  
  // 发送消息
  void sendMessage() {
    final text = state.messageController.text.trim();
    if (text.isEmpty) return;
    
    // 添加用户消息
    state.messages.add({
      'isUser': true,
      'content': text,
    });
    
    // 清空输入框
    state.messageController.clear();
    
    // 模拟发送请求
    state.isLoading.value = true;
    
    // 模拟接收响应
    Future.delayed(const Duration(seconds: 1), () {
      state.isLoading.value = false;
      
      // 模拟AI回复
      if (text.contains('行业') || text.contains('碳排放')) {
        state.messages.add({
          'isUser': false,
          'title': '行业的影响',
          'content': '''的影响主要表现在以下几个方面：
          
1. 成本上升: 钢铁和铝材等船舶制造原材料的关税增加，导致全球造船成本上升10-15%。特别是使用美国进口钢材的亚洲造船厂受影响最为明显。

2. 贸易流量变化：关税政策导致...''',
        });
      } else {
        state.messages.add({
          'isUser': false,
          'content': '您好，我已收到您的问题。请问有什么可以帮到您的？',
        });
      }
    });
  }
  
  // 显示聊天历史
  void showChatHistory() {
    Get.bottomSheet(
      Container(
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
                    '聊天历史',
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
            Expanded(
              child: ListView.builder(
                itemCount: state.chatHistory.length,
                itemBuilder: (context, index) {
                  final history = state.chatHistory[index];
                  return ListTile(
                    leading: const Icon(Icons.chat_bubble_outline),
                    title: Text(history['title']),
                    subtitle: Text(history['time']),
                    trailing: const Icon(Icons.delete_outline),
                    onTap: () {
                      // 加载对话
                      loadConversation(history['title']);
                      Get.back();
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  createNewConversation();
                },
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: const Text('删除所有历史'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade100,
                  foregroundColor: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }
  
  // 显示提示词模板
  void showPromptTemplates() {
    Get.bottomSheet(
      Container(
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
              child: ListView.builder(
                itemCount: state.promptTemplates.length,
                itemBuilder: (context, index) {
                  final template = state.promptTemplates[index];
                  return ListTile(
                    title: Text(template['title']),
                    subtitle: Text(
                      template['content'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
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
      ),
      isScrollControlled: true,
      enableDrag: true,
    );
  }
  
  // 创建新的对话
  void createNewConversation() {
    state.messages.clear();
    state.messages.add({
      'isUser': false,
      'content': 'Hi~ 我是您身边的智能助手，可以为您答疑解惑、精读文档、尽情创作，让科技助你轻松工作，多点生活',
    });
    state.currentConversationId = null;
  }
  
  // 加载对话
  void loadConversation(String title) {
    // 模拟加载对话
    state.messages.clear();
    
    if (title == '行业分析报告') {
      state.messages.addAll([
        {
          'isUser': false,
          'content': 'Hi~ 我是您身边的智能助手，有什么可以帮助您？',
        },
        {
          'isUser': true,
          'content': '分析船舶行业碳排放政策影响',
        },
        {
          'isUser': false,
          'title': '行业的影响',
          'content': '''的影响主要表现在以下几个方面：
          
1. 成本上升: 钢铁和铝材等船舶制造原材料的关税增加，导致全球造船成本上升10-15%。特别是使用美国进口钢材的亚洲造船厂受影响最为明显。

2. 贸易流量变化：关税政策导致...''',
        },
      ]);
    } else {
      state.messages.addAll([
        {
          'isUser': false,
          'content': 'Hi~ 我是您身边的智能助手，有什么可以帮助您？',
        },
        {
          'isUser': true,
          'content': title,
        },
        {
          'isUser': false,
          'content': '已收到您的问题，正在为您分析...',
        },
      ]);
    }
    
    state.currentConversationId = title;
  }
  
  // 加载所有对话
  void loadConversations() {
    // 模拟从服务器加载对话列表
    // 实际项目中应该从API获取
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
}
