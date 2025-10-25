import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/image_resource.dart';
import 'package:safe_app/widgets/custom_app_bar.dart';
import '../../../widgets/markdown_message_widget.dart';
import 'privacy_safe_logic.dart';
import 'privacy_safe_state.dart';

class PrivacySafePage extends StatelessWidget {
  PrivacySafePage({Key? key}) : super(key: key);

  final PrivacySafeLogic logic = Get.put(PrivacySafeLogic());
  final PrivacySafeState state = Get.find<PrivacySafeLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FYAppBar(title: '隐私保护'),
      body: SingleChildScrollView(
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPrivacyHeader(),
              SizedBox(height: 24.h),
              MarkdownMessageWidget(
                content: state.privacyContent.value,
                isUser: false,
                isShowName: false,
                isAI: false
              )
            ],
          );
        }),
      ),
    );
  }

  // 隐私保护头部
  Widget _buildPrivacyHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 24.h),
          Image.asset(FYImages.privacy_safe, width: 56.w, height: 56.w, fit: BoxFit.contain),
          SizedBox(height: 8.h),
          Text(
            '隐私政策声明',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: FYColors.color_1A1A1A,
              height: 1.5,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '上次更新：${state.lastUpdated}',
            style: TextStyle(
              fontSize: 14.sp,
              color: FYColors.color_A6A6A6,
            ),
          ),
        ],
      ),
    );
  }

  // 隐私说明
  Widget _buildPrivacyDescription() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        state.privacyVideoDescription,
        style: TextStyle(
          fontSize: 14.sp,
          color: FYColors.color_666666,
          height: 1.5,
        ),
      ),
    );
  }
  
  // 信息收集部分
  Widget _buildInfoCollectionSection() {
    return _buildInfoSection(
      title: '信息收集',
      items: state.collectedInfoItems,
    );
  }

  // 信息使用部分
  Widget _buildInfoUsageSection() {
    return _buildInfoSection(
      title: '信息使用',
      items: state.infoUsageItems,
    );
  }

  // 信息保护部分
  Widget _buildInfoProtectionSection() {
    return _buildInfoSection(
      title: '信息保护',
      items: state.infoProtectionItems,
    );
  }

  // 信息存储部分
  Widget _buildInfoStorageSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '信息存储',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: FYColors.color_1A1A1A,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            state.infoStorageDescription,
            style: TextStyle(
              fontSize: 14.sp,
              color: FYColors.color_A6A6A6,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // 通用信息部分构建
  Widget _buildInfoSection(
      {required String title, required List<String> items}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: FYColors.color_1A1A1A,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '我们${title == '信息收集' ? '收集的信息包括但不限于：' : title ==
                '信息使用'
                ? '使用收集的信息用于：'
                : '采取严格的技术和管理措施保护您的信息安全：'}',
            style: TextStyle(
              fontSize: 14.sp,
              color: FYColors.color_A6A6A6,
              height: 1.5,
            ),
          ),
          SizedBox(height: 8.h),
          ...items.map((item) => _buildBulletItem(item)).toList(),
        ],
      ),
    );
  }

  // 构建带圆点的项目
  Widget _buildBulletItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 7.h, right: 8.w),
            width: 6.w,
            height: 6.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: FYColors.color_3361FE,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: FYColors.color_A6A6A6,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
