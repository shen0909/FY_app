import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safe_app/styles/colors.dart';
import 'package:safe_app/styles/text_styles.dart';

import '../../styles/image_resource.dart';
import 'login_logic.dart';
import 'login_state.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String prefixIconPath;
  final Widget? suffixIcon;
  final bool obscureText;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIconPath,
    this.suffixIcon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 311.w,
      height: 56.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.w),
        border: Border.all(color: const Color(0xFFE6E6E6), width: 1),
      ),
      child: Row(
        children: [
          SizedBox(width: 16.w),
          Image.asset(prefixIconPath, width: 24.w, height: 24.w,fit: BoxFit.contain,),
          SizedBox(width: 16.w),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              style: FYTextStyles.inputStyle(color: FYColors.color_1A1A1A),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: FYTextStyles.hintStyle(color: FYColors.color_A6A6A6),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (suffixIcon != null) suffixIcon!
        ],
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final LoginLogic logic = Get.put(LoginLogic());
  final LoginState state = Get.find<LoginLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              image: DecorationImage(image: AssetImage(FYImages.login_bg), fit: BoxFit.fill)),
          padding: EdgeInsets.only(top: 58.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  style: FYTextStyles.loginTipStyle(color: FYColors.text1Color),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 34.w, right: 32.w),
                child: Column(
                  children: [
                    CustomInputField(
                      controller: state.nameController,
                      hintText: '用户名',
                      prefixIconPath: FYImages.login_account,
                    ),
                    SizedBox(height: 16.w),
                    CustomInputField(
                      controller: state.pwdController,
                      hintText: '请输入密码',
                      prefixIconPath: FYImages.login_pwd,
                      obscureText: false,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          // todo:隐藏/显示密码
                        },
                        child: Padding(
                          padding: EdgeInsets.only(right: 16.w),
                          child: Image.asset(FYImages.pwd_see, width: 24.w, height: 24.w,fit: BoxFit.contain),
                        ),
                      ),
                    ),
                    SizedBox(height: 40.w),
                    GestureDetector(
                      onTap: () => logic.submit(),
                      child: Container(
                        width: double.infinity,
                        height: 48.w,
                        decoration: BoxDecoration(
                            gradient:
                                const LinearGradient(colors: FYColors.loginBtn),
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.w))),
                        child: Center(
                            child: Text('登录',
                                style: FYTextStyles.loginBtnStyle(color: FYColors.whiteColor))),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
