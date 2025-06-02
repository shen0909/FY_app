import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/image_resource.dart';
import 'package:side_sheet/side_sheet.dart';

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
    state.titleController.dispose();
    state.contentController.dispose();
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
    // 首先确保当前焦点被移除
    if (Get.context != null) {
      FocusScope.of(Get.context!).unfocus();
    }
    SideSheet.left(
      context: Get.context!,
      width: MediaQuery.of(Get.context!).size.width * 0.8,
      // 内容部分
      body: SafeArea(
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
                child: ListView.separated(
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
                                '确定要清空当前对话吗？',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  color: const Color(0xFF1A1A1A),
                                  fontWeight: FontWeight.w400,
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
                                                color: const Color(0xFFEFEFEF),
                                                width: 1.w,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            '取消',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w400,
                                              color: const Color(0xFF1A1A1A),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // 确定按钮
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          // 确认后删除记录
                                          state.chatHistory.removeAt(index);
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          height: 44.w,
                                          alignment: Alignment.center,
                                          child: Text(
                                            '确定',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w400,
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
                        child: Image.asset(
                          FYImages.cancle_cion,
                          width: 24.w,
                          height: 24.w,
                          fit: BoxFit.contain,
                        ),
                      ),
                      onTap: () {
                        // 加载对话
                        loadConversation(history['title']);
                        Navigator.pop(Get.context!);
                      },
                    );
                  },
                ),
              ),
              // 底部按钮
              Container(
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
                                          color: const Color(0xFFEFEFEF),
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
                                  onTap: () {
                                    // 确认后执行操作
                                    Navigator.pop(context);
                                    Navigator.pop(Get.context!);
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
      ),
    ).then((_) {
      // 确保在弹窗关闭后移除焦点
      if (Get.context != null) {
        FocusScope.of(Get.context!).unfocus();
      }
    });
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

    // 状态控制
    bool showTemplateForm = false;

    // 更新状态UI，添加半透明蒙层
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.w),
                topRight: Radius.circular(16.w),
              ),
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
                      bottom: BorderSide(
                          color: const Color(0xFFEFEFEF), width: 1.w),
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
                    setState(() {
                      showTemplateForm = !showTemplateForm;
                    });
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
                    child: Row(
                      children: [
                        Container(
                            width: 24.w,
                            height: 24.w,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
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
                        Spacer(),
                        Icon(
                          showTemplateForm
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
                if (showTemplateForm)
                  Container(
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
                            // 添加模板到列表
                            if (state.titleController.text.isNotEmpty &&
                                state.contentController.text.isNotEmpty) {
                              state.promptTemplates.add({
                                'title': state.titleController.text,
                                'content': state.contentController.text,
                              });
                              // 清空输入框
                              state.titleController.clear();
                              state.contentController.clear();
                              // 收起表单
                              setState(() {
                                showTemplateForm = false;
                              });
                            }
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

                // 分割线
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                  height: 1.w,
                  color: const Color(0xFFD8D8D8),
                ),

                // 我的模板标题
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
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
                              state.messageController.text =
                                  template['content'];
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
                                  Text(
                                    template['title'],
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  SizedBox(height: 8.w),
                                  Text(
                                    template['content'],
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color(0xFFA6A6A6),
                                    ),
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
          );
        },
      ),
    );
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
                                SizedBox(
                                  width: 80.w,
                                  child: Text(
                                    model['name'].toString(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                  ),
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
    Overlay.of(context).insert(overlayEntry);
  }

  // 隐藏模型选择弹窗
  void hideModelSelection() {
    state.modelOverlayEntry.value?.remove();
    state.modelOverlayEntry.value = null;
  }

  // 选择模型
  void selectModel(String modelName) {
    state.selectedModel.value = modelName;
    hideModelSelection();
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
}
