import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/image_resource.dart';
import 'package:safe_app/styles/text_styles.dart';
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
    return GestureDetector(
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
        body: Column(
          children: [
            // 新增的顶部操作区域
            _buildTopActionBar(),
            // 提示信息区域
            _buildNotificationBar(),
            SizedBox(height: 10.w),
            // 聊天内容区域
            Expanded(
              child: Obx(() => ListView.builder(
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
        floatingActionButton: Container(
          margin: EdgeInsets.only(bottom: 80.w, right: 16.w),
          width: 48.w,
          height: 48.w,
          child: FloatingActionButton(
            onPressed: () => logic.showAIAssistant(),
            child: Image.asset(
              FYImages.addTip,
              width: 57.w,
              height: 57.w,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    final bool isUser = message['isUser'] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.all(12.w),
              margin: EdgeInsets.only(
                  right: isUser ? 17.w : 57.w, left: !isUser ? 17.w : 57.w),
              decoration: BoxDecoration(
                gradient: !isUser
                    ? null
                    : const LinearGradient(colors: FYColors.loginBtn),
                color: isUser ? null : FYColors.color_F9F9F9,
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: Text(
                message['content'],
                style: TextStyle(
                    fontSize: 14.sp,
                    color: isUser ? FYColors.whiteColor : FYColors.color_1A1A1A,
                    fontWeight: FontWeight.w400),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
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
                maxLines: null,
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
  Widget _buildTopActionBar() {
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
              // Perplexity下拉选择器
              GestureDetector(
                onTap: () {},
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
                      Text(
                        'Perplexity',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: FYColors.color_1A1A1A,
                        ),
                      ),
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
              SizedBox(width: 8.w),
              // 删除按钮
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 24.w,
                  height: 24.w,
                  child: Image.asset(
                    FYImages.cancle_cion,
                    width: 24.w,
                    height: 24.w,
                    fit: BoxFit.contain,
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
}
