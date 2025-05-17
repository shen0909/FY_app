import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/main.dart';
import 'package:safe_app/styles/image_resource.dart';
import 'package:safe_app/widgets/widgets.dart';

import '../../widgets/custom_app_bar.dart';
import 'ai_qus_logic.dart';
import 'ai_qus_state.dart';

class AiQusPage extends StatelessWidget {
  AiQusPage({Key? key}) : super(key: key);

  final AiQusLogic logic = Get.put(AiQusLogic());
  final AiQusState state = Get.find<AiQusLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FYAppBar(
        title: 'AI智能问答',
        actions: [
          GestureDetector(
              onTap: () => logic.showChatHistory(),
              child: Image.asset(FYImages.addAI,width: 24.w,height: 24.w,fit: BoxFit.contain)),
          SizedBox(width: 16.w),
          GestureDetector(
              onTap: () => logic.showChatHistory(),
              child: Image.asset(FYImages.history_icon,width: 24.w,height: 24.w,fit: BoxFit.contain)),
          SizedBox(width: 16.w),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final message = state.messages[index];
                return _buildMessageItem(message);
              },
            )),
          ),
          _buildInputArea(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => logic.showAIAssistant(),
        child: const Icon(Icons.lightbulb_outline),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    final bool isUser = message['isUser'] ?? false;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) 
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.smart_toy, color: Colors.blue),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser && message['title'] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        message['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    message['content'],
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isUser) 
            const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () => logic.showPromptTemplates(),
          ),
          Expanded(
            child: TextField(
              controller: state.messageController,
              decoration: const InputDecoration(
                hintText: '输入您的问题...',
                border: InputBorder.none,
              ),
              maxLines: null,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () => logic.sendMessage(),
          ),
        ],
      ),
    );
  }
}
