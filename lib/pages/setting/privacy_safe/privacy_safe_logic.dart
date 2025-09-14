import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:safe_app/utils/dialog_utils.dart';
import '../../../cache/business_cache_service.dart';
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
  Future<void> loadPrivacyPolicy() async {
    DialogUtils.showLoading();
    final result = await BusinessCacheService.instance.getPrivacyContentWithCache();
    DialogUtils.hideLoading();
    if(result != null) {
      state.privacyContent.value = result['content'];
      state.lastUpdated.value = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(result['created_at']));
    }
  }
}
