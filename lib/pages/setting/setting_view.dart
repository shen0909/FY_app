import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/image_resource.dart';
import 'package:safe_app/widgets/custom_app_bar.dart';

import 'setting_logic.dart';
import 'setting_state.dart';

class SettingPage extends StatelessWidget {
  SettingPage({Key? key}) : super(key: key);

  final SettingLogic logic = Get.put(SettingLogic());
  final SettingState state = Get.find<SettingLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FYColors.whiteColor,
      appBar: FYAppBar(title: '系统设置'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfoCard(),
            _buildDivider(),
            _buildTitleSection('账户与安全', FYImages.setting_person),
            _buildSecuritySection(),
            _buildDivider(),
            _buildTitleSection('系统设置', FYImages.setting_phone),
            _buildSystemSettingSection(),
            _buildDivider(),
            _buildTitleSection('消息推送设置',  FYImages.setting_message),
            _buildNotificationSection(),
            _buildDivider(),
            _buildTitleSection('数据管理',  FYImages.setting_data),
            _buildDataSection(),
            _buildDivider(),
            _buildTitleSection('权限管理',  FYImages.setting_permission),
            _buildPermissionCard(),
            _buildDivider(),
            _buildTitleSection('统计信息', FYImages.setting_tongji),
            _buildStatisticsSection(),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      width: double.infinity,
      height: 110.h,
      color: FYColors.whiteColor,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Image.asset(
            state.userInfo['avatar'] ?? FYImages.default_avatar,
            width: 48.w,
            height: 48.w,
            fit: BoxFit.cover
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.userInfo['name'] ?? '',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: FYColors.color_1A1A1A,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '用户名：${state.userInfo['username']}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: FYColors.color_1A1A1A,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: FYColors.color_F0F5FF,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  state.userInfo['department'] ?? '',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: FYColors.color_3361FE,
                  ),
                ),
              ),
            ],
          ),
          Spacer(),
          Text(
            '版本号：${state.userInfo['version']}',
            style: TextStyle(
              fontSize: 14.sp,
              color: FYColors.color_666666,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          colors: FYColors.loginBtn,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Image.asset(
          state.userInfo['avatar'] ?? 'assets/images/default_avatar.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 30.w,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 8.h,
      color: FYColors.color_F5F5F5,
    );
  }

  Widget _buildTitleSection(String title, String imageUrl) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Row(
        children: [
          Image.asset(imageUrl,width: 24.w,height: 24.w,fit: BoxFit.contain,),
          SizedBox(width: 8.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: FYColors.color_1A1A1A,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Column(
      children: [
        _buildSwitchItem('设置划线解锁', state.isLockEnabled, logic.toggleLockScreen),
        _buildSwitchItem('指纹解锁', state.isFingerprintEnabled, logic.toggleFingerprint),
        _buildNavigationItem('用户日志', '查看您的登录日志', logic.goToUserLogs),
      ],
    );
  }

  Widget _buildSystemSettingSection() {
    return Column(
      children: [
        _buildNavigationItem('隐私保护', null, logic.goToPrivacySafe),
        _buildNavigationItem('使用教程', null, logic.goToUseTutorial),
        _buildNavigationItem('用户反馈', '提交问题或建议', logic.goToFeedback),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return Column(
      children: [
        _buildSwitchItem('风险预警信息', state.isRiskAlertEnabled, logic.toggleRiskAlert),
        _buildSwitchItem('订阅信息', state.isSubscriptionEnabled, logic.toggleSubscriptionNotification),
      ],
    );
  }

  Widget _buildDataSection() {
    return Column(
      children: [
        _buildNavigationItem('清除缓存', null, logic.clearCache),
      ],
    );
  }

  Widget _buildSwitchItem(String title, RxBool value, Function(bool) onChanged) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              color: FYColors.color_1A1A1A,
            ),
          ),
          Spacer(),
          Obx(() => Switch(
                value: value.value,
                onChanged: onChanged,
                activeColor: FYColors.color_3361FE,
                activeTrackColor: FYColors.color_F0F5FF,
              )),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(String title, String? subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                color: FYColors.color_1A1A1A,
              ),
            ),
            const Spacer(),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: FYColors.color_666666,
                ),
              ),
            SizedBox(width: 8.w),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: FYColors.color_1A1A1A,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCard() {
    return Column(
      children: [
        _buildNavigationItem('角色管理', null, logic.goToRoleManagement),
        _buildNavigationItem('权限申请审核', null, logic.goToPermissionRequests),
        Container(
          margin: EdgeInsets.all(16.w),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: FYColors.color_F9F9F9,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(FYImages.userSetting_icon,width: 32.w,height: 32.w,fit: BoxFit.contain,),
                  SizedBox(width: 8.w),
                  Text(
                    '管理员',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: FYColors.color_1A1A1A,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                '系统最高权限，操作需审核员审核',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: FYColors.color_A6A6A6,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '角色权限说明：',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: FYColors.color_A6A6A6,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xff3361FE),
                      borderRadius: BorderRadius.all(Radius.circular(50))
                    ),
                    width: 6.w,
                    height: 6.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '管理员：添加账户等操作需经审核员审核才能生效',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: FYColors.color_A6A6A6,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xff3361FE),
                      borderRadius: BorderRadius.all(Radius.circular(50))
                    ),
                    width: 6.w,
                    height: 6.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '审核员：负责审核管理员的操作，确保系统安全',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: FYColors.color_A6A6A6,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xff3361FE),
                      borderRadius: BorderRadius.all(Radius.circular(50))
                    ),
                    width: 6.w,
                    height: 6.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '普通用户：基本浏览和使用权限',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: FYColors.color_A6A6A6,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '统计信息',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: FYColors.color_1A1A1A,
                ),
              ),
              Text(
                '(仅管理员可见)',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: FYColors.color_A6A6A6,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '今日访问',
                  '${state.statistics['todayVisits']}',
                  state.statistics['visitTrend'],
                  true,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  '预警数量',
                  '${state.statistics['predictionCount']}',
                  state.statistics['predictionTrend'].abs(),
                  false,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '订阅数量',
                  '${state.statistics['subscriptionCount']}',
                  state.statistics['subscriptionTrend'],
                  true,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildRegionCard('区域统计', state.statistics['region']),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: logic.goToUserAnalysis,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '查看完整用户行为分析',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: FYColors.color_3361FE,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12.sp,
                    color: FYColors.color_3361FE,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, int trendValue, bool isPositive) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: FYColors.color_F9F9F9,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: FYColors.color_A6A6A6,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: FYColors.color_1A1A1A,
                ),
              ),
              SizedBox(width: 8.w),
              Row(
                children: [
                  Text(
                    '$trendValue%',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isPositive ? FYColors.color_07CC89 : Colors.red,
                    ),
                  ),
                  Icon(
                    isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                    size: 12.sp,
                    color: isPositive ? FYColors.color_07CC89 : Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegionCard(String title, String region) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: FYColors.color_F9F9F9,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: FYColors.color_A6A6A6,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Text(
                region,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: FYColors.color_1A1A1A,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      '查看详情',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: FYColors.color_3361FE,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12.sp,
                      color: FYColors.color_3361FE,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
