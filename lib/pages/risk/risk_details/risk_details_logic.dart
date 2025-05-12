import 'package:get/get.dart';

import 'risk_details_state.dart';

class RiskDetailsLogic extends GetxController {
  final RiskDetailsState state = RiskDetailsState();

  @override
  void onReady() {
    super.onReady();
    // 获取传入的企业数据，实际项目中可以在这里加载详细数据
    if (Get.arguments != null) {
      // 这里可以用于处理接收到的参数
      // 例如：state.companyInfo = Get.arguments['companyInfo'];
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
  
  // 显示风险评分详情对话框
  void showRiskScoreDetails() {
    state.toggleRiskScoreDialog();
  }
  
  // 关闭风险评分详情对话框
  void closeRiskScoreDetails() {
    if (state.showRiskScoreDialog.value) {
      state.toggleRiskScoreDialog();
    }
  }
  
  // 展开更多时间线
  void showMoreTimeline() {
    // 实际项目中这里可以加载更多历史数据
    Get.snackbar('提示', '加载更多时间线数据');
  }
}
