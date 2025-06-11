import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:safe_app/styles/colors.dart';

class UnreadMessageDialog extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  final Function()? onClose;

  const UnreadMessageDialog({
    Key? key,
    required this.messages,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogHeight = screenHeight * 0.6;
    
    return Container(
      height: dialogHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 弹窗标题栏
          _buildDialogHeader(),
          // 消息列表
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 20.h),
              itemCount: messages.length,
              itemBuilder: (context, index) => _buildMessageItem(messages[index]),
            ),
          ),
        ],
      ),
    );
  }

  // 弹窗标题栏
  Widget _buildDialogHeader() {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '未读消息',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: FYColors.color_1A1A1A,
              fontFamily: 'AlibabaPuHuiTi',
            ),
          ),
          // 关闭按钮
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 24.w,
              height: 24.h,
              alignment: Alignment.center,
              child: Icon(
                Icons.close,
                size: 20.sp,
                color: FYColors.color_1A1A1A,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 消息项
  Widget _buildMessageItem(Map<String, dynamic> message) {
    return Container(
      margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 10.h, top: message == messages.first ? 0 : 0),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: FYColors.color_F9F9F9,
        borderRadius: BorderRadius.circular(8.r),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 消息标题
              Expanded(
                child: Text(
                  message['title'] ?? '',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: FYColors.color_1A1A1A,
                    fontFamily: 'AlibabaPuHuiTi',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              // 未读标签
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: FYColors.color_FFD8D2,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '未读',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: FYColors.color_FF2A08,
                    fontWeight: FontWeight.w400,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // 底部信息
          Row(
            children: [
              // 日期
              Text(
                message['date'] ?? '',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: FYColors.color_A6A6A6,
                ),
              ),
              Spacer(),
              // 来源/公司
              Text(
                message['company'] ?? '',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: FYColors.color_A6A6A6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 