import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_app/https/api_service.dart';
import 'package:safe_app/routers/routers.dart';
import 'login_state.dart';

class LoginLogic extends GetxController {
  final LoginState state = LoginState();

  @override
  void onInit() {
    super.onInit();
    state.nameController = TextEditingController();
    state.pwdController = TextEditingController();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    state.nameController.dispose();
    state.pwdController.dispose();
    super.onClose();
  }

  submit() async {
    if (state.nameController.text.isEmpty || state.pwdController.text.isEmpty) {
      Get.snackbar(
        '提示',
        '用户名和密码不能为空',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.5),
        colorText: Colors.white,
      );
      return;
    }
    // 显示加载框
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    
    // 调用登录接口
    var result = await ApiService().login(
        username: state.nameController.text,
        password: state.pwdController.text);
    
    // 关闭加载框
    Get.back();
    
    if (result['code'] == 10010) {
      // 登录成功，跳转到首页
      Get.offAllNamed(Routers.home);
    } else {
      // 登录失败，提示用户
      Get.snackbar(
        '提示',
        result['msg'] ?? '登录失败，请检查用户名和密码',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.5),
        colorText: Colors.white,
      );
    }
  }
}
