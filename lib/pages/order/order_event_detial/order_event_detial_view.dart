import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/widgets/custom_app_bar.dart';
import '../../../styles/image_resource.dart';
import 'order_event_detial_logic.dart';
import 'order_event_detial_state.dart';

class OrderEventDetialPage extends StatelessWidget {
  OrderEventDetialPage({Key? key}) : super(key: key);

  final OrderEventDetialLogic logic = Get.put(OrderEventDetialLogic());
  final OrderEventDetialState state = Get.find<OrderEventDetialLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Stack(
        children: [
          Scaffold(
            backgroundColor: FYColors.whiteColor,
            appBar: FYAppBar(
              title: logic.getPageTitle(), // 使用动态标题
              actions: [
                batchCheckWidget()
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEventHeader(),
                  _buildEventDescription(),
                  _buildTagList(),
                  _buildDivider(),
                  _buildUpdatesList(),
                ],
              ),
            ),
            bottomSheet: state.isBatchCheck.value && state.selectedItems.isNotEmpty
                ? _buildBottomActionBar()
                : null,
          ),
          // 生成报告弹窗
          _buildReportDialog(),
        ],
      );
    });
  }

  // 事件头部信息
  Widget _buildEventHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
      margin: EdgeInsets.fromLTRB(0, 0, 0, 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.eventTitle.value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: FYColors.color_1A1A1A,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14.sp,
                color: FYColors.color_A6A6A6,
              ),
              SizedBox(width: 4.w),
              Text(
                state.eventDate.value,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: FYColors.color_A6A6A6,
                ),
              ),
              SizedBox(width: 16.w),
              Icon(
                Icons.remove_red_eye_outlined,
                size: 14.sp,
                color: FYColors.color_A6A6A6,
              ),
              SizedBox(width: 4.w),
              Text(
                '已查看数: ${state.viewCount.value}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: FYColors.color_A6A6A6,
                ),
              ),
              SizedBox(width: 16.w),
              Icon(
                Icons.person_add_alt_1_outlined,
                size: 14.sp,
                color: FYColors.color_A6A6A6,
              ),
              SizedBox(width: 4.w),
              Text(
                '已关注数: ${state.followCount.value}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: FYColors.color_A6A6A6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 事件描述
  Widget _buildEventDescription() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Text(
        state.eventDescription.value,
        style: TextStyle(
          fontSize: 14.sp,
          color: FYColors.color_1A1A1A,
        ),
      ),
    );
  }
  
  // 标签列表
  Widget _buildTagList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Wrap(
        spacing: 8.w,
        children: state.eventTags.map((tag) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
            decoration: BoxDecoration(
              color: Color(0xFFF0F5FF),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: 14.sp,
                color: Color(0xFF3361FE),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  // 分隔线
  Widget _buildDivider() {
    return Container(
      height: 8.h,
      color: FYColors.color_F9F9F9,
      margin: EdgeInsets.symmetric(vertical: 1.h),
    );
  }
  
  // 最新动态列表
  Widget _buildUpdatesList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '最新动态',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: FYColors.color_1A1A1A,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '共 ',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: FYColors.color_A6A6A6,
                        ),
                      ),
                      TextSpan(
                        text: '${state.latestUpdates.length} ',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3361FE),
                        ),
                      ),
                      TextSpan(
                        text: '条',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: FYColors.color_A6A6A6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 动态列表
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.latestUpdates.length,
            itemBuilder: (context, index) {
              return _buildUpdateItem(index);
            },
          ),
          
          // 查看更多
          if (state.hasMoreData.value || state.isLoadingMore.value)
            GestureDetector(
              onTap: () => logic.loadMoreUpdates(),
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: state.isLoadingMore.value
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 14.w,
                            height: 14.h,
                            child: CircularProgressIndicator(
                              color: Color(0xFF3361FE),
                              strokeWidth: 2.w,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '加载中...',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Color(0xFF3361FE),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '查看更多',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Color(0xFF3361FE),
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 14.sp,
                            color: Color(0xFF3361FE),
                          ),
                        ],
                      ),
              ),
            ),
          
          // 没有更多数据提示
          if (!state.hasMoreData.value && !state.isLoadingMore.value && state.latestUpdates.isNotEmpty)
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Text(
                '没有更多数据了',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: FYColors.color_A6A6A6,
                ),
              ),
            ),
          // 底部留白，防止底部操作栏遮挡内容
          SizedBox(height: 80.h),
        ],
      ),
    );
  }
  
  // 单条动态项
  Widget _buildUpdateItem(int index) {
    final update = state.latestUpdates[index];
    return GestureDetector(
      onTap: () {
        if (state.isBatchCheck.value) {
          logic.toggleItemSelection(index);
        } else {
          logic.viewUpdateDetail(update);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 选择框
            if (state.isBatchCheck.value)
              Padding(
                padding: EdgeInsets.only(top: 8.h, right: 8.w),
                child: _buildCheckbox(index),
              ),
            // 内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    update['title'],
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: FYColors.color_1A1A1A,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    update['content'],
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Color(0xFF666666),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        update['date'],
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: FYColors.color_A6A6A6,
                        ),
                      ),
                      if (!state.isBatchCheck.value)
                        GestureDetector(
                          onTap: () => logic.viewUpdateDetail(update),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: FYColors.color_F9F9F9,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              '查看详情',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: FYColors.color_1A1A1A,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Divider(
                  //   height: 1.h,
                  //   thickness: 1,
                  //   color: FYColors.color_F9F9F9,
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建选择框
  Widget _buildCheckbox(int index) {
    final bool isSelected = logic.isItemSelected(index);
    
    return isSelected
        ? Image.asset(
            FYImages.check_icon,
            width: 24.w,
            height: 24.w,
            fit: BoxFit.contain,
          )
        : Image.asset(
            FYImages.uncheck_icon,
            width: 24.w,
            height: 24.w,
            fit: BoxFit.contain,
          );
  }
  
  // 批量选择开关按钮
  Widget batchCheckWidget() {
    return Obx(() {
      return GestureDetector(
        onTap: () => logic.batchCheck(),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 8.w),
          margin: EdgeInsets.only(right: 16.w),
          decoration: BoxDecoration(
            color: state.isBatchCheck.value ? Color(0xFFF0F5FF) : Colors.white,
            borderRadius: BorderRadius.circular(20.w),
            border: Border.all(
              color: state.isBatchCheck.value ? Color(0xFFF0F5FF) : Color(0xFFEFEFEF),
              width: 1.w,
            ),
          ),
          child: Row(
            children: [
              Icon(
                state.isBatchCheck.value ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                size: 16.w,
                color: state.isBatchCheck.value ? Color(0xFF3361FE) : Color(0xFF666666),
              ),
              SizedBox(width: 4.w),
              Text(
                '批量选择',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: state.isBatchCheck.value ? Color(0xFF3361FE) : Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
  
  // 底部操作栏
  Widget _buildBottomActionBar() {
    return Container(
      height: 71.w,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.r,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Image.asset(FYImages.check_icon,width: 24.w,height: 24.w,fit: BoxFit.contain,),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${state.selectedItems.length} ',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3361FE),
                          ),
                        ),
                        TextSpan(
                          text: '条内容已选择',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    logic.isEvent ? '可生成事件报告' : '可生成专题报告',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Color(0xFFA6A6A6),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // 生成报告按钮
              GestureDetector(
                onTap: () => logic.generateReport(),
                child: Container(
                  width: 80.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: FYColors.loginBtn,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      '生成报告',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              /*// 生成报告按钮
              GestureDetector(
                onTap: () => logic.generateReport(),
                child: Container(
                  // padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  width: 80.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: FYColors.color_3361FE,
                      width: 1.w,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '生成报告',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: FYColors.color_3361FE,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),*/
              // 取消按钮
              GestureDetector(
                onTap: () => logic.cancelSelection(),
                child: Container(
                  width: 96.w,
                  height: 40.w,
                  // padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      '取消',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // 生成报告弹窗
  Widget _buildReportDialog() {
    return Obx(() {
      if (!state.isGeneratingReport.value) {
        return const SizedBox.shrink();
      }

      return Stack(
        children: [
          // 半透明背景
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          // 弹窗内容
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Material(
                color: FYColors.whiteColor,
                borderRadius: BorderRadius.only(topRight: Radius.circular(16.r),topLeft: Radius.circular(16.r)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 顶部标题栏
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.withOpacity(0.1),
                            width: 1.h,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            logic.isEvent ? '生成事件报告' : '生成专题报告',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => logic.closeReportDialog(),
                            child: Icon(
                              Icons.close,
                              size: 24.w,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 根据状态显示不同内容
                    if (state.reportGenerationStatus.value == ReportGenerationStatus.generating)
                      _buildGeneratingContent()
                    else if (state.reportGenerationStatus.value == ReportGenerationStatus.success)
                      _buildSuccessContent()
                      else if (state.reportGenerationStatus.value == ReportGenerationStatus.failed)
                      _buildFailedContent(),
                    SizedBox(height: MediaQuery.of(Get.context!).padding.bottom),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
  
  // 生成中的内容
  Widget _buildGeneratingContent() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 60.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 加载动画
          SizedBox(
            width: 64.w,
            height: 64.h,
            child: CircularProgressIndicator(
              color: Color(0xFF3361FE),
              strokeWidth: 3.w,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '正在生成报告...',
            style: TextStyle(
              fontSize: 14.sp,
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            logic.isEvent ? '正在处理所选事件并整合为分析报告' : '正在处理所选专题并整合为分析报告',
            style: TextStyle(
              fontSize: 12.sp,
              color: Color(0xFF666666),
            ),
          ),
          SizedBox(height: 60.h),
        ],
      ),
    );
  }
  
  // 生成成功的内容
  Widget _buildSuccessContent() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 40.h, 16.w, 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 成功图标
          Container(
            width: 64.w,
            height: 64.h,
            decoration: BoxDecoration(
              color: Color(0xFF3361FE),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 40.w,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '报告生成成功',
            style: TextStyle(
              fontSize: 14.sp,
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            logic.isEvent ? '事件分析报告已生成，可立即下载查看' : '专题分析报告已生成，可立即下载查看',
            style: TextStyle(
              fontSize: 12.sp,
              color: Color(0xFF666666),
            ),
          ),
          SizedBox(height: 20.h),
          
          // 报告信息卡片
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: Colors.grey.withOpacity(0.1),
                width: 1.w,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.reportInfo['title'] ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14.sp,
                      color: Color(0xFF666666),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      state.reportInfo['date'] ?? '',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Color(0xFFA6A6A6),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Icon(
                      Icons.description,
                      size: 14.sp,
                      color: Color(0xFF666666),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      state.reportInfo['fileType'] ?? '',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Color(0xFFA6A6A6),
                      ),
                    ),
                    Spacer(),
                    Text(
                      state.reportInfo['size'] ?? '',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Color(0xFFA6A6A6),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  state.reportInfo['description'] ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          
          // 操作按钮
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => logic.previewReport(),
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: FYColors.loginBtn,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '预览报告',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => logic.downloadReport(),
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1.w,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '下载报告',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 生成失败的内容
  Widget _buildFailedContent() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 40.h, 16.w, 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64.w,
            height: 64.h,
            decoration: BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close,
              color: Colors.white,
              size: 40.w,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '报告生成失败',
            style: TextStyle(
              fontSize: 14.sp,
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '请稍后重试，或减少选择的内容后再次尝试',
            style: TextStyle(
              fontSize: 12.sp,
              color: Color(0xFF666666),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => logic.closeReportDialog(),
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1.w,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '关闭',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => logic.generateReport(),
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: FYColors.loginBtn,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '重试',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
