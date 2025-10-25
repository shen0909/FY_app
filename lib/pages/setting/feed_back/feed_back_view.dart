import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/widgets/custom_app_bar.dart';

import 'feed_back_logic.dart';

class FeedBackPage extends StatelessWidget {
  const FeedBackPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(FeedBackLogic());
    final state = Get.find<FeedBackLogic>().state;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FYAppBar(title: '用户反馈'),
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题部分
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                Text(
                  '您的反馈对我们至关重要',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: FYColors.color_1A1A1A,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  '请告诉我们您的使用体验和建议，帮助我们提升产品质量。',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: FYColors.color_A6A6A6,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // 反馈类型选择
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: InkWell(
              onTap: () => logic.showFeedbackTypeDialog(context),
              child: Container(
                height: 48.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: FYColors.color_F9F9F9,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Text(
                      '反馈类型',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: FYColors.color_666666,
                      ),
                    ),
                    const Spacer(),
                    Obx(() => Text(
                          state.selectedType.value.isEmpty
                              ? '请选择'
                              : state.selectedType.value,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: state.selectedType.value.isEmpty
                                ? FYColors.color_A6A6A6
                                : FYColors.color_1A1A1A,
                          ),
                        )),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16.sp,
                      color: FYColors.color_1A1A1A,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // 反馈详情
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              height: 80.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: FYColors.color_F9F9F9,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 16.h),
                    child: Text(
                      '反馈详情',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: FYColors.color_666666,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: TextFormField(
                      onChanged: (value) => state.feedbackDetail.value = value,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: '请详细描述您的反馈内容',
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: FYColors.color_A6A6A6,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(top: 16.h),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 48.h),

          // 提交按钮
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: GestureDetector(
              onTap: () => logic.submitFeedback(),
              child: Container(
                height: 48.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: FYColors.loginBtn,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '提交反馈',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // 反馈处理说明
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '反馈处理说明',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: FYColors.color_1A1A1A,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '我们会认真阅读每一条反馈，并优先解决用户普遍反映的问题。对于紧急问题，我们会尽快处理。感谢您的宝贵意见！',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: FYColors.color_A6A6A6,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
