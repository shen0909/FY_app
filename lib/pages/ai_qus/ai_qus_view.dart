import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/image_resource.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/markdown_message_widget.dart';
import 'ai_qus_logic.dart';
import 'ai_qus_state.dart';
import 'dart:async';

class AiQusPage extends StatelessWidget {
  AiQusPage({Key? key}) : super(key: key);

  final AiQusLogic logic = Get.put(AiQusLogic());
  final AiQusState state = Get.find<AiQusLogic>().state;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => logic.canPopFunction(didPop),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: FYColors.whiteColor,
          appBar: FYAppBar(
            title: 'AI智能问答',
            actions: [
              GestureDetector(
                onTap: () => logic.createNewConversation(),
                child: Container(
                  margin: EdgeInsets.only(right: 8.w),
                  child: Image.asset(FYImages.addAI,
                      width: 24.w, height: 24.w, fit: BoxFit.contain),
                ),
              ),
              GestureDetector(
                onTap: () => logic.showChatHistory(),
                child: Container(
                  margin: EdgeInsets.only(right: 16.w),
                  child: Image.asset(FYImages.history_icon,
                      width: 24.w, height: 24.w, fit: BoxFit.contain),
                ),
              ),
            ],
          ),
          body: NotificationListener<SizeChangedLayoutNotification>(
            onNotification: (notification) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                logic.updateInputBoxHeightOptimized();
              });
              return false;
            },
            child: SizeChangedLayoutNotifier(
              child: Obx(() {
                // 显示初始化加载状态
                if (state.isInitializing.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                return Stack(
                children: [
                  Column(
                    children: [
                      // 新增的顶部操作区域
                      _buildTopActionBar(context),
                      // 提示信息区域
                      _buildNotificationBar(),
                      SizedBox(height: 10.w),
                      // 聊天内容区域
                      Expanded(
                          child: Stack(
                            children: [
                              Obx(() => ListView.builder(
                              controller: state.scrollController,
                              padding: EdgeInsets.only(bottom: state.isBatchCheck.value ? 105.w : 16.w),
                              itemCount: state.messages.length,
                              itemBuilder: (context, index) {
                                final message = state.messages[index];
                                return _buildMessageItem(message, index);
                              },
                            )),
                              // 显示历史消息加载状态
                              if (state.isLoadingHistory.value)
                                Container(
                                  color: Colors.white.withOpacity(0.7),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                            ],
                          ),
                      ),
                      Obx(() => state.isBatchCheck.value
                          ? const SizedBox()
                          : _buildInputArea()),
                    ],
                  ),
                  // 提示词按钮 - 浮动在聊天内容上方
                  Obx(() => state.isBatchCheck.value 
                      ? const SizedBox()
                      : Positioned(
                          bottom: state.inputBoxHeight.value + 20.w,
                          right: 16.w,
                          child: GestureDetector(
                            onTap: () => logic.showTipTemplateDialog(context),
                            child: Image.asset(
                              FYImages.addTip,
                              width: 57.w,
                              height: 57.w,
                              fit: BoxFit.contain,
                            ),
                          ),
                        )),
                  // 底部操作栏 - 批量选择模式
                  Obx(() => state.isBatchCheck.value 
                      ? Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: _buildBatchSelectionBar(),
                        )
                      : const SizedBox()),
                  // 导出弹窗
                  _buildExportDialog(),
                ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message, int index) {
    final bool isUser = message['isUser'] ?? false;
    final bool isLoading = message['isLoading'] ?? false;
    final bool isStreaming = message['isStreaming'] ?? false;
    final bool isError = message['isError'] ?? false;
    final String content = message['content']?.toString() ?? '';
    final bool isMarkdown = message['isMarkdown'] ?? !isUser; // AI消息默认使用Markdown

    return Obx(() => Container(
      margin: EdgeInsets.only(bottom: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // 批量选择模式下显示选择框
          if (state.isBatchCheck.value && !isUser) // 只为AI消息添加选择框
            GestureDetector(
              onTap: () => logic.toggleMessageSelection(index),
              child: Container(
                margin: EdgeInsets.only(left: 16.w, top: 8.w),
                child: Image.asset(
                  state.selectedMessageIndexes.contains(index)
                    ? FYImages.check_icon
                    : FYImages.uncheck_icon,
                  width: 24.w,
                  height: 24.w,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          Flexible(
            child: GestureDetector(
              onTap: () => logic.copyContent(content),
              child: Container(
                margin: EdgeInsets.only(
                    right: isUser ? 8.w : 57.w,
                    left: !isUser ? (state.isBatchCheck.value ? 8.w : 17.w) : 57.w),
                child: isMarkdown && !isUser
                    ? MarkdownMessageWidget(
                        content: message['content']?.toString() ?? '',
                        isUser: isUser,
                        isStreaming: isStreaming,
                      )
                    : Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          gradient: !isUser
                              ? null
                              : const LinearGradient(colors: FYColors.loginBtn),
                          color: isUser ? null : (isError ? const Color(0xFFFFECE9) : FYColors.color_F9F9F9),
                          borderRadius: BorderRadius.circular(8.w),
                          border: isError ? Border.all(color: const Color(0xFFFF6850), width: 1) : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 消息内容
                            if (message['content'].toString().isNotEmpty)
                              Text(
                                message['content'],
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: isUser ? FYColors.whiteColor : (isError ? const Color(0xFFFF3B30) : FYColors.color_1A1A1A),
                                    fontWeight: FontWeight.w400),
                              ),
                            // Loading状态指示器
                            if (isLoading && !isUser)
                              SizedBox(
                                width: 16.w,
                                height: 16.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(FYColors.color_3361FE),
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          if (state.isBatchCheck.value && isUser) // 只为AI消息添加选择框
            GestureDetector(
              onTap: () => logic.toggleMessageSelection(index),
              child: Container(
                margin: EdgeInsets.only(right: 16.w, top: 8.w),
                child: Image.asset(
                  state.selectedMessageIndexes.contains(index)
                      ? FYImages.check_icon
                      : FYImages.uncheck_icon,
                  width: 24.w,
                  height: 24.w,
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    ));
  }

  // 批量选择模式下的底部操作栏
  Widget _buildBatchSelectionBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w,vertical: 16.w),
      decoration: BoxDecoration(
        color: FYColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 选择信息
          Row(
            children: [
              Obx(() => state.selectedMessageIndexes.isNotEmpty
                  ? Image.asset(
                      FYImages.check_icon,
                      width: 24.w,
                      height: 24.w,
                      fit: BoxFit.contain,
                    )
                  : Image.asset(
                      FYImages.uncheck_icon,
                      width: 24.w,
                      height: 24.w,
                      fit: BoxFit.contain,
                    )),
              SizedBox(width: 8.w),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() => RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: state.selectedMessageIndexes.length.toString(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: FYColors.color_3361FE,
                          ),
                        ),
                        TextSpan(
                          text: " 条内容已选择",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: FYColors.color_1A1A1A,
                          ),
                        ),
                      ],
                    ),
                  )),
                  Text(
                    "可导出问题和回答",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: FYColors.color_A6A6A6,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 导出按钮
                  Obx(() => GestureDetector(
                    onTap: state.selectedMessageIndexes.isNotEmpty
                        ? () => logic.exportSelectedMessages()
                        : null,
                    child: Container(
                      width: 96.w,
                      height: 40.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: state.selectedMessageIndexes.isNotEmpty
                            ? const LinearGradient(
                          colors: [Color(0xFF345DFF), Color(0xFF2F89F8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                            : null,
                        color: state.selectedMessageIndexes.isEmpty
                            ? FYColors.color_EFEFEF
                            : null,
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      child: Text(
                        "导出文本",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: state.selectedMessageIndexes.isNotEmpty
                              ? FYColors.whiteColor
                              : FYColors.color_A6A6A6,
                        ),
                      ),
                    ),
                  )),
                  // 取消按钮
                  GestureDetector(
                    onTap: () => logic.cancelBatchSelection(),
                    child: Container(
                      width: 96.w,
                      height: 40.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: FYColors.color_F9F9F9,
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      child: Text(
                        "取消",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: FYColors.color_1A1A1A,
                        ),
                      ),
                    ),
                  ),
                ],
              )

            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      key: state.inputBoxKey,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
      decoration: BoxDecoration(
        color: FYColors.whiteColor,
        border: Border(
          top: BorderSide(color: FYColors.color_E6E6E6, width: 1.w),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: BoxConstraints(minHeight: 36.w),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
              decoration: BoxDecoration(
                color: FYColors.color_F5F5F5,
                borderRadius: BorderRadius.circular(4.w),
              ),
              alignment: Alignment.center,
              child: TextField(
                controller: state.messageController,
                decoration: InputDecoration.collapsed(
                  hintText: '输入您的问题...',
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: FYColors.color_A6A6A6,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: FYColors.color_1A1A1A,
                ),
                maxLines: 4,
                minLines: 1,
                keyboardType: TextInputType.multiline,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          GestureDetector(
              onTap: () => logic.sendMessage(),
              child: Image.asset(FYImages.sendIcon,
                  width: 36.w, height: 36.w, fit: BoxFit.contain)),
        ],
      ),
    );
  }

  // 顶部操作区域
  Widget _buildTopActionBar(BuildContext context) {
    final GlobalKey modelKey = GlobalKey();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
      decoration: BoxDecoration(
        color: FYColors.whiteColor,
        border: Border(
          bottom: BorderSide(
            color: FYColors.color_E6E6E6,
            width: 1.w,
          ),
        ),
      ),
      child: Row(
        children: [
          // 新的对话文本
          Text(
            '新的对话',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: FYColors.color_1A1A1A,
            ),
          ),
          const Spacer(),
          // 右侧操作按钮组
          Row(
            children: [
              // 批量选择按钮
              batchCheckWidget(),
              SizedBox(width: 10.w),
              // 模型选择按钮
              GestureDetector(
                key: modelKey,
                onTap: () => logic.showModelSelectionDialog(context, modelKey),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 9.w),
                  decoration: BoxDecoration(
                    color: FYColors.color_F5F5F5,
                    borderRadius: BorderRadius.circular(20.w),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        FYImages.robot,
                        width: 16.w,
                        height: 16.w,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 8.w),
                      Obx(() => Text(
                        "FY+AI(${state.selectedModel.value.substring(0, 1)})",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: FYColors.color_1A1A1A,
                        ),
                      )),
                      SizedBox(width: 8.w),
                      Image.asset(
                        FYImages.down_icon,
                        height: 10.w,
                        width: 5.w,
                        fit: BoxFit.contain,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 提示信息区域
  Widget _buildNotificationBar() {
    return Container(
      width: double.infinity,
      height: 32.w,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      color: const Color(0xFFEAF1FF),
      child: Row(
        children: [
          Image.asset(
            FYImages.aiTip,
            width: 20.w,
            height: 20.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 8.w),
          Text(
            '提示：聊天记录保留7天时间',
            style: TextStyle(
              fontSize: 12.sp,
              color: FYColors.color_3361FE,
            ),
          ),
        ],
      ),
    );
  }

  Widget batchCheckWidget() {
    return Obx(() {
      return state.isBatchCheck.value
          ? GestureDetector(
              onTap: () => logic.batchCheck(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 8.w),
                decoration: BoxDecoration(
                    color: FYColors.color_F0F5FF,
                    borderRadius: BorderRadius.circular(20.w),
                    border: Border.all(color: FYColors.color_F0F5FF, width: 1.w)),
                child: Row(
                  children: [
                    Image.asset(
                      FYImages.choose_icon,
                      width: 16.w,
                      height: 16.w,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '批量选择',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: FYColors.color_3361FE,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : GestureDetector(
              onTap: () => logic.batchCheck(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 8.w),
                decoration: BoxDecoration(
                    color: FYColors.whiteColor,
                    borderRadius: BorderRadius.circular(20.w),
                    border:
                        Border.all(color: FYColors.color_EFEFEF, width: 1.w)),
                child: Row(
                  children: [
                    Image.asset(
                      FYImages.unchoose_icon,
                      width: 16.w,
                      height: 16.w,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '批量选择',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: FYColors.color_666666,
                      ),
                    ),
                  ],
                ),
              ),
            );
    });
  }

  // 导出弹窗
  Widget _buildExportDialog() {
    return Obx(() {
      if (!state.isExporting.value) {
        return const SizedBox.shrink();
      }

      return Stack(
        children: [
          // 半透明背景
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          // 弹窗内容
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Material(
                color: FYColors.whiteColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16.r),
                  topLeft: Radius.circular(16.r)
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 顶部标题栏
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.withOpacity(0.1),
                            width: 1.h,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '导出对话内容',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => logic.closeExportDialog(),
                            child: Icon(
                              Icons.close,
                              size: 24.w,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 根据状态显示不同内容
                    if (state.exportStatus.value == ExportStatus.generating)
                      _buildGeneratingContent()
                    else if (state.exportStatus.value == ExportStatus.success)
                      _buildSuccessContent(),
                    SizedBox(height: MediaQuery.of(Get.context!).padding.bottom),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  // 生成中的内容
  Widget _buildGeneratingContent() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 60.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 加载动画
          SizedBox(
            width: 64.w,
            height: 64.h,
            child: CircularProgressIndicator(
              color: Color(0xFF3361FE),
              strokeWidth: 3.w,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '正在导出内容...',
            style: TextStyle(
              fontSize: 14.sp,
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '正在处理所选对话内容并整合为文本文件',
            style: TextStyle(
              fontSize: 12.sp,
              color: Color(0xFF666666),
            ),
          ),
          SizedBox(height: 60.h),
        ],
      ),
    );
  }

  // 导出成功的内容
  Widget _buildSuccessContent() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 40.h, 16.w, 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 成功图标
          Container(
            width: 64.w,
            height: 64.h,
            decoration: BoxDecoration(
              color: Color(0xFF3361FE),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 40.w,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '已成功导出所选问答内容',
            style: TextStyle(
              fontSize: 14.sp,
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 4.h),
          Obx(() => Text(
            '文件已保存至: ${state.exportInfo['saveLocation'] ?? '应用文档目录'}',
            style: TextStyle(
              fontSize: 12.sp,
              color: Color(0xFF666666),
            ),
          )),
          SizedBox(height: 24.h),

          // 文件信息卡片
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: Colors.grey.withOpacity(0.1),
                width: 1.w,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.exportInfo.value['title'] ?? '导出文件',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14.sp,
                      color: Color(0xFF666666),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      state.exportInfo.value['date'] ?? '',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Color(0xFFA6A6A6),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Icon(
                      Icons.description,
                      size: 14.sp,
                      color: Color(0xFF666666),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      state.exportInfo.value['fileType'] ?? '',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Color(0xFFA6A6A6),
                      ),
                    ),
                    Spacer(),
                    Text(
                      state.exportInfo.value['size'] ?? '',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Color(0xFFA6A6A6),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  state.exportInfo.value['description'] ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          
          // 操作按钮
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => logic.previewExport(),
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF345DFF), Color(0xFF2F89F8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '预览内容',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => logic.downloadExport(),
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1.w,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '分享/保存',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Color(0xFF1A1A1A),
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
  }
}
