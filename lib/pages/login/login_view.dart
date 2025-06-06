import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/text_styles.dart';
import 'package:safe_app/widgets/pattern_lock_widget.dart';

import '../../styles/image_resource.dart';
import '../../widgets/custom_textEdit.dart';
import 'login_logic.dart';
import 'login_state.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final LoginLogic logic = Get.put(LoginLogic());
  final LoginState state = Get
      .find<LoginLogic>()
      .state;

  Widget _buildPasswordLoginForm() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 34.w),
      child: Column(
        children: [
          Image.asset(
            FYImages.logo,
            width: 88.w,
            height: 88.w,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 16.w),
          Text(
            'FY App',
            style: FYTextStyles.loginTitleStyle(),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.w, bottom: 40.w),
            child: Text(
              '请登录',
              style: FYTextStyles.loginTipStyle(
                  color: FYColors.text1Color),
            ),
          ),
          CustomInputField(
            controller: state.accountController,
            hintText: '用户名',
            prefixIconPath: FYImages.login_account,
          ),
          SizedBox(height: 16.w),
          Obx(() =>
              CustomInputField(
                controller: state.passwordController,
                hintText: '请输入密码',
                prefixIconPath: FYImages.login_pwd,
                obscureText: !state.showPassword.value,
                suffixIcon: GestureDetector(
                  onTap: () =>
                  state.showPassword.value = !state.showPassword.value,
                  child: Padding(
                    padding: EdgeInsets.only(right: 16.w),
                    child: Image.asset(
                      state.showPassword.value
                          ? FYImages.pwd_see
                          : FYImages.pwd_unsee,
                      width: 24.w,
                      height: 24.w,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              )),
          SizedBox(height: 40.w),
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildPatternLoginForm() {
    return Expanded(
      child: Column(
        children: [
          SizedBox(height: 13.h),
          // 用户头像
          ClipOval(
            child: Image.asset(
              FYImages.user_avatar,
              width: 88.w,
              height: 88.h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 42.h),
          // 用户信息和问候语
          Obx(() {
            String displayName =
            state.userName.value.isNotEmpty ? state.userName.value : '用户';
            String greeting = state.greetingMessage.value.isNotEmpty
                ? state.greetingMessage.value
                : '你好';
            return Text(
              '$displayName,$greeting',
              style: TextStyle(
                fontSize: 24.sp,
                color: FYColors.color_1A1A1A,
                fontWeight: FontWeight.w400,
                fontFamily: 'AlibabaPuHuiTi',
              ),
            );
          }),
          SizedBox(height: 32.h),
          // 错误信息显示 - 固定高度的容器
          Container(
            height: 20.h,
            alignment: Alignment.center,
            child: Obx(() =>
            state.errorMessage.isNotEmpty
                ? Text(
              state.errorMessage.value,
              style: TextStyle(
                fontSize: 14.sp,
                color: FYColors.color_FF3B30,
              ),
              textAlign: TextAlign.center,
            )
                : Container()),
          ),
          // 图案锁控件
          Obx(() {
            // 使用一个状态标志来确保只在布局准备好后渲染PatternLockWidget
            if (!state.isPatternReady.value) {
              // 如果图案锁未准备好，先显示一个占位符容器
              Future.delayed(Duration.zero, () {
                // 延迟标记为就绪，让页面先完成布局
                state.isPatternReady.value = true;
              });
              return Container(
                width: 300.w,
                height: 300.w,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
              );
            }
            // 布局准备好后，显示图案锁
            return PatternLockWidget(
              size: 300.w,
              dotSize: 59.w,
              lineWidth: 4.w,
              selectedColor: FYColors.color_1A1A1A,
              notSelectedColor: FYColors.color_D8D8D8,
              errorColor: FYColors.color_FF3B30,
              isError: state.isError.value,
              onCompleted: (pattern) {
                logic.handlePatternLogin(pattern);
              },
              showInput: false,
            );
          }),
          // 锁定信息显示
          Obx(() =>
              Visibility(
                visible: state.isLocked.value,
                child: Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Text(
                    '尝试次数过多，请${state.lockTimeMinutes.value}分钟后再试',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: FYColors.color_FF3B30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )),
          // 使用密码登录选项
          Padding(
            padding: EdgeInsets.only(top: 24.h),
            child: GestureDetector(
              onTap: () => logic.switchToPasswordLogin(),
              child: Text(
                '使用密码登录',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: FYColors.text1Color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return Obx(() =>
        GestureDetector(
          onTap: state.isLogging.value ? null : () => logic.doLogin(),
          child: Container(
            width: double.infinity,
            height: 48.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: FYColors.loginBtn),
              borderRadius: BorderRadius.all(Radius.circular(12.w)),
            ),
            child: Center(
              child: state.isLogging.value
                  ? SizedBox(
                width: 24.w,
                height: 24.w,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.w,
                ),
              )
                  : Text(
                '登录',
                style: FYTextStyles.loginBtnStyle(
                    color: FYColors.whiteColor),
              ),
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: Obx(() {
          if (state.isChecking.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    FYImages.logo,
                    width: 88.w,
                    height: 88.w,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 20.h),
                  const CircularProgressIndicator(color: FYColors.color_3361FE),
                ],
              ),
            );
          }
          return SafeArea(
            child: Container(
              decoration: BoxDecoration(
                  image: state.loginMethod.value != 1
                      ? const DecorationImage(
                          image: AssetImage(FYImages.login_bg),
                          fit: BoxFit.fill)
                      : null),
              padding: EdgeInsets.only(top: 58.w),
              child: Column(
                children: [
                  // 根据登录方式显示对应的表单
                  Obx(() {
                    switch (state.loginMethod.value) {
                      case 1: // 划线登录
                        return _buildPatternLoginForm();
                      case 2: // 指纹登录
                        return _buildPasswordLoginForm();
                      case 0: // 密码登录
                      default:
                        return _buildPasswordLoginForm();
                    }
                  })
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
