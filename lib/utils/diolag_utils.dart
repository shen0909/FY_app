import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class FYDialogUtils {
  static void showBottomSheet(Widget child,{bool hasMaxHeightConstraint = false,bool hasMinHeightConstraint = false,double? heightMinFactor,double? heightMaxFactor,}) {
    showModalBottomSheet(
      context: Get.context!,
      constraints: BoxConstraints(
        // 如果限制底部弹窗高度，默认最大高度为高度的一半
        maxHeight: hasMaxHeightConstraint
            ? MediaQuery.of(Get.context!).size.height * (heightMaxFactor ?? 0.5)
            : double.infinity,
        // minHeight: hasMinHeightConstraint
        //     ? MediaQuery.of(Get.context!).size.height * (heightMinFactor ?? 0.5)
        //     : 0.0,
        maxWidth: MediaQuery.of(Get.context!).size.width, // 强制宽度为屏幕宽度
        minWidth: MediaQuery.of(Get.context!).size.width, // 防止最小宽度限制
      ),
      builder: (context) => child,
      isScrollControlled: true,
      backgroundColor: Colors.black54,
    );
  }
}
