import 'package:get/get.dart';

import 'risk_state.dart';

class RiskLogic extends GetxController {
  final RiskState state = RiskState();

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

  // 切换单位
  changeUnit(int index) {
    state.chooseUint.value = index;
  }
}
