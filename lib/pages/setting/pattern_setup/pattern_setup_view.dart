import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/utils/pattern_lock_util.dart';
import 'package:safe_app/widgets/custom_app_bar.dart';
import 'package:safe_app/widgets/pattern_lock_widget.dart';

import 'pattern_setup_logic.dart';
import 'pattern_setup_state.dart';

class PatternSetupPage extends StatelessWidget {
  PatternSetupPage({Key? key}) : super(key: key);

  final PatternSetupLogic logic = Get.put(PatternSetupLogic());
  final PatternSetupState state = Get.find<PatternSetupLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FYAppBar(title: '设置划线解锁图案'),
      body: Obx(() => _buildStepContent()),
    );
  }

  Widget _buildStepContent() {
    switch (state.currentStep.value) {
      case PatternStep.create:
        return _buildCreatePattern();
      case PatternStep.confirm:
        return _buildConfirmPattern();
      case PatternStep.success:
        return _buildSuccessScreen();
      default:
        return _buildCreatePattern();
    }
  }

  Widget _buildCreatePattern() {
    return Column(
      children: [
        SizedBox(height: 40.h),
        Text(
          '请绘制解锁图案',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: FYColors.color_1A1A1A,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          '连接至少4个点，创建解锁图案',
          style: TextStyle(
            fontSize: 14.sp,
            color: FYColors.color_666666,
          ),
        ),
        SizedBox(height: 60.h),
        Obx(() => Center(
          child: PatternLockWidget(
            key: ValueKey('create_pattern_${state.refreshTrigger.value}'),
            size: 300.w,
            dotSize: 60.w,
            lineWidth: 4.w,
            selectedColor: FYColors.color_1A1A1A,
            onCompleted: (pattern) {
              logic.setPattern(pattern);
            },
          ),
        )),
        SizedBox(height: 30.h),
        // 错误提示
        Obx(() => Visibility(
          visible: state.errorMessage.isNotEmpty,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              state.errorMessage.value,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )),
        // 一般提示
        Obx(() => Visibility(
          visible: state.promptMessage.isNotEmpty,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              state.promptMessage.value,
              style: TextStyle(
                fontSize: 14.sp,
                color: FYColors.color_666666,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildConfirmPattern() {
    return Column(
      children: [
        SizedBox(height: 40.h),
        Text(
          '请再次绘制解锁图案',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: FYColors.color_1A1A1A,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          '请再次绘制相同的图案以确认',
          style: TextStyle(
            fontSize: 14.sp,
            color: FYColors.color_666666,
          ),
        ),
        SizedBox(height: 60.h),
        Obx(() => Center(
          child: PatternLockWidget(
            key: ValueKey('confirm_pattern_${state.refreshTrigger.value}'),
            size: 300.w,
            dotSize: 60.w,
            lineWidth: 4.w,
            selectedColor: FYColors.color_1A1A1A,
            isError: state.isError.value,
            onCompleted: (pattern) {
              logic.confirmPattern(pattern);
            },
          ),
        )),
        SizedBox(height: 30.h),
        // 错误提示
        Obx(() => Visibility(
          visible: state.errorMessage.isNotEmpty,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              state.errorMessage.value,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )),
        SizedBox(height: 16.h),
        TextButton(
          onPressed: () {
            logic.resetPattern();
          },
          child: Text(
            '重新绘制',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle,
          color: Colors.blue,
          size: 80.w,
        ),
        SizedBox(height: 24.h),
        Text(
          '图案设置成功',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: FYColors.color_1A1A1A,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          '下次登录时将使用此图案解锁',
          style: TextStyle(
            fontSize: 14.sp,
            color: FYColors.color_666666,
          ),
        ),
        SizedBox(height: 60.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: ElevatedButton(
            onPressed: () {
              Get.back(result: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: Size(double.infinity, 50.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
            ),
            child: Text(
              '完成',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
