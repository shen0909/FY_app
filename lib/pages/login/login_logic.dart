import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
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
    // TODO: implement onClose
    super.onClose();
  }

  submit() {
    print("提交:${state.nameController.text}----${state.pwdController.text}");
    Get.offAllNamed(Routers.home);
  }
}
