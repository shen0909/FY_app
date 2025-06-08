import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/image_resource.dart';
import 'package:safe_app/widgets/custom_app_bar.dart';

import 'use_tutorial_logic.dart';
import 'use_tutorial_state.dart';

class UseTutorialPage extends StatelessWidget {
  UseTutorialPage({Key? key}) : super(key: key);

  final UseTutorialLogic logic = Get.put(UseTutorialLogic());
  final UseTutorialState state = Get.find<UseTutorialLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FYColors.color_F5F5F5,
      appBar: FYAppBar(title: '使用教程'),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Obx(() {
                final tabIndex = state.selectedTabIndex.value;
                if (tabIndex == 0) {
                  return _buildBasicFunctions();
                } else if (tabIndex == 1) {
                  return _buildAdvancedFunctions();
                } else {
                  return _buildVideoTutorials();
                }
              }),
            ),
          ),
        ],
      ),
    );
  }

  // 顶部标签栏
  Widget _buildTabBar() {
    return Container(
      height: 48.h,
      color: FYColors.whiteColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabItem('基础功能', 0),
          _buildTabItem('高级功能', 1),
          _buildTabItem('视频教程', 2),
        ],
      ),
    );
  }

  // 单个标签项
  Widget _buildTabItem(String title, int index) {
    return Obx(() {
      bool isSelected = state.selectedTabIndex.value == index;
      return GestureDetector(
        onTap: () => logic.switchTab(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                color: isSelected ? FYColors.color_3361FE : FYColors.color_A6A6A6,
              ),
            ),
            SizedBox(height: 5.h),
            if (isSelected)
              Container(
                width: 80.w,
                height: 2.h,
                decoration: BoxDecoration(
                  color: FYColors.color_3361FE,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(1.r),
                    topRight: Radius.circular(1.r),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  // 基础功能教程
  Widget _buildBasicFunctions() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          ...state.basicTutorials.map((tutorial) {
            return _buildTutorialCard(tutorial);
          }).toList(),
          SizedBox(height: 20.h),
          _buildFeedbackSection(),
        ],
      ),
    );
  }

  // 高级功能教程
  Widget _buildAdvancedFunctions() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          ...state.advancedTutorials.map((tutorial) {
            return _buildAdvancedTutorialCard(tutorial);
          }).toList(),
          SizedBox(height: 20.h),
          _buildFeedbackSection(),
        ],
      ),
    );
  }

  // 视频教程
  Widget _buildVideoTutorials() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          ...state.videoTutorials.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> tutorial = entry.value;
            return _buildVideoCard(tutorial, index);
          }).toList(),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Text(
              '如需进一步帮助，请联系技术支持部门',
              style: TextStyle(
                fontSize: 14.sp,
                color: FYColors.color_A6A6A6,
              ),
            ),
          ),
          _buildFeedbackSection(),
        ],
      ),
    );
  }

  // 基础教程卡片
  Widget _buildTutorialCard(Map<String, dynamic> tutorial) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: FYColors.whiteColor,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Image.asset(tutorial['icon_path'],width: 24.w,height: 24.w,fit: BoxFit.contain,),
                SizedBox(width: 8.w),
                Text(
                  tutorial['title'],
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: FYColors.color_1A1A1A,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              tutorial['description'],
              style: TextStyle(
                fontSize: 14.sp,
                color: FYColors.color_A6A6A6,
              ),
            ),
          ),
          if (tutorial.containsKey('features')) ...[
            SizedBox(height: 16.h),
            if (tutorial['features'] is List<String>)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: FYColors.color_F9F9F9,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '主要功能',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: FYColors.color_1A1A1A,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      ...(tutorial['features'] as List<String>).map((feature) {
                        return Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 6.w,
                                height: 6.w,
                                margin: EdgeInsets.only(top: 5.h),
                                decoration: BoxDecoration(
                                  color: FYColors.color_3361FE,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: FYColors.color_A6A6A6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              )
            else if (tutorial['features'] is List<Map<String, dynamic>>)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    ...(tutorial['features'] as List<Map<String, dynamic>>).map((feature) {
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: (feature == tutorial['features'].last) ? 0 : 8.w),
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: FYColors.color_F9F9F9,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                feature['title'],
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: FYColors.color_1A1A1A,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                feature['description'],
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: FYColors.color_A6A6A6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
          ],
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: GestureDetector(
              onTap: () {
                // 查看详情逻辑
              },
              child: Container(
                width: double.infinity,
                height: 36.h,
                decoration: BoxDecoration(
                  color: FYColors.color_F9F9F9,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '查看详情',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: FYColors.color_3361FE,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14.w,
                      color: FYColors.color_3361FE,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  // 高级教程卡片
  Widget _buildAdvancedTutorialCard(Map<String, dynamic> tutorial) {
    // 根据标题确定索引值
    int index = 0;
    if (tutorial['title'] == 'AI问答功能') {
      index = 0;
    } else if (tutorial['title'] == '权限管理') {
      index = 1;
    } else if (tutorial['title'] == '数据导出功能') {
      index = 2;
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: FYColors.whiteColor,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                if (tutorial['title'] == 'AI问答功能')
                  Image.asset(FYImages.aiIcon,width: 24.w,height: 24.w,fit: BoxFit.contain,)
                else if (tutorial['title'] == '权限管理')
                  Image.asset(FYImages.setting_person,width: 24.w,height: 24.w,fit: BoxFit.contain,)
                else
                  Image.asset(FYImages.export_data,width: 24.w,height: 24.w,fit: BoxFit.contain,),
                SizedBox(width: 8.w),
                Text(
                  tutorial['title'],
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: FYColors.color_1A1A1A,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              tutorial['description'],
              style: TextStyle(
                fontSize: 14.sp,
                color: FYColors.color_A6A6A6,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          
          // AI问答功能
          if (tutorial['title'] == 'AI问答功能') ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: FYColors.color_F0F5FF,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '使用提示',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: FYColors.color_1A1A1A,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    ...(tutorial['tips'] as List<String>).map((tip) {
                      return Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 6.w,
                              height: 6.w,
                              margin: EdgeInsets.only(top: 5.h),
                              decoration: BoxDecoration(
                                color: FYColors.color_3361FE,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                tip,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: FYColors.color_A6A6A6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            if (state.isExpandAi.value)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      '如何使用AI问答',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: FYColors.color_1A1A1A,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...(tutorial['steps'] as List<String>).asMap().entries.map((step) {
                          return Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${step.key+1}.',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: FYColors.color_A6A6A6,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    step.value,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: FYColors.color_A6A6A6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      '提示词模板',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: FYColors.color_1A1A1A,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      '系统提供多种提示词模板，帮助您更高效地获取信息：',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: FYColors.color_A6A6A6,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Wrap(
                      spacing: 7.w,
                      runSpacing: 8.h,
                      children: (tutorial['templates'] as List<String>).map((template) {
                        return Container(
                          width: 152.w,
                          height: 36.w,
                          // padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: FYColors.color_F9F9F9,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Center(
                            child: Text(
                              template,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: FYColors.color_1A1A1A,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              )
          ],
          
          // 权限管理
          if (tutorial['title'] == '权限管理') ...[
            // 角色卡片
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  _buildRoleCard('管理员', FYColors.color_F0F5FF, FYColors.color_3361FE),
                  SizedBox(width: 8.w),
                  _buildRoleCard('审核员', Colors.orange.withOpacity(0.1), Colors.orange),
                  SizedBox(width: 8.w),
                  _buildRoleCard('平台用户', FYColors.color_F9F9F9, FYColors.color_1A1A1A),
                ],
              ),
            ),
            if (state.isExpandPermission.value) ...[
              SizedBox(height: 16.h),
              // 角色职责
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  '角色职责',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: FYColors.color_1A1A1A,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              ...(tutorial['roles'] as List<Map<String, dynamic>>).map((role) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role['name'],
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: FYColors.color_1A1A1A,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Text(
                          role['description'],
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: FYColors.color_A6A6A6,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              SizedBox(height: 16.h),
              // 权限申请流程
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  '权限申请流程',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: FYColors.color_1A1A1A,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...(tutorial['process'] as List<String>).asMap().entries.map((step) {
                      return Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${step.key + 1}.',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: FYColors.color_A6A6A6,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                step.value,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: FYColors.color_A6A6A6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ],
          
          // 数据导出功能
          if (tutorial['title'] == '数据导出功能') ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ...(tutorial['formats'] as List<String>).map((format) {
                    return Container(
                      width: 71.w,
                      height: 36.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: FYColors.color_F9F9F9,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        format,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: FYColors.color_1A1A1A,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            if (state.isExpandData.value) ...[
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: FYColors.color_F0F5FF,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '导出提示',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: FYColors.color_1A1A1A,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '◈',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: FYColors.color_A6A6A6,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              '导出的数据可以按照时间范围、数据类型和导出格式进行筛选，系统会保留最近7天的导出记录。',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: FYColors.color_A6A6A6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '◈',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: FYColors.color_A6A6A6,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              '导出较大文件可能需要等待，系统会通过消息通知您导出完成。',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: FYColors.color_A6A6A6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
          
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: GestureDetector(
              onTap: () => logic.dealExpand(index),
              child: Container(
                width: double.infinity,
                height: 36.h,
                decoration: BoxDecoration(
                  color: FYColors.color_F9F9F9,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      index == 0 
                          ? (state.isExpandAi.value ? '收起详情' : '展开详情')
                          : index == 1 
                              ? (state.isExpandPermission.value ? '收起详情' : '展开详情')
                              : (state.isExpandData.value ? '收起详情' : '展开详情'),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: FYColors.color_3361FE,
                      ),
                    ),
                    Transform.rotate(
                      angle: index == 0 
                          ? (state.isExpandAi.value ? -3.14159 / 2 : 3.14159 / 2)
                          : index == 1 
                              ? (state.isExpandPermission.value ? -3.14159 / 2 : 3.14159 / 2)
                              : (state.isExpandData.value ? -3.14159 / 2 : 3.14159 / 2),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 14.w,
                        color: FYColors.color_3361FE,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  // 角色卡片
  Widget _buildRoleCard(String title, Color bgColor, Color textColor) {
    return Expanded(
      child: Container(
        height: 36.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            color: textColor,
          ),
        ),
      ),
    );
  }

  // 视频卡片
  Widget _buildVideoCard(Map<String, dynamic> tutorial, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: FYColors.whiteColor,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Icon(
                  Icons.video_library,
                  color: Colors.black,
                  size: 24.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  tutorial['title'],
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: FYColors.color_1A1A1A,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Stack(
              children: [
                Container(
                  height: 132.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8.r),
                    image: DecorationImage(
                      image: AssetImage('assets/images/video_thumbnail1.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => logic.playVideoTutorial(index),
                    child: Center(
                      child: Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 30.w,
                        ),
                      ),
                    ),
                  ),
                ),
                // 底部进度条
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8.r),
                        bottomRight: Radius.circular(8.r),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: logic.togglePlayPause,
                            child: Icon(
                              Icons.pause,
                              color: Colors.white,
                              size: 20.w,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                Container(
                                  height: 4.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                ),
                                Container(
                                  height: 4.h,
                                  width: 60.w, // 模拟进度
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '00:24/${tutorial['duration']}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              '${tutorial['title']}（${tutorial['duration']}）',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: FYColors.color_1A1A1A,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
            child: Text(
              tutorial['description'],
              style: TextStyle(
                fontSize: 14.sp,
                color: FYColors.color_A6A6A6,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          
          // 管理员权限提示
          if (tutorial['requiresPermission'] == true)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: FYColors.color_F0F5FF,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: FYColors.color_3361FE,
                      size: 20.w,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '本视频仅对管理员和审核员开放',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: FYColors.color_3361FE,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  // 反馈部分
  Widget _buildFeedbackSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: FYColors.whiteColor,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                FYImages.tutorial_feedBack,
                height: 24.w,
                width: 24.w,
                fit: BoxFit.contain
              ),
              SizedBox(width: 8.w),
              Text(
                '教程反馈',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: FYColors.color_1A1A1A,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            '这些教程是否对您有帮助？请告诉我们您的想法。',
            style: TextStyle(
              fontSize: 14.sp,
              color: FYColors.color_1A1A1A,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildFeedbackButton('有帮助', true, Icons.thumb_up_outlined),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildFeedbackButton('需改进', false, Icons.thumb_down_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackButton(String text, bool isHelpful, IconData icon) {
    return GestureDetector(
      onTap: () => logic.sendFeedback(isHelpful),
      child: Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: FYColors.color_F9F9F9,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: FYColors.color_1A1A1A,
              size: 16.w,
            ),
            SizedBox(width: 8.w),
            Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: FYColors.color_1A1A1A,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
