import 'package:get/get.dart';

import 'privacy_safe_state.dart';

class PrivacySafeLogic extends GetxController {
  final PrivacySafeState state = PrivacySafeState();

  @override
  void onReady() {
    super.onReady();
    // 加载隐私政策数据
    loadPrivacyPolicy();
  }

  @override
  void onClose() {
    super.onClose();
  }
  
  // 加载隐私政策
  void loadPrivacyPolicy() {
    // 实际项目中应该从API获取数据
    // 这里使用了state中的示例数据
  }
  
  // 跳转到隐私政策详情页面
  void goToPrivacyPolicy() {
    Get.toNamed('/privacy_policy');
  }
}
