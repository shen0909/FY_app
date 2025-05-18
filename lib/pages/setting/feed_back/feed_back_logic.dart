import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../styles/colors.dart';
import 'feed_back_state.dart';

class FeedBackLogic extends GetxController {
  final FeedBackState state = FeedBackState();
  // 当前选择的索引
  final RxInt selectedIndex = RxInt(0);

  // 显示反馈类型选择弹窗
  void showFeedbackTypeDialog(BuildContext context) {
    // 先找到当前已选类型的索引，如果没有选择则默认为0
    if (state.selectedType.isNotEmpty) {
      int index = state.feedbackTypes.indexOf(state.selectedType.value);
      if (index != -1) {
        selectedIndex.value = index;
      }
    }
    
    Get.bottomSheet(
      _buildFeedbackTypeSheet(context),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  // 构建反馈类型选择底部弹窗
  Widget _buildFeedbackTypeSheet(BuildContext context) {
    return Container(
      height: 338.w,
      decoration: BoxDecoration(
        color: FYColors.whiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: FYColors.whiteColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Text(
                    '取消',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: FYColors.color_1A1A1A,
                    ),
                  ),
                ),
                Text(
                  '反馈类型',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: FYColors.color_1A1A1A,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // 确认选择
                    state.selectedType.value = state.feedbackTypes[selectedIndex.value];
                    Get.back();
                  },
                  child: Text(
                    '确定',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: FYColors.color_3361FE,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 类型滚轮选择器
          Expanded(
            child: _buildTypeList(context),
          ),

        ],
      ),
    );
  }

  // 构建滚轮选择器
  Widget _buildTypeList(BuildContext context) {
    return Stack(
      children: [
        // 中间选中区域高亮
        Positioned.fill(
          child: Center(
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: FYColors.color_F9F9F9,
                border: Border(
                  top: BorderSide(color: FYColors.color_E6E6E6, width: 1),
                  bottom: BorderSide(color: FYColors.color_E6E6E6, width: 1),
                ),
              ),
            ),
          ),
        ),
        // 滚轮选择器
        Obx(() => ListWheelScrollView.useDelegate(
          itemExtent: 48.h, // 每项高度
          perspective: 0.005, // 透视效果
          diameterRatio: 1.5, // 直径比
          physics: const FixedExtentScrollPhysics(), // 固定距离滚动物理效果
          controller: FixedExtentScrollController(initialItem: selectedIndex.value),
          onSelectedItemChanged: (index) {
            selectedIndex.value = index;
          },
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: state.feedbackTypes.length,
            builder: (context, index) {
              return Container(
                height: 48.h,
                alignment: Alignment.center,
                child: Text(
                  state.feedbackTypes[index],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: index == selectedIndex.value ? FontWeight.bold : FontWeight.normal,
                    color: index == selectedIndex.value 
                        ? FYColors.color_1A1A1A 
                        : FYColors.color_666666,
                  ),
                ),
              );
            },
          ),
        )),
      ],
    );
  }

  // 提交反馈
  void submitFeedback() {
    if (state.selectedType.isEmpty) {
      Get.snackbar('提示', '请选择反馈类型');
      return;
    }

    if (state.feedbackDetail.isEmpty) {
      Get.snackbar('提示', '请填写反馈详情');
      return;
    }

    // TODO: 实现反馈提交逻辑
    Get.snackbar('提示', '反馈提交成功');
    Get.back(); // 返回上一页
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
