import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_app/widgets/unread_message_dialog.dart';

import 'risk_state.dart';

class RiskLogic extends GetxController {
  final RiskState state = RiskState();

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  // 切换单位
  changeUnit(int index) {
    state.chooseUint.value = index;
  }
  
  // 显示未读消息弹窗
  void showMessageDialog() {
    Get.bottomSheet(
      UnreadMessageDialog(
        messages: state.unreadMessages,
        onClose: () => Get.back(),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }
  
  // 关闭未读消息弹窗
  void closeMessageDialog() {
    Get.back();
  }
  
  // 将消息标记为已读
  void markMessageAsRead(int index) {
    if (index >= 0 && index < state.unreadMessages.length) {
      final updatedMessage = Map<String, dynamic>.from(state.unreadMessages[index]);
      updatedMessage['isRead'] = true;
      state.unreadMessages[index] = updatedMessage;
    }
  }
  
  // 将所有消息标记为已读
  void markAllMessagesAsRead() {
    final updatedMessages = state.unreadMessages.map((message) {
      final updatedMessage = Map<String, dynamic>.from(message);
      updatedMessage['isRead'] = true;
      return updatedMessage;
    }).toList();
    
    state.unreadMessages.assignAll(updatedMessages);
  }
}
