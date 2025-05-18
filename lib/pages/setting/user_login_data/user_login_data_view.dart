import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/widgets/custom_app_bar.dart';

import '../../../styles/image_resource.dart';
import 'user_login_data_logic.dart';
import 'user_login_data_state.dart';

class UserLoginDataPage extends StatelessWidget {
  UserLoginDataPage({Key? key}) : super(key: key);

  final UserLoginDataLogic logic = Get.put(UserLoginDataLogic());
  final UserLoginDataState state = Get.find<UserLoginDataLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FYColors.color_F5F5F5,
      appBar: FYAppBar(
        title: '用户登录日志',
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    Map<String, List<Map<String, dynamic>>> groupedLogs =
        logic.getGroupedLogs();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...groupedLogs.entries.map((entry) {
            return _buildDateSection(entry.key, entry.value);
          }).toList(),

          // 加载更多按钮
          GestureDetector(
            onTap: logic.loadMoreLogs,
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '加载更多记录',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: FYColors.color_3361FE,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_right,
                    size: 16.sp,
                    color: FYColors.color_3361FE,
                  ),
                ],
              ),
            ),
          ),

          // 底部留白，防止内容被遮挡
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildDateSection(String date, List<Map<String, dynamic>> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.w, top: 16.h, bottom: 8.h),
          child: Text(
            date,
            style: TextStyle(
              fontSize: 16.sp,
              color: FYColors.color_1A1A1A,
            ),
          ),
        ),
        Container(
          color: FYColors.whiteColor,
          child: Column(
            children: logs.map((log) => _buildLogItem(log)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLogItem(Map<String, dynamic> log) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          // 登录状态图标
          Image.asset(FYImages.user_avatar,
              width: 32.w, height: 32.w, fit: BoxFit.contain),
          SizedBox(width: 8.w),
          // 登录状态文本
          Text(
            log['status'],
            style: TextStyle(
              fontSize: 16.sp,
              color: log['isSuccess']
                  ? FYColors.color_1A1A1A
                  : FYColors.highRiskBorder,
            ),
          ),

          const Spacer(),
          // 登录时间
          Text(
            log['time'],
            style: TextStyle(
              fontSize: 12.sp,
              color: FYColors.color_A6A6A6,
            ),
          ),
        ],
      ),
    );
  }
}
